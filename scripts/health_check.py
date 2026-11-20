#!/usr/bin/env python3
"""
PalexusOS Health Check Script

Verify system integrity and diagnose common issues.

Usage:
    python scripts/health_check.py              # Full health check
    python scripts/health_check.py --quick      # Quick 5-minute check
    python scripts/health_check.py --verbose    # Detailed output
    python scripts/health_check.py --module token  # Check specific module
"""

import sys
import subprocess
import json
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional


class HealthChecker:
    """Verify PalexusOS system health."""

    def __init__(self, verbose: bool = False):
        self.verbose = verbose
        self.project_root = Path(__file__).parent.parent
        self.checks_passed = 0
        self.checks_failed = 0
        self.warnings = []

    def print_header(self, text: str) -> None:
        """Print a formatted header."""
        print(f"\n{'='*60}")
        print(f"  {text}")
        print(f"{'='*60}")

    def print_check(self, name: str, passed: bool, message: str = "") -> None:
        """Print a check result."""
        status = "✓" if passed else "✗"
        print(f"{status} {name}")
        if message:
            print(f"  {message}")
        if passed:
            self.checks_passed += 1
        else:
            self.checks_failed += 1

    def print_warning(self, text: str) -> None:
        """Print a warning."""
        print(f"⚠️  {text}")
        self.warnings.append(text)

    # ========== Installation Checks ==========

    def check_installation(self) -> bool:
        """Verify package is installed correctly."""
        self.print_header("Installation")

        try:
            import palexus
            self.print_check("Package installed", True)
        except ImportError as e:
            self.print_check("Package installed", False, str(e))
            return False

        # Check modules
        try:
            from palexus.design.token_registry import TokenRegistry
            from palexus.build.gate_registry import GateRegistry
            from palexus.desktop.environment import DesktopEnvironment
            from palexus.test.orchestrator import TestOrchestrator

            self.print_check("All modules importable", True)
            return True
        except ImportError as e:
            self.print_check("All modules importable", False, str(e))
            return False

    # ========== File Structure Checks ==========

    def check_file_structure(self) -> bool:
        """Verify project file structure."""
        self.print_header("File Structure")

        required_files = [
            "palexus/__init__.py",
            "palexus/design/token_registry.py",
            "palexus/build/gate_registry.py",
            "palexus/desktop/environment.py",
            "palexus/test/orchestrator.py",
            "tests/test_design.py",
            "tests/test_build.py",
            "tests/test_desktop.py",
            "tests/test_test.py",
            "docs/ARCHITECTURE.md",
            "docs/API_REFERENCE.md",
            "Makefile",
            "pyproject.toml",
        ]

        all_exist = True
        for file in required_files:
            path = self.project_root / file
            exists = path.exists()
            self.print_check(f"File: {file}", exists)
            if not exists:
                all_exist = False

        return all_exist

    # ========== Token System Checks ==========

    def check_token_system(self) -> bool:
        """Verify token system integrity."""
        self.print_header("Token System")

        try:
            from palexus.design.token_registry import TokenRegistry

            token_file = self.project_root / "docs/design-system/tokens.json"
            if not token_file.exists():
                self.print_check("Token file exists", False)
                return False

            registry = TokenRegistry(token_file)
            self.print_check("Token file loads", True)

            # Check token categories
            categories = ["colors", "typography", "spacing", "radius"]
            for cat in categories:
                method = getattr(registry, cat, None)
                if method and callable(method):
                    tokens = method()
                    self.print_check(f"Token category: {cat}", len(tokens) > 0)
                else:
                    self.print_check(f"Token category: {cat}", False)

            # Check data integrity
            data_ok = hasattr(registry, '_data') and len(registry._data) > 0
            self.print_check("Token data loaded", data_ok)

            return True
        except Exception as e:
            self.print_check("Token system", False, str(e))
            return False

    # ========== Gate System Checks ==========

    def check_gate_system(self) -> bool:
        """Verify gate system integrity."""
        self.print_header("Gate System")

        try:
            from palexus.build.gate_registry import GateRegistry

            registry = GateRegistry()
            self.print_check(f"Gates initialized ({len(registry.gates)} gates)", True)

            # Run gates (they need repo_root)
            results = registry.run(repo_root=self.project_root)
            if results is None:
                self.print_check("Gates run", False, "No results returned")
                return False

            # Results is a dict of gate_name -> result
            if isinstance(results, dict):
                gate_names = list(results.keys())
                self.print_check(f"Gates run: {len(gate_names)} gates completed", True,
                               f"({', '.join(gate_names)})")
                return True
            else:
                self.print_check("Gates run", False, f"Unexpected result type: {type(results)}")
                return False

            return failed == 0
        except Exception as e:
            self.print_check("Gate system", False, str(e))
            return False

    # ========== Boot System Checks ==========

    def check_boot_system(self) -> bool:
        """Verify boot system integrity."""
        self.print_header("Boot System")

        try:
            from palexus.desktop.environment import DesktopEnvironment, BootPhase

            env = DesktopEnvironment()
            context = env.boot_context

            # Test boot sequence
            phases = [
                BootPhase.GREETER,
                BootPhase.USER_SELECT,
                BootPhase.HUD,
                BootPhase.THEME,
                BootPhase.COMPLETE,
            ]

            context.set_user("test-user")
            context.set_theme("catppuccin-mocha")

            for phase in phases:
                try:
                    context.advance_phase(phase)
                    self.print_check(f"Boot phase: {phase.name}", True)
                except Exception as e:
                    self.print_check(f"Boot phase: {phase.name}", False, str(e))
                    return False

            return True
        except Exception as e:
            self.print_check("Boot system", False, str(e))
            return False

    # ========== Test System Checks ==========

    def check_test_system(self) -> bool:
        """Verify test system integrity."""
        self.print_header("Test System")

        try:
            from palexus.test.orchestrator import TestOrchestrator, Level

            orchestrator = TestOrchestrator()

            # Run tests
            print("Running test suite (this may take a minute)...")
            results = orchestrator.run_all()

            if results is None:
                self.print_check("Test suite runs", False, "No results returned")
                return False

            passed = sum(1 for r in results if r.passed)
            failed = sum(1 for r in results if not r.passed)
            total = len(results)

            self.print_check(f"Tests: {passed}/{total} passed", failed == 0)

            if self.verbose and failed > 0:
                for result in results:
                    if not result.passed:
                        self.print_warning(f"Test failed: {result.name}")

            return failed == 0
        except Exception as e:
            self.print_check("Test system", False, str(e))
            return False

    # ========== Code Quality Checks ==========

    def check_code_quality(self) -> bool:
        """Verify code quality standards."""
        self.print_header("Code Quality")

        # Type checking
        try:
            result = subprocess.run(
                ["python", "-m", "mypy", "palexus/", "--ignore-missing-imports"],
                cwd=self.project_root,
                capture_output=True,
                timeout=30,
            )
            type_check_ok = result.returncode == 0
            self.print_check("Type hints (mypy)", type_check_ok)
        except Exception as e:
            self.print_check("Type hints (mypy)", False, str(e))
            type_check_ok = False

        # Linting
        try:
            result = subprocess.run(
                ["python", "-m", "ruff", "check", "palexus/"],
                cwd=self.project_root,
                capture_output=True,
                timeout=30,
            )
            lint_ok = result.returncode == 0
            self.print_check("Linting (ruff)", lint_ok)
        except Exception as e:
            self.print_check("Linting (ruff)", False, str(e))
            lint_ok = False

        # Formatting
        try:
            result = subprocess.run(
                ["python", "-m", "black", "--check", "palexus/"],
                cwd=self.project_root,
                capture_output=True,
                timeout=30,
            )
            format_ok = result.returncode == 0
            self.print_check("Code formatting (black)", format_ok)
        except Exception as e:
            self.print_check("Code formatting (black)", False, str(e))
            format_ok = False

        return type_check_ok and lint_ok and format_ok

    # ========== Documentation Checks ==========

    def check_documentation(self) -> bool:
        """Verify documentation completeness."""
        self.print_header("Documentation")

        required_docs = [
            "README.md",
            "docs/ARCHITECTURE.md",
            "docs/API_REFERENCE.md",
            "docs/GETTING_STARTED_TUTORIAL.md",
            "docs/DEVELOPER_HANDBOOK.md",
            "docs/CONTRIBUTION_LADDER.md",
            "docs/MAINTENANCE_PLAYBOOK.md",
            "docs/SECURITY_HARDENING.md",
            "CONTRIBUTING.md",
        ]

        all_exist = True
        for doc in required_docs:
            path = self.project_root / doc
            exists = path.exists()
            self.print_check(f"Doc: {doc}", exists)
            if not exists:
                all_exist = False

        return all_exist

    # ========== Performance Checks ==========

    def check_performance(self) -> bool:
        """Verify performance is acceptable."""
        self.print_header("Performance")

        try:
            from palexus.design.token_registry import TokenRegistry
            import time

            token_file = self.project_root / "docs/design-system/tokens.json"

            # Token loading speed
            start = time.time()
            registry = TokenRegistry(token_file)
            load_duration = time.time() - start

            load_ok = load_duration < 1.0  # Should be <1 second
            self.print_check(f"Token loading (<1s)", load_ok, f"{load_duration*1000:.1f}ms")

            # Data access speed
            start = time.time()
            colors = registry.colors()
            access_duration = time.time() - start

            access_ok = access_duration < 0.1  # Should be <100ms
            self.print_check(f"Token access (<100ms)", access_ok, f"{access_duration*1000:.1f}ms")

            return load_ok and access_ok
        except Exception as e:
            self.print_check("Performance", False, str(e))
            return False

    # ========== Main Health Check ==========

    def run_full_health_check(self) -> int:
        """Run complete health check."""
        print(f"\nPalexusOS Health Check - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

        checks = [
            ("Installation", self.check_installation),
            ("File Structure", self.check_file_structure),
            ("Token System", self.check_token_system),
            ("Gate System", self.check_gate_system),
            ("Boot System", self.check_boot_system),
            ("Test System", self.check_test_system),
            ("Code Quality", self.check_code_quality),
            ("Documentation", self.check_documentation),
            ("Performance", self.check_performance),
        ]

        for name, check_func in checks:
            try:
                check_func()
            except Exception as e:
                self.print_warning(f"Check '{name}' failed with exception: {e}")

        # Summary
        self.print_header("Summary")
        total = self.checks_passed + self.checks_failed
        print(f"Checks passed: {self.checks_passed}/{total}")
        print(f"Checks failed: {self.checks_failed}/{total}")

        if self.warnings:
            print(f"\nWarnings: {len(self.warnings)}")
            for warning in self.warnings:
                print(f"  • {warning}")

        if self.checks_failed == 0:
            print("\n✓ All checks passed! System is healthy.\n")
            return 0
        else:
            print(
                f"\n✗ {self.checks_failed} check(s) failed. Please review above.\n"
            )
            return 1

    def run_quick_health_check(self) -> int:
        """Run quick 5-minute health check."""
        print(f"\nPalexusOS Quick Health Check - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")

        checks = [
            ("Installation", self.check_installation),
            ("Token System", self.check_token_system),
            ("Gate System", self.check_gate_system),
        ]

        for name, check_func in checks:
            try:
                check_func()
            except Exception as e:
                self.print_warning(f"Check '{name}' failed: {e}")

        # Summary
        self.print_header("Summary")
        total = self.checks_passed + self.checks_failed
        print(f"Checks passed: {self.checks_passed}/{total}")

        if self.checks_failed == 0:
            print("\n✓ Quick check passed!\n")
            return 0
        else:
            print(f"\n✗ Issues found. Run full check: python scripts/health_check.py\n")
            return 1


def main() -> int:
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="PalexusOS Health Check")
    parser.add_argument(
        "--quick", action="store_true", help="Run quick 5-minute check"
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Show detailed output"
    )
    parser.add_argument(
        "--module", type=str, help="Check specific module (token, gate, boot, test)"
    )

    args = parser.parse_args()

    checker = HealthChecker(verbose=args.verbose)

    if args.quick:
        return checker.run_quick_health_check()
    else:
        return checker.run_full_health_check()


if __name__ == "__main__":
    sys.exit(main())
