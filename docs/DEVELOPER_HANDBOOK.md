# PalexusOS Developer Handbook

Deep guide for extending PalexusOS modules and contributing advanced features.

**Audience**: Contributors ready to modify module internals  
**Prerequisites**: Read QUICKSTART.md, ARCHITECTURE.md, examples/  
**Time to read**: 30–45 minutes

---

## Table of Contents

1. [Module Extension Patterns](#module-extension-patterns)
2. [TokenRegistry: Adding Token Types](#tokenregistry-adding-token-types)
3. [GateRegistry: Creating Custom Gates](#gateregistry-creating-custom-gates)
4. [DesktopEnvironment: Custom Boot Phases](#desktopenv-custom-boot-phases)
5. [TestOrchestrator: Custom Test Levels](#testorch-custom-test-levels)
6. [Performance Optimization](#performance-optimization)
7. [Security Hardening](#security-hardening)
8. [Testing Strategy](#testing-strategy)

---

## Module Extension Patterns

All PalexusOS modules follow the **Ralph Wiggum Adapter Pattern**:

```
┌──────────────────────────────────────────────┐
│          Module Interface (Public)           │
├──────────────────────────────────────────────┤
│          Adapter Layer (Adapts input)        │
├──────────────────────────────────────────────┤
│      Implementation Core (Business logic)    │
├──────────────────────────────────────────────┤
│      Persistence Layer (Save/load state)    │
└──────────────────────────────────────────────┘
```

**Key Principle**: Changes at any layer should not leak into other layers.

### Generic Extension Steps

For any module extension:

1. **Define the interface** (what the module exposes)
2. **Write tests first** (test the new interface)
3. **Implement the core** (business logic)
4. **Add persistence** (if needed)
5. **Verify isolation** (changes don't break other modules)
6. **Document** (ADR + code comments)

---

## TokenRegistry: Adding Token Types

### Current Token Types

```python
# Supported:
- colors (semantic colors)
- typography (fonts, sizes, weights)
- spacing (margins, padding, gaps)
- radius (border-radius values)
- shadows (drop shadows, glows)
```

### Add a New Token Type: `transitions`

**Step 1: Define Interface**

```python
# In palexus/design/token_registry.py

class TokenRegistry:
    def transitions(self, category: Optional[str] = None) -> Dict[str, Any]:
        """Get transition/animation tokens.
        
        Args:
            category: "fast", "normal", "slow" (optional)
            
        Returns:
            All transitions or specific category
        """
        transitions = self._data.get("transitions", {})
        if category:
            return transitions.get(category, {})
        return transitions
    
    def transition(self, category: str, name: str) -> str:
        """Get specific transition value.
        
        Args:
            category: "fast", "normal", "slow"
            name: transition name (e.g., "fade", "slide")
            
        Returns:
            CSS transition string (e.g., "all 0.2s ease-in-out")
            
        Raises:
            KeyError: If transition not found
        """
        return self.transitions(category)[name]
```

**Step 2: Write Tests First**

```python
# In tests/test_design.py

def test_registry_transitions_fast():
    """TokenRegistry retrieves fast transition tokens."""
    registry = TokenRegistry(test_tokens_file)
    
    fast = registry.transitions("fast")
    assert "fade" in fast
    assert fast["fade"] == "all 0.15s ease-in-out"


def test_registry_transition_specific():
    """TokenRegistry retrieves specific transition by category+name."""
    registry = TokenRegistry(test_tokens_file)
    
    value = registry.transition("normal", "slide")
    assert value == "all 0.3s cubic-bezier(0.4, 0, 0.2, 1)"


def test_registry_transition_all_categories():
    """TokenRegistry transitions include all categories."""
    registry = TokenRegistry(test_tokens_file)
    
    for category in ["fast", "normal", "slow"]:
        trans = registry.transitions(category)
        assert len(trans) > 0
        assert all(isinstance(v, str) for v in trans.values())
```

**Step 3: Implement Core**

```python
def export_css_transitions(self) -> str:
    """Export transition tokens as CSS custom properties."""
    css = []
    transitions = self._data.get("transitions", {})
    
    for category, items in transitions.items():
        for name, value in items.items():
            # Custom property: --transition-{category}-{name}
            prop = f"--transition-{category}-{name}"
            css.append(f"{prop}: {value};")
    
    return ":root {\n  " + "\n  ".join(css) + "\n}"
```

**Step 4: Add to Persistence**

```python
# In tokens.json
{
  "transitions": {
    "fast": {
      "fade": "all 0.15s ease-in-out",
      "slide": "all 0.15s cubic-bezier(0.4, 0, 0.2, 1)"
    },
    "normal": {
      "fade": "all 0.3s ease-in-out",
      "slide": "all 0.3s cubic-bezier(0.4, 0, 0.2, 1)"
    },
    "slow": {
      "fade": "all 0.6s ease-in-out",
      "slide": "all 0.6s cubic-bezier(0.4, 0, 0.2, 1)"
    }
  }
}
```

**Step 5: Verify Isolation**

```python
def test_transitions_dont_affect_colors():
    """Adding transitions doesn't break color tokens."""
    registry = TokenRegistry(test_tokens_file)
    
    colors_before = registry.colors()
    transitions = registry.transitions()
    colors_after = registry.colors()
    
    # Must be identical
    assert colors_before == colors_after
    # Transitions are separate
    assert len(transitions) > 0
```

**Step 6: Document (ADR)**

```markdown
# ADR-0005: Transition Token Type

## Context
Animation transitions (durations, timing functions) are part of design system.
Currently stored separately, not integrated with TokenRegistry.

## Decision
Add `transitions` as first-class token type in TokenRegistry.

## Consequences
- One unified token interface for all animation values
- CSS export includes `--transition-*` custom properties
- Enables consistent animation across UI
```

---

## GateRegistry: Creating Custom Gates

### Current Gates

```python
Gate("Package", "Verify package builds cleanly")
Gate("ISO", "Verify ISO builds", dependencies=["Package"])
Gate("Graphics", "Verify graphics assets", dependencies=["Package"])
Gate("Boot", "Verify boot sequence", dependencies=["Graphics"])
Gate("Performance", "Verify performance metrics", dependencies=["Boot"])
```

### Add a New Gate: `security`

A gate subclasses `Gate`, names its dependencies, and implements
`run(repo_root) -> GateResult` and `test() -> bool`. The registry handles
ordering and skips the gate if a dependency fails.

**Step 1: Write the test first**

```python
# tests/test_build.py
def test_security_gate_fails_on_eval(tmp_path):
    (tmp_path / "palexus").mkdir()
    (tmp_path / "palexus" / "bad.py").write_text("eval(input())\n")

    result = SecurityGate().run(tmp_path)

    assert result.status == GateStatus.FAILED
    assert "eval" in result.message


def test_security_gate_passes_on_clean_code(tmp_path):
    (tmp_path / "palexus").mkdir()
    (tmp_path / "palexus" / "ok.py").write_text("x = 1\n")

    assert SecurityGate().run(tmp_path).status == GateStatus.PASSED
```

**Step 2: Implement the gate**

```python
# palexus/build/gate_registry.py
class SecurityGate(Gate):
    """G6: No dangerous calls in the Python sources."""

    DANGEROUS = ("eval(", "exec(", "pickle.load", "__import__(")

    def __init__(self):
        super().__init__("security", dependencies={"package"})

    def run(self, repo_root: Path) -> GateResult:
        src = repo_root / "palexus"
        if not src.exists():
            return GateResult(self.name, GateStatus.SKIPPED, "No palexus/ sources")
        found = sorted(
            {call for f in src.rglob("*.py") for call in self.DANGEROUS if call in f.read_text()}
        )
        if found:
            return GateResult(self.name, GateStatus.FAILED, f"Found: {', '.join(found)}")
        return GateResult(self.name, GateStatus.PASSED, "No dangerous calls")

    def test(self) -> bool:
        return self.name == "security" and self.dependencies == {"package"}
```

A substring check like this is a tripwire, not an audit: it will flag
`eval(` in a comment and miss `getattr(builtins, "eval")`. Say so in the
gate's docstring if you ship it.

**Step 3: Register it**

```python
# GateRegistry.__init__
self.gates: dict[str, Gate] = {
    "package": PackageGate(),
    # ... existing gates ...
    "security": SecurityGate(),
}
```

`palexus build list` and `palexus build run --gates security` pick it up with
no CLI changes.

---

## DesktopEnvironment: Custom Boot Phases

### Current Phases

```
GREETER → USER_SELECT → HUD → THEME → COMPLETE
```

### Add Intermediate Phase: `CREDENTIALS`

After USER_SELECT but before HUD initialization, collect credentials.

**Step 1: Extend BootPhase Enum**

```python
# In palexus/desktop/environment.py

class BootPhase(Enum):
    """Desktop boot sequence phases."""

    GREETER = "greeter"
    USER_SELECT = "user_select"
    CREDENTIALS = "credentials"  # NEW
    HUD = "hud"
    THEME = "theme"
    COMPLETE = "complete"
```

**Step 2: Add a context field and an adapter**

`BootContext` is a dataclass; add a field. Each phase is handled by an
`Adapter` that acts only when the context is in its phase, then advances it.

```python
@dataclass
class BootContext:
    selected_user: str | None = None
    selected_theme: str | None = None
    hud_enabled: bool = True
    phase: BootPhase = BootPhase.GREETER
    credentials: dict | None = None  # NEW


class CredentialsAdapter(Adapter):
    def __init__(self):
        self.name = "credentials"

    def initialize(self, context: BootContext) -> None:
        if context.phase != BootPhase.CREDENTIALS:
            return
        context.credentials = {}  # collect here; keep in memory only
        context.phase = BootPhase.HUD

    def test(self) -> bool:
        return self.name == "credentials"
```

Then have the greeter advance to `CREDENTIALS` instead of `HUD`, and call the
new adapter in `DesktopEnvironment.boot()` between the greeter and the HUD.

**Step 3: Document Phase**

```python
# Boot sequence documentation

"""
Phase: CREDENTIALS (after USER_SELECT)

Purpose: Collect user credentials if needed
- SSH keys
- Cloud API tokens (optional, opt-in)
- Encryption passwords

Design: Credentials stored in-memory, not on disk
Isolation: Credentials not passed to HUD or THEME phases
Cleanup: Wiped on boot completion
"""
```

---

## TestOrchestrator: Custom Test Levels

### Current Levels

```
UNIT → GATE → INTEGRATION
```

### Add Level: `PERFORMANCE`

`TestOrchestrator` aggregates suites; it does not execute tests. So a new
level means: add the enum value, produce a `Suite` at that level from real
measurements, and register it.

```python
# palexus/test/orchestrator.py
class Level(Enum):
    UNIT = "unit"
    GATE = "gate"
    INTEGRATION = "integration"
    PERFORMANCE = "performance"  # NEW
    ALL = "all"
```

```python
# Build the suite from scripts/perf_baseline.py, which already measures
# medians and owns the budgets.
import sys; sys.path.insert(0, "scripts")
from perf_baseline import BUDGETS_MS, measure

timings = measure(runs=10, with_tests=False)
tests = [
    Result(
        name=f"{op} <= {BUDGETS_MS[op]:.0f}ms",
        level=Level.PERFORMANCE,
        passed=ms <= BUDGETS_MS[op],
        duration_ms=ms,
        error=None if ms <= BUDGETS_MS[op] else f"took {ms:.2f}ms",
    )
    for op, ms in timings.items()
]
passed = sum(t.passed for t in tests)
orchestrator.register_suite(
    Suite("performance", Level.PERFORMANCE, len(tests), passed, len(tests) - passed, tests=tests)
)
orchestrator.run_level(Level.PERFORMANCE)
```

Keep the budgets in one place (`BUDGETS_MS`); do not copy thresholds into
the orchestrator.

---

## Performance Optimization

### Profiling Pattern

```python
import cProfile
import pstats
from io import StringIO

def profile_function(func, *args, **kwargs):
    """Profile function execution."""
    pr = cProfile.Profile()
    pr.enable()
    
    result = func(*args, **kwargs)
    
    pr.disable()
    s = StringIO()
    ps = pstats.Stats(pr, stream=s).sort_stats('cumulative')
    ps.print_stats(10)  # Top 10
    
    print(s.getvalue())
    return result


# Usage:
profile_function(registry.export_css)
```

### Common Bottlenecks

| Bottleneck | Solution | Impact |
|-----------|----------|--------|
| JSON parsing | Use `orjson` or cache | 50-70% faster |
| File I/O | Cache in memory | 10-100x faster |
| Loop iteration | Vectorize or use comprehensions | 2-5x faster |
| Regex matching | Pre-compile patterns | 3-5x faster |

---

## Security Hardening

### Secure Defaults Pattern

```python
class SecureContext:
    """Ensure secure defaults throughout."""
    
    def __init__(self):
        # ✓ No default credentials
        self.credentials = None
        
        # ✓ Minimal permissions
        self.permissions = set()
        
        # ✓ Secrets encrypted
        self._secrets = {}
    
    def set_secret(self, key: str, value: str) -> None:
        """Store secret securely (encrypted)."""
        import hashlib
        
        # Never store plaintext
        hashed = hashlib.sha256(value.encode()).hexdigest()
        self._secrets[key] = hashed
    
    def verify_secret(self, key: str, value: str) -> bool:
        """Verify secret without exposing plaintext."""
        import hashlib
        
        expected = self._secrets.get(key)
        actual = hashlib.sha256(value.encode()).hexdigest()
        
        return expected == actual
```

### Input Validation Pattern

```python
def validate_token_name(name: str) -> bool:
    """Validate token name format."""
    import re
    
    # Must match: category/subcategory/name
    pattern = r"^[a-z]+(/[a-z0-9]+)*$"
    
    return bool(re.match(pattern, name))


def validate_phase(phase: BootPhase) -> bool:
    """Validate boot phase is known."""
    return phase in BootPhase.__members__.values()
```

---

## Testing Strategy

### Test Pyramid

```
           △
          ╱│╲
         ╱ │ ╲ Integration (10%)
        ╱──┼──╲ 
       ╱   │   ╲
      ╱    │    ╲ Gate (30%)
     ╱─────┼─────╲
    ╱      │      ╲ Unit (60%)
   ╱───────┴───────╲
```

### Test Organization

```python
# 1. Unit Tests (single function/method)
def test_token_registry_color_lookup():
    """Single responsibility: lookup by name."""
    registry = TokenRegistry(test_file)
    result = registry.color("primary", "mauve")
    assert result == "#cba6f7"


# 2. Gate Tests (feature verification)
def test_package_gate_verifies_build():
    """Gate verifies expected behavior."""
    gate = PackageGate()
    result = gate.run(REPO_ROOT)
    assert result.status == GateStatus.PASSED


# 3. Integration Tests (module interactions)
def test_boot_uses_configured_tokens(tmp_path):
    """The theme loader uses the token file it was given, and boot completes."""
    tokens = tmp_path / "tokens.json"
    tokens.write_text(test_file.read_text())
    env = DesktopEnvironment()
    env.set_design_tokens(tokens)

    assert env.theme_loader() == tokens
    assert env.boot().phase == BootPhase.COMPLETE
```

### Edge Case Testing

```python
def test_token_registry_missing_file():
    """Handle missing tokens file gracefully."""
    with pytest.raises(FileNotFoundError):
        TokenRegistry(Path("nonexistent.json"))


def test_boot_without_hud_skips_theme():
    """With the HUD disabled, boot still completes."""
    env = DesktopEnvironment()
    env.context.hud_enabled = False

    assert env.boot().phase == BootPhase.COMPLETE
    assert env.hud_interface() is None


def test_gate_dependency_cycle(tmp_path):
    """A dependency cycle is reported, not looped on."""
    registry = GateRegistry()
    registry.gates["package"].dependencies = {"perf"}  # perf -> boot -> ... -> package

    with pytest.raises(ValueError, match="Circular dependency"):
        registry.run(tmp_path)
```

---

## Contribution Workflow for Extensions

1. **Create ADR** - Document design decision
2. **Write failing test** - Define the new interface
3. **Implement core** - Add business logic
4. **Add integration test** - Verify module interaction
5. **Update docs** - ADR, examples, QUICKSTART
6. **Performance test** - Benchmark if relevant
7. **Security review** - Check for vulnerabilities
8. **Submit PR** - With all above included

---

## References

- **Module APIs**: `palexus/design/`, `palexus/build/`, `palexus/desktop/`, `palexus/test/`
- **Examples**: `examples/01-04_*.py`
- **Tests**: `tests/test_*.py`
- **ADRs**: `docs/adr/0001-0004.md`

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete guidance for extensions
