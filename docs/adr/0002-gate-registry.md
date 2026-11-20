# ADR 0002: Extract GateRegistry (Build Quality Gates Module Deepening)

**Date**: 2026-11-20  
**Status**: Decided  
**Deciders**: earnerbaymalay, Claude Haiku 4.5

## Context

Currently, quality verification gates are defined in `build/verify-gates.sh` (828 lines):
- **G1 (Package)**: makepkg builds all packages
- **G2 (ISO)**: ISO image is created and bootable
- **G3 (Graphics)**: Qt6 rendering works
- **G4 (Boot)**: QEMU boots to login prompt
- **G5 (Performance)**: Build completes within target time

**Pain Points**:
1. All gates in one script → hard to understand, modify, test individually
2. No gate independence declared → can't run G2 without G1–G5 passing
3. Adding gate #6 requires understanding entire 828-line script
4. CI can't run selective gates (all-or-nothing)
5. Gate logic mixed with shell environment concerns

## Decision

Extract a **GateRegistry** Python module (`palexus/build/gate_registry.py`) that:

1. **Owns**: Gate definitions, execution order, dependencies
2. **Manages**: Which gates passed/failed, skipped reasons
3. **Abstracts**: Individual gates as small classes
   - `PackageGate.run()` → G1
   - `ISOGate.run()` → G2
   - `GraphicsGate.run()` → G3
   - `BootGate.run()` → G4
   - `PerfGate.run()` → G5
4. **Exports**: Public interface
   - `GateRegistry.run(selected=None)` → Run all or selected gates
   - `GateRegistry.test(gate_name)` → Test one gate in isolation
   - `registry.results()` → Get pass/fail status per gate

Each gate declares:
- `name`: Gate identifier
- `description`: Human-readable purpose
- `dependencies`: Which gates must pass first
- `run()`: Test logic (subprocess calls, assertions)

## Benefits

### Locality
- **Before**: Changing gate logic means editing 828-line script
- **After**: Changing G2 only affects ISOGate class (~50 lines)

### Testability
- Each gate tested independently
- Mock gate #1 results to test gate #2 in isolation
- Gates don't depend on shell environment

### Extensibility
- Adding gate #6 is a new Gate class + GateRegistry registration
- CI can map file changes to gates (e.g., packages/ → test PackageGate)

### Clarity
- Gate dependencies explicit (ISOGate depends on PackageGate)
- Each gate responsible for one concern
- Interface: "What does PackageGate verify?"

## Tradeoffs

### Added Complexity
- 5 Gate classes + GateRegistry orchestrator
- Requires Python for orchestration

### Shell Subprocess Calls
- Some gate logic (makepkg, QEMU) still executes in subprocess
- Gateway classes capture output, check return codes

## Implementation Plan

1. Create `palexus/build/gate_registry.py` with GateRegistry class
2. Create `palexus/build/gates.py` with individual Gate classes
3. Write tests in `tests/build_test.py`
4. Update `build/verify-gates.sh` to call Python GateRegistry
5. Support `--gates package,iso` for selective runs

## Consequences

- Quality gates are now modular and independently testable
- CI can run only affected gates (faster feedback)
- Adding new gates becomes straightforward
- Gate dependencies explicit and validated
