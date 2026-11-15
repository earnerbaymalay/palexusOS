# PalexusOS design audit

**Checked:** `main` at `d31a39c`, 16 November 2026. This is a read-only review: nothing was changed.

**Covered:** the login screen (`palexus-greeter/Main.qml`), the Command HUD (`palexus-hud/Main.qml`, `CommandCategoryCard.qml`), the first-boot wizard (`palexus-hud/Welcome.qml`), and the Waybar, Rofi and GTK styles in `overlay/etc/skel/.config/`.

**Method:** three of the newly installed skills, run against the source.
- `design-token-audit`
- `accessibility-audit` (WCAG 2.2)
- `ux-writing`

Contrast ratios were computed with the WCAG formula. Nothing has been checked on a running system yet; that needs the VM.

## Summary

| Area | Verdict |
|---|---|
| First-boot wizard | **Good.** 62 accessibility labels, full keyboard paths, honours reduced motion, plain copy. The model for the other screens. |
| Command HUD | **Weakest.** No screen-reader labels. Commands can only be clicked, not reached by Tab or arrow keys. Small grey text fails contrast. |
| Login screen | Works by keyboard and has labels, but uses jargon copy ("AUTH GATE", "operator username"). 7 animations loop forever, and the only way to stop them is a theme config value. |
| Colours and type | No shared source. Each screen defines its own palette, so the same role has different values. 17 different font sizes. |
| Translation | **Not possible today.** Not one string uses `qsTr()`. |

## 1. Tokens: colours and type

There is no single palette. The nearest thing to one is the theme table in `packages/desktop/palexus-themes/palexus-theme` (for example `monolith-mauve|…|#09090d|#181825|#cba6f7|#cdd6f4`). The QML screens and CSS files each copy values by hand.

| Role | Greeter | HUD | Wizard | GTK/Waybar |
|---|---|---|---|---|
| Main text | `#cdd6f4` | `#cdd6f4` | `#f5f5fc` | `#cdd6f4` |
| Secondary text | `#bac2de` | `#a6adc8` | `#bac2de` | — |
| Muted text | `#7f849c` | `#6c7086` | `#8990b3` | `#6c7086` |
| Darkest background | `#07070b` | `#11111b` | `Qt.rgba(13,12,20)` | `#11111b` / `#050508` |

The counts:
- **106** hard-coded hex colours across 8 files, with 30+ distinct values.
- `CommandCategoryCard.qml` ignores the HUD's own palette properties and hard-codes `#cdd6f4`, `#ffffff` and `#6c7086` inline (lines 87, 95).

There are **17 font sizes** in QML, including fractional ones: 10, 10.5, 11, 11.5, 12, 12.5, 13, 14, 15, 16, 17, 30, 36, 64. Half-pixel sizes render blurry on non-HiDPI screens, and the spread shows there is no type scale.

The accent switcher (`accents[variant.split("-").pop()]`) is copied in three files. If they drift apart, the login screen and the desktop show different accents.

**What to do:**
1. Add one token file, `packages/desktop/palexus-themes/tokens.json`, with these roles: `bg.base`, `bg.surface`, `bg.raised`, `text.main`, `text.sub`, `text.muted`, `line`, `accent.*`, `status.ok/warn/error`, and a type scale of 11 / 13 / 15 / 18 / 24 / 36 / 64.
2. Have `palexus-theme` generate a QML singleton (`Palette.qml`) and the CSS `@define-color` file from it, so every surface reads the same values.
3. Add a gate in `build/verify-gates.sh` that fails if a raw `#rrggbb` appears in QML outside `Palette.qml`.

## 2. Accessibility (WCAG 2.2)

