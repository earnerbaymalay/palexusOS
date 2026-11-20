# ADR 0004: Extract TestOrchestrator (Unified Testing Framework Module Deepening)

**Date**: 2026-11-20  
**Status**: Decided  
**Deciders**: earnerbaymalay, Claude Haiku 4.5

## Context

Currently, quality verification and testing split across three disconnected systems:
- **Unit tests**: Python in `tests/` (pytest framework)
- **Gate tests**: Shell in `build/verify-gates.sh` (subprocess execution)
- **Integration tests**: QEMU in `build/test-iso-boot.sh` (manual setup)

**Pain Points**:
1. Can't run individual gate tests (all-or-nothing)
2. Can't run gate tests in CI without full ISO build
3. No unified test reporting
4. New quality checks have no clear home (Python? Shell? QEMU?)
5. Test artifacts (ISO, logs) scattered, no centralized management

## Decision

Extract a **TestOrchestrator** Python module (`palexus/test/orchestrator.py`) that:

1. **Owns**: Unified test execution and reporting
2. **Manages**: Test discovery, execution, artifact lifecycle
3. **Abstracts**: Three test classes
   - `UnitTests` → Run Python test suite
   - `GateTests` → Run GateRegistry tests (selective)
   - `IntegrationTests` → Run end-to-end boot (ISO → QEMU → login)
4. **Exports**: Public interface
   - `TestOrchestrator.run_all()` → All test suites
   - `orchestrator.run_gate(name)` → Single gate test
   - `orchestrator.run_integration()` → E2E boot test
   - `orchestrator.results()` → Unified report

Each test class manages:
- Test discovery and selection
- Execution with timeout handling
- Artifact staging and cleanup
- Result collection and reporting

## Benefits

### Locality
- **Before**: Adding new quality check requires deciding Python vs Shell vs QEMU
- **After**: New check registers with TestOrchestrator, inherits framework

### Testability
- Run unit tests without gates
- Run gate #2 without gates #1–#5
- Run integration without full ISO
- Tests can be parameterized, filtered, isolated

### CI Integration
- `python -m palexus.test run --gate package` → Fast feedback on package changes
- `python -m palexus.test run --integration` → Nightly full boot test
- Selective test running reduces CI time

### Clarity
- Test responsibility clear per class
- Unified reporting (JSON, markdown, human)
- Artifact provenance tracked

## Tradeoffs

### Added Complexity
- TestOrchestrator + 3 test classes
- Artifact management (ISO staging, cleanup)

### Dependencies
- Must work with both shell gates and Python tests
- QEMU setup/teardown coordination

## Implementation Plan

1. Create `palexus/test/orchestrator.py` with TestOrchestrator class
2. Create test classes: UnitTests, GateTests, IntegrationTests
3. Implement artifact staging (ISO copy, log collection)
4. Write tests in `tests/test_orchestrator_test.py`
5. Provide CLI: `python -m palexus.test run [--all|--gate|--integration]`
6. Generate unified test report (JSON)

## Consequences

- Testing framework unified and extensible
- CI can run selective tests (faster feedback)
- New quality checks integrated cleanly
- Test artifacts managed centrally
- Developers can run full test suite locally: `python -m palexus.test run --all`
