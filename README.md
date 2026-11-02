<div align="center">

# SynapseOS

### **The AI-Native Rolling Linux Workstation**  
*Surgical Precision. Zero Friction. One Brain. All Models.*

[![Build & Engineering Gates](https://img.shields.io/github/actions/workflow/status/earnerbaymalay/synapseOS/build-iso.yml?branch=main&label=Build%20%26%20Gates&logo=githubactions&logoColor=cdd6f4&color=cba6f7&style=flat-square)](https://github.com/earnerbaymalay/synapseOS/actions/workflows/build-iso.yml)
[![Verification Gates](https://img.shields.io/badge/Gates-279%2F279%20Passing-3fb950?style=flat-square&logo=shield&logoColor=ffffff)](build/verify-gates.sh)
[![Release](https://img.shields.io/github/v/release/earnerbaymalay/synapseOS?include_prereleases&label=Latest%20Release&color=74c7ec&style=flat-square)](https://github.com/earnerbaymalay/synapseOS/releases)
[![Rolling Base](https://img.shields.io/badge/Rolling%20Base-Arch%20Linux-1793d1?style=flat-square&logo=archlinux&logoColor=ffffff)](https://archlinux.org)
[![Kernel](https://img.shields.io/badge/Kernel-linux--cachyos%20(BORE)-fab387?style=flat-square&logo=linux&logoColor=ffffff)](https://github.com/CachyOS/linux-cachyos)
[![Telemetry](https://img.shields.io/badge/Telemetry-0%20(Prime%20Directive)-f38ba8?style=flat-square&logo=privatedivision&logoColor=ffffff)](#-the-prime-directive-zero-telemetry-sovereignty)
[![License](https://img.shields.io/badge/License-MIT%20%2F%20GPLv3-d4dae2?style=flat-square)](LICENSE)

<br/>

<img src="docs/assets/synapseos-banner.png" alt="SynapseOS Monolithic Banner" width="100%"/>

<br/>

**SynapseOS** is an open-source, AI-native operating system designed to liberate personal computing from cloud telemetry, forced subscriptions, and interface bloat. Powered by low-latency schedulers, aggressive memory compression, and deeply integrated local neural models, SynapseOS converts any modern PC into an ultra-fast sovereign cyberdeck.

[**Get Started in 3 Steps**](#-get-started-in-3-steps) • [**1-Command Instant Demo**](#-test-drive-in-60-seconds-no-usb-required) • [**Architecture**](#-deep-system-architecture) • [**Hardware Support**](#-supported-hardware-matrix) • [**Documentation**](docs/)

</div>

---

## ⚡ Why SynapseOS? (The Plain-English Breakdown)

Modern commercial operating systems increasingly treat your hardware as a client terminal to harvest data, deliver unsolicited promotions, and charge ongoing subscriptions for basic intelligence features.

**SynapseOS turns the paradigm inside-out:**

* 🧠 **Your AI Lives on Your Silicon**: Tap **`Super + Space`** from any screen to summon your local AI assistant. Query documentation, generate code, draft technical reports, and execute system commands. The weights run **100% locally on your CPU and GPU via resident Ollama models**—no internet connection required, zero token meters, and total privacy on airplane mode.
* 🛡️ **The Prime Directive (Zero Telemetry)**: Every network interface enforces hardware MAC address randomization. IPv6 privacy extensions (RFC 4941) are active by default. Outbound DNS queries are encrypted over TLS via Quad9 (`9.9.9.9:853`), and system daemons operate with a default-drop inbound firewall posture.
* 🚀 **Instantaneous Response (BORE Scheduler & AVX2)**: Utilizing `linux-cachyos` with the **Burst-Oriented Response Enhancer (BORE)**, interactive terminal typing and UI animations retain zero-latency priority even during 100% CPU multi-threaded local AI inference or kernel compilation.
* 🛡️ **Bulletproof Snapshot Protection (Time Machine)**: Every `pacman` update automatically generates a read-only Btrfs snapshot. If an upstream regression ever occurs, roll your entire workstation back to a pristine working state in under 5 seconds directly from the bootloader.
* 🎨 **Bespoke Cyberdeck Aesthetic**: Built with dark obsidian glass, liquid chrome typography, Catppuccin Mocha Mauve palettes, laser-engraved Plymouth boot animations, and 4 precision CNC vector icon suites.

---

## 📊 How SynapseOS Compares

| Feature | Windows 11 Copilot+ | Ubuntu 24.04 LTS | Vanilla Arch Linux | CachyOS | **SynapseOS** |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Local AI Subsystem** | ❌ Cloud / NPU Only | ❌ None | ❌ DIY | ❌ DIY | **✅ Native Core & HUD** |
| **Context & Secret Firewall**| ❌ Telemetry Ingestion | ❌ None | ❌ None | ❌ None | **✅ Bidirectional Proxy** |
| **System Telemetry** | ⚠️ Pervasive / Diagnostic | ⚠️ Opt-out Metrics | ✅ Zero Default | ✅ Minimal | **🛡️ 0 (Prime Directive)** |
| **CPU Scheduler Tuning** | Standard Round-Robin | CFS / EEVDF | Standard EEVDF | BORE / BMQ | **🚀 BORE + Auto-Nicing** |
| **Microarchitecture Binaries**| Generic x86-64 | Generic x86-64 | Generic x86-64 | x86-64-v3/v4 | **⚡ x86-64-v3 (AVX2/BMI2)** |
| **Memory Compression** | Basic Pagefile | Basic Swap | DIY | ZRAM zstd | **💾 8GB ZRAM (180 Swappiness)** |
| **Rollback Time Machine** | System Restore (Slow) | Manual TimeShift | DIY Btrfs | Automated Snapper | **✅ 5-Second Boot Snapshots** |
| **First-Boot Experience** | Mandatory Online Account | Generic Installer | Terminal CLI | Calamares | **✨ Guided Cyberdeck Wizard** |

---

## 🧪 Test Drive in 60 Seconds (No USB Required!)

Want to experience SynapseOS right now without touching your disk or flashing a USB drive? Run this single command on any Linux or macOS machine with QEMU installed:

```bash
# Download the latest 2.9GB verified ISO and launch in an accelerated VM:
curl -LO https://github.com/earnerbaymalay/synapseOS/releases/latest/download/synapseos-x86_64.iso

qemu-system-x86_64 \
  -enable-kvm -m 8G -smp 4 -cpu host \
  -vga virtio -display gtk,gl=on \
  -audiodev pa,id=snd0 -device intel-hda -device hda-duplex,audiodev=snd0 \
  -cdrom synapseos-x86_64.iso -boot d
```

*(On Windows, you can launch the ISO directly inside Hyper-V, VMware Workstation, or VirtualBox with 3D Acceleration enabled).*

---

## 🚀 Get Started in 3 Steps

SynapseOS runs seamlessly on standard laptops, workstations, and custom desktops (Dell Latitude, ThinkPad, Framework, ASUS ROG, HP, Razer, Intel/AMD/NVIDIA).

> [!NOTE]
> **No Linux experience required.** You do not need to be a programmer or terminal expert. Everything can be operated via standard mouse and keyboard. When you choose to install, Calamares offers safe dual-boot alongside Windows without touching your existing personal files.

### 1. Prepare Your Media (The Ventoy Multi-Boot Way)
We recommend **[Ventoy](https://www.ventoy.net)** because it turns any USB flash drive into a reusable drag-and-drop installer:
1. Install Ventoy onto a USB drive (16 GB or larger) using the Ventoy GUI or CLI.
2. Download `synapseos-x86_64.iso` from our [GitHub Releases](https://github.com/earnerbaymalay/synapseOS/releases).
3. Copy the `.iso` file directly onto the USB partition.

> [!TIP]
> Prefer classic flashing tools? You can write the image directly using [BalenaEtcher](https://etcher.balena.io/) or the terminal:
> ```bash
> sudo dd if=synapseos-x86_64.iso of=/dev/sdX bs=4M status=progress oflag=direct
> ```

### 2. Boot into the Live Cyberdeck
1. Insert the USB drive and power on your PC.
2. Press your computer's boot selection key immediately:
   * **`F12`** for Dell, Lenovo, and Framework
   * **`F9`** for HP
   * **`F8`** or **`F11`** for ASUS, MSI, and ASRock
3. Select your USB drive and choose **SynapseOS (Live Mode)**.

### 3. Explore & Install
You are now in the live environment running directly in memory:
* Press **`Super + Space`** to open the **Synapse Command HUD** and test your local AI.
* Verify your Wi-Fi, audio output, multi-monitor display scaling, and trackpad gestures.
* When ready to install permanently, double-click **Install SynapseOS** on the desktop to launch the Calamares installer (select **Install Alongside Windows** or **Replace Entire Disk** with Btrfs).

📖 **Comprehensive walkthroughs:**
* ➡️ [**Ventoy Flashing & Boot Guide**](docs/VENTOY_BOOT_GUIDE.md)
* ➡️ [**Dual-Boot Safety & BitLocker Suspension Guide**](docs/DUAL_BOOT_AND_HARDWARE.md)

---

## ⌨️ Fluid Cyberdeck Navigation

SynapseOS is engineered around keyboard-driven ergonomics. Learn these primary shortcuts to command your workspace:

| Shortcut | Action | Description |
| :--- | :--- | :--- |
| **`Super + Space`** | **Synapse Command HUD** | Universal quick-launcher, local AI prompt bar, calculation engine, and application index. |
| **`Super + Return`** | **Kitty Terminal** | Ultra-responsive hardware-accelerated GPU terminal with JetBrains Mono and auto-completion. |
| **`Super + Ctrl + T`** | **Cycle Desktop Themes** | Instantly switch between *Liquid Chrome*, *Smoked Obsidian*, *Radial Tungsten*, and *Mauve*. |
| **`Super + Alt + S`** | **Neural Read Aloud** | Reads selected text or the latest AI response aloud using natural low-latency local speech. |
| **`Super + /`** | **Cheat Sheet Overlay** | Summons an interactive on-screen shortcut matrix at any time. |
| **`Super + Shift + Q`** | **Close Window** | Instantly closes active focused window with zero visual tearing. |

---

## 💻 Supported Hardware Matrix

SynapseOS features an automated hardware sensing engine (`synapse-hardware`) that configures thermal governors, CPU instruction paths, and GPU acceleration on boot:

| Tier | Classification | Reference Machines | Hardware Tuning |
| :--- | :--- | :--- | :--- |
| **Tier 0** | **Engineering Reference** | **Dell Latitude 7490** (Intel Core i5/i7 8th-Gen, UHD 620, 16–32 GB RAM) | **100% Certified**. Custom 25W sustained PL1 thermal profile, sub-5ms PipeWire audio, tuned trackpad gestures. |
| **Tier 1** | **Certified Laptops** | **Lenovo ThinkPad** (T14, T480, X1 Carbon), **Framework Laptop 13 & 16**, Dell XPS 13/15 | Flawless out-of-the-box hardware enablement, Wi-Fi 6E/7, Bluetooth LE, deep sleep S3/Modern Standby, automatic brightness. |
| **Tier 2** | **Universal x86-64** | AMD Ryzen 3000–9000 series, Intel 9th–14th Gen, custom gaming PCs, ASUS ROG, HP Spectre | Full AVX2 CPU vector utilization, Vulkan compute acceleration for Ollama, NVIDIA proprietary / open-kernel drivers. |

Verify your hardware health and AI thermal acceleration status anytime:
```bash
synapse-hardware status
```

📖 **Detailed hardware matrix, power profiles, and GPU notes:**  
➡️ [**docs/HARDWARE_COMPATIBILITY.md**](docs/HARDWARE_COMPATIBILITY.md)

---

## ⚙️ Deep System Architecture

SynapseOS synthesizes four proven engineering foundations into a single cohesive operating system:

```mermaid
flowchart TD
    classDef ui fill:#1e1e2e,stroke:#cba6f7,stroke-width:2px,color:#cdd6f4;
    classDef ai fill:#181825,stroke:#74c7ec,stroke-width:2px,color:#cdd6f4;
    classDef os fill:#11111b,stroke:#a6e3a1,stroke-width:2px,color:#cdd6f4;
    classDef kern fill:#0b0b10,stroke:#fab387,stroke-width:2px,color:#cdd6f4;

    subgraph UI ["Layer 4: Cyberdeck Interface & Presentation"]
        direction TB
        COMP["Dual Compositor: XFCE 4.20 (Picom dual_kawase) & Sway Wayland"]:::ui
        HUD["synapse-hud (Qt6/QML Material You HUD — Super+Space)"]:::ui
        KITTY["Kitty Terminal (ble.sh + JetBrains Mono Nerd Font)"]:::ui
        THEMES["4 Metallic Icon Suites (Chrome, Obsidian, Tungsten, Billet)"]:::ui
    end

    subgraph AI ["Layer 3: Synapse AI Core & Context Engine"]
        direction TB
        GW["synapse-core Loopback Gateway (127.0.0.1:8000 REST/SSE)"]:::ai
        CFW["Bidirectional Context Firewall (Entropy & Secret Masking)"]:::ai
        SQUASH["Lossless Token Squasher (/usr/bin/squash)"]:::ai
        MEM["3-Layer Vector Memory Engine (~/AIBrain/notes)"]:::ai
        OLLAMA["Resident Ollama Engine (qwen2.5-coder:latest, 24h Keepalive)"]:::ai
    end

    subgraph OS ["Layer 2: Base System & Stealth Network Posture"]
        direction TB
        ARCH["Upstream Arch Linux Rolling Repositories"]:::os
        OVERLAY["[synapseos] Optimized Overlay Repository (x86-64-v3)"]:::os
        SEC["NetworkManager Stealth (MAC Randomization + RFC 4941 IPv6)"]:::os
        DNS["Quad9 Encrypted DNS-over-TLS (9.9.9.9:853 via systemd-resolved)"]:::os
        BTRFS["Btrfs @ Subvolumes with Automated Snapper Rollbacks"]:::os
    end

    subgraph KERN ["Layer 1: Low-Latency High-Throughput Kernel"]
        direction TB
        BORE["linux-cachyos Kernel (BORE Interactive Burst Scheduler)"]:::kern
        ZRAM["8 GB ZRAM Block Device (zstd, vm.swappiness=180, page-cluster=0)"]:::kern
        ANAN["ananicy-cpp (Dynamic Process Autogrouping & Auto-Nicing)"]:::kern
        GOV["synapse-governor (Dynamic PL1/PL2 CPU Thermal Tuner)"]:::kern
    end

    UI ==> AI
    AI ==> OS
    OS ==> KERN
```

### 1. Bidirectional Context Firewall (`firewall.rs`)
All application interactions with local or remote models pass through the loopback proxy at `127.0.0.1:8000`. The Context Firewall performs deep inspection to prevent credential leakage:
* **Outbound Secret Redaction**: Intercepts high-entropy hashes, private SSH/GPG keys, bearer tokens, hardware MAC addresses, and internal network IP addresses before prompts reach model weights.
* **Semantic Token Squashing**: Automatically compresses verbose terminal logs and build traces via `/usr/bin/squash`, preserving semantic density while minimizing context memory overhead.
* **Inbound Rehydration**: Reconstitutes redacted local variable names during the markdown streaming phase so you see clean, actionable code.

```mermaid
sequenceDiagram
    autonumber
    actor User as User / App / Script
    participant HUD as synapse-hud (Super+Space)
    participant FW as Context Firewall (127.0.0.1:8000)
    participant OLLAMA as Local Ollama (qwen2.5-coder)
    participant EXT as Optional Cloud Fallback

    User->>HUD: Enter prompt with source code / logs
    HUD->>FW: Forward raw payload via local loopback
    critical Deep Token Sanitization
        FW->>FW: High-entropy secret detection (API keys, tokens)
        FW->>FW: Redact hardware MAC addresses & RFC 1918 private IPs
        FW->>FW: Token squashing & semantic distillation (/usr/bin/squash)
    end
    alt Local Inference (Prime Directive Standard)
        FW->>OLLAMA: Dispatch sanitized context to local resident weights
        OLLAMA-->>FW: Stream raw generated markdown tokens
    else Cloud Endpoint (User Explicitly Configured)
        FW->>EXT: Transmit sanitized, de-identified prompt via TLS
        EXT-->>FW: Stream response back
    end
    FW->>FW: Inbound rehydration (restore local variable identifiers)
    FW-->>HUD: Stream clean, natural response to desktop HUD
    HUD-->>User: Display markdown output & trigger neural TTS (Super+Alt+S)
```

### 2. Time Machine Btrfs Subvolume Rollback
SynapseOS partitions disks with clean Btrfs subvolumes (`@` for root, `@home` for user data, `@snapshots` for Snapper). Before `pacman` writes a single byte during system upgrades, `snap-pac` captures an atomic snapshot:

```mermaid
stateDiagram-v2
    [*] --> RunningState: Healthy Running System
    RunningState --> PackageUpdateTriggered: pacman -Syu or setup update
    state PackageUpdateTriggered {
        [*] --> PreSnapshot: snap-pac triggers Snapper
        PreSnapshot --> SubvolumeSnapshot: Capture read-only @ and @home snapshot
        SubvolumeSnapshot --> ApplyBinaries: Unpack & verify signed packages
        ApplyBinaries --> PostSnapshot: Capture post-update state
        PostSnapshot --> [*]
    }
    PackageUpdateTriggered --> VerificationCheck: Reboot / Service Restart
    VerificationCheck --> RunningState: Update Verified Successful
    VerificationCheck --> SystemRegressionDetected: Issue / Driver Crash / Kernel Panic
    state SystemRegressionDetected {
        [*] --> SelectSnapshotInBootloader: Tap GRUB / systemd-boot menu
        SelectSnapshotInBootloader --> RollbackSnapshot: Run 'sudo snapper rollback'
        RollbackSnapshot --> InstantReboot: Re-point default @ subvolume
    }
    SystemRegressionDetected --> RunningState: Restored to Previous Working State in 5s
```

### 3. Monolithic Laser Boot Kinematics
During system boot, the GPU directly renders a 120 FPS twin-hook laser fabrication animation via Plymouth:

```mermaid
sequenceDiagram
    autonumber
    participant BIOS as UEFI / Firmware
    participant BOOT as systemd-boot / GRUB
    participant PLY as synapse-plymouth (Laser Fabrication Splash)
    participant SDDM as synapse-greeter (Chamfered Obsidian SDDM)
    participant SESS as Session Manager (XFCE 4.20 / Sway)
    participant DAEMON as synapse-core & ollama.service

    BIOS->>BOOT: Hand off EFI execution
    BOOT->>PLY: Kernel init (linux-cachyos BORE, x86-64-v3)
    activate PLY
    PLY->>PLY: Phase 1: Dual laser collimators cut Twin-Hook Cipher (120 FPS)
    PLY->>PLY: Phase 2: Dielectric ion arc convergence across central gap
    PLY->>PLY: Phase 3: Liquid chrome typography reveal & status telemetry
    PLY->>SDDM: Seamless graphical handoff (Zero display flicker)
    deactivate PLY
    activate SDDM
    SDDM->>SESS: Local authentication (Wheel group, zero GeoIP lookup)
    deactivate SDDM
    par Parallel Subsystem Initialization
        SESS->>SESS: Composite desktop (Picom dual_kawase glass blur)
        SESS->>DAEMON: Spawn synapse.service (127.0.0.1:8000) & resident Ollama
        SESS->>SESS: Initialize synapse-hud daemon & register Super+Space hotkey
    end
```

---

## 🛠️ Building & Verifying from Source

The entire distribution image is fully reproducible and audited against **279 strict engineering quality gates**.

### 1. Verification Gate Harness (279/279 Passing)
Run the automated test suite locally to verify packaging syntax, kernel sysctls, theme assets, and Calamares installer recipes:

```bash
git clone https://github.com/earnerbaymalay/synapseOS.git
cd synapseOS
./build/verify-gates.sh
```

### 2. Building the Bootable ISO Image
Generate a pristine `synapseos-x86_64.iso` locally using the clean Archiso profile:

```bash
# Requires Arch Linux, archiso, and squashfs-tools:
sudo ./build/build-iso.sh
```
The finished bootable image is emitted into `out/synapseos-<timestamp>-x86_64.iso`.

### 3. Public Package Repository & SDK Recipes
Community and custom packages are built using our standalone recipe harness in [`SynapseOS/public-repo`](https://github.com/SynapseOS/public-repo):
```bash
# Clone the package recipe tree:
git clone https://github.com/SynapseOS/public-repo.git
cd public-repo

# Build and verify packages with GNU Make:
make check
make all JOBS=4
```
Packages are bundled into cryptographic `.spkg` archives with USTAR formatting and Ed25519 repository index v2 signatures.

---

## 🗺️ Engineering Roadmap

```mermaid
gantt
    title SynapseOS Engineering Milestones
    dateFormat  YYYY-MM
    section Core Infrastructure
    BORE Kernel & Arch Foundation (Phases 1–5)       :done,    des1, 2026-01, 2026-06
    Laser Plymouth & Material You HUD (Phases 6–7)   :done,    des2, 2026-07, 2026-09
    Release v0.1.0-alpha.2 (279 Gates Passing)       :done,    des3, 2026-10, 2026-11
    section Active & Upcoming
    Dynamic Thermal Governor & Tuning (Phase 9.1)    :active,  des4, 2026-11, 2026-12
    eBPF Kernel Secret Leak Interceptor (Phase 9.2)  :         des5, 2027-01, 2027-03
    Peer-to-Peer Distributed Swarm Memory (Phase 10) :         des6, 2027-04, 2027-06
    Immutable Root Filesystem Mode (Phase 11)        :         des7, 2027-07, 2027-09
    Open-Source Cyberdeck Hardware Spec (Phase 12)   :         des8, 2027-10, 2027-12
```

📖 **Detailed milestone specifications & changelog:**  
➡️ [**ROADMAP.md**](ROADMAP.md)

---

## 📂 Repository Directory Layout

```
synapseOS/
├── .github/workflows/       # Automated CI/CD ISO generation & 279-gate harness
├── build/                   # Archiso live image definitions & build tooling
│   ├── archiso/             # Profile definition, package lists, syslinux/systemd-boot
│   ├── build-iso.sh         # ISO packaging script
│   └── verify-gates.sh      # 279/279 Engineering gate test harness
├── docs/                    # Technical whitepapers & installation manuals
│   ├── VENTOY_BOOT_GUIDE.md # Detailed USB burning instructions
│   ├── DUAL_BOOT_AND_HARDWARE.md # BitLocker, EFI, and partitioning manual
│   ├── HARDWARE_COMPATIBILITY.md # Detailed laptop & desktop validation matrix
│   ├── ARCHITECTURE.md      # Subsystem technical whitepaper
│   └── TECHNICAL_FAQ.md     # Audio, networking, and memory tuning FAQ
├── packages/                # Native PKGBUILD recipes & desktop components
│   ├── core/synapse-core/   # AI proxy gateway daemon & systemd services
│   ├── desktop/             # synapse-hud, synapse-greeter, themes, and plymouth
│   └── installer/calamares/ # Calamares installer branding and Btrfs configuration
├── overlay/                 # Root filesystem live overlays (sysctl, NetworkManager)
├── AGENTS.md                # System instructions & Prime Directive policies
└── ROADMAP.md               # Feature timeline & version history
```

---

## 📜 Licensing & Community

* **SynapseOS Base & Tooling**: Licensed under the **MIT License** and **GNU General Public License v3.0**. See [`LICENSE`](LICENSE) for terms.
* **Component Licenses**: Upstream packages retain their respective open-source licenses (GPL, Apache 2.0, BSD, MIT).
* **The Prime Directive**: System telemetry is permanently disabled by default. SynapseOS does not track IP addresses, usage metrics, or AI token prompts.

<div align="center">
<sub>Crafted with surgical precision for sovereign computing. Built on Arch Linux & CachyOS.</sub>
</div>
