# PalexusOS — Comprehensive UX/UI Design & Interaction Audit
**Target:** PalexusOS (formerly SynapseOS) Desktop, Cockpit & Greeter Suite  
**Evaluation Standard:** Catppuccin Mocha Mauve + Liquid Silver Chrome + Obsidian Crust Identity  
**Audit Scope:** 100% of all UI buttons, keyboard shortcuts, window controls, state transitions, focus paths, and accessibility contracts.

---

## 1. Executive UX/UI Matrix

| Component | Technology | Primary Trigger / Binding | Primary Palette Accent | Window Model | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Command HUD** (`palexus-hud`) | Qt6 / QML | `Super+Space` / `Super+D` | Catppuccin Mauve (`#cba6f7`) | Frameless, Topmost, Chamfered | **Verified** |
| **Onboarding Cockpit** (`palexus-welcome`) | Qt6 / QML | First Boot / `palexus-welcome` | Dynamic Accent Variant | Frameless Cyberdeck Cockpit | **Verified** |
| **System Settings** (`palexus-settings`) | Python / PyQt6 | `Super+C` / HUD | Theme Variant Accent | Themed System Window (760x580) | **Verified** |
| **Markdown Scratchpad** (`palexus-notes`) | Python / PyQt6 | `Super+N` / HUD | Specular Silver + Accent | Auto-saving Note Canvas | **Verified** |
| **Screensaver** (`palexus-screensaver`) | Python / PyQt6 | Sway Idle / Lock | Dynamic Torus Wireframe | Fullscreen Canvas | **Verified** |
| **SDDM Login Greeter** (`palexus-greeter`) | Qt6 / QML | Boot / Display Manager | Dynamic Theme Variant | Right-aligned Cyberdeck Card | **Verified** |
| **Calamares Installer** (`palexusos`) | Calamares / QML | Live Boot / Desktop Icon | Catppuccin Mauve & Obsidian | Branded Installation Wizard | **Verified** |

---

## 2. Component Deep-Dive & Element-by-Element Verification

### A. Palexus Command HUD (`Main.qml` & `palexus-hud`)
- **Visual Architecture**:
  - 960x640 frameless chamfered obsidian glass container (`#0d0e15`, 95% opacity).
  - Procedural traveling border light trails (12px dash, 120px gap, 6.5s infinite loop).
  - Specular outer drop-glow with corner radius 20px.
- **Search & Input Field**:
  - Focus is forced on launch via `Component.onCompleted: searchBox.forceActiveFocus()`.
  - Placeholder guidance: `[Esc] Close · [Enter] Launch / Ask AI · [Ctrl+Enter] Ask AI`.
  - Active focus border changes dynamically to current accent (`#cba6f7`).
  - Text selection color bound to accent with obsidian contrast text (`#11111b`).
- **Interactive Buttons & Handlers**:
  - **Close Button (`closeBtn`)**:
    - Top-right 24x24 button with 6px border radius.
    - Hover animation: Background shifts from `#313244` to `#f38ba8` (Catppuccin Red), icon shifts from `#cdd6f4` to `#11111b`.
    - Mouse cursor: `Qt.PointingHandCursor`.
    - Click event: Signals `root.closeHud()`, which safely quits the Qt application.
  - **Category Command Cards (6 Grid Sections)**:
    - *Section 1 (AI Agents)*: Keys `1`–`5` launch `palexus hud`, `palexus sync`, `palexus vibe`, `palexus mem`, and `palexus doctor` inside Kitty terminal.
    - *Section 2 (Local Inference)*: Keys `Q`, `L`, `W`, `F`, `O` trigger Qwen 2.5 Coder, LLaMA 3.2, pre-warming, model flush, and Ollama shell.
    - *Section 3 (Stealth & Security)*: Keys `A`, `S`, `N`, `F`, `D` invoke security status, stealth shield, nmtui, firewall, and DNS-over-TLS check.
    - *Section 4 (Audio & Hardware)*: Keys `Z`, `H`, `P`, `V`, `E` manage audio sinks, hardware telemetry, PipeWire restart, and 25W/15W thermal toggles.
    - *Section 5 (Dev Tools)*: Keys `G`, `Y`, `K`, `T`, `B` launch lazygit, yazi, token squasher, fastfetch, and btop.
    - *Section 6 (Desktop & Apps)*: Keys `N`, `C`, `W`, `J`, `U` launch notes, settings, Chromium, calculator, and screensaver.
- **Keyboard Navigation Paths**:
  - `Escape`: Unconditionally dismisses HUD.
  - `Enter`: Evaluates query. If prefixed with `?` or `ai `, executes LLM query; if query matches command card, executes command; otherwise falls back to LLM prompt.
  - `Ctrl+Enter`: Forces direct AI prompt execution inside Kitty with `ask-qwen`.
  - Direct alphanumeric key: When input is empty, instantly fires mapped card action.

---

