# Desktop look audit: themes, login screen, default user settings

- **Scope:** `packages/desktop/palexus-themes`, `packages/desktop/palexus-greeter`, `overlay/etc/skel`, `overlay/etc/sddm.conf.d`, `overlay/etc/xdg`
- **Branch:** `desktop-look-fixes` from `main` @ `17814cf`. Audited 2026-11-12.
- **Out of scope:** the boot screen and first-boot wizard are covered by `docs/BOOT_FIRSTBOOT_AUDIT.md`.

**Evidence tags:**
- **[verified]**: checked against repo package databases or by running the code
- **[read]**: from the code
- **[VM]**: needs a real session to confirm

## In plain words

1. **Changing the theme on Sway probably doesn't change the wallpaper.** The Sway config starts its own Mauve wallpaper on top of the one the theme switcher controls.
2. **Changing the theme leaves half the desktop Mauve.** Window borders and the whole top bar are hard-coded to Mauve; only the wallpaper, terminal and launcher follow the theme.
3. **The login screen can't switch users.** It always signs in as the last (or first) account.
4. **The login cursor theme doesn't exist** in any repo the ISO uses.
5. **Two XFCE shortcuts do nothing:** Alt+F1 and Ctrl+Alt+Esc.
6. **The "zero-telemetry" Chromium flags** include two that Chromium doesn't recognise, and one that switches off security updates (certificate revocation lists).

## Findings

| # | Problem | Evidence |
|---|---|---|
| L1 | ❌ Sway runs `exec swaybg -i …monolith-mauve…` in addition to `output * bg`. `palexus-theme` only updates Sway's managed background (`swaymsg output * bg`), so the extra swaybg probably stays on top and theme changes look like they do nothing. | [read]+[VM] `skel/.config/sway/config:32-35`, `palexus-theme:122-124` |
| L2 | ❌ Sway `client.*` colours and every Waybar colour are fixed to Mauve (`#cba6f7`). `palexus-theme` writes only Kitty and Rofi palettes and the wallpaper. | [read] `sway/config:45-50`, `waybar/style.css`, `palexus-theme:148-203` |
| L3 | ❌ The greeter's username comes from config or the last user, falling back to the first account, and there is no control to change it. A second account can't log in from the graphical greeter. | [read] `palexus-greeter/Main.qml:31,47-55,344` |
| L4 | ❌ `CursorTheme=Catppuccin-Mocha-Mauve-Cursors`: no such package in Arch, CachyOS or `packages.x86_64`; SDDM silently falls back. | [verified] Arch package search plus CachyOS repo DBs. `sddm.conf.d/10-palexusos.conf:7` |
| L5 | ❌ XFCE Alt+F1 runs `/usr/local/bin/xfce-launcher-toggle`, which exists nowhere in the repo. Ctrl+Alt+Esc runs `xkill`, but `xorg-xkill` is not on the ISO. | [verified] `git grep`, `packages.x86_64`. `xfce4-keyboard-shortcuts.xml:60,66` |
| L6 | ⚠️ `chromium-flags.conf`: `--disable-telemetry` and `--disable-metrics` are not Chromium switches. `--disable-component-update` also stops CRLSet (certificate revocation) and other security component updates, against the security-first directive. | [read] `skel/.config/chromium-flags.conf` |
| L7 | ⚠️ The greeter only follows a theme change after `palexus-theme --sync-greeter`, which asks for the admin password each time. Nothing calls it from the theme menu. | [read] `palexus-theme:229-233` |
| L8 | ⚠️ `picom.conf` (blur, rounded corners, shadows) ships, but nothing starts picom. XFCE uses xfwm4's own compositor, so the installer slideshow's "dual-kawase blur" isn't what users get. | [read] `git grep picom` |
| L9 | ⚠️ XFCE Alt+Super+S runs `orca` (XFCE default), but no screen reader is installed. | [read] `xfce4-keyboard-shortcuts.xml:55` |

**Working as intended ✅:** 14 wallpapers all exist and are checksummed. The theme ids match the first-boot helper's allow-list (no monolith-crimson, by design). The greeter falls back to the Mauve wallpaper if one is missing, handles failed logins (clears the field, shakes, refocuses), warns about Caps Lock, has F-key session switching, and labels the password field for screen readers. All fonts used (JetBrains Mono Nerd, Noto) ship on the ISO.

## Decisions for you

- **L7:** sync the login screen automatically when you change theme (one admin-password prompt), keep it manual, or drop per-user greeter theming?
- **L8:** start picom (prettier, but its GLX backend can show a black screen in some VMs), or remove `picom.conf` and the blur claim?
- **L9:** ship `orca` (screen reader, ~10 MB with deps), or unbind the shortcut?

## Progress

| # | Status | Proven by |
|---|---|---|
| L1 | ✅ second swaybg removed. VM check: confirm the wallpaper changes on Sway. | gate "Sway runs no second swaybg", `test_iso_profile.py` |
| L2 | ✅ Waybar imports `theme-colors.css` written by `palexus-theme`; Sway borders follow via `swaymsg` | `tests/test_palexus_theme.py` (5 tests), 3 gates |
| L3 | ✅ editable login name; Up/Down cycles accounts | `tests/test_greeter.py` (3 offscreen QML tests; they fail on the old greeter), gate |
| L4 | ✅ phantom cursor theme removed | gate |
| L5 | ✅ Alt+F1 opens the applications menu; `xorg-xkill` added to the ISO | 2 gates |
| L6 | ✅ fake and security-weakening Chromium flags removed from both flag files; FAQ corrected | 2 gates |
| L7–L9 | open: decisions for you (above) | — |

On a clean Linux clone this branch passes 302/302 gates. Merged with `boot-firstboot-fixes`, the result passes 309/309 gates, 63/63 pytest and ShellCheck.
