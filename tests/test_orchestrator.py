"""Tests for test orchestrator."""

from pathlib import Path

import pytest

from palexus.test.orchestrator import (
    TestOrchestrator,
    Level,
    Suite,
    Result,
)


class TestResultClass:
    """Test Result data class."""

    def test_case_creation(self):
        """Result stores test metadata."""
        case = Result(
            name="test_foo",
            level=Level.UNIT,
            passed=True,
            duration_ms=42.5,
        )
        assert case.name == "test_foo"
        assert case.level == Level.UNIT
        assert case.passed


class TestSuiteClass:
    """Test Suite data class."""

    def test_suite_creation(self):
        """Suite stores suite metadata."""
        suite = Suite(
            name="unit",
            level=Level.UNIT,
            test_count=5,
            passed=4,
            failed=1,
        )
        assert suite.name == "unit"
        assert suite.test_count == 5

    def test_pass_rate(self):
        """Suite calculates pass rate."""
        suite = Suite(
            name="unit",
            level=Level.UNIT,
            test_count=10,
            passed=8,
            failed=2,
        )
        assert suite.pass_rate == 80.0

    def test_pass_rate_empty(self):
        """Suite handles empty test count."""
        suite = Suite(
            name="unit",
            level=Level.UNIT,
            test_count=0,
            passed=0,
            failed=0,
        )
        assert suite.pass_rate == 0.0


class TestLevelEnum:
    """Test Level enum."""

    def test_levels_defined(self):
        """All test levels are defined."""
        assert Level.UNIT
        assert Level.GATE
        assert Level.INTEGRATION
        assert Level.ALL


class TestOrchestratorClass:
    """Test orchestrator functionality."""

    def test_initialization(self):
        """TestOrchestrator initializes with repo root."""
        orchestrator = TestOrchestrator()
        assert orchestrator.repo_root == Path.cwd()

    def test_initialization_with_root(self, tmp_path):
        """TestOrchestrator accepts custom repo root."""
        orchestrator = TestOrchestrator(tmp_path)
        assert orchestrator.repo_root == tmp_path

    def test_register_suite(self):
        """TestOrchestrator registers test suites."""
        orchestrator = TestOrchestrator()
        suite = Suite("unit", Level.UNIT)

        orchestrator.register_suite(suite)

        assert "unit" in orchestrator.suites
        assert orchestrator.suites["unit"] == suite

    def test_run_all(self):
        """TestOrchestrator runs all registered suites."""
        orchestrator = TestOrchestrator()

        suite1 = Suite("unit", Level.UNIT, test_count=5, passed=5)
        suite2 = Suite("gate", Level.GATE, test_count=3, passed=3)

        orchestrator.register_suite(suite1)
        orchestrator.register_suite(suite2)

        results = orchestrator.run_all()

        assert "unit" in results
        assert "gate" in results
        assert len(results) == 2

    def test_run_level_unit(self):
        """TestOrchestrator filters by test level."""
        orchestrator = TestOrchestrator()

        suite1 = Suite("unit", Level.UNIT, test_count=5, passed=5)
        suite2 = Suite("gate", Level.GATE, test_count=3, passed=3)

        orchestrator.register_suite(suite1)
        orchestrator.register_suite(suite2)

        results = orchestrator.run_level(Level.UNIT)

        assert "unit" in results
        assert len(results) == 1

    def test_run_gate_specific(self):
        """TestOrchestrator runs specific gate."""
        orchestrator = TestOrchestrator()

        suite = Suite("gate_package", Level.GATE, test_count=3, passed=3)
        orchestrator.register_suite(suite)

        result = orchestrator.run_gate("package")

        assert result is not None
        assert result.name == "gate_package"

    def test_run_gate_missing(self):
        """TestOrchestrator returns None for missing gate."""
        orchestrator = TestOrchestrator()

        result = orchestrator.run_gate("nonexistent")

        assert result is None

    def test_run_integration(self):
        """TestOrchestrator runs integration tests."""
        orchestrator = TestOrchestrator()

        suite = Suite("integration", Level.INTEGRATION)
        orchestrator.register_suite(suite)

        result = orchestrator.run_integration()

        assert result is not None
        assert result.name == "integration"

    def test_summary_no_tests(self):
        """TestOrchestrator summary with no tests."""
        orchestrator = TestOrchestrator()

        summary = orchestrator.summary()

        assert "No tests executed" in summary

    def test_summary_with_results(self):
        """TestOrchestrator generates summary."""
        orchestrator = TestOrchestrator()

        suite = Suite("unit", Level.UNIT, test_count=10, passed=8, failed=2)
        orchestrator.register_suite(suite)
        orchestrator.run_all()

        summary = orchestrator.summary()

        assert "Tests: 10" in summary
        assert "Passed: 8" in summary
        assert "Failed: 2" in summary

    def test_report_failures_empty(self):
        """TestOrchestrator reports no failures when all pass."""
        orchestrator = TestOrchestrator()

        suite = Suite("unit", Level.UNIT, test_count=5, passed=5)
        orchestrator.register_suite(suite)
        orchestrator.run_all()

        failures = orchestrator.report_failures()

        assert len(failures) == 0

    def test_report_failures_with_errors(self):
        """TestOrchestrator reports test failures."""
        orchestrator = TestOrchestrator()

        case = Result("test_bad", Level.UNIT, passed=False, error="Assertion failed")
        suite = Suite(
            "unit",
            Level.UNIT,
            test_count=1,
            passed=0,
            failed=1,
            tests=[case],
        )

        orchestrator.register_suite(suite)
        orchestrator.run_all()

        failures = orchestrator.report_failures()

        assert len(failures) > 0
        assert "test_bad" in failures[0]
