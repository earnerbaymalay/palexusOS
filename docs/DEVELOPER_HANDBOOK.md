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

### Add a New Gate: `Security`

**Step 1: Define Gate Class**

```python
# In palexus/build/gate_registry.py

class SecurityGate(Gate):
    """Security verification gate.
    
    Checks:
    - No hardcoded secrets
    - No dangerous functions used
    - Dependencies audited for CVEs
    - Code signing ready
    """
    
    def __init__(self):
        super().__init__(
            name="Security",
            description="Verify security requirements",
            dependencies=["Package"]  # Must build first
        )
    
    def verify(self) -> Result:
        """Run security checks."""
        checks = [
            self._check_no_secrets(),
            self._check_no_dangerous_functions(),
            self._check_dependencies_audited(),
        ]
        
        passed = all(c.passed for c in checks)
        error = "; ".join(c.error for c in checks if not c.passed)
        
        return Result(
            name=self.name,
            passed=passed,
            error=error or None
        )
    
    def _check_no_secrets(self) -> Result:
        """Check for hardcoded secrets."""
        import re
        
        patterns = [
            r"password\s*=\s*['\"].*['\"]",
            r"api[_-]?key\s*=\s*['\"].*['\"]",
            r"secret\s*=\s*['\"].*['\"]",
        ]
        
        found = []
        for pattern in patterns:
            # Search codebase
            matches = re.finditer(pattern, self._read_codebase())
            if matches:
                found.extend(str(m) for m in matches)
        
        return Result(
            name="No hardcoded secrets",
            passed=len(found) == 0,
            error=f"Found {len(found)} potential secrets" if found else None
        )
    
    def _check_no_dangerous_functions(self) -> Result:
        """Check for dangerous function usage."""
        dangerous = ["eval", "exec", "pickle.load", "__import__"]
        
        found = []
        for func in dangerous:
            if func in self._read_codebase():
                found.append(func)
        
        return Result(
            name="No dangerous functions",
            passed=len(found) == 0,
            error=f"Found dangerous: {', '.join(found)}" if found else None
        )
    
    def _check_dependencies_audited(self) -> Result:
        """Check dependencies are audited."""
        # Run: pip audit
        try:
            import subprocess
            result = subprocess.run(
                ["pip", "audit"],
                capture_output=True,
                timeout=30
            )
            
            return Result(
                name="Dependencies audited",
                passed=result.returncode == 0,
                error="CVEs found in dependencies" if result.returncode != 0 else None
            )
        except Exception as e:
            return Result(
                name="Dependencies audited",
                passed=False,
                error=str(e)
            )
    
    def _read_codebase(self) -> str:
        """Read all source code."""
        from pathlib import Path
        
        code = []
        for file in Path("palexus").rglob("*.py"):
            with open(file) as f:
                code.append(f.read())
        
        return "\n".join(code)
```

**Step 2: Register Gate**

```python
class GateRegistry:
    def __init__(self):
        self.gates = [
            # ... existing gates ...
            SecurityGate(),
        ]
```

**Step 3: Write Integration Test**

```python
def test_security_gate_runs():
    """SecurityGate executes and returns result."""
    registry = GateRegistry()
    
    security_gate = next(
        g for g in registry.gates 
        if g.name == "Security"
    )
    
    result = security_gate.verify()
    assert result is not None
    assert hasattr(result, "passed")
    assert hasattr(result, "error")
```

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

from enum import Enum, auto

class BootPhase(Enum):
    """Boot sequence phases."""
    GREETER = auto()
    USER_SELECT = auto()
    CREDENTIALS = auto()  # NEW
    HUD = auto()
    THEME = auto()
    COMPLETE = auto()
```

**Step 2: Update BootContext**

```python
class BootContext:
    def __init__(self):
        self.current_phase = BootPhase.GREETER
        self.user = None
        self.credentials = None  # NEW
        self.hud_enabled = False
        self.theme = None
    
    def set_credentials(self, creds: dict) -> None:
        """Store credentials collected at CREDENTIALS phase."""
        self.credentials = creds
    
    def get_credentials(self) -> Optional[dict]:
        """Retrieve stored credentials."""
        return self.credentials
```

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

Run performance benchmarks and profile critical paths.

```python
# In palexus/test/orchestrator.py

from enum import Enum

class Level(Enum):
    """Test levels."""
    UNIT = "unit"
    GATE = "gate"
    INTEGRATION = "integration"
    PERFORMANCE = "performance"  # NEW


class TestOrchestrator:
    def run_level(self, level: Level) -> Optional[List[Result]]:
        """Run tests at specified level."""
        if level == Level.PERFORMANCE:
            return self._run_performance_tests()
        
        # ... existing levels ...
    
    def _run_performance_tests(self) -> List[Result]:
        """Run performance benchmarks."""
        import time
        
        results = []
        
        # Benchmark TokenRegistry
        start = time.time()
        registry = TokenRegistry(Path("docs/design-system/tokens.json"))
        registry.colors()
        duration = time.time() - start
        
        results.append(Result(
            name="TokenRegistry.colors() < 10ms",
            passed=duration < 0.01,
            error=f"Took {duration*1000:.2f}ms" if duration >= 0.01 else None
        ))
        
        # Benchmark GateRegistry
        start = time.time()
        gate_registry = GateRegistry()
        gate_registry.run()
        duration = time.time() - start
        
        results.append(Result(
            name="GateRegistry.run() < 5s",
            passed=duration < 5,
            error=f"Took {duration:.2f}s" if duration >= 5 else None
        ))
        
        return results
```

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
    result = registry.color("accent", "primary")
    assert result == "#cba6f7"


# 2. Gate Tests (feature verification)
def test_package_gate_verifies_build():
    """Gate verifies expected behavior."""
    gate = PackageGate()
    result = gate.verify()
    assert result.passed


# 3. Integration Tests (module interactions)
def test_tokens_applied_during_boot():
    """Tokens flow through boot sequence."""
    registry = TokenRegistry(test_file)
    context = BootContext()
    
    # Apply theme
    context.set_theme("tokens-from-registry")
    
    # Verify tokens available
    assert context.get_theme() is not None
```

### Edge Case Testing

```python
def test_token_registry_missing_file():
    """Handle missing tokens file gracefully."""
    with pytest.raises(FileNotFoundError):
        TokenRegistry(Path("nonexistent.json"))


def test_boot_phase_invalid_transition():
    """Prevent invalid phase transitions."""
    context = BootContext()
    context.current_phase = BootPhase.COMPLETE
    
    # Should not allow backwards
    # (Implementation depends on actual API)


def test_gate_dependency_cycle():
    """Prevent circular gate dependencies."""
    gate = Gate("Test", "test", dependencies=["Test"])
    
    with pytest.raises(ValueError):
        registry = GateRegistry()
        registry.add(gate)
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
