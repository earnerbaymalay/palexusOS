# Integration Guide

Using PalexusOS modules in your own projects.

**Audience**: Developers integrating PalexusOS into other systems  
**Use Cases**: Design systems, build tooling, testing frameworks, boot sequences  

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [TokenRegistry Integration](#tokenregistry-integration)
3. [GateRegistry Integration](#gateregistry-integration)
4. [DesktopEnvironment Integration](#desktopenvironment-integration)
5. [TestOrchestrator Integration](#testorchestrator-integration)
6. [Common Patterns](#common-patterns)
7. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Install PalexusOS

```bash
# Install from PyPI (future)
pip install palexus

# Or from source
pip install git+https://github.com/earnerbaymalay/palexusOS.git
```

### Verify Installation

```python
from palexus.design.token_registry import TokenRegistry
from palexus.build.gate_registry import GateRegistry
from palexus.desktop.environment import DesktopEnvironment
from palexus.test.orchestrator import TestOrchestrator

print("✓ All modules imported successfully")
```

---

## TokenRegistry Integration

### Use Case: Design System in Web App

#### Step 1: Export Tokens to CSS

```python
from pathlib import Path
from palexus.design.token_registry import TokenRegistry

# Load PalexusOS tokens
registry = TokenRegistry(Path("docs/design-system/tokens.json"))

# Export to CSS
css_variables = registry.export_css()

# Write to your app's CSS file
with open("src/styles/tokens.css", "w") as f:
    f.write(css_variables)

print("✓ Tokens exported to src/styles/tokens.css")
```

#### Step 2: Use in Your App

```css
/* src/styles/app.css */

@import "tokens.css";

.button {
  background-color: var(--color-accent-primary);
  color: var(--color-text-primary);
  padding: var(--spacing-md);
  border-radius: var(--radius-md);
  font-size: var(--typography-size-md);
  transition: all var(--transition-normal-fade);
}

.button:hover {
  background-color: var(--color-accent-secondary);
}
```

#### Step 3: Sync on Changes

```bash
# Add to your build process (e.g., Makefile)

tokens:
	python -c "from pathlib import Path; from palexus.design.token_registry import TokenRegistry; registry = TokenRegistry(Path('docs/design-system/tokens.json')); open('src/styles/tokens.css', 'w').write(registry.export_css())"

# Or use pre-commit hook
# .git/hooks/pre-commit:
# python scripts/sync_tokens.py
```

---

### Use Case: CLI Tool Using Tokens

```python
from pathlib import Path
from palexus.design.token_registry import TokenRegistry

def setup_cli_theme():
    """Apply PalexusOS tokens to CLI output."""
    
    registry = TokenRegistry(Path("docs/design-system/tokens.json"))
    
    # Get shell environment variables
    shell_exports = registry.export_shell()
    
    # Source in your shell script
    with open("cli_theme.sh", "w") as f:
        f.write("#!/bin/bash\n")
        f.write(shell_exports)
    
    return "cli_theme.sh"

# Usage:
# source cli_theme.sh
# echo -e "\033[38;5;${COLOR_ACCENT_PRIMARY}m✓ Success\033[0m"
```

---

## GateRegistry Integration

### Use Case: Quality Assurance Pipeline

#### Step 1: Create Custom Gates for Your Project

```python
from palexus.build.gate_registry import GateRegistry, Gate, Result

class CustomGates:
    """Add custom gates to your project."""
    
    @staticmethod
    def create_documentation_gate() -> Gate:
        """Verify documentation is up-to-date."""
        gate = Gate(
            name="Documentation",
            description="Verify docs are current",
            dependencies=["Package"]
        )
        
        def verify():
            # Check if all files documented
            docs = Path("docs/").glob("*.md")
            source = Path("src/").glob("**/*.py")
            
            # Count public functions without docs
            undocumented = count_undocumented_functions()
            
            return Result(
                name="Documentation",
                passed=undocumented == 0,
                error=f"{undocumented} functions lack documentation" if undocumented > 0 else None
            )
        
        gate.verify = verify
        return gate


class MyGateRegistry(GateRegistry):
    """Extended gate registry with custom gates."""
    
    def __init__(self):
        super().__init__()
        
        # Add custom gates
        self.gates.append(CustomGates.create_documentation_gate())
```

#### Step 2: Use in CI/CD Pipeline

```yaml
# .github/workflows/quality.yml

name: Quality Gates

on: [push, pull_request]

jobs:
  gates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: pip install -e .
      
      - name: Run quality gates
        run: |
          python -c "
          from palexus.build.gate_registry import GateRegistry
          registry = GateRegistry()
          results = registry.run()
          
          failed = sum(1 for r in results if not r.passed)
          print(f'\\n{len(results) - failed}/{len(results)} gates passed')
          
          for result in results:
              print(f\"{'✓' if result.passed else '✗'} {result.name}\")
          
          exit(1 if failed > 0 else 0)
          "
```

---

## DesktopEnvironment Integration

### Use Case: Custom OS Installer

#### Step 1: Extend Boot Sequence

```python
from palexus.desktop.environment import (
    DesktopEnvironment, BootPhase, BootContext
)

class CustomInstaller:
    """Custom OS installer using PalexusOS boot sequence."""
    
    def __init__(self):
        self.env = DesktopEnvironment()
        self.context = self.env.boot_context
    
    def run_installation(self):
        """Execute installation with structured boot sequence."""
        
        # Phase 1: Greeter
        self.context.advance_phase(BootPhase.GREETER)
        self.show_welcome_screen()
        
        # Phase 2: User Selection
        self.context.advance_phase(BootPhase.USER_SELECT)
        user = self.ask_for_username()
        self.context.set_user(user)
        
        # Phase 3: HUD Initialization
        self.context.advance_phase(BootPhase.HUD)
        self.context.set_hud_enabled(True)
        self.show_progress_hud()
        
        # Phase 4: Theme Selection
        self.context.advance_phase(BootPhase.THEME)
        theme = self.ask_for_theme()
        self.context.set_theme(theme)
        self.apply_theme(theme)
        
        # Phase 5: Complete
        self.context.advance_phase(BootPhase.COMPLETE)
        self.show_completion_screen()
    
    def show_welcome_screen(self):
        print("Welcome to Custom Installer")
    
    def ask_for_username(self) -> str:
        return input("Enter username: ")
    
    def show_progress_hud(self):
        print("Installation in progress...")
    
    def ask_for_theme(self) -> str:
        return "catppuccin-mocha"
    
    def apply_theme(self, theme: str):
        print(f"Applying theme: {theme}")
    
    def show_completion_screen(self):
        print(f"✓ Installation complete for {self.context.get_user()}")


# Usage:
installer = CustomInstaller()
installer.run_installation()
```

---

## TestOrchestrator Integration

### Use Case: Unified Test Framework

#### Step 1: Integrate with Your Tests

```python
# tests/conftest.py - pytest configuration

import pytest
from palexus.test.orchestrator import TestOrchestrator, Level

@pytest.fixture
def test_orchestrator():
    """Provide test orchestrator to tests."""
    return TestOrchestrator()


# tests/test_myapp.py

def test_integration_with_palexus(test_orchestrator):
    """Example test using orchestrator."""
    
    # Run PalexusOS tests
    results = test_orchestrator.run_level(Level.UNIT)
    
    # Verify they all pass
    assert results is not None
    assert all(r.passed for r in results)
```

#### Step 2: Run Tests with Reports

```bash
# Run all tests
python -m pytest tests/

# Generate test report
python -c "
from palexus.test.orchestrator import TestOrchestrator

orchestrator = TestOrchestrator()
orchestrator.run_all()

summary = orchestrator.summary()
print(f'\\n{summary}')

failures = orchestrator.report_failures()
if failures:
    print(f'\\nFailed tests: {failures}')
    exit(1)
"
```

---

## Common Patterns

### Pattern 1: Multi-Project Token Sharing

```python
# shared/tokens.py

from pathlib import Path
from palexus.design.token_registry import TokenRegistry

# Central token source
_registry = None

def get_registry():
    """Singleton registry for token sharing."""
    global _registry
    
    if _registry is None:
        tokens_file = Path(__file__).parent / "design-system" / "tokens.json"
        _registry = TokenRegistry(tokens_file)
    
    return _registry


# app1/styles.py - Project 1
from shared.tokens import get_registry

registry = get_registry()
app1_css = registry.export_css()


# app2/cli_theme.sh - Project 2
# source <(python -c "from shared.tokens import get_registry; print(get_registry().export_shell())")
```

---

### Pattern 2: Gate Chain (Dependency Management)

```python
# build/gates.py

from palexus.build.gate_registry import GateRegistry

registry = GateRegistry()

# Gates with dependencies automatically order themselves:
# 1. Package (no dependencies)
# 2. Graphics (depends: Package)
# 3. ISO (depends: Package)
# 4. Boot (depends: Graphics)
# 5. Performance (depends: Boot)

# Run in order:
results = registry.run()

# Or run specific ones (dependencies still respected):
results = registry.run(selected=["ISO"])  # Will run Package first
```

---

### Pattern 3: Isolated Environments

```python
# Each project gets its own context:

# Project A:
context_a = BootContext()
context_a.set_user("alice")
context_a.set_theme("catppuccin-mocha")

# Project B (independent):
context_b = BootContext()
context_b.set_user("bob")
context_b.set_theme("nord")

# Changes to A don't affect B:
assert context_a.get_user() == "alice"
assert context_b.get_user() == "bob"
```

---

## Troubleshooting

### "Import fails: Module not found"

```bash
# Check installation
pip show palexus

# Install if missing
pip install -e git+https://github.com/earnerbaymalay/palexusOS.git

# Verify imports
python -c "from palexus.design.token_registry import TokenRegistry; print('✓')"
```

---

### "TokenRegistry can't find tokens file"

```python
from pathlib import Path
from palexus.design.token_registry import TokenRegistry

# Make sure path is absolute and correct:
tokens_file = Path("/absolute/path/to/tokens.json")

# Or relative to project root:
tokens_file = Path.cwd() / "docs/design-system/tokens.json"

print(f"Looking for: {tokens_file}")
print(f"Exists: {tokens_file.exists()}")

registry = TokenRegistry(tokens_file)
```

---

### "Gates don't run in dependency order"

```python
from palexus.build.gate_registry import GateRegistry

registry = GateRegistry()

# Check dependency ordering:
for gate in registry.gates:
    print(f"{gate.name}: depends on {gate.dependencies}")

# Expected order:
# Package: depends on []
# ISO: depends on [Package]
# Graphics: depends on [Package]
# Boot: depends on [Graphics]
# Performance: depends on [Boot]
```

---

### "Boot phases fail to advance"

```python
from palexus.desktop.environment import BootContext, BootPhase

context = BootContext()

print(f"Current: {context.current_phase}")

# Phases must advance in order:
valid_sequence = [
    BootPhase.GREETER,
    BootPhase.USER_SELECT,
    BootPhase.HUD,
    BootPhase.THEME,
    BootPhase.COMPLETE,
]

for phase in valid_sequence:
    context.advance_phase(phase)
    print(f"✓ Advanced to {context.current_phase}")
```

---

## Best Practices

### 1. Version Locking

```toml
# pyproject.toml or requirements.txt
palexus>=0.1.0,<1.0.0  # Range for security updates
# NOT palexus or palexus>=0.1.0 (unbounded)
```

### 2. Error Handling

```python
# Always handle potential errors
from palexus.design.token_registry import TokenRegistry
from pathlib import Path

try:
    registry = TokenRegistry(Path("tokens.json"))
except FileNotFoundError:
    print("tokens.json not found - using defaults")
    registry = None
except ValueError as e:
    print(f"Invalid tokens: {e}")
    exit(1)
```

### 3. Explicit Dependencies

```python
# Document what you're using:
from palexus.design.token_registry import TokenRegistry  # For token export
from palexus.build.gate_registry import GateRegistry    # For quality gates

# Not: from palexus import *  (what are you using?)
```

### 4. Local Testing

```bash
# Before shipping, test integration locally:

# 1. Install in development
pip install -e .

# 2. Run tests
make test

# 3. Try integration
python scripts/test_integration.py

# 4. Verify exports
python -c "from palexus.design.token_registry import TokenRegistry; ..."
```

---

## Example: Complete Integration

See [GETTING_STARTED_TUTORIAL.md](GETTING_STARTED_TUTORIAL.md) for a complete, working example showing all 4 modules integrated together.

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete integration guide