| # | Severity | Where | Problem | Criterion |
|---|---|---|---|---|
| A1 | **Critical** | HUD `CommandCategoryCard.qml:102` | Each command row is a bare `MouseArea`: it has no focus, no Tab or arrow-key path and no `Accessible.role`. A keyboard or screen-reader user can reach a command only by typing its name, and has no way to browse the list. | 2.1.1 Keyboard, 4.1.2 Name/Role |
| A2 | **Major** | HUD (all), greeter power buttons | The HUD has zero `Accessible.*` properties, so orca reads nothing. It matters now that orca is shipping. | 4.1.2 |
| A3 | **Major** | HUD `Main.qml:148,211`, card `:95`, `gtk.css:23` | Muted text `#6c7086` measures 3.84:1 on `#11111b` and 3.36:1 on `#1e1e2e`, at 10–13 px. That fails the 4.5:1 minimum, and these lines are the command descriptions and the HUD's help line. Wizard muted `#8990b3` passes at 5.77:1, so use it. | 1.4.3 Contrast |
| A4 | **Major** | HUD card rows | There is no visible focus state, because hover is the only highlight. | 2.4.7 Focus Visible |
| A5 | **Minor** | Greeter (7 infinite loops) | Motion runs forever unless `animations=false` is set in the theme config. The system reduced-motion setting is never read (the wizard already does this). | 2.3.3 Animation from Interactions |
| A6 | **Minor** | Borders `#313244` / `#2b2a3d` | At 1.4–1.5:1 they are too faint to show input and field edges. | 1.4.11 Non-text Contrast |
| A7 | **Minor** | HUD | The command descriptions are 10 px, below a comfortable reading size. | best practice |

**What to do:** the HUD needs the same treatment the wizard already has.
- Make each command row a focusable `ItemDelegate`, with `Accessible.role: Accessible.Button` and `Accessible.name: label + ", " + desc`.
- Arrow keys move through the results list, and Enter runs the selected command.
- Show an accent outline on `activeFocus`.
- Replace `#6c7086` text with the wizard's muted colour.

## 3. Copy (UX writing)

The first-boot wizard is the voice to copy: "Runs locally with Ollama. Nothing you type leaves the device, and it works offline." It is plain, specific and honest.

The login screen and HUD use a different voice: cyberpunk role-play that gets in the way of the task.

| Where | Now | Suggested |
|---|---|---|
| Greeter field hint | `operator username (↑/↓ to cycle)` | `Username — ↑/↓ to switch account` |
| Greeter password hint | `(not required - press enter)` | `No password on this account — press Enter` |
| Greeter header | `PALEXUS // NEURAL INTERFACE ONLINE`, `AUTH GATE`, `PALEXUS SECURITY SUBSYSTEM // TTY7` | Keep one line of flavour at most (e.g. `PALEXUS OS`); drop "TTY7" and "AUTH GATE" |
| Greeter subtitle | `PALEXUS OS · LINUX-CACHYOS` | `PALEXUS OS` (the kernel name means nothing at login) |
| Greeter button | `AUTHENTICATE ↵` | `Sign in ↵` |
| HUD descriptions | raw command names (`dns-dot`, `pal-vibe`, `hw-status`) | say what it does: "Encrypted DNS status", "Battery and CPU" |
| HUD help line | `[Esc] Close · [Enter] Launch / Ask AI · [Ctrl+Enter] Ask AI` | `Enter runs the top match · Ctrl+Enter asks the AI · Esc closes` (the current line lists "Ask AI" twice) |
| Wizard | `Core Cyberdeck Applications` | `Apps` or `Built-in apps` |
| Wizard | `Crimson isn't made for Monolith.` | Say what to do: `Crimson isn't available for Monolith — pick another accent.` |

**Translation:** wrap every visible string in `qsTr()` and add a `.ts` source. Without it, PalexusOS can't be localised.

## 4. Fix order

1. **HUD keyboard and screen-reader access** (A1, A2, A4). Shipping orca without this leaves its main launcher unusable for blind users.
2. **HUD contrast** (A3). Change one colour in four places.
3. **One token file and a generated palette** (section 1), plus the gate. This also fixes the accent drift.
4. **Greeter copy and reduced motion** (section 3, A5).
5. **`qsTr()` pass.**

## Skills that fit this repo

**Used:** `design-token-audit`, `accessibility-audit`, `ux-writing`.

**Worth running next, once the VM shows real screens:**
- `heuristic-evaluation` on the installer and first-boot flow.
- `onboarding-design` on the wizard's time to first value.
- `critique-visual-hierarchy` and `critique-color` on screenshots.
- `icon-system` on the 4 icon packs, which share 17 icons each and have no grid spec.
- `loading-states` for the first model download.
- `error-handling-ux` for installer failures.

**Needs brand files first:** `critique-brand-consistency` looks for `mood.md`, `voice.md` and `tokens.md`, and none exist. Writing them is part of the PalexusOS docs and rebrand task.

**Not relevant to a Linux distro:** the Vercel and React/React Native skills, the web-marketing ones (`taste-skill`, `banner-design`), and the research ones that need real participants (`diary-study-plan`, `survey-design`, `a-b-test-design`).
