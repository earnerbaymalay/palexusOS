# Community Examples & Use Cases

Real-world usage patterns for PalexusOS modules.

**Audience**: Developers integrating PalexusOS into their projects  
**Purpose**: Show practical applications and inspire contributions  

---

## Table of Contents

1. [Design System Integration](#design-system-integration)
2. [CLI Tool Development](#cli-tool-development)
3. [Quality Gates in CI/CD](#quality-gates-in-cicd)
4. [Custom Boot Sequences](#custom-boot-sequences)
5. [Testing Frameworks](#testing-frameworks)
6. [Contribute Your Example](#contribute-your-example)

---

## Design System Integration

### Use Case: Figma → CSS Sync

**Problem**: Design tokens in Figma are out of sync with CSS in production.

**Solution**: Use TokenRegistry to export tokens to CSS and validate them in CI.

```python
# scripts/sync_design_system.py

from pathlib import Path
from palexus.design.token_registry import TokenRegistry

def sync_figma_to_css():
    """Sync Figma tokens to CSS (after fetching from Figma API)."""
    
    # Load tokens (normally fetched from Figma first)
    registry = TokenRegistry(Path("design-tokens.json"))
    
    # Export to CSS
    colors = registry.colors()
    css_lines = [":root {"]
    
    for category, values in colors.items():
        for name, color in values.items():
            var_name = f"--color-{category}-{name}".lower()
            css_lines.append(f"  {var_name}: {color};")
    
    css_lines.append("}")
    
    css_output = "\n".join(css_lines)
    
    # Write to app
    output_file = Path("app/styles/design-tokens.css")
    output_file.write_text(css_output)
    
    print(f"✓ Exported {len(colors)} color categories to {output_file}")

if __name__ == "__main__":
    sync_figma_to_css()
```

**Result**: Design changes in Figma automatically reflect in CSS build.

---

### Use Case: Multi-Brand Token Management

**Problem**: SaaS product with multiple brand themes (white-label support).

**Solution**: Load different token sets for different brands.

```python
# config/themes.py

from pathlib import Path
from palexus.design.token_registry import TokenRegistry

class ThemeManager:
    """Manage multiple brand token sets."""
    
    def __init__(self):
        self.themes = {}
        self.load_themes()
    
    def load_themes(self):
        """Load all available themes."""
        themes_dir = Path("design-system/themes")
        
        for theme_file in themes_dir.glob("*.json"):
            theme_name = theme_file.stem
            self.themes[theme_name] = TokenRegistry(theme_file)
    
    def get_theme(self, brand_id: str) -> TokenRegistry:
        """Get tokens for a specific brand."""
        # Map brand_id to theme
        theme_map = {
            "acme": "acme-blue",
            "widgets-inc": "widgets-green",
            "default": "default",
        }
        
        theme_name = theme_map.get(brand_id, "default")
        return self.themes[theme_name]
    
    def export_for_brand(self, brand_id: str, format: str = "css"):
        """Export theme tokens for a brand."""
        registry = self.get_theme(brand_id)
        
        if format == "css":
            return self.export_css(registry)
        elif format == "json":
            return self.export_json(registry)
        elif format == "javascript":
            return self.export_javascript(registry)
    
    def export_css(self, registry):
        """Export as CSS variables."""
        lines = [":root {"]
        for color_cat, colors in registry.colors().items():
            for name, value in colors.items():
                lines.append(f"  --{color_cat}-{name}: {value};")
        lines.append("}")
        return "\n".join(lines)

# Usage:
manager = ThemeManager()
acme_css = manager.export_for_brand("acme", format="css")
print(acme_css)
```

**Result**: Each brand gets its own token set without code duplication.

---

## CLI Tool Development

### Use Case: Tokens CLI

**Problem**: Designers want to export tokens without touching code.

**Solution**: Build a CLI around TokenRegistry.

```python
# palexus_cli/commands/tokens.py

import click
from pathlib import Path
from palexus.design.token_registry import TokenRegistry

@click.group()
def tokens():
    """Manage design tokens."""
    pass

@tokens.command()
@click.option("--format", type=click.Choice(["css", "json", "js"]), default="css")
@click.option("--output", type=click.Path(), required=True)
@click.argument("token-file")
def export(format, output, token_file):
    """Export tokens to specified format."""
    
    registry = TokenRegistry(Path(token_file))
    
    if format == "css":
        content = export_css(registry)
    elif format == "json":
        content = export_json(registry)
    elif format == "js":
        content = export_javascript(registry)
    
    Path(output).write_text(content)
    click.echo(f"✓ Exported to {output}")

@tokens.command()
@click.argument("token-file")
def validate(token_file):
    """Validate token file schema."""
    
    try:
        registry = TokenRegistry(Path(token_file))
        click.echo("✓ Token file is valid")
        
        # Show summary
        colors = len(registry.colors())
        typography = len(registry.typography())
        spacing = len(registry.spacing())
        
        click.echo(f"  Colors: {colors}")
        click.echo(f"  Typography entries: {typography}")
        click.echo(f"  Spacing values: {spacing}")
        
    except Exception as e:
        click.echo(f"✗ Validation failed: {e}", err=True)

# CLI usage:
# palexus-cli tokens export --format css --output styles.css tokens.json
# palexus-cli tokens validate tokens.json
```

**Result**: Non-technical users can manage tokens via CLI.

---

## Quality Gates in CI/CD

### Use Case: Monorepo Gate Chain

**Problem**: Large monorepo with multiple packages; need to verify each one.

**Solution**: Use GateRegistry to create a custom gate chain.

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
        run: python scripts/run_gates.py
```

```python
# scripts/run_gates.py

from pathlib import Path
from palexus.build.gate_registry import GateRegistry

def main():
    registry = GateRegistry()
    
    # Run all gates
    results = registry.run(repo_root=Path('.'))
    
    # Format results
    print("\n" + "="*60)
    print("Quality Gates Report")
    print("="*60 + "\n")
    
    passed = []
    failed = []
    
    for gate_name, result in results.items():
        if result:  # Some gates may return None
            status = "✓" if getattr(result, 'passed', True) else "✗"
            print(f"{status} {gate_name}")
            
            if getattr(result, 'passed', True):
                passed.append(gate_name)
            else:
                failed.append(gate_name)
                if hasattr(result, 'error') and result.error:
                    print(f"  Error: {result.error}")
    
    # Summary
    print("\n" + "="*60)
    print(f"Summary: {len(passed)} passed, {len(failed)} failed")
    print("="*60 + "\n")
    
    return 1 if failed else 0

if __name__ == "__main__":
    exit(main())
```

**Result**: Automated quality verification on every push.

---

## Custom Boot Sequences

### Use Case: Installer Boot

**Problem**: Custom OS installer needs a structured boot sequence.

**Solution**: Extend DesktopEnvironment with custom phases.

```python
# installer/boot.py

from palexus.desktop.environment import DesktopEnvironment, BootPhase, BootContext

class InstallerBootSequence:
    """Custom boot sequence for OS installer."""
    
    def __init__(self):
        self.env = DesktopEnvironment()
        self.context = self.env.boot_context
    
    def run_installer(self):
        """Execute installation in structured phases."""
        
        # Phase 1: Welcome
        self.context.advance_phase(BootPhase.GREETER)
        self.show_welcome_screen()
        
        # Phase 2: User setup
        self.context.advance_phase(BootPhase.USER_SELECT)
        username = self.prompt_username()
        self.context.set_user(username)
        
        # Phase 3: Partitioning (using HUD)
        self.context.advance_phase(BootPhase.HUD)
        self.context.set_hud_enabled(True)
        self.show_partition_progress()
        
        # Phase 4: Theme selection
        self.context.advance_phase(BootPhase.THEME)
        theme = self.select_theme()
        self.context.set_theme(theme)
        self.apply_theme(theme)
        
        # Phase 5: Complete
        self.context.advance_phase(BootPhase.COMPLETE)
        self.show_success_screen()
    
    def show_welcome_screen(self):
        print("Welcome to PalexusOS Installer")
    
    def prompt_username(self) -> str:
        return input("Enter username: ")
    
    def show_partition_progress(self):
        print("Partitioning disk...")
    
    def select_theme(self) -> str:
        print("1. Catppuccin Mocha (default)")
        print("2. Nord")
        choice = input("Select theme: ")
        return "catppuccin-mocha" if choice == "1" else "nord"
    
    def apply_theme(self, theme: str):
        print(f"Applying theme: {theme}")
    
    def show_success_screen(self):
        print(f"✓ Installation complete for {self.context.get_user()}")
        print(f"✓ Theme: {self.context.get_theme()}")

# Usage:
if __name__ == "__main__":
    installer = InstallerBootSequence()
    installer.run_installer()
```

**Result**: Installer follows a structured, debuggable sequence.

---

## Testing Frameworks

### Use Case: Multi-Level Test Pyramid

**Problem**: Different types of tests need different environments and speeds.

**Solution**: Use TestOrchestrator for a complete test pyramid.

```python
# tests/conftest.py

import pytest
from palexus.test.orchestrator import TestOrchestrator, Level

@pytest.fixture
def orchestrator():
    """Provide test orchestrator to tests."""
    return TestOrchestrator()

# tests/test_e2e.py

def test_complete_workflow(orchestrator):
    """E2E test: token export → CSS generation → app rendering."""
    
    # 1. Load tokens
    from palexus.design.token_registry import TokenRegistry
    from pathlib import Path
    
    registry = TokenRegistry(Path("design-system/tokens.json"))
    assert registry.colors() is not None
    
    # 2. Run gates
    gate_results = registry.validate()
    assert gate_results.passed
    
    # 3. Boot system
    from palexus.desktop.environment import DesktopEnvironment, BootPhase
    
    env = DesktopEnvironment()
    context = env.boot_context
    context.advance_phase(BootPhase.GREETER)
    context.advance_phase(BootPhase.USER_SELECT)
    context.set_user("test-user")
    
    # 4. Assert final state
    assert context.get_user() == "test-user"

# tests/test_integration.py

def test_module_integration(orchestrator):
    """Integration test: verify modules work together."""
    
    results = orchestrator.run_level(Level.INTEGRATION)
    assert all(r.passed for r in results)
```

**Result**: Tests organized by scope and execution speed.

---

## Contributing Your Example

Have a use case or pattern you've built with PalexusOS? We'd love to include it!

### Process

1. **Write your example** (100-200 lines of well-commented code)
2. **Add context** (problem, solution, result)
3. **Test it** (make sure it actually works)
4. **Submit a PR** to `docs/COMMUNITY_EXAMPLES.md`

### Template

```markdown
### Use Case: [Your Use Case]

**Problem**: What problem does this solve?

**Solution**: How does PalexusOS help?

\`\`\`python
# Your code example
\`\`\`

**Result**: What can users do with this?
```

---

## Ideas for Contributions

Looking for use cases to implement? Consider:

- **Web frameworks** (Next.js, Django, FastAPI token integration)
- **Design tools** (Figma plugin, Adobe XD integration)
- **CMS platforms** (Contentful, Strapi token sync)
- **Static site generators** (Hugo, Jekyll token support)
- **Mobile development** (React Native, Flutter token support)
- **Performance monitoring** (token size tracking, export benchmarking)
- **Accessibility testing** (contrast ratio validation, semantic verification)
- **Multi-language support** (token localization, RTL support)

---

## See Also

- [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) — Integration patterns
- [examples/01-04_*.py](../examples/) — Complete working examples
- [GETTING_STARTED_TUTORIAL.md](GETTING_STARTED_TUTORIAL.md) — Real workflow
- [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md) — Extension patterns

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete community examples guide
