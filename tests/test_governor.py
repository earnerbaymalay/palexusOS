"""Tests for palexus-governor (Milestone 9.1) against a fake sysfs/procfs tree.

The governor is an extension-less script, so it is loaded with SourceFileLoader.
No test touches the real /sys, /proc or /etc, and no test needs root.
"""

from __future__ import annotations

import http.server
import importlib.machinery
import importlib.util
import ipaddress
import json
import os
import signal
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
GOVERNOR_PATH = REPO_ROOT / "packages" / "desktop" / "palexus-hud" / "palexus-governor"
DEFAULT_TOML = REPO_ROOT / "packages" / "desktop" / "palexus-hud" / "governor.toml"
SERVICE_PATH = REPO_ROOT / "packages" / "desktop" / "palexus-hud" / "palexus-governor.service"


def load_governor():
    loader = importlib.machinery.SourceFileLoader("palexus_governor", str(GOVERNOR_PATH))
    spec = importlib.util.spec_from_loader("palexus_governor", loader)
    module = importlib.util.module_from_spec(spec)
    sys.modules["palexus_governor"] = module  # dataclasses resolve annotations via sys.modules
    loader.exec_module(module)
    return module


gov = load_governor()
CLK = os.sysconf("SC_CLK_TCK")
W = 1_000_000  # microwatts per watt

THROTTLED_CONF = """\
[GENERAL]
# Enable or disable the script execution
Enabled: True
Sysfs_Power_Path: /sys/class/power_supply/AC*/online
Autoreload: True

[BATTERY]
Update_Rate_s: 30
PL1_Tdp_W: 29
PL1_Duration_s: 28
PL2_Tdp_W: 44
PL2_Duration_S: 0.002

[AC]
Update_Rate_s: 5
PL1_Tdp_W: 44
PL1_Duration_s: 28
PL2_Tdp_W: 44
PL2_Duration_S: 0.002
"""


