"""Unit tests for palexus-vulkan-probe (Vulkan GPU offload profiler & Ollama autotuning)."""

import os
import sys
import json
import tempfile
import unittest
import subprocess
from pathlib import Path
from importlib.machinery import SourceFileLoader

REPO_ROOT = Path(__file__).resolve().parent.parent
PROBE_BIN = REPO_ROOT / "packages" / "desktop" / "palexus-hud" / "palexus-vulkan-probe"

MOCK_INTEL_UHD_620 = """==========
VULKANINFO
==========

Vulkan Instance Version: 1.3.275

Devices:
========
GPU0:
\tapiVersion         = 1.3.275
\tdriverVersion      = 24.2.0
\tvendorID           = 0x8086
\tdeviceID           = 0x5917
\tdeviceType         = PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU
\tdeviceName         = Intel(R) UHD Graphics 620 (KBL GT2)
\tdriverID           = DRIVER_ID_INTEL_OPEN_SOURCE_MESA
\tdriverName         = Intel open-source Mesa driver
\tdriverInfo         = Mesa 24.2.0
"""

MOCK_INTEL_IRIS_XE = """==========
VULKANINFO
==========

Vulkan Instance Version: 1.3.296

Devices:
========
GPU0:
\tapiVersion         = 1.3.296
\tdriverVersion      = 24.2.4
\tvendorID           = 0x8086
\tdeviceID           = 0x9a49
\tdeviceType         = PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU
\tdeviceName         = Intel(R) Iris(R) Xe Graphics (TGL GT2)
\tdriverID           = DRIVER_ID_INTEL_OPEN_SOURCE_MESA
\tdriverName         = Intel open-source Mesa driver
\tdriverInfo         = Mesa 24.2.4
"""

MOCK_AMD_VEGA = """==========
VULKANINFO
==========

Vulkan Instance Version: 1.3.296

Devices:
========
GPU0:
\tapiVersion         = 1.3.296
\tdriverVersion      = 24.2.4
\tvendorID           = 0x1002
\tdeviceID           = 0x15dd
\tdeviceType         = PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU
\tdeviceName         = AMD Radeon RX Vega 10 Graphics (RADV RAVEN)
\tdriverID           = DRIVER_ID_MESA_RADV
\tdriverName         = radv
\tdriverInfo         = Mesa 24.2.4
"""

MOCK_AMD_780M = """==========
VULKANINFO
==========

Vulkan Instance Version: 1.3.296

Devices:
========
GPU0:
\tapiVersion         = 1.3.296
\tdriverVersion      = 24.2.4
\tvendorID           = 0x1002
\tdeviceID           = 0x15bf
\tdeviceType         = PHYSICAL_DEVICE_TYPE_INTEGRATED_GPU
\tdeviceName         = AMD Radeon 780M Graphics (RADV PHOENIX)
\tdriverID           = DRIVER_ID_MESA_RADV
\tdriverName         = radv
\tdriverInfo         = Mesa 24.2.4
"""

MOCK_CPU_ONLY = """==========
VULKANINFO
==========

Vulkan Instance Version: 1.3.275

Devices:
========
GPU0:
\tapiVersion         = 1.3.275
\tdriverVersion      = 24.2.0
\tvendorID           = 0x10005
\tdeviceID           = 0x0000
\tdeviceType         = PHYSICAL_DEVICE_TYPE_CPU
\tdeviceName         = llvmpipe (LLVM 18.1.8, 256 bits)
\tdriverID           = DRIVER_ID_MESA_LLVMPIPE
\tdriverName         = llvmpipe
\tdriverInfo         = Mesa 24.2.0 (LLVM 18.1.8)
"""


def load_probe_module():
    loader = SourceFileLoader("palexus_vulkan_probe_mod", str(PROBE_BIN))
    import importlib.util
    spec = importlib.util.spec_from_loader("palexus_vulkan_probe_mod", loader)
    mod = importlib.util.module_from_spec(spec)
    sys.modules["palexus_vulkan_probe_mod"] = mod
    loader.exec_module(mod)
    return mod


