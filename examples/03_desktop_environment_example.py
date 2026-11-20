#!/usr/bin/env python3
"""Example: Using DesktopEnvironment for boot sequence orchestration.

This example demonstrates how to use DesktopEnvironment and BootContext
to manage the 5-phase boot sequence: GREETER → USER_SELECT → HUD → THEME → COMPLETE.
"""

from palexus.desktop.environment import DesktopEnvironment, BootPhase, BootContext


def example_boot_phases():
    """Show the 5-phase boot sequence."""
    print("=" * 60)
    print("PalexusOS 5-Phase Boot Sequence")
    print("=" * 60)

    phases = [
        (BootPhase.GREETER, "Display login greeter"),
        (BootPhase.USER_SELECT, "User selects account"),
        (BootPhase.HUD, "Initialize command HUD"),
        (BootPhase.THEME, "Apply theme & colors"),
        (BootPhase.COMPLETE, "Boot sequence complete"),
    ]

    print("\nBoot Phases (in order):")
    for i, (phase, description) in enumerate(phases, 1):
        print(f"  {i}. {phase.name:15} - {description}")


def example_boot_context_lifecycle():
    """Demonstrate BootContext lifecycle and state management."""
    print("\n" + "=" * 60)
    print("BootContext Lifecycle")
    print("=" * 60)

    context = BootContext()

    print(f"\nInitial phase: {context.current_phase.name}")

    # Collect user information
    print("\nPhase 1: GREETER")
    print("  → Displaying login screen...")
    context.advance_phase(BootPhase.USER_SELECT)
    print(f"  → Advanced to: {context.current_phase.name}")

    # User selection
    print("\nPhase 2: USER_SELECT")
    print("  → User 'alice' selected...")
    context.set_user("alice")
    print(f"  → Current user: {context.get_user()}")
    context.advance_phase(BootPhase.HUD)
    print(f"  → Advanced to: {context.current_phase.name}")

    # Initialize HUD
    print("\nPhase 3: HUD")
    print("  → Initializing command HUD...")
    context.set_hud_enabled(True)
    print(f"  → HUD enabled: {context.get_hud_status()}")
    context.advance_phase(BootPhase.THEME)
    print(f"  → Advanced to: {context.current_phase.name}")

    # Apply theme
    print("\nPhase 4: THEME")
    print("  → Applying theme 'catppuccin-mocha'...")
    context.set_theme("catppuccin-mocha")
    print(f"  → Current theme: {context.get_theme()}")
    context.advance_phase(BootPhase.COMPLETE)
    print(f"  → Advanced to: {context.current_phase.name}")

    # Complete
    print("\nPhase 5: COMPLETE")
    print("  → Boot sequence complete!")
    print(f"  → System ready for user: {context.get_user()}")


def example_desktop_environment_creation():
    """Create and configure a DesktopEnvironment."""
    print("\n" + "=" * 60)
    print("Creating DesktopEnvironment")
    print("=" * 60)

    env = DesktopEnvironment()

    print(f"\nDesktop Environment created")
    print(f"  → Type: {type(env).__name__}")

    # Show environment properties
    context = env.boot_context
    print(f"\nBoot Context Properties:")
    print(f"  → Current phase: {context.current_phase.name}")
    print(f"  → User: {context.get_user() or '(none)'}")
    print(f"  → Theme: {context.get_theme() or '(none)'}")
    print(f"  → HUD enabled: {context.get_hud_status()}")


def example_theme_management():
    """Manage themes during boot sequence."""
    print("\n" + "=" * 60)
    print("Theme Management")
    print("=" * 60)

    context = BootContext()

    # Available themes
    themes = [
        ("catppuccin-mocha", "Dark theme with Mauve accent"),
        ("catppuccin-latte", "Light theme with Lavender accent"),
        ("nord", "Arctic blue theme"),
        ("dracula", "High contrast dark theme"),
    ]

    print("\nAvailable Themes:")
    for theme_name, description in themes:
        print(f"  - {theme_name:20} {description}")

    # Apply different themes
    print("\nTheme Application:")

    for theme_name, _ in themes[:3]:
        context.set_theme(theme_name)
        print(f"  → Applied: {context.get_theme()}")


