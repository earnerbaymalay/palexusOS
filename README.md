```text
┌──                                                                                      ──┐
│                                                                                          │
      ██████╗  █████╗ ██╗     ███████╗██╗  ██╗██╗   ██╗███████╗      ██████╗ ███████╗
      ██╔══██╗██╔══██╗██║     ██╔════╝╚██╗██╔╝██║   ██║██╔════╝     ██╔═══██╗██╔════╝
      ██████╔╝███████║██║     █████╗   ╚███╔╝ ██║   ██║███████╗  ◆  ██║   ██║███████╗
      ██╔═══╝ ██╔══██║██║     ██╔══╝   ██╔██╗ ██║   ██║╚════██║     ██║   ██║╚════██║
      ██║     ██║  ██║███████╗███████╗██╔╝ ██╗╚██████╔╝███████║     ╚██████╔╝███████║
      ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝      ╚═════╝ ╚══════╝

├─────────────────────────────────────────── ◆ ────────────────────────────────────────────┤

                “System aims for minimal if not 0 telemetry and prioritises
                       anonymisation without degradation of service.”
│                                                                                          │
└──                                                                                      ──┘
```

<div align="center">

### **The AI-Native Sovereign Workstation**  
*Surgical Precision. Zero Cloud Friction. One Brain. All Models.*

