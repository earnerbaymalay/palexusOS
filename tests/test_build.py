"""Tests for build gate registry."""

from palexus.build.gate_registry import (
    BootGate,
    GateRegistry,
    GateStatus,
    GraphicsGate,
    ISOGate,
    PackageGate,
    PerfGate,
)


class TestPackageGate:
    """Test package verification gate."""

    def test_gate_name(self):
        """PackageGate has correct name."""
        gate = PackageGate()
        assert gate.name == "package"

    def test_gate_dependencies(self):
        """PackageGate has no dependencies."""
        gate = PackageGate()
        assert gate.dependencies == set()

    def test_gate_test(self):
        """PackageGate passes self-test."""
        gate = PackageGate()
        assert gate.test()


class TestISOGate:
    """Test ISO gate."""

    def test_gate_name(self):
        """ISOGate has correct name."""
        gate = ISOGate()
        assert gate.name == "iso"

    def test_gate_dependencies(self):
        """ISOGate depends on package."""
        gate = ISOGate()
        assert "package" in gate.dependencies

    def test_gate_test(self):
        """ISOGate passes self-test."""
        gate = ISOGate()
        assert gate.test()


class TestGraphicsGate:
    """Test graphics gate."""

    def test_gate_name(self):
        """GraphicsGate has correct name."""
        gate = GraphicsGate()
        assert gate.name == "graphics"

    def test_gate_dependencies(self):
        """GraphicsGate depends on package."""
        gate = GraphicsGate()
        assert "package" in gate.dependencies

    def test_gate_test(self):
        """GraphicsGate passes self-test."""
        gate = GraphicsGate()
        assert gate.test()


class TestBootGate:
    """Test boot gate."""

    def test_gate_name(self):
        """BootGate has correct name."""
        gate = BootGate()
        assert gate.name == "boot"

    def test_gate_dependencies(self):
        """BootGate depends on iso and graphics."""
        gate = BootGate()
        assert "iso" in gate.dependencies
        assert "graphics" in gate.dependencies

    def test_gate_test(self):
        """BootGate passes self-test."""
        gate = BootGate()
        assert gate.test()


class TestPerfGate:
    """Test performance gate."""

    def test_gate_name(self):
        """PerfGate has correct name."""
        gate = PerfGate()
        assert gate.name == "perf"

    def test_gate_dependencies(self):
        """PerfGate depends on boot."""
        gate = PerfGate()
        assert "boot" in gate.dependencies

    def test_gate_test(self):
        """PerfGate passes self-test."""
        gate = PerfGate()
        assert gate.test()


class TestGateRegistry:
    """Test gate registry."""

    def test_registry_has_all_gates(self):
        """Registry contains all gate types."""
        registry = GateRegistry()
        assert "package" in registry.gates
        assert "iso" in registry.gates
        assert "graphics" in registry.gates
        assert "boot" in registry.gates
        assert "perf" in registry.gates

    def test_run_all_gates(self, tmp_path):
        """Registry runs all gates in dependency order."""
        registry = GateRegistry()
        results = registry.run(tmp_path)

        assert "package" in results
        assert "iso" in results
        assert results["package"].status == GateStatus.SKIPPED

    def test_run_selected_gates(self, tmp_path):
        """Registry runs only selected gates."""
        registry = GateRegistry()
        results = registry.run(tmp_path, selected=["package"])

        assert "package" in results
        assert len(results) == 1

    def test_gate_independence(self):
        """Each gate is independent and testable."""
        registry = GateRegistry()

        for gate_name in registry.gates:
            assert registry.test(gate_name)

    def test_topological_sort(self):
        """Registry sorts gates by dependencies."""
        registry = GateRegistry()
        order = registry._topological_sort({"package", "iso", "boot", "graphics", "perf"})

        # package must come before iso
        assert order.index("package") < order.index("iso")
        # iso and graphics must come before boot
        assert order.index("iso") < order.index("boot")
        assert order.index("graphics") < order.index("boot")
        # boot must come before perf
        assert order.index("boot") < order.index("perf")