class FakeSystem:
    """A throwaway sysroot with cpufreq, intel-rapl powercap and a /proc tree."""

    def __init__(self, root: Path, cpus: int = 4, epp: bool = True) -> None:
        self.root = root
        for n in range(cpus):
            cf = root / f"sys/devices/system/cpu/cpu{n}/cpufreq"
            cf.mkdir(parents=True)
            (cf / "scaling_governor").write_text("powersave\n")
            if epp:
                (cf / "energy_performance_preference").write_text("balance_power\n")
        self.pkg = self._zone("intel-rapl:0", "package-0", pl1=15, pl2=25, max_w=44)
        self._zone("intel-rapl:0:0", "core", pl1=10, pl2=0, max_w=0)
        (root / "proc").mkdir()

    def _zone(self, zone: str, name: str, pl1: int, pl2: int, max_w: int) -> Path:
        z = self.root / "sys/class/powercap" / zone
        z.mkdir(parents=True)
        (z / "name").write_text(name + "\n")
        for i, (cname, val) in enumerate((("long_term", pl1), ("short_term", pl2))):
            (z / f"constraint_{i}_name").write_text(cname + "\n")
            (z / f"constraint_{i}_power_limit_uw").write_text(f"{val * W}\n")
            (z / f"constraint_{i}_max_power_uw").write_text(f"{max_w * W}\n")
        return z

    def spawn(self, pid: int, comm: str, ticks: int = 0, cmdline: str | None = None) -> None:
        d = self.root / "proc" / str(pid)
        d.mkdir(exist_ok=True)
        (d / "comm").write_text(comm + "\n")
        (d / "cmdline").write_bytes((cmdline or comm).replace(" ", "\0").encode() + b"\0")
        self.set_ticks(pid, ticks)

    def set_ticks(self, pid: int, ticks: int) -> None:
        comm = (self.root / "proc" / str(pid) / "comm").read_text().strip()
        # utime is field 14 and stime field 15 (1-based); split them evenly.
        rest = ["S", "1", "1", "1", "0", "-1", "0", "0", "0", "0", "0", str(ticks // 2), str(ticks - ticks // 2)]
        (self.root / "proc" / str(pid) / "stat").write_text(f"{pid} ({comm}) {' '.join(rest)} 0 0 20 0 1 0\n")

    def kill(self, pid: int) -> None:
        d = self.root / "proc" / str(pid)
        for f in d.iterdir():
            f.unlink()
        d.rmdir()

    def epp_values(self) -> set[str]:
        return {p.read_text().strip() for p in self.root.glob("sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference")}

    def pl(self) -> tuple[int, int]:
        return (
            int((self.pkg / "constraint_0_power_limit_uw").read_text()),
            int((self.pkg / "constraint_1_power_limit_uw").read_text()),
        )


class FakeOllama:
    def __init__(self, loaded: bool = False) -> None:
        self.loaded = loaded
        self.calls = 0

    def models_loaded(self) -> bool:
        self.calls += 1
        return self.loaded


class OllamaStub(http.server.ThreadingHTTPServer):
    """Loopback HTTP server answering /api/ps like Ollama does."""

    def __init__(self, loaded: bool = True) -> None:
        payload = json.dumps({"models": [{"name": "qwen2.5-coder:7b"}] if loaded else []}).encode()

        class Handler(http.server.BaseHTTPRequestHandler):
            def do_GET(self):  # noqa: N802 - stdlib naming
                self.send_response(200 if self.path == "/api/ps" else 404)
                self.send_header("Content-Type", "application/json")
                self.end_headers()
                self.wfile.write(payload)

            def log_message(self, *args):
                pass

        super().__init__(("127.0.0.1", 0), Handler)
        self.thread = threading.Thread(target=self.serve_forever, daemon=True)
        self.thread.start()

    @property
    def url(self) -> str:
        return f"http://127.0.0.1:{self.server_address[1]}/api/ps"

    def close(self) -> None:
        self.shutdown()
        self.server_close()


class GovernorTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp = Path(self._tmp.name)
        self.sys = FakeSystem(self.tmp / "root")
        self.cfg = gov.default_config()
        self.ollama = FakeOllama()

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def make_governor(self, cfg=None, backend=None):
        cfg = cfg or self.cfg
        proc = gov.ProcScanner(self.sys.root / "proc")
        backend = backend or gov.RaplBackend(self.sys.root)
        return gov.Governor(
            cfg,
            gov.Detector(cfg, proc, self.ollama, clk_tck=CLK),
            gov.Policy(cfg.cooldown_s),
            gov.EppControl(self.sys.root),
            backend,
            log=lambda msg: None,
        )


class TestStates(GovernorTestCase):
    """Idle, inference and compile states drive EPP and PL1/PL2 on fake sysfs."""

    def test_idle_applies_idle_profile(self) -> None:
        g = self.make_governor()
        g.start(now=0.0)
        g.tick(now=1.0)
        self.assertEqual(g.applied, gov.State.IDLE)
        self.assertEqual(self.sys.epp_values(), {"balance_power"})
        self.assertEqual(self.sys.pl(), (15 * W, 25 * W))

    def test_inference_applies_inference_profile(self) -> None:
        self.ollama.loaded = True
        self.sys.spawn(4242, "ollama_llama_se", ticks=0)
        g = self.make_governor()
        g.start(now=0.0)
        self.sys.set_ticks(4242, 2 * CLK)  # two cores busy for one second
        g.tick(now=1.0)
        self.assertEqual(g.applied, gov.State.INFERENCE)
        self.assertEqual(self.sys.epp_values(), {"performance"})
        self.assertEqual(self.sys.pl(), (25 * W, 35 * W))

    def test_resident_model_without_cpu_activity_is_idle(self) -> None:
        # Ollama keeps a model loaded for minutes after the last request (keep_alive).
        self.ollama.loaded = True
        self.sys.spawn(4242, "ollama_llama_se", ticks=500)
        g = self.make_governor()
        g.start(now=0.0)
        g.tick(now=1.0)
        self.assertEqual(g.applied, gov.State.IDLE)
        self.assertEqual(self.ollama.calls, 0, "Ollama is only asked once the runner is busy")

    def test_busy_runner_without_loaded_model_is_not_inference(self) -> None:
        self.ollama.loaded = False
        self.sys.spawn(4242, "ollama", ticks=0)
        g = self.make_governor()
        g.start(now=0.0)
        self.sys.set_ticks(4242, 3 * CLK)
        g.tick(now=1.0)
        self.assertEqual(g.applied, gov.State.IDLE)

    def test_compile_applies_compile_profile(self) -> None:
        self.sys.spawn(777, "rustc")
        g = self.make_governor()
        g.start(now=0.0)
        g.tick(now=1.0)
        self.assertEqual(g.applied, gov.State.COMPILE)
        self.assertEqual(self.sys.epp_values(), {"balance_performance"})
        self.assertEqual(self.sys.pl(), (20 * W, 30 * W))

    def test_inference_outranks_compile(self) -> None:
        self.ollama.loaded = True
        self.sys.spawn(777, "cc1plus")
        self.sys.spawn(4242, "ollama_llama_se", ticks=0)
        g = self.make_governor()
        g.start(now=0.0)
        self.sys.set_ticks(4242, CLK)
        g.tick(now=1.0)
        self.assertEqual(g.applied, gov.State.INFERENCE)

    def test_cooldown_steps_down_one_state_at_a_time(self) -> None:
        self.ollama.loaded = True
        self.sys.spawn(777, "rustc")
        self.sys.spawn(4242, "ollama_llama_se", ticks=0)
        g = self.make_governor()
        g.start(now=0.0)
        self.sys.set_ticks(4242, CLK)
        g.tick(now=1.0)
        self.assertEqual(g.applied, gov.State.INFERENCE)
        # Generation stops (no more CPU ticks); compile keeps running.
        g.tick(now=5.0)
        self.assertEqual(g.applied, gov.State.INFERENCE, "held during cooldown")
        g.tick(now=11.5)
        self.assertEqual(g.applied, gov.State.COMPILE)
        self.sys.kill(777)
        g.tick(now=15.0)
        self.assertEqual(g.applied, gov.State.COMPILE, "held during cooldown")
        g.tick(now=21.0)
        self.assertEqual(g.applied, gov.State.COMPILE, "last compile sighting was at 11.5")
        g.tick(now=22.0)
        self.assertEqual(g.applied, gov.State.IDLE)
        self.assertEqual(self.sys.pl(), (15 * W, 25 * W))

    def test_scaling_governor_fallback_without_epp(self) -> None:
        self.sys = FakeSystem(self.tmp / "noepp", epp=False)
        self.sys.spawn(777, "rustc")
        g = self.make_governor()
        g.start(now=0.0)
        g.tick(now=1.0)
        govs = {p.read_text().strip() for p in self.sys.root.glob("sys/devices/system/cpu/cpu*/cpufreq/scaling_governor")}
        self.assertEqual(govs, {"powersave"}, "balance_performance maps to powersave")
        self.sys.spawn(4242, "ollama_llama_se", ticks=0)
        self.ollama.loaded = True
        g.tick(now=2.0)
        self.sys.set_ticks(4242, CLK)
        g.tick(now=3.0)
        govs = {p.read_text().strip() for p in self.sys.root.glob("sys/devices/system/cpu/cpu*/cpufreq/scaling_governor")}
        self.assertEqual(govs, {"performance"})


class TestRestore(GovernorTestCase):
    def test_restore_puts_back_boot_values(self) -> None:
        for p in self.sys.root.glob("sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference"):
            p.write_text("default\n")
        (self.sys.pkg / "constraint_0_power_limit_uw").write_text(f"{12 * W}\n")
        self.sys.spawn(777, "rustc")
        g = self.make_governor()
        g.start(now=0.0)
        g.tick(now=1.0)
        self.assertEqual(self.sys.epp_values(), {"balance_performance"})
        g.restore()
        self.assertEqual(self.sys.epp_values(), {"default"})
        self.assertEqual(self.sys.pl(), (12 * W, 25 * W))

    def test_sigterm_exits_cleanly_and_restores(self) -> None:
        stub = OllamaStub(loaded=False)
        self.addCleanup(stub.close)
        conf = self.tmp / "governor.toml"
        conf.write_text(f'backend = "rapl"\npoll_interval_s = 0.05\n[ollama]\nurl = "{stub.url}"\n')
        self.sys.spawn(777, "rustc")
        proc = subprocess.Popen(
            [sys.executable, str(GOVERNOR_PATH), "run", "--config", str(conf), "--sysroot", str(self.sys.root)],
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
        )
        try:
            deadline = time.monotonic() + 10
            while self.sys.epp_values() != {"balance_performance"}:
                self.assertIsNone(proc.poll(), "daemon died early")
                self.assertLess(time.monotonic(), deadline, "compile profile never applied")
                time.sleep(0.02)
            self.assertEqual(self.sys.pl(), (20 * W, 30 * W))
            proc.send_signal(signal.SIGTERM)
            out, _ = proc.communicate(timeout=5)
        finally:
            if proc.poll() is None:
                proc.kill()
        self.assertEqual(proc.returncode, 0, out)
        self.assertEqual(self.sys.epp_values(), {"balance_power"})
        self.assertEqual(self.sys.pl(), (15 * W, 25 * W))
        self.assertIn("restored", out.lower())


class TestRapl(GovernorTestCase):
    def test_only_package_zones_are_driven(self) -> None:
        backend = gov.RaplBackend(self.sys.root)
        self.assertEqual([z.name for z in backend.zones], ["intel-rapl:0"])

    def test_limits_clamp_to_hardware_max(self) -> None:
        backend = gov.RaplBackend(self.sys.root)
        backend.apply(gov.Profile("performance", 60, 90))
        self.assertEqual(self.sys.pl(), (44 * W, 44 * W))

    def test_unavailable_without_powercap(self) -> None:
        empty = self.tmp / "empty"
        empty.mkdir()
        self.assertFalse(gov.RaplBackend(empty).available())


class TestThrottled(GovernorTestCase):
    def setUp(self) -> None:
        super().setUp()
        self.conf = self.tmp / "throttled.conf"
        self.conf.write_text(THROTTLED_CONF)

    def test_rewrites_ac_and_battery_limits_and_restores(self) -> None:
        backend = gov.ThrottledBackend(self.conf, gov.ProcScanner(self.sys.root / "proc"))
        snap = backend.snapshot()
        backend.apply(gov.Profile("performance", 25, 35))
        text = self.conf.read_text()
        self.assertEqual(text.count("PL1_Tdp_W: 25"), 2)
        self.assertEqual(text.count("PL2_Tdp_W: 35"), 2)
        self.assertIn("# Enable or disable the script execution", text, "comments survive")
        self.assertIn("PL1_Duration_s: 28", text)
        backend.restore(snap)
        self.assertEqual(self.conf.read_text(), THROTTLED_CONF)

    def test_auto_prefers_throttled_when_it_is_running(self) -> None:
        # throttled rewrites MSR 0x610 every few seconds, so RAPL writes would be undone.
        self.sys.spawn(99, "python3", cmdline="/usr/bin/python3 /usr/lib/throttled/throttled.py")
        cfg = gov.replace_config(self.cfg, throttled_conf=str(self.conf))
        backend = gov.select_backend(cfg, self.sys.root, gov.ProcScanner(self.sys.root / "proc"), log=lambda m: None)
        self.assertEqual(backend.name, "throttled")

    def test_auto_uses_rapl_when_throttled_is_not_running(self) -> None:
        cfg = gov.replace_config(self.cfg, throttled_conf=str(self.conf))
        backend = gov.select_backend(cfg, self.sys.root, gov.ProcScanner(self.sys.root / "proc"), log=lambda m: None)
        self.assertEqual(backend.name, "rapl")

    def test_auto_falls_back_to_epp_only(self) -> None:
        bare = self.tmp / "bare"
        (bare / "proc").mkdir(parents=True)
        cfg = gov.replace_config(self.cfg, throttled_conf=str(self.tmp / "missing.conf"))
        backend = gov.select_backend(cfg, bare, gov.ProcScanner(bare / "proc"), log=lambda m: None)
        self.assertEqual(backend.name, "none")


class TestConfig(GovernorTestCase):
    def test_shipped_default_matches_built_in_defaults(self) -> None:
        cfg, warnings = gov.load_config(DEFAULT_TOML)
        self.assertEqual(warnings, [])
        self.assertEqual(cfg, gov.default_config())

    def test_missing_file_uses_defaults(self) -> None:
        cfg, warnings = gov.load_config(self.tmp / "nope.toml")
        self.assertEqual(cfg, gov.default_config())
        self.assertEqual(warnings, [])

    def test_overrides_are_applied(self) -> None:
        p = self.tmp / "g.toml"
        p.write_text('cooldown_s = 4\n[profiles.inference]\nepp = "performance"\npl1_w = 28\npl2_w = 40\n')
        cfg, warnings = gov.load_config(p)
        self.assertEqual(warnings, [])
        self.assertEqual(cfg.cooldown_s, 4.0)
        self.assertEqual(cfg.profiles[gov.State.INFERENCE], gov.Profile("performance", 28, 40))
        self.assertEqual(cfg.profiles[gov.State.IDLE], gov.default_config().profiles[gov.State.IDLE])

    def test_invalid_values_fall_back_with_warnings(self) -> None:
        p = self.tmp / "g.toml"
        p.write_text(
            'backend = "msr"\npoll_interval_s = -1\n'
            '[profiles.compile]\nepp = "ludicrous"\npl1_w = 40\npl2_w = 20\n'
        )
        cfg, warnings = gov.load_config(p)
        defaults = gov.default_config()
        self.assertEqual(cfg.backend, defaults.backend)
        self.assertEqual(cfg.poll_interval_s, defaults.poll_interval_s)
        self.assertEqual(cfg.profiles[gov.State.COMPILE], defaults.profiles[gov.State.COMPILE])
        self.assertGreaterEqual(len(warnings), 3)

    def test_broken_toml_falls_back_with_warning(self) -> None:
        p = self.tmp / "g.toml"
        p.write_text("this is = = not toml")
        cfg, warnings = gov.load_config(p)
        self.assertEqual(cfg, gov.default_config())
        self.assertEqual(len(warnings), 1)


class TestLoopbackOnly(GovernorTestCase):
    """The daemon makes no network request other than loopback Ollama."""

    def test_remote_ollama_url_in_config_is_rejected(self) -> None:
        for url in ("http://10.0.0.5:11434/api/ps", "http://ollama.example.com/api/ps", "https://127.0.0.1/api/ps"):
            p = self.tmp / "g.toml"
            p.write_text(f'[ollama]\nurl = "{url}"\n')
            cfg, warnings = gov.load_config(p)
            self.assertEqual(cfg.ollama_url, gov.DEFAULT_OLLAMA_URL, url)
            self.assertEqual(len(warnings), 1, url)

    def test_probe_refuses_non_loopback_url(self) -> None:
        with self.assertRaises(ValueError):
            gov.OllamaProbe("http://192.168.1.20:11434/api/ps")

    def test_loopback_urls_are_accepted(self) -> None:
        for url in ("http://127.0.0.1:11434/api/ps", "http://localhost:11434/api/ps", "http://[::1]:11434/api/ps"):
            self.assertTrue(gov.is_loopback_url(url), url)

    def test_probe_ignores_proxy_environment(self) -> None:
        stub = OllamaStub(loaded=True)
        self.addCleanup(stub.close)
        old = {k: os.environ.get(k) for k in ("http_proxy", "HTTP_PROXY", "no_proxy", "NO_PROXY")}
        os.environ["http_proxy"] = os.environ["HTTP_PROXY"] = "http://203.0.113.9:3128"
        os.environ.pop("no_proxy", None)
        os.environ.pop("NO_PROXY", None)
        try:
            self.assertTrue(gov.OllamaProbe(stub.url).models_loaded())
        finally:
            for k, v in old.items():
                if v is None:
                    os.environ.pop(k, None)
                else:
                    os.environ[k] = v

    def test_running_daemon_only_connects_to_loopback(self) -> None:
        stub = OllamaStub(loaded=True)
        self.addCleanup(stub.close)
        seen: list[str] = []
        recording = threading.Event()

        def audit(event, args):
            if recording.is_set() and event == "socket.connect":
                seen.append(str(args[1][0]))

        sys.addaudithook(audit)
        cfg = gov.replace_config(self.cfg, ollama_url=stub.url)
        self.sys.spawn(4242, "ollama_llama_se", ticks=0)
        proc = gov.ProcScanner(self.sys.root / "proc")
        g = gov.Governor(
            cfg,
            gov.Detector(cfg, proc, gov.OllamaProbe(cfg.ollama_url), clk_tck=CLK),
            gov.Policy(cfg.cooldown_s),
            gov.EppControl(self.sys.root),
            gov.RaplBackend(self.sys.root),
            log=lambda m: None,
        )
        recording.set()
        try:
            g.start(now=0.0)
            for i in range(1, 6):
                self.sys.set_ticks(4242, i * CLK)
                g.tick(now=float(i))
        finally:
            recording.clear()
        self.assertEqual(g.applied, gov.State.INFERENCE)
        self.assertTrue(seen, "the probe should have contacted the stub")
        for host in seen:
            self.assertTrue(ipaddress.ip_address(host).is_loopback, host)


class TestServiceUnit(unittest.TestCase):
    def test_unit_is_hardened(self) -> None:
        unit = SERVICE_PATH.read_text(encoding="utf-8")
        for directive in (
            "ProtectSystem=strict",
            "NoNewPrivileges=yes",
            "ProtectKernelTunables=yes",
            "PrivateTmp=yes",
            "IPAddressDeny=any",
            "IPAddressAllow=localhost",
            "RestrictAddressFamilies=AF_INET AF_INET6",
        ):
            self.assertIn(directive, unit)
        rw = [line for line in unit.splitlines() if line.startswith("ReadWritePaths=")]
        self.assertTrue(rw, "unit must whitelist the paths it writes")
        allowed_prefixes = ("/sys/devices/system/cpu", "/sys/devices/virtual/powercap", "/etc/throttled.conf")
        for path in " ".join(line.split("=", 1)[1] for line in rw).split():
            self.assertTrue(path.lstrip("-").startswith(allowed_prefixes), path)


if __name__ == "__main__":
    unittest.main()
