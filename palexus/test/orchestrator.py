"""TestOrchestrator: Unified test execution framework.

Coordinates unit tests, gate tests, and integration tests from one interface.
Enables selective test execution and cross-test reporting.
"""

from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path
from typing import Dict, List, Optional, Set


class TestLevel(Enum):
    """Test execution levels."""
    UNIT = "unit"
    GATE = "gate"
    INTEGRATION = "integration"
    ALL = "all"


@dataclass
class TestCase:
    """Single test case execution record."""
    name: str
    level: TestLevel
    passed: bool
    duration_ms: float = 0.0
    error: Optional[str] = None


@dataclass
class TestSuite:
    """Collection of related test cases."""
    name: str
    level: TestLevel
    test_count: int = 0
    passed: int = 0
    failed: int = 0
    duration_ms: float = 0.0
    tests: List[TestCase] = field(default_factory=list)

    @property
    def pass_rate(self) -> float:
        """Get pass rate as percentage."""
        if self.test_count == 0:
            return 0.0
        return (self.passed / self.test_count) * 100


class TestOrchestrator:
    """Unified test orchestration framework."""

    def __init__(self, repo_root: Optional[Path] = None):
        """Initialize test orchestrator.

        Args:
            repo_root: Repository root for test discovery
        """
        self.repo_root = repo_root or Path.cwd()
        self.suites: Dict[str, TestSuite] = {}
        self.results: Dict[str, TestSuite] = {}

    def register_suite(self, suite: TestSuite) -> None:
        """Register a test suite.

        Args:
            suite: TestSuite to register
        """
        self.suites[suite.name] = suite

    def run_all(self) -> Dict[str, TestSuite]:
        """Execute all registered test suites.

        Returns:
            Dict of suite name to results
        """
        self.results = {}
        for suite_name, suite in self.suites.items():
            self.results[suite_name] = self._execute_suite(suite)
        return self.results

    def run_level(self, level: TestLevel) -> Dict[str, TestSuite]:
        """Execute tests at specific level.

        Args:
            level: TestLevel to run

        Returns:
            Dict of suite name to results for that level
        """
        self.results = {}
        for suite_name, suite in self.suites.items():
            if suite.level == level or level == TestLevel.ALL:
                self.results[suite_name] = self._execute_suite(suite)
        return self.results

    def run_gate(self, gate_name: str) -> Optional[TestSuite]:
        """Execute tests for specific gate.

        Args:
            gate_name: Name of gate (e.g., "package", "iso")

        Returns:
            Results for that gate's test suite, or None
        """
        suite_name = f"gate_{gate_name}"
        if suite_name not in self.suites:
            return None

        suite = self.suites[suite_name]
        result = self._execute_suite(suite)
        self.results[suite_name] = result
        return result

    def run_integration(self) -> Optional[TestSuite]:
        """Execute integration tests.

        Returns:
            Integration test results
        """
        suite_name = "integration"
        if suite_name not in self.suites:
            return None

        suite = self.suites[suite_name]
        result = self._execute_suite(suite)
        self.results[suite_name] = result
        return result

    def test_specific(self, suite_name: str, test_name: str) -> Optional[TestCase]:
        """Run specific test case.

        Args:
            suite_name: Name of test suite
            test_name: Name of test case

        Returns:
            TestCase result, or None if not found
        """
        if suite_name not in self.suites:
            return None

        suite = self.suites[suite_name]
        # In real implementation, would run specific test
        for test in suite.tests:
            if test.name == test_name:
                return test

        return None

    def summary(self) -> str:
        """Get test execution summary.

        Returns:
            Summary string with pass/fail counts
        """
        if not self.results:
            return "No tests executed"

        total_tests = 0
        total_passed = 0
        total_failed = 0
        total_time = 0.0

        for suite in self.results.values():
            total_tests += suite.test_count
            total_passed += suite.passed
            total_failed += suite.failed
            total_time += suite.duration_ms

        pass_rate = (total_passed / total_tests * 100) if total_tests > 0 else 0

        return (
            f"Tests: {total_tests} | "
            f"Passed: {total_passed} | "
            f"Failed: {total_failed} | "
            f"Pass rate: {pass_rate:.1f}% | "
            f"Time: {total_time:.0f}ms"
        )

    def _execute_suite(self, suite: TestSuite) -> TestSuite:
        """Execute a test suite.

        Args:
            suite: TestSuite to execute

        Returns:
            TestSuite with updated results
        """
        # In real implementation, would discover and run tests
        # This is a placeholder that returns the suite as-is
        result = TestSuite(
            name=suite.name,
            level=suite.level,
            test_count=suite.test_count,
            passed=suite.passed,
            failed=suite.failed,
            tests=suite.tests,
        )
        return result

    def report_failures(self) -> List[str]:
        """Get list of failed test names.

        Returns:
            List of failed test names
        """
        failures = []
        for suite in self.results.values():
            for test in suite.tests:
                if not test.passed:
                    failures.append(f"{suite.name}/{test.name}: {test.error}")
        return failures
