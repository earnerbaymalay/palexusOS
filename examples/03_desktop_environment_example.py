#!/usr/bin/env python3
"""DesktopEnvironment: run the boot sequence and inspect the boot context.

The adapters stand in for the real greeter, HUD and theme loader binaries:
they advance the phase and fill in the context, but launch nothing.

Run from anywhere:  python examples/03_desktop_environment_example.py
"""

from pathlib import Path

from palexus.desktop.environment import BootContext, BootPhase, DesktopEnvironment

TOKENS = Path(__file__).resolve().parent.parent / "docs" / "design-system" / "tokens.json"


def describe(context: BootContext) -> str:
    return (
        f"phase={context.phase.value} user={context.selected_user} "
        f"theme={context.selected_theme} hud={context.hud_enabled}"
    )


def default_boot() -> None:
    print("== Default boot ==")
    env = DesktopEnvironment()
    print("before:", describe(env.context))
    # boot() runs greeter -> HUD -> theme. The greeter picks the user and
    # moves straight to the HUD phase; USER_SELECT is not used yet.
    context = env.boot()
    print("after: ", describe(context))
    print("hud:   ", env.hud_interface())
    assert context.phase == BootPhase.COMPLETE


def boot_without_hud() -> None:
    print("\n== Boot with the HUD disabled ==")
    env = DesktopEnvironment()
    env.context.hud_enabled = False
    # With the HUD off, the HUD adapter jumps to COMPLETE and the theme step is skipped.
    print("after: ", describe(env.boot()))
    print("hud:   ", env.hud_interface())


def custom_tokens() -> None:
    print("\n== Point the theme loader at a token file ==")
    env = DesktopEnvironment()
    print("default:", env.theme_loader())
    env.set_design_tokens(TOKENS)
    print("custom: ", env.theme_loader())


def reboot() -> None:
    print("\n== Reset between sessions ==")
    env = DesktopEnvironment()
    env.boot()
    print("booted:", describe(env.context))
    env.reset()
    print("reset: ", describe(env.context))
    print("adapters self-test:", env.test_adapters())


def main() -> None:
    default_boot()
    boot_without_hud()
    custom_tokens()
    reboot()


if __name__ == "__main__":
    main()
