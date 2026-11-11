"""Unit tests for palexus-governor (RAPL powercap, thermal throttling & workload classification)."""

import os
import sys
import json
import tempfile
import unittest
from pathlib import Path
from importlib.machinery import SourceFileLoader

REPO_ROOT = Path(__file__).resolve().parent.parent
GOVERNOR_BIN = REPO_ROOT / "packages" / "desktop" / "palexus-hud" / "palexus-governor"


def load_governor_module():
    loader = SourceFileLoader("palexus_governor_mod", str(GOVERNOR_BIN))
    import importlib.util
    spec = importlib.util.spec_from_loader("palexus_governor_mod", loader)
    mod = importlib.util.module_from_spec(spec)
    sys.modules["palexus_governor_mod"] = mod
    loader.exec_module(mod)
    return mod


class TestPalexusGovernor(unittest.TestCase):
    """Zero-dependency validation tests for palexus-governor."""

    @classmethod
    def setUpClass(cls):
        cls.gov = load_governor_module()

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tmpdir.name)

        # Mock sysfs directories
        self.cpu_dir = self.root / "cpu"
        self.rapl_dir = self.root / "rapl"
        self.thermal_dir = self.root / "thermal"
        self.proc_dir = self.root / "proc"

        self.cpu_dir.mkdir(parents=True)
        self.rapl_dir.mkdir(parents=True)
        self.thermal_dir.mkdir(parents=True)
        self.proc_dir.mkdir(parents=True)

        os.environ["PALEXUS_CPU_DIR"] = str(self.cpu_dir)
        os.environ["PALEXUS_RAPL_DIR"] = str(self.rapl_dir)
        os.environ["PALEXUS_THERMAL_DIR"] = str(self.thermal_dir)
        os.environ["PALEXUS_PROC_DIR"] = str(self.proc_dir)

    def tearDown(self):
        self.tmpdir.cleanup()
        for env_var in [
            "PALEXUS_CPU_DIR",
            "PALEXUS_RAPL_DIR",
            "PALEXUS_THERMAL_DIR",
            "PALEXUS_PROC_DIR",
            "PALEXUS_GOVERNOR_CONF",
        ]:
            os.environ.pop(env_var, None)

    def test_load_default_config(self):
        """Verify load_config returns standard defaults when no file is present."""
        os.environ["PALEXUS_GOVERNOR_CONF"] = str(self.root / "nonexistent.toml")
        cfg = self.gov.load_config()
        self.assertIn("governor", cfg)
        self.assertEqual(cfg["governor"]["poll_interval_sec"], 1.0)
        self.assertEqual(cfg["governor"]["temp_throttle_c"], 88.0)
        self.assertIn("inference", cfg["profiles"])
        self.assertEqual(cfg["profiles"]["inference"]["pl1_watts"], 25.0)

    def test_load_user_toml_config(self):
        """Verify custom TOML file overrides default values correctly."""
        conf_file = self.root / "governor.toml"
        conf_file.write_text(
            """
[governor]
poll_interval_sec = 0.5
temp_throttle_c = 85.0

[profiles.inference]
pl1_watts = 30.0
"""
        )
        os.environ["PALEXUS_GOVERNOR_CONF"] = str(conf_file)
        cfg = self.gov.load_config()
        self.assertEqual(cfg["governor"]["poll_interval_sec"], 0.5)
        self.assertEqual(cfg["governor"]["temp_throttle_c"], 85.0)
        self.assertEqual(cfg["profiles"]["inference"]["pl1_watts"], 30.0)

    def test_rapl_read_and_write(self):
        """Verify RAPL power limits (PL1 and PL2) can be read and written in micro-watts."""
        c0 = self.rapl_dir / "constraint_0_power_limit_uw"
        c1 = self.rapl_dir / "constraint_1_power_limit_uw"
        c0.write_text("15000000\n")
        c1.write_text("25000000\n")

        pl1, pl2 = self.gov.get_rapl_limits()
        self.assertEqual(pl1, 15.0)
        self.assertEqual(pl2, 25.0)

        # Set new limits
        success = self.gov.set_rapl_limits(25.0, 44.0)
        self.assertTrue(success)
        self.assertEqual(c0.read_text().strip(), "25000000")
        self.assertEqual(c1.read_text().strip(), "44000000")

    def test_epp_scaling(self):
        """Verify EPP can be written across mock CPU cores."""
        cpu0_epp = self.cpu_dir / "cpu0" / "cpufreq" / "energy_performance_preference"
        cpu1_epp = self.cpu_dir / "cpu1" / "cpufreq" / "energy_performance_preference"
        cpu0_epp.parent.mkdir(parents=True)
        cpu1_epp.parent.mkdir(parents=True)
        cpu0_epp.write_text("balance_power\n")
        cpu1_epp.write_text("balance_power\n")

        self.assertEqual(self.gov.get_current_epp(), "balance_power")

        self.gov.set_epp("performance")
        self.assertEqual(cpu0_epp.read_text().strip(), "performance")
        self.assertEqual(cpu1_epp.read_text().strip(), "performance")

    def test_thermal_monitoring(self):
        """Verify peak temperature is correctly detected across thermal zones."""
        zone0 = self.thermal_dir / "thermal_zone0" / "temp"
        zone1 = self.thermal_dir / "thermal_zone1" / "temp"
        zone0.parent.mkdir(parents=True)
        zone1.parent.mkdir(parents=True)

        zone0.write_text("54000\n")  # 54°C
        zone1.write_text("68500\n")  # 68.5°C

        temp = self.gov.get_max_temp_c()
        self.assertEqual(temp, 68.5)

    def test_classify_workload_inference(self):
        """Verify workload is classified as INFERENCE when ollama processes are active."""
        pid_dir = self.proc_dir / "1234"
        pid_dir.mkdir()
        (pid_dir / "comm").write_text("ollama_llama_se\n")

        workload = self.gov.classify_workload()
        self.assertEqual(workload, self.gov.WorkloadType.INFERENCE)

    def test_classify_workload_build(self):
        """Verify workload is classified as BUILD when compiler processes are active."""
        pid_dir = self.proc_dir / "5678"
        pid_dir.mkdir()
        (pid_dir / "comm").write_text("rustc\n")

        workload = self.gov.classify_workload()
        self.assertEqual(workload, self.gov.WorkloadType.BUILD)

    def test_classify_workload_idle(self):
        """Verify workload is classified as IDLE when only normal desktop processes run."""
        pid_dir = self.proc_dir / "9999"
        pid_dir.mkdir()
        (pid_dir / "comm").write_text("bash\n")

        workload = self.gov.classify_workload()
        self.assertEqual(workload, self.gov.WorkloadType.IDLE)

    def test_apply_profile(self):
        """Verify applying a profile updates both EPP and RAPL settings."""
        c0 = self.rapl_dir / "constraint_0_power_limit_uw"
        c1 = self.rapl_dir / "constraint_1_power_limit_uw"
        c0.write_text("15000000\n")
        c1.write_text("25000000\n")

        cpu0_epp = self.cpu_dir / "cpu0" / "cpufreq" / "energy_performance_preference"
        cpu0_epp.parent.mkdir(parents=True)
        cpu0_epp.write_text("balance_power\n")

        cfg = self.gov.DEFAULT_CONFIG
        self.gov.apply_profile("inference", cfg)

        self.assertEqual(cpu0_epp.read_text().strip(), "performance")
        self.assertEqual(c0.read_text().strip(), "25000000")
        self.assertEqual(c1.read_text().strip(), "44000000")


if __name__ == "__main__":
    unittest.main()