class TestVulkanProbe(unittest.TestCase):
    """Test suite for palexus-vulkan-probe GPU detection, scoring and configuration."""

    @classmethod
    def setUpClass(cls):
        cls.probe = load_probe_module()

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tmpdir.name)

        self.mock_vulkan_file = self.root / "mock_vulkaninfo.txt"
        self.mock_drm_dir = self.root / "drm"
        self.mock_meminfo = self.root / "meminfo"
        self.mock_dropin_dir = self.root / "ollama.service.d"

        self.mock_drm_dir.mkdir(parents=True)
        self.mock_dropin_dir.mkdir(parents=True)

        # Standard 16GB RAM mock
        self.mock_meminfo.write_text("MemTotal:       16384000 kB\nMemFree:        8192000 kB\n")

        os.environ["PALEXUS_VULKANINFO_PATH"] = str(self.mock_vulkan_file)
        os.environ["PALEXUS_DRM_DIR"] = str(self.mock_drm_dir)
        os.environ["PALEXUS_MEMINFO_PATH"] = str(self.mock_meminfo)
        os.environ["PALEXUS_OLLAMA_OVERRIDE_DIR"] = str(self.mock_dropin_dir)

    def tearDown(self):
        self.tmpdir.cleanup()
        for env_var in [
            "PALEXUS_VULKANINFO_PATH",
            "PALEXUS_DRM_DIR",
            "PALEXUS_MEMINFO_PATH",
            "PALEXUS_OLLAMA_OVERRIDE_DIR",
            "PALEXUS_RENDER_DEV",
        ]:
            os.environ.pop(env_var, None)

    def test_intel_uhd_620_detection(self):
        """Verify Intel UHD 620 detection, layer scoring, and env variables."""
        self.mock_vulkan_file.write_text(MOCK_INTEL_UHD_620)
        info = self.probe.probe_vulkan()

        self.assertTrue(info["detected"])
        self.assertEqual(info["vendor"], "Intel")
        self.assertEqual(info["vendor_id"], "0x8086")
        self.assertEqual(info["device_id"], "0x5917")
        self.assertEqual(info["device_type"], "INTEGRATED_GPU")
        self.assertTrue(info["vulkan_supported"])
        self.assertTrue(info["compute_reachable"])

        env = info["recommended_profile"]["env"]
        self.assertEqual(env["OLLAMA_NUM_PARALLEL"], "1")
        self.assertEqual(env["OLLAMA_NUM_GPU"], "99")
        self.assertEqual(env["LLAMA_VULKAN_DEVICE"], "0")

    def test_intel_iris_xe_detection(self):
        """Verify Intel Iris Xe detection and optimal profile."""
        self.mock_vulkan_file.write_text(MOCK_INTEL_IRIS_XE)
        info = self.probe.probe_vulkan()

        self.assertTrue(info["detected"])
        self.assertEqual(info["vendor"], "Intel")
        self.assertIn("Iris", info["device_name"])
        self.assertEqual(info["device_type"], "INTEGRATED_GPU")

        env = info["recommended_profile"]["env"]
        self.assertEqual(env["OLLAMA_NUM_GPU"], "99")
        self.assertEqual(env["LLAMA_VULKAN_DEVICE"], "0")

    def test_amd_radeon_vega_detection(self):
        """Verify AMD Radeon Vega detection with HSA_OVERRIDE_GFX_VERSION."""
        self.mock_vulkan_file.write_text(MOCK_AMD_VEGA)
        info = self.probe.probe_vulkan()

        self.assertTrue(info["detected"])
        self.assertEqual(info["vendor"], "AMD")
        self.assertEqual(info["vendor_id"], "0x1002")
        self.assertEqual(info["device_type"], "INTEGRATED_GPU")

        env = info["recommended_profile"]["env"]
        self.assertEqual(env["OLLAMA_NUM_PARALLEL"], "1")
        self.assertEqual(env["OLLAMA_NUM_GPU"], "99")
        self.assertEqual(env["HSA_OVERRIDE_GFX_VERSION"], "9.0.0")

    def test_amd_radeon_780m_detection(self):
        """Verify modern AMD Radeon 780M RDNA3 detection."""
        self.mock_vulkan_file.write_text(MOCK_AMD_780M)
        info = self.probe.probe_vulkan()

        self.assertTrue(info["detected"])
        self.assertEqual(info["vendor"], "AMD")
        self.assertIn("780M", info["device_name"])

        env = info["recommended_profile"]["env"]
        self.assertEqual(env["OLLAMA_NUM_GPU"], "99")
        self.assertEqual(env["LLAMA_VULKAN_DEVICE"], "0")
        self.assertNotIn("HSA_OVERRIDE_GFX_VERSION", env)

    def test_cpu_only_fallback(self):
        """Verify graceful CPU fallback when only llvmpipe or no Vulkan device is present."""
        self.mock_vulkan_file.write_text(MOCK_CPU_ONLY)
        info = self.probe.probe_vulkan()

        self.assertFalse(info["detected"])
        self.assertEqual(info["device_type"], "CPU")
        self.assertFalse(info["vulkan_supported"])
        self.assertFalse(info["compute_reachable"])

        env = info["recommended_profile"]["env"]
        self.assertEqual(env["OLLAMA_NUM_PARALLEL"], "1")
        self.assertEqual(env["OLLAMA_NUM_GPU"], "0")

    def test_sysfs_drm_card_fallback(self):
        """Verify GPU detection from /sys/class/drm/ when vulkaninfo is empty."""
        self.mock_vulkan_file.write_text("")
        card0 = self.mock_drm_dir / "card0" / "device"
        card0.mkdir(parents=True)
        (card0 / "vendor").write_text("0x8086\n")
        (card0 / "device").write_text("0x9a49\n")
        (self.mock_drm_dir / "renderD128").touch()

        info = self.probe.probe_vulkan()
        self.assertTrue(info["detected"])
        self.assertEqual(info["vendor"], "Intel")
        self.assertEqual(info["vendor_id"], "0x8086")
        self.assertEqual(info["device_id"], "0x9a49")

    def test_low_ram_layer_calculation(self):
        """Verify memory thresholding calculates conservative layer counts for <8GB RAM."""
        self.mock_vulkan_file.write_text(MOCK_INTEL_UHD_620)
        # Mock 4GB RAM
        self.mock_meminfo.write_text("MemTotal:        4194304 kB\n")
        info = self.probe.probe_vulkan()
        self.assertEqual(info["recommended_profile"]["ollama_num_gpu"], 24)

    def test_cli_status(self):
        """Verify palexus-vulkan-probe status prints formatted hardware summary."""
        self.mock_vulkan_file.write_text(MOCK_INTEL_UHD_620)
        proc = subprocess.run([str(PROBE_BIN), "status"], capture_output=True, text=True)
        self.assertEqual(proc.returncode, 0)
        self.assertIn("PalexusOS Vulkan AI Offload Profiler", proc.stdout)
        self.assertIn("Intel", proc.stdout)
        self.assertIn("OLLAMA_NUM_GPU=99", proc.stdout)

    def test_cli_json(self):
        """Verify palexus-vulkan-probe json returns valid machine-readable JSON."""
        self.mock_vulkan_file.write_text(MOCK_INTEL_IRIS_XE)
        proc = subprocess.run([str(PROBE_BIN), "json"], capture_output=True, text=True)
        self.assertEqual(proc.returncode, 0)
        data = json.loads(proc.stdout)
        self.assertTrue(data["detected"])
        self.assertEqual(data["vendor"], "Intel")
        self.assertIn("recommended_profile", data)

    def test_cli_apply_writes_dropin(self):
        """Verify palexus-vulkan-probe apply writes systemd service drop-in."""
        self.mock_vulkan_file.write_text(MOCK_AMD_VEGA)
        proc = subprocess.run([str(PROBE_BIN), "apply"], capture_output=True, text=True)
        self.assertEqual(proc.returncode, 0)

        dropin = self.mock_dropin_dir / "10-vulkan.conf"
        self.assertTrue(dropin.is_file())
        content = dropin.read_text(encoding="utf-8")
        self.assertIn("[Service]", content)
        self.assertIn('Environment="OLLAMA_NUM_GPU=99"', content)
        self.assertIn('Environment="OLLAMA_NUM_PARALLEL=1"', content)
        self.assertIn('Environment="LLAMA_VULKAN_DEVICE=0"', content)
        self.assertIn('Environment="HSA_OVERRIDE_GFX_VERSION=9.0.0"', content)

    def test_cli_test_vulkan_reachability(self):
        """Verify palexus-vulkan-probe test exits with code 0 on GPU and 1 on CPU fallback."""
        # 1. Success on Vulkan GPU
        self.mock_vulkan_file.write_text(MOCK_INTEL_IRIS_XE)
        proc_ok = subprocess.run([str(PROBE_BIN), "test"], capture_output=True, text=True)
        self.assertEqual(proc_ok.returncode, 0)
        self.assertIn("[PASS]", proc_ok.stdout)

        # 2. Failure on CPU fallback
        self.mock_vulkan_file.write_text(MOCK_CPU_ONLY)
        proc_fail = subprocess.run([str(PROBE_BIN), "test"], capture_output=True, text=True)
        self.assertEqual(proc_fail.returncode, 1)
        self.assertIn("[WARN]", proc_fail.stdout)

    def test_cli_help(self):
        """Verify palexus-vulkan-probe --help displays usage instructions."""
        proc = subprocess.run([str(PROBE_BIN), "--help"], capture_output=True, text=True)
        self.assertEqual(proc.returncode, 0)
        self.assertIn("usage: palexus-vulkan-probe", proc.stdout)


if __name__ == "__main__":
    unittest.main()
