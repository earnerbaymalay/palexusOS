# API Reference

Complete API documentation for PalexusOS modules.

---

## Table of Contents

- [TokenRegistry](#tokenregistry)
- [GateRegistry](#gateregistry)
- [DesktopEnvironment](#desktopenvironment)
- [TestOrchestrator](#testorchestrator)

---

## TokenRegistry

**Module**: `palexus.design.token_registry`

**Purpose**: Unified design token management with multi-format export.

### Classes

#### `TokenRegistry`

Main registry for all design tokens.

**Constructor**

```python
TokenRegistry(tokens_file: Path)
```

**Parameters**:
- `tokens_file` (Path): Path to tokens.json file

**Raises**:
- `FileNotFoundError`: If tokens file doesn't exist
- `ValueError`: If tokens JSON is invalid

**Example**:
```python
from pathlib import Path
from palexus.design.token_registry import TokenRegistry

registry = TokenRegistry(Path("docs/design-system/tokens.json"))
```

### Methods

#### `load() -> None`

Load and validate tokens from file.

```python
registry.load()
```

**Raises**:
- `FileNotFoundError`: If file not found
- `ValueError`: If schema invalid

---

#### `validate() -> None`

Validate token schema has required sections.

```python
registry.validate()
```

**Raises**:
- `ValueError`: If required sections missing

**Required sections**: `colors`, `typography`, `spacing`, `radius`

---

#### `colors(category: Optional[str] = None) -> Dict[str, Any]`

Get all color tokens or specific category.

```python
# All colors
all_colors = registry.colors()

# Specific category (e.g., "primary", "surface", "text")
primary_colors = registry.colors("primary")
```

**Parameters**:
- `category` (str, optional): Color category to retrieve

**Returns**: Dict mapping color names to values

**Example**:
```python
primary = registry.colors("primary")
# Output: {"50": "#faf8ff", "500": "#cba6f7", "900": "#6a0dad"}
```

---

#### `color(category: str, name: str) -> str`

Get specific color value.

```python
value = registry.color("primary", "500")
# Output: "#cba6f7"
```

**Parameters**:
- `category` (str): Color category
- `name` (str): Color name

**Returns**: Color hex value

**Raises**:
- `KeyError`: If color not found

---

#### `export_css() -> str`

Export tokens as CSS custom properties.

```python
css = registry.export_css()
```

**Returns**: CSS string with `:root { --var-name: value; }`

**Example**:
```
:root {
  --color-primary-50: #faf8ff;
  --color-primary-500: #cba6f7;
  --spacing-md: 16px;
}
```

---

#### `export_shell() -> str`

Export tokens as shell environment variables.

```python
shell = registry.export_shell()
```

**Returns**: Shell script with `EXPORT VAR_NAME=value`

**Example**:
```bash
export COLOR_PRIMARY_50="#faf8ff"
export COLOR_PRIMARY_500="#cba6f7"
export SPACING_MD="16px"
```

---

#### `export_kitty() -> str`

Export tokens for Kitty terminal configuration.

```python
kitty_config = registry.export_kitty()
```

**Returns**: Kitty conf format `color0 = #value`

---

#### `export_xfce() -> str`

Export tokens for XFCE theme.

```python
xfce_theme = registry.export_xfce()
```

**Returns**: XFCE theme XML format

---

### Data Classes

#### `TokenSchema`

Schema for validated token structure.

```python
@dataclass
class TokenSchema:
    version: str
    name: str
    colors: Dict[str, Dict[str, Any]]
    typography: Dict[str, Any]
    spacing: Dict[str, str]
    radius: Dict[str, str]
    shadows: Dict[str, str]
```

---

## GateRegistry

**Module**: `palexus.build.gate_registry`

**Purpose**: Quality verification gates for design system and builds.

### Classes

#### `GateRegistry`

Registry managing 5 quality gates.

**Constructor**

```python
GateRegistry()
```

**Example**:
```python
from palexus.build.gate_registry import GateRegistry

registry = GateRegistry()
```

### Properties

#### `gates: List[Gate]`

List of all available gates.

```python
gates = registry.gates

for gate in gates:
    print(f"{gate.name}: {gate.description}")
```

**Available gates**:
- `Package` - Verify package builds
- `ISO` - Verify ISO image
- `Graphics` - Verify graphics assets
- `Boot` - Verify boot sequence
- `Performance` - Verify performance

---

#### `results: List[Result]`

Results from last gate run.

```python
results = registry.results

for result in results:
    status = "✓" if result.passed else "✗"
    print(f"{status} {result.name}")
```

---

### Methods

#### `run(selected: Optional[List[str]] = None) -> List[Result]`

Run quality gates.

```python
# Run all gates
results = registry.run()

# Run specific gates
results = registry.run(selected=["Package", "Graphics"])
```

**Parameters**:
- `selected` (List[str], optional): Gate names to run. If None, runs all.

**Returns**: List of Result objects

**Example**:
```python
results = registry.run(selected=["Package"])

for result in results:
    if result.passed:
        print(f"✓ {result.name}")
    else:
        print(f"✗ {result.name}: {result.error}")
```

---

### Data Classes

#### `Gate`

Represents a quality verification gate.

```python
@dataclass
class Gate:
    name: str
    description: str
    dependencies: List[str] = field(default_factory=list)
```

**Attributes**:
- `name` (str): Gate identifier
- `description` (str): Human-readable description
- `dependencies` (List[str]): Names of gates that must run first

---

#### `Result`

Result of a gate execution.

```python
@dataclass
class Result:
    name: str
    passed: bool
    error: Optional[str] = None
```

**Attributes**:
- `name` (str): Gate name
- `passed` (bool): Whether gate passed
- `error` (str, optional): Error message if failed

---

## DesktopEnvironment

**Module**: `palexus.desktop.environment`

**Purpose**: Boot sequence orchestration with 5-phase progression.

### Classes

#### `BootPhase` (Enum)

Boot sequence phases in order.

```python
from palexus.desktop.environment import BootPhase

class BootPhase(Enum):
    GREETER = auto()      # 1. Display login
    USER_SELECT = auto()  # 2. Select user
    HUD = auto()          # 3. Initialize HUD
    THEME = auto()        # 4. Apply theme
    COMPLETE = auto()     # 5. Ready
```

---

#### `BootContext`

Manages boot state and progression.

**Constructor**

```python
from palexus.desktop.environment import BootContext

context = BootContext()
```

---

### Methods

#### `advance_phase(phase: BootPhase) -> None`

Move to next boot phase.

```python
context.advance_phase(BootPhase.USER_SELECT)
context.advance_phase(BootPhase.HUD)
```

**Parameters**:
- `phase` (BootPhase): Next phase to enter

**Raises**:
- `ValueError`: If invalid phase transition

---

#### `set_user(user: str) -> None`

Set current user.

```python
context.set_user("alice")
```

**Parameters**:
- `user` (str): Username

---

#### `get_user() -> Optional[str]`

Get current user.

```python
user = context.get_user()
# Output: "alice"
```

**Returns**: Username or None if not set

---

#### `set_theme(theme: str) -> None`

Set UI theme.

```python
context.set_theme("catppuccin-mocha")
```

**Parameters**:
- `theme` (str): Theme name

**Available themes**:
- `catppuccin-mocha` - Dark with Mauve accent
- `catppuccin-latte` - Light with Lavender accent
- `nord` - Arctic blue
- `dracula` - High contrast dark

---

#### `get_theme() -> Optional[str]`

Get current theme.

```python
theme = context.get_theme()
# Output: "catppuccin-mocha"
```

**Returns**: Theme name or None if not set

---

#### `set_hud_enabled(enabled: bool) -> None`

Enable/disable command HUD.

```python
context.set_hud_enabled(True)
```

**Parameters**:
- `enabled` (bool): Whether HUD is active

---

#### `get_hud_status() -> bool`

Get HUD enabled state.

```python
is_enabled = context.get_hud_status()
# Output: True
```

**Returns**: Whether HUD is enabled

---

#### `current_phase: BootPhase` (Property)

Get current boot phase.

```python
phase = context.current_phase
# Output: BootPhase.THEME
```

**Returns**: Current BootPhase

---

#### `DesktopEnvironment`

Main desktop environment orchestrator.

**Constructor**

```python
from palexus.desktop.environment import DesktopEnvironment

env = DesktopEnvironment()
```

---

#### `boot_context: BootContext` (Property)

Access boot context.

```python
context = env.boot_context
# Access context methods
context.set_user("alice")
```

---

## TestOrchestrator

**Module**: `palexus.test.orchestrator`

**Purpose**: Unified test execution (unit, gate, integration).

### Classes

#### `Level` (Enum)

Test execution levels.

```python
from palexus.test.orchestrator import Level

class Level(Enum):
    UNIT = "unit"               # Unit tests
    GATE = "gate"               # Quality gates
    INTEGRATION = "integration" # Integration tests
```

---

#### `TestOrchestrator`

Main test orchestration interface.

**Constructor**

```python
from palexus.test.orchestrator import TestOrchestrator

orchestrator = TestOrchestrator()
```

---

### Methods

#### `run_level(level: Level) -> Optional[List[Result]]`

Run tests at specified level.

```python
# Run unit tests
results = orchestrator.run_level(Level.UNIT)

# Run gate tests
results = orchestrator.run_level(Level.GATE)
```

**Parameters**:
- `level` (Level): Test level to run

**Returns**: List of Result objects or None if level unavailable

---

#### `run_all() -> Optional[List[Result]]`

Run all test levels.

```python
results = orchestrator.run_all()
```

**Returns**: Combined results from all levels

---

#### `summary() -> str`

Get human-readable test summary.

```python
summary = orchestrator.summary()
# Output: "160 tests passed, 0 failed, 2 skipped"
```

**Returns**: Summary string with test counts

---

#### `report_failures() -> List[str]`

Get list of failed tests.

```python
failures = orchestrator.report_failures()

if failures:
    for test_name in failures:
        print(f"Failed: {test_name}")
```

**Returns**: List of failed test names

---

### Data Classes

#### `Suite`

Represents a test suite.

```python
@dataclass
class Suite:
    name: str
    tests: List[str]
    level: Level
```

---

#### `Result`

Test execution result.

```python
@dataclass
class Result:
    name: str
    passed: int
    failed: int
    skipped: int = 0
```

---

## Common Patterns

### Error Handling

```python
# TokenRegistry
try:
    registry = TokenRegistry(Path("tokens.json"))
except FileNotFoundError:
    print("Tokens file not found")
except ValueError as e:
    print(f"Invalid tokens: {e}")

# GateRegistry
results = registry.run()
for result in results:
    if not result.passed:
        print(f"Gate failed: {result.error}")

# DesktopEnvironment
try:
    context.advance_phase(BootPhase.NEXT)
except ValueError:
    print("Invalid phase transition")
```

### Context Managers

```python
# TestOrchestrator context (if supported)
with TestOrchestrator() as orchestrator:
    results = orchestrator.run_all()
    if orchestrator.report_failures():
        print("Tests failed")
```

### Type Hints

All APIs use type hints for IDE support:

```python
from typing import Optional, List, Dict, Any

def colors(self, category: Optional[str] = None) -> Dict[str, Any]:
    ...

def run(self, selected: Optional[List[str]] = None) -> List[Result]:
    ...

def set_user(self, user: str) -> None:
    ...
```

---

## Logging

Each module logs important operations:

```python
import logging

logger = logging.getLogger("palexus.design.token_registry")

logger.info("Loading tokens from %s", tokens_file)
logger.debug("Validating token schema")
logger.warning("Missing optional token category: %s", category)
logger.error("Invalid token format: %s", error)
```

Enable logging:

```python
import logging

logging.basicConfig(level=logging.DEBUG)
```

---

## Exceptions

**Common exceptions**:

```python
# TokenRegistry
FileNotFoundError       # Tokens file not found
ValueError              # Invalid schema or values
KeyError                # Token not found

# GateRegistry
ValueError              # Invalid gate configuration
TypeError               # Wrong argument type

# DesktopEnvironment
ValueError              # Invalid phase or state
AttributeError          # Context attribute not found

# TestOrchestrator
ValueError              # Invalid test level
RuntimeError            # Test execution error
```

---

## Performance Characteristics

| Operation | Typical Time | Notes |
|-----------|--------------|-------|
| `TokenRegistry()` load | 10-50ms | Depends on file size |
| `colors()` lookup | <1ms | In-memory |
| `export_css()` | 5-20ms | Generate string |
| `GateRegistry.run()` | 500ms-2s | Depends on gates |
| `BootContext` operations | <1ms | All in-memory |
| `TestOrchestrator.run_all()` | 5-10s | Full 160 test suite |

---

## Versioning

API versioning follows Semantic Versioning (SemVer):

- **MAJOR**: Breaking API changes
- **MINOR**: New methods/features (backward compatible)
- **PATCH**: Bug fixes, documentation

Current version: **0.1.0**

---

## See Also

- [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md) - Extension patterns
- [examples/](../examples/) - Working code examples
- [ARCHITECTURE.md](ARCHITECTURE.md) - Module design
- [CONTEXT.md](CONTEXT.md) - Domain terminology

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete API reference