### B. Palexus Onboarding Cockpit (`Welcome.qml` & `palexus-welcome`)
- **Window Architecture & Management**:
  - 980x640 frameless obsidian cockpit with dedicated AMOLED black (`#050508`) top navigation bar.
  - Draggable window header via `DragHandler { onActiveChanged: if (active) root.startSystemMove() }`.
  - Standardized window controls:
    - **Minimize Button**: 14x14 circular badge, `#fab387` amber glow, triggers `root.showMinimized()`.
    - **Maximize / Restore Button**: 14x14 circular badge, theme accent glow, toggles `root.showMaximized()` / `root.showNormal()`.
    - **Close Button**: 14x14 circular badge, `#f38ba8` red glow, executes `backend.closeOnly()`.
- **Sidebar Navigation**:
  - 5 navigable segments: Overview, Display & Themes, Security & Stealth, Local AI Models, Keybindings & Engagement.
  - Selected sidebar item highlighted with obsidian container `#1a1a2c` and accent indicator bar.
- **Interactive Controls**:
  - **Themes & Wallpapers**: 16:9 wallpaper miniatures with live preview. Clicking selects theme and dynamically updates accent color across all UI widgets.
  - **Stealth & Privacy**: Animated sliding toggle switches for Wi-Fi MAC randomization, RFC 4941 IPv6 privacy, and Quad9 DoT. Smooth transitions with `#a6e3a1` active fill.
  - **AI Model Selection**: Ollama detection status with live health pip (Green when running, Red when offline). Model selector with pre-flight RAM requirement verification. Claude API key input with show/hide password toggle.
  - **Section 5 (Engage)**: Tactile cyberdeck action button "ENGAGE PALEXUS COCKPIT" triggers complete configuration write and smooth desktop handoff.

---

### C. System Settings Control Center (`palexus-settings`)
- **Layout & Structure**:
  - 760x580 responsive window with tabbed navigation: Themes, AI Models, Stealth, Audio & Latency.
- **Tab 1: Visual Themes**:
  - Radio button selector across all 5 official variants (`monolith-mauve`, `monolith-tungsten`, `monolith-crimson`, `monolith-sapphire`, `monolith-emerald`).
  - Instant live synchronization to `~/.config/palexus/theme` and wallpaper daemon.
- **Tab 2: AI Inference**:
  - Displays resident Ollama models, memory footprint, and provides one-click pre-warm or memory flush.
- **Tab 3: Prime Directive Stealth**:
  - Displays real-time MAC randomization state (ensuring hardware MAC `b4:69:21:fa:71:d4` is never leaked over Wi-Fi).
  - Quad9 DoT connectivity validator (`resolvectl status`).
- **Tab 4: Audio & Latency**:
  - Interactive PipeWire buffer selector (64, 128, 256 samples).
  - Dell 7490 thermal power limit toggle (25W PL1 Performance / 15W Battery Eco).

---

### D. Markdown Scratchpad (`palexus-notes`)
- **Features & UX**:
  - Focused distraction-free note canvas.
  - Real-time syntax highlighter: Headers in Mauve accent, bold words highlighted, code blocks monospace.
  - Auto-save engine: Debounced 3.0s timer automatically syncs buffer to `~/AIBrain/notes/scratchpad.md`.
  - Keyboard shortcuts: `Ctrl+S` forces immediate save; `Ctrl+Q` closes window cleanly.

---

### E. SDDM Login Greeter (`palexus-greeter`)
- **Visual Design**:
  - Scaled dynamically for 1080p, 1440p, and 4K displays (`s = height / 768`).
  - High-precision digital clock + date telemetry positioned right-aligned.
  - Chamfered obsidian credentials panel with dual traveling light trails matching system theme variant.
- **Interactive Controls**:
  - User selection dropdown with automatic fallback to first account on new installs.
  - Session selector (XFCE 4.20 Desktop / Sway Wayland Compositor) accessible via `F2`–`F5` or UI buttons.
  - Password input field with dynamic focus glow and enter key authentication (`sddm.login`).
  - Automatic live-user passwordless login bypass for USB live-boot environments.
  - Failure feedback: 4-stage horizontal shake animation and red status notification (`#f38ba8`).

---

### F. Calamares Installer Branding (`palexusos`)
- **Aesthetic**: Catppuccin Mocha Mauve + Liquid Silver Chrome + Obsidian Crust.
- **Branded QML Slideshow**:
  - Slide 1: Welcome to PalexusOS (Intelligent Cyberdeck distribution).
  - Slide 2: Zero-Telemetry & Prime Directive Stealth (MAC randomization, Quad9 DoT, no GeoIP).
  - Slide 3: Neural Concurrency (Local LLM acceleration & Ollama runtime).
  - Slide 4: Metallic Vector Suites & Themes.
- **Partitioning Strategy**: Automated Btrfs layout with `@`, `@home`, and `@snapshots` subvolumes with zstd compression.