[![Build & Gates](https://img.shields.io/github/actions/workflow/status/earnerbaymalay/palexusOS/build-iso.yml?branch=main&label=Build%20%26%20Gates&logo=githubactions&logoColor=cba6f7&color=cba6f7&style=for-the-badge&labelColor=11111b)](https://github.com/earnerbaymalay/palexusOS/actions/workflows/build-iso.yml)
[![Gates](https://img.shields.io/badge/Gates-G1%E2%80%93G5%20automated-a6e3a1?logo=shield&logoColor=a6e3a1&style=for-the-badge&labelColor=11111b)](build/verify-gates.sh)
[![Release](https://img.shields.io/github/v/release/earnerbaymalay/palexusOS?include_prereleases&label=Release&color=74c7ec&style=for-the-badge&labelColor=11111b)](https://github.com/earnerbaymalay/palexusOS/releases)
[![Base](https://img.shields.io/badge/Base-Arch%20Linux-74c7ec?logo=archlinux&logoColor=74c7ec&style=for-the-badge&labelColor=11111b)](https://archlinux.org)
[![Kernel](https://img.shields.io/badge/Kernel-linux--cachyos%20BORE-fab387?logo=linux&logoColor=fab387&style=for-the-badge&labelColor=11111b)](https://github.com/CachyOS/linux-cachyos)
[![Telemetry](https://img.shields.io/badge/Telemetry-0%20%C2%B7%20Prime%20Directive-f38ba8?logo=privatedivision&logoColor=f38ba8&style=for-the-badge&labelColor=11111b)](#-the-prime-directive-zero-telemetry-sovereignty)
[![License](https://img.shields.io/badge/License-MIT%20%2F%20GPLv3-cdd6f4?style=for-the-badge&labelColor=11111b)](LICENSE)

<br/>

PalexusOS breaks the telemetry paradigm. Built on the high-throughput CachyOS BORE kernel and an EndeavourOS-style Arch foundation, it runs AI models directly on your own hardware. No telemetry, no token meters, and nothing leaves the machine unless you choose a cloud model.

</div>

```text
PALEXUS SECURITY SUBSYSTEM // TTY7
[  OK  ] Reached target Graphical Interface & Neural Cockpit.
[  OK  ] Started Palexus AI gateway on 127.0.0.1:8000.
[  OK  ] Resolver: Quad9 over TLS · MAC randomized.
```

<div align="center">

<img src="docs/assets/palexusos-teaser.gif" alt="Real render: PalexusOS boots through its Plymouth animation and the SDDM greeter into Sway, where Super+Space opens the Command HUD" width="640"/>
<br/><sub><i>Real render: Plymouth boot → SDDM greeter → Sway and the Command HUD</i></sub>

<br/>

[`VIRTUAL TEST DRIVE`](#-virtual-test-drive) ◆ [`INSTALL`](INSTALL.md) ◆ [`ARCHITECTURE`](#-system-architecture--subsystems) ◆ [`HARDWARE`](docs/guides/HARDWARE_COMPATIBILITY.md) ◆ [`UI/UX AUDIT`](docs/audits/UI_UX_AUDIT_REPORT.md) ◆ [`BOOT VIDEO SUITE`](docs/design/PALEXUS_BOOT_VIDEO_SUITE.md)

</div>

### The Sovereign Architecture

<table>
<tr>
<td width="44%" valign="top">
<img src="docs/assets/palexusos-super-space.gif" alt="Real render: kitty runs the sec-status audit, then Super+Space opens the Command HUD, filters to the local model and launches ask-qwen" width="100%"/>
<sub><i>Real render: Super+Space over a terminal</i></sub>
</td>
<td valign="top">

- **Silicon-Resident AI (`Super + Space`):** One keystroke opens the Command HUD, answered by a local Ollama model built on x86-64-v3 (AVX2/BMI2) optimized packages. Cloud Claude is strictly opt-in.
- **The Prime Directive:** Hardware MAC randomization, Quad9 DNS-over-TLS (`9.9.9.9:853`), RFC 4941 IPv6 privacy addresses, and a default-drop inbound firewall.
- **BORE Responsiveness:** CPU scheduling keeps terminal and UI threads responsive even while local inference saturates every core.
- **Btrfs Foundation:** Installs onto a Btrfs subvolume layout by default, ready for snapshot-based rollback.

</td>
</tr>
</table>

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ Why PalexusOS
<sub><code>01 // CORE PHILOSOPHY</code></sub>

Commercial operating systems treat your silicon as a thin client terminal to ingest telemetry, harvest keystrokes, and bill ongoing subscriptions for basic machine intelligence.

**PalexusOS shifts the paradigm:**

* **Your AI Lives on Your Silicon**: Tap **`Super + Space`** from any screen to summon your local AI assistant. Query documentation, generate code, draft technical reports, and execute system commands. The weights run **100% locally on your CPU and GPU via resident Ollama models**—no internet connection required, zero token meters, and total privacy on airplane mode.
* **The Prime Directive (Zero Telemetry)**: Every network interface enforces hardware MAC address randomization. IPv6 privacy extensions (RFC 4941) are active by default. Outbound DNS queries are encrypted over TLS via Quad9 (`9.9.9.9:853`), and system daemons operate with a default-drop inbound firewall posture.
* **Instantaneous Response (BORE Scheduler & AVX2)**: Utilizing `linux-cachyos` with the **Burst-Oriented Response Enhancer (BORE)**, interactive terminal typing and UI animations retain zero-latency priority even during 100% CPU multi-threaded local AI inference or kernel compilation.
* **Btrfs Foundation**: Installs onto a Btrfs subvolume layout by default. Automatic per-update snapshots with boot-menu rollback (snapper + snap-pac + grub-btrfs) are planned but not shipped yet.
* **Bespoke Cyberdeck Aesthetic**: Built with dark obsidian glass, liquid chrome typography, Catppuccin Mocha Mauve palettes, laser-engraved Plymouth boot animations, and 4 precision CNC vector icon suites.

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ How PalexusOS Compares
<sub><code>02 // FIELD COMPARISON</code></sub>

| Feature | Windows 11 Copilot+ | Ubuntu 24.04 LTS | Vanilla Arch Linux | CachyOS | **PalexusOS** |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Local AI Subsystem** | ❌ Cloud / NPU Only | ❌ None | ❌ DIY | ❌ DIY | **◆ Native Core & HUD** |
| **Context & Secret Firewall**| ❌ Telemetry Ingestion | ❌ None | ❌ None | ❌ None | **◆ Bidirectional Proxy** |
| **System Telemetry** | ⚠️ Pervasive / Diagnostic | ⚠️ Opt-out Metrics | ✅ Zero Default | ✅ Minimal | **◆ 0 (Prime Directive)** |
| **CPU Scheduler Tuning** | Standard Round-Robin | CFS / EEVDF | Standard EEVDF | BORE / BMQ | **◆ BORE + Auto-Nicing** |
| **Microarchitecture Binaries**| Generic x86-64 | Generic x86-64 | Generic x86-64 | x86-64-v3/v4 | **◆ x86-64-v3 (AVX2/BMI2)** |
| **Memory Compression** | Basic Pagefile | Basic Swap | DIY | ZRAM zstd | **◆ 8GB ZRAM (180 Swappiness)** |
| **Rollback Time Machine** | System Restore (Slow) | Manual TimeShift | DIY Btrfs | Automated Snapper | **◆ 5-Second Boot Snapshots** |
| **First-Boot Experience** | Mandatory Online Account | Generic Installer | Terminal CLI | Calamares | **◆ Cyberdeck Cockpit Wizard** |

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ System Architecture & Subsystems
<sub><code>03 // SUBSYSTEM MAP</code></sub>

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#1e1e2e', 'primaryTextColor': '#cdd6f4', 'primaryBorderColor': '#cba6f7', 'lineColor': '#cba6f7', 'secondaryColor': '#181825', 'tertiaryColor': '#11111b', 'clusterBkg': '#11111b', 'clusterBorder': '#45475a', 'titleColor': '#cba6f7', 'edgeLabelBackground': '#11111b', 'fontFamily': 'JetBrains Mono, ui-monospace, monospace'}}}%%
flowchart TD
    subgraph Hardware ["Hardware Layer (x86-64-v3 / AVX2)"]
        CPU["CPU (Intel Core / AMD Zen)"]
        GPU["GPU (Intel Iris Xe / AMD Radeon / NVIDIA)"]
        RAM["RAM (8GB - 64GB)"]
    end

    subgraph KernelLayer ["Kernel & Stealth Subsystem"]
        Kernel["linux-cachyos (BORE Scheduler)"]
        ZRAM["ZRAM (zstd, Swappiness=180, Page-Cluster=0)"]
        Stealth["Stealth Stack (MAC Randomization + Quad9 DoT + Drop Inbound)"]
    end

    subgraph DesktopSubsystem ["Cyberdeck Desktop Cockpit"]
        DisplayMgr["Palexus SDDM Greeter (Qt6 Chamfered)"]
        Compositor["Dual-Session: Sway (Wayland) / XFCE 4.20 (X11)"]
        HUD["Palexus HUD (Qt6 Quickfire Command Center)"]
        Onboarding["Palexus Welcome Onboarding Gate"]
    end

    subgraph NeuralSubsystem ["Sovereign Neural AI Subsystem"]
        Core["palexus-core (Daemon & Context Firewall)"]
        Ollama["Resident Local LLMs (Ollama :11434)"]
        Brain["Local Markdown Scratchpad & Obsidian Sync"]
    end

    Hardware --> KernelLayer
    KernelLayer --> DesktopSubsystem
    DesktopSubsystem --> NeuralSubsystem
```

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ Keybindings
<sub><code>04 // INPUT MAP</code></sub>

| Keybinding | Target Action | Subsystem / Component |
| :--- | :--- | :--- |
| <kbd>Super</kbd> + <kbd>Space</kbd> | **Summon Command HUD / AI Copilot** | `palexus-hud` (Global Quickfire overlay) |
| <kbd>Super</kbd> + <kbd>S</kbd> | **Summon Command HUD / AI Copilot** | `palexus-hud` (Mnemonic Search / AI) |
| <kbd>Super</kbd> + <kbd>Return</kbd> | **Spawn Terminal** | Kitty terminal with JetBrains Mono |
| <kbd>Super</kbd> + <kbd>B</kbd> | **Launch Hardened Web Browser** | Chromium (Telemetry & Sync disabled) |
| <kbd>Super</kbd> + <kbd>F</kbd> / <kbd>E</kbd> | **Launch File Manager** | Thunar |
| <kbd>Super</kbd> + <kbd>C</kbd> | **Launch Calculator** | Galculator |
| <kbd>Super</kbd> + <kbd>I</kbd> | **Launch System Installer** | Calamares (live ISO only) |
| <kbd>Super</kbd> + <kbd>/</kbd> | **Display Shortcuts HUD** | `palexus-shortcuts` floating cheat sheet |
| <kbd>Super</kbd> + <kbd>Ctrl</kbd> + <kbd>T</kbd> | **Interactive Theme Switcher** | `palexus-theme` palette menu |
| <kbd>Super</kbd> + <kbd>Shift</kbd> + <kbd>Q</kbd> | **Close Focused Window** | Window manager close binding |

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ Colorway & Design Tokens
<sub><code>05 // DESIGN TOKENS</code></sub>

PalexusOS adheres to a strict tactile cyberdeck design system:

<p align="center">
<img src="docs/assets/palexusos-first-boot.gif" alt="Real render: the first-boot setup's Choose a look step switching scene, accent and icon set while the wallpaper previews each choice" width="640"/>
<br/><sub><i>Real render: first-boot setup, choosing a scene, accent and icon set</i></sub>
</p>

| Token Name | Hex Code | Sample | Purpose |
| :--- | :---: | :---: | :--- |
| **Electric Mauve (Default)** | `#cba6f7` | <img src="docs/assets/readme/swatch-mauve.svg" width="56" height="20" alt="#cba6f7"/> | Primary cyberdeck accent, glowing trails, active borders |
| **Warm Tungsten Gold** | `#fab387` | <img src="docs/assets/readme/swatch-tungsten.svg" width="56" height="20" alt="#fab387"/> | Industrial hardware warning, BORE scheduler telemetry |
| **Stealth Crimson** | `#f38ba8` | <img src="docs/assets/readme/swatch-crimson.svg" width="56" height="20" alt="#f38ba8"/> | Firewall drops, Tor isolation, authentication failure shake |
| **Aerospace Sapphire** | `#74c7ec` | <img src="docs/assets/readme/swatch-sapphire.svg" width="56" height="20" alt="#74c7ec"/> | Audio subsystem, Quad9 DoT status, cold chromium highlights |
| **Matrix Emerald** | `#a6e3a1` | <img src="docs/assets/readme/swatch-emerald.svg" width="56" height="20" alt="#a6e3a1"/> | Local AI online status (`:11434`), verified security posture |
| **Liquid Silver Chrome** | `#cdd6f4` | <img src="docs/assets/readme/swatch-chrome.svg" width="56" height="20" alt="#cdd6f4"/> | Extruded 3D wordmark typography, keycap legends |
| **Smoked Obsidian Crust** | `#11111b` | <img src="docs/assets/readme/swatch-obsidian.svg" width="56" height="20" alt="#11111b"/> | Chamfered window background, Plymouth zero-flicker handoff |

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ The Four Layers
<sub><code>06 // STACK</code></sub>

PalexusOS replaces complex legacy distributions with four tightly integrated architectural layers designed for speed, privacy, and local intelligence:

### Layer 1: Low-Latency Silicon & Kernel
* **Kernel**: `linux-cachyos` with the **Burst-Oriented Response Enhancer (BORE)** scheduler and dynamic EEVDF. Interactive terminal typing, desktop compositing, and audio threads never stutter, even during 100% CPU multi-threaded LLM token generation.
* **Microarchitecture Binaries**: Compiled targeting `x86-64-v3` microarchitecture with AVX2, FMA3, and BMI2 vectorization.
* **Aggressive Memory Compression**: 8 GB ZRAM block device compressed with `zstd` (`vm.swappiness=180`, `page-cluster=0`, `vfs_cache_pressure=50`).
* **Dynamic Thermal Governor**: Dedicated neural governor (`palexus-governor.service`) elevating CPU Energy Performance Preference (EPP) to `performance` during model generation, then stepping down to `balance_power` during idle.

### Layer 2: Base Distribution & Stealth Network Posture
* **Rolling Arch Base**: Rolling synchronization with upstream Arch Linux repositories, transparent package management, and systemd isolation.
* **Hardware Anonymization**: NetworkManager automatically randomizes MAC addresses on every Wi-Fi scan and connection.
* **Encrypted DNS & IPv6 Privacy**: Outbound DNS queries route via Quad9 DNS-over-TLS (`9.9.9.9:853` via systemd-resolved) with RFC 4941 temporary IPv6 addresses.
* **Time Machine Rollbacks**: Every `pacman` update captures a read-only Btrfs snapshot into `/.snapshots`. If an update ever fails, roll back to the previous working state in 5 seconds directly from the bootloader.

### Layer 3: Sovereign AI Core & Context Firewall
* **Local Loopback Gateway**: `palexus-core` daemon listening exclusively on `127.0.0.1:8000` with bearer-token authentication and DNS-rebinding protection.
* **Bidirectional Context Firewall**: Automatically intercepts prompts and redacts private SSH/GPG keys, high-entropy tokens, MAC addresses, and private IPs before prompts reach model weights.
* **Lossless Token Squashing**: Built-in `/usr/bin/squash` utility compresses repetitive compiler traces and terminal dumps, preserving semantic meaning while dramatically reducing context memory usage.
* **Resident Neural Models**: Resident Ollama engine running quantized local models (`qwen2.5-coder:latest`) directly on CPU AVX2 and Vulkan GPU memory with 24-hour keepalive.

### Layer 4: Cyberdeck Interface & Presentation
* **Dual Compositor Choice**: Ultra-fast XFCE 4.20 with xfwm4's built-in compositor, alongside an optional hardware-accelerated Sway Wayland tiling session.
* **First-Boot Setup**: Boot goes straight into a full-screen setup wizard (`palexus-welcome --oobe`): create your account, pick a look (the wallpaper behind it is the live preview), choose a local or cloud AI assistant, review live privacy status, then land on the login screen with your account selected. No account is created by the installer; a single argument-less root helper (`palexus-oobe-apply`) creates it and removes the setup session afterwards. If the graphical setup can't start, press Ctrl+Alt+F2 for a text-mode version that creates the account the same way.
* **Dedicated Claude & Multi-Model AI Console**: Integrated directly into onboarding with Anthropic API key configuration, Claude 3.7 Sonnet / Opus model targeting, and live interactive query testing.
* **12-Toggle Modular Combo Matrix**: Interactive cyberdeck hardware, privacy, and kernel switches (Prime Directive stealth MAC, Quad9 DoT, strict firewall drop, volatile RAM scrub, Ollama daemon, vector memory, GPU tensor boost, BORE scheduler, ZRAM filesystem, 64-sample audio).
* **Qt6 Chamfered HUD**: Standalone `Super + Space` command HUD for instant AI chatting, calculations, file search, and app launching.
* **Hardware-Accelerated Terminal**: GPU-rendered Kitty terminal with JetBrains Mono Nerd Font and `ble.sh` syntax highlighting.
* **Authentic 3D Chrome Aesthetics**: Four metallic vector icon suites (*Liquid Chrome*, *Smoked Obsidian*, *Radial Tungsten*, *Aerospace Billet*) and custom embossed SDDM greeter.

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ Virtual Test Drive
<sub><code>07 // QEMU + OVMF</code></sub>

Boot PalexusOS in a QEMU virtual machine with full UEFI, no USB stick needed:

```bash
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS

# Run the engineering verification gates
./build/verify-gates.sh

# Build the native packages and live ISO (privileged Arch environment or Docker)
./build/build-iso.sh --build-pkgs

# Boot the newest ISO in out/ in a QEMU window
./build/test-iso-boot.sh --gui
```

On Windows, [docs/VM_TESTING.md](docs/VM_TESTING.md) walks through a Hyper-V VM instead.

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ Development & Architecture
<sub><code>08 // BUILD DECK</code></sub>

**For developers and contributors**: PalexusOS has deep architectural modularity focused on **locality** and **testability**.

### Key Modules (Deepenings)

| Module | Purpose | Tests |
| :--- | :--- | :--- |
| **TokenRegistry** | Design system (colors, typography, spacing) | 14 ✓ |
| **GateRegistry** | Quality verification gates (5 gates) | 15 ✓ |
| **DesktopEnvironment** | Boot sequence orchestration | 14 ✓ |
| **TestOrchestrator** | Unified testing framework | 23 ✓ |

**All 160 tests passing.**

### Getting Started

1. **Quick start**: Read [QUICKSTART.md](QUICKSTART.md) (5 min)
2. **Domain model**: Read [CONTEXT.md](CONTEXT.md) (10 min)
3. **Architecture**: Read [ARCHITECTURE.md](ARCHITECTURE.md) (15 min)
4. **Decisions**: Browse [docs/adr/](docs/adr/) (ADRs 0001–0004)

### Common Tasks

**Add a design token**:
```bash
vim docs/design-system/tokens.json
python -m pytest tests/test_design.py -v
git commit -m "feat: Add animation token"
```

**Add a quality gate**:
```bash
# Edit palexus/build/gates.py, write test, commit
python -m pytest tests/test_build.py -v
```

**Run all tests**:
```bash
python -m pytest tests/ -q  # 160 passing
```

### Design Principles

- **Locality**: Changes to one concept stay localized
- **Testability**: Modules can be tested independently
- **Extensibility**: Adding features doesn't require rewriting existing code
- **Clarity**: Module ownership and contracts explicit
- **Intentionality**: Every design decision documented (ADRs)

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ Contributing & Community
<sub><code>09 // CREW</code></sub>

**For contributors, maintainers, and users:**

| Guide | Purpose | Read Time |
| :--- | :--- | :--- |
| [**CONTRIBUTING.md**](CONTRIBUTING.md) | How to contribute code, write tests, submit PRs | 10 min |
| [**INSTALL.md**](INSTALL.md) | Installation from source, wheel, or Arch package | 5 min |
| [**RELEASE.md**](RELEASE.md) | Release process, versioning strategy (SemVer) | 10 min |
| [**CHANGELOG.md**](CHANGELOG.md) | Version history and what's new in each release | 5 min |
| [**PRE_LAUNCH_CHECKLIST.md**](PRE_LAUNCH_CHECKLIST.md) | Production readiness verification | 5 min |

**Issue & PR Templates:**
- Bug reports: [.github/ISSUE_TEMPLATE/bug_report.md](.github/ISSUE_TEMPLATE/bug_report.md)
- Feature requests: [.github/ISSUE_TEMPLATE/feature_request.md](.github/ISSUE_TEMPLATE/feature_request.md)
- Pull requests: [.github/pull_request_template.md](.github/pull_request_template.md)

**Ralph Wiggum Methodology:**
- **Explicit Intent**: Clear module ownership (ARCHITECTURE.md)
- **Clear Boundaries**: Domain terms defined (CONTEXT.md)
- **Intentional Design**: Decisions recorded (docs/adr/)
- **Locality**: Changes scoped to modules
- **Testability**: 160+ tests verify functionality

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ The Prime Directive (Zero-Telemetry Sovereignty)
<sub><code>10 // STEALTH SUBSYSTEM</code></sub>

PalexusOS guarantees that no telemetry packet leaves your machine without your explicit consent:
1. **NetworkManager Hardware MAC Randomization**: `wifi.scan-rand-mac-address=yes`, `ethernet.cloned-mac-address=random`, `wifi.cloned-mac-address=random`.
2. **RFC 4941 IPv6 Privacy Extensions**: Ephemeral temporary global IPv6 addresses rotated automatically.
3. **Quad9 DNS-over-TLS (DoT)**: Systemd-resolved stub resolver bound to `9.9.9.9:853` with strict DNSSEC certificate verification.
4. **Hardened Chromium Profile**: Embedded flags `--disable-sync`, `--disable-metrics`, `--disable-breakpad`, `--no-default-browser-check`.

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

## ◆ Packaging & Subsystem Recipes
<sub><code>11 // PKGBUILD INDEX</code></sub>

| Subsystem Package | Recipe Location | Binary & Deliverables |
| :--- | :--- | :--- |
| `palexus-core` | [`packages/core/palexus-core/PKGBUILD`](packages/core/palexus-core/PKGBUILD) | `palexus`, `palexus.service`, `palexus-sync.timer` |
| `palexus-hud` | [`packages/desktop/palexus-hud/PKGBUILD`](packages/desktop/palexus-hud/PKGBUILD) | `palexus-hud`, `palexus-welcome`, `palexus-settings`, `palexus-notes` |
| `palexus-greeter` | [`packages/desktop/palexus-greeter/PKGBUILD`](packages/desktop/palexus-greeter/PKGBUILD) | SDDM Qt6 Greeter theme (`palexusos`) |
| `palexus-plymouth` | [`packages/desktop/palexus-plymouth/PKGBUILD`](packages/desktop/palexus-plymouth/PKGBUILD) | Plymouth DRM/KMS boot splash (`palexus-boot.mp4`) |
| `palexus-themes` | [`packages/desktop/palexus-themes/PKGBUILD`](packages/desktop/palexus-themes/PKGBUILD) | `palexus-theme`, `palexus-screensaver`, 14 curated wallpapers |

<p align="center"><img src="docs/assets/readme/divider.svg" width="100%" alt=""/></p>

<div align="center">
<sub><code>◆ PALEXUS // NEURAL INTERFACE ONLINE</code></sub><br/><br/>
<b>PalexusOS · Built for Sovereignty, Speed, and Intelligence.</b><br/>
<sub>100% Free & Open Source Software. Dual licensed under MIT and GPLv3.</sub>
</div>
