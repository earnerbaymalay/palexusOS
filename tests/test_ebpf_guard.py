"""Unit tests for palexus-ebpf-guard (userspace DLP & eBPF secret leak interceptor)."""

import importlib.util
import json
import os
import subprocess
import sys
import tempfile
import unittest
from importlib.machinery import SourceFileLoader
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
GUARD_BIN = REPO_ROOT / "packages" / "core" / "palexus-ebpf-guard" / "palexus-ebpf-guard"


def load_guard_module():
    loader = SourceFileLoader("palexus_ebpf_guard_mod", str(GUARD_BIN))
    spec = importlib.util.spec_from_loader("palexus_ebpf_guard_mod", loader)
    mod = importlib.util.module_from_spec(spec)
    sys.modules["palexus_ebpf_guard_mod"] = mod
    loader.exec_module(mod)
    return mod


class TestPalexusEbpfGuard(unittest.TestCase):
    """Validation test suite for palexus-ebpf-guard."""

    @classmethod
    def setUpClass(cls):
        cls.guard = load_guard_module()

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tmpdir.name)

    def tearDown(self):
        self.tmpdir.cleanup()
        os.environ.pop("PALEXUS_EBPF_CONF", None)

    def test_config_loading_defaults(self):
        """Verify load_config returns standard defaults when no file is present."""
        os.environ["PALEXUS_EBPF_CONF"] = str(self.root / "nonexistent.toml")
        cfg = self.guard.load_config()
        self.assertIn("general", cfg)
        self.assertEqual(cfg["general"]["mode"], "audit")
        self.assertEqual(cfg["patterns"]["entropy_threshold"], 4.65)
        self.assertTrue(cfg["network"]["exempt_loopback"])
        self.assertTrue(cfg["patterns"]["block_private_keys"])
        self.assertTrue(cfg["patterns"]["block_cloud_tokens"])

    def test_config_loading_custom_toml(self):
        """Verify custom TOML file overrides default values correctly."""
        conf_file = self.root / "ebpf-guard.toml"
        conf_file.write_text(
            """
[general]
mode = "enforce"

[patterns]
entropy_threshold = 4.80
block_private_keys = false
"""
        )
        os.environ["PALEXUS_EBPF_CONF"] = str(conf_file)
        cfg = self.guard.load_config()
        self.assertEqual(cfg["general"]["mode"], "enforce")
        self.assertEqual(cfg["patterns"]["entropy_threshold"], 4.80)
        self.assertFalse(cfg["patterns"]["block_private_keys"])
        # Defaults retained for unset keys
        self.assertTrue(cfg["patterns"]["block_cloud_tokens"])

    def test_detect_openssh_private_key(self):
        """Verify detection of OpenSSH private keys."""
        payload = "test payload\n-----BEGIN OPENSSH PRIVATE KEY-----\nb3BlbnNzaA==\n-----END OPENSSH PRIVATE KEY-----"
        detected = self.guard.inspect_payload(payload)
        self.assertTrue(any(d["type"] == "openssh_private_key" for d in detected))

    def test_detect_rsa_pem_private_keys(self):
        """Verify detection of RSA, EC, DSA, and encrypted PEM private keys."""
        keys = [
            "-----BEGIN RSA PRIVATE KEY-----",
            "-----BEGIN EC PRIVATE KEY-----",
            "-----BEGIN DSA PRIVATE KEY-----",
            "-----BEGIN ENCRYPTED PRIVATE KEY-----",
            "-----BEGIN PRIVATE KEY-----",
        ]
        for key in keys:
            detected = self.guard.inspect_payload(f"Prefix {key} Suffix")
            self.assertTrue(
                any(d["type"] == "pem_private_key" for d in detected),
                f"Failed to detect {key}",
            )

    def test_detect_pgp_private_key(self):
        """Verify detection of PGP private key blocks."""
        payload = "-----BEGIN PGP PRIVATE KEY BLOCK-----\nVersion: BCPG v1.0\n"
        detected = self.guard.inspect_payload(payload)
        self.assertTrue(any(d["type"] == "pgp_private_key" for d in detected))

    def test_detect_openai_token(self):
        """Verify detection of OpenAI API secret keys."""
        payload = "Authorization: Bearer sk-1234567890abcdefghijklmnopqrstuv"
        detected = self.guard.inspect_payload(payload)
        self.assertTrue(any(d["type"] == "openai_token" for d in detected))

    def test_detect_anthropic_token(self):
        """Verify detection of Anthropic API keys."""
        payload = "x-api-key: sk-ant-api03-1234567890abcdefghijklmnopqrstuv"
        detected = self.guard.inspect_payload(payload)
        self.assertTrue(any(d["type"] == "anthropic_token" for d in detected))

    def test_detect_github_and_aws_tokens(self):
        """Verify detection of GitHub PATs and AWS access key IDs."""
        gh_payload = "token: ghp_1234567890abcdefghijklmnopqrstuvwxyz123"
        detected_gh = self.guard.inspect_payload(gh_payload)
        self.assertTrue(any(d["type"] == "github_token" for d in detected_gh))

        aws_payload = "aws_access_key_id = AKIAIOSFODNN7EXAMPLE"
        detected_aws = self.guard.inspect_payload(aws_payload)
        self.assertTrue(any(d["type"] == "aws_key" for d in detected_aws))

    def test_shannon_entropy_calculation(self):
        """Verify Shannon entropy mathematical calculation."""
        # Zero entropy: single repeating character
        self.assertEqual(self.guard.shannon_entropy("A" * 64), 0.0)
        # Hexadecimal 16-character uniform distribution: log2(16) == 4.0
        hex_str = "0123456789abcdef" * 4
        self.assertAlmostEqual(self.guard.shannon_entropy(hex_str), 4.0, places=2)
        # 32 distinct characters in 32-length string: log2(32) == 5.0 (> 4.65 threshold)
        high_entropy_str = "abcdefghijklmnopqrstuvwxyz012345"
        self.assertAlmostEqual(self.guard.shannon_entropy(high_entropy_str), 5.0, places=2)

    def test_shannon_entropy_detection_and_base64_bypass(self):
        """Verify high entropy tokens are detected unless accompanied by base64 asset headers."""
        secret = "abcdefghijklmnopqrstuvwxyz012345"  # Entropy = 5.0 > 4.65
        # Standalone secret should be detected
        detected = self.guard.inspect_payload(f"SECRET_VALUE={secret}")
        self.assertTrue(any(d["type"] == "high_entropy_secret" for d in detected))

        # Base64 asset header should exempt the entropy trigger
        asset_payload = f"data:image/png;base64,{secret}"
        detected_asset = self.guard.inspect_payload(asset_payload)
        self.assertFalse(any(d["type"] == "high_entropy_secret" for d in detected_asset))

    def test_loopback_and_subnet_exemptions(self):
        """Verify loopback addresses and exempt subnets bypass interception."""
        payload = "-----BEGIN OPENSSH PRIVATE KEY-----"
        # 127.0.0.1 should be exempt
        res_lo4 = self.guard.evaluate_transmission(payload, dest_ip="127.0.0.1")
        self.assertEqual(res_lo4["verdict"], "ALLOW")
        self.assertTrue(res_lo4["exempt"])

        # ::1 should be exempt
        res_lo6 = self.guard.evaluate_transmission(payload, dest_ip="::1")
        self.assertEqual(res_lo6["verdict"], "ALLOW")
        self.assertTrue(res_lo6["exempt"])

        # Private subnet (10.0.0.5) should be exempt
        res_priv = self.guard.evaluate_transmission(payload, dest_ip="10.0.0.5")
        self.assertEqual(res_priv["verdict"], "ALLOW")
        self.assertTrue(res_priv["exempt"])

        # Public IP (8.8.8.8) should NOT be exempt
        res_pub = self.guard.evaluate_transmission(payload, dest_ip="8.8.8.8")
        self.assertNotEqual(res_pub["verdict"], "ALLOW")
        self.assertFalse(res_pub.get("exempt", False))

    def test_whitelist_process_exemption(self):
        """Verify processes in whitelist bypass interception."""
        payload = "-----BEGIN OPENSSH PRIVATE KEY-----"
        for proc in ["/usr/bin/ssh", "/usr/bin/git", "/usr/bin/gpg"]:
            res = self.guard.evaluate_transmission(payload, process=proc)
            self.assertEqual(res["verdict"], "ALLOW")
            self.assertTrue(res["exempt"])

        # Non-whitelisted process (e.g. curl) should NOT be exempt
        res_curl = self.guard.evaluate_transmission(payload, process="/usr/bin/curl")
        self.assertNotEqual(res_curl["verdict"], "ALLOW")
        self.assertFalse(res_curl.get("exempt", False))

    def test_audit_vs_enforce_mode(self):
        """Verify audit mode logs without blocking while enforce mode halts transmission."""
        payload = "sk-1234567890abcdefghijklmnopqrstuv"

        # Audit mode: records leak and allows
        res_audit = self.guard.evaluate_transmission(payload, mode="audit")
        self.assertEqual(res_audit["verdict"], "AUDIT")
        self.assertEqual(res_audit["action"], "logged")
        self.assertTrue(len(res_audit["secrets"]) > 0)

        # Enforce mode: rejects transmission with EPERM
        res_enforce = self.guard.evaluate_transmission(payload, mode="enforce")
        self.assertEqual(res_enforce["verdict"], "BLOCK")
        self.assertEqual(res_enforce["action"], "rejected")
        self.assertEqual(res_enforce["errno"], "EPERM")

        # Enforce mode with raise_on_block: raises PermissionError
        with self.assertRaises(PermissionError):
            self.guard.evaluate_transmission(payload, mode="enforce", raise_on_block=True)

    def test_cli_commands(self):
        """Verify palexus-ebpf-guard CLI subcommands (test and status)."""
        # 1. Status command
        proc_status = subprocess.run(
            [sys.executable, str(GUARD_BIN), "status", "--json"],
            capture_output=True,
            text=True,
            check=True,
        )
        status_json = json.loads(proc_status.stdout)
        self.assertIn("operational_mode", status_json)
        self.assertIn("inspected_sockets", status_json)
        self.assertIn("blocked_leaks", status_json)

        # 2. Test command with clean text
        proc_test_clean = subprocess.run(
            [sys.executable, str(GUARD_BIN), "test", "harmless payload"],
            capture_output=True,
            text=True,
        )
        self.assertEqual(proc_test_clean.returncode, 0)
        self.assertIn("[ALLOW]", proc_test_clean.stdout)

        # 3. Test command with secret in audit mode (exit 0, logged)
        proc_test_audit = subprocess.run(
            [sys.executable, str(GUARD_BIN), "--mode", "audit", "test", "-----BEGIN OPENSSH PRIVATE KEY-----"],
            capture_output=True,
            text=True,
        )
        self.assertEqual(proc_test_audit.returncode, 0)
        self.assertIn("[AUDIT]", proc_test_audit.stdout)

        # 4. Test command with secret in enforce mode (exit 1, -EPERM)
        proc_test_enforce = subprocess.run(
            [sys.executable, str(GUARD_BIN), "--mode", "enforce", "test", "-----BEGIN OPENSSH PRIVATE KEY-----"],
            capture_output=True,
            text=True,
        )
        self.assertEqual(proc_test_enforce.returncode, 1)
        self.assertIn("-EPERM", proc_test_enforce.stderr)

        # 5. Test command inspecting file
        secret_file = self.root / "sample_key.pem"
        secret_file.write_text("-----BEGIN RSA PRIVATE KEY-----\nMIIE\n-----END RSA PRIVATE KEY-----")
        proc_test_file = subprocess.run(
            [sys.executable, str(GUARD_BIN), "--mode", "enforce", "test", str(secret_file)],
            capture_output=True,
            text=True,
        )
        self.assertEqual(proc_test_file.returncode, 1)
        self.assertIn("-EPERM", proc_test_file.stderr)


if __name__ == "__main__":
    unittest.main()