def example_hud_initialization():
    """Initialize and manage the command HUD."""
    print("\n" + "=" * 60)
    print("Command HUD Initialization")
    print("=" * 60)

    context = BootContext()

    print("\nHUD Status:")
    print(f"  → Initial: {context.get_hud_status()}")

    # Enable HUD
    context.set_hud_enabled(True)
    print(f"  → After enable: {context.get_hud_status()}")

    # Configure HUD settings
    hud_config = {
        "position": "top-right",
        "opacity": 0.95,
        "font_size": 12,
        "theme": "catppuccin-mocha",
    }

    print("\nHUD Configuration:")
    for key, value in hud_config.items():
        print(f"  - {key}: {value}")

    # Disable HUD
    context.set_hud_enabled(False)
    print(f"\n  → After disable: {context.get_hud_status()}")


def example_multi_user_boot():
    """Demonstrate multi-user boot scenarios."""
    print("\n" + "=" * 60)
    print("Multi-User Boot Scenarios")
    print("=" * 60)

    users = ["alice", "bob", "charlie"]

    for user in users:
        print(f"\nBooting for user: {user}")

        context = BootContext()
        context.advance_phase(BootPhase.USER_SELECT)
        context.set_user(user)

        # Customize for user
        if user == "alice":
            theme = "catppuccin-mocha"
        elif user == "bob":
            theme = "catppuccin-latte"
        else:
            theme = "nord"

        context.set_theme(theme)
        context.advance_phase(BootPhase.HUD)
        context.set_hud_enabled(True)
        context.advance_phase(BootPhase.THEME)
        context.advance_phase(BootPhase.COMPLETE)

        print(f"  ✓ Boot complete")
        print(f"    - User: {context.get_user()}")
        print(f"    - Theme: {context.get_theme()}")
        print(f"    - HUD: {'enabled' if context.get_hud_status() else 'disabled'}")


def example_boot_error_handling():
    """Demonstrate error handling during boot."""
    print("\n" + "=" * 60)
    print("Boot Error Handling")
    print("=" * 60)

    context = BootContext()

    print("\nScenario 1: Invalid phase transition")
    print(f"  Current phase: {context.current_phase.name}")

    try:
        # Try to go backwards (should handle gracefully)
        context.current_phase = BootPhase.GREETER
        context.advance_phase(BootPhase.GREETER)
        print(f"  → Handled gracefully")
    except Exception as e:
        print(f"  → Error: {e}")

    print("\nScenario 2: Missing user during boot")
    print(f"  Current phase: {context.current_phase.name}")

    if context.get_user() is None:
        print(f"  ⚠️  No user set, using default")
        context.set_user("guest")

    print(f"  → User: {context.get_user()}")

    print("\nScenario 3: Recovery from theme error")
    print(f"  Setting invalid theme...")
    context.set_theme("nonexistent-theme")

    if context.get_theme() == "nonexistent-theme":
        print(f"  ⚠️  Theme not found, reverting to default")
        context.set_theme("catppuccin-mocha")

    print(f"  → Current theme: {context.get_theme()}")


def example_boot_performance():
    """Demonstrate boot sequence performance."""
    print("\n" + "=" * 60)
    print("Boot Performance")
    print("=" * 60)

    import time

    context = BootContext()

    print("\nBoot Phase Timing:")

    phases = [
        BootPhase.GREETER,
        BootPhase.USER_SELECT,
        BootPhase.HUD,
        BootPhase.THEME,
        BootPhase.COMPLETE,
    ]

    start = time.time()

    for phase in phases:
        phase_start = time.time()

        # Simulate phase execution
        context.advance_phase(phase)
        time.sleep(0.01)  # Minimal delay

        phase_time = (time.time() - phase_start) * 1000  # Convert to ms
        print(f"  → {phase.name:15} {phase_time:6.2f} ms")

    total_time = (time.time() - start) * 1000  # Convert to ms
    print(f"\n  Total boot time: {total_time:6.2f} ms")


if __name__ == "__main__":
    print("PalexusOS DesktopEnvironment Examples\n")

    # Example 1: Boot phases
    print("1. Boot Phases")
    example_boot_phases()

    # Example 2: Context lifecycle
    print("\n2. BootContext Lifecycle")
    example_boot_context_lifecycle()

    # Example 3: Create environment
    print("\n3. Create DesktopEnvironment")
    example_desktop_environment_creation()

    # Example 4: Theme management
    print("\n4. Theme Management")
    example_theme_management()

    # Example 5: HUD initialization
    print("\n5. HUD Initialization")
    example_hud_initialization()

    # Example 6: Multi-user boot
    print("\n6. Multi-User Boot")
    example_multi_user_boot()

    # Example 7: Error handling
    print("\n7. Error Handling")
    example_boot_error_handling()

    # Example 8: Performance
    print("\n8. Boot Performance")
    example_boot_performance()

    print("\n" + "=" * 60)
    print("✅ All examples completed successfully!")
    print("=" * 60)
