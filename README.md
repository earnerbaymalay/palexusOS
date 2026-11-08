<div align="center">

# SynapseOS

### **The AI-Native Sovereign Workstation**  
*Surgical Precision. Zero Cloud Friction. One Brain. All Models.*

[![Build & Engineering Gates](https://img.shields.io/github/actions/workflow/status/earnerbaymalay/synapseOS/build-iso.yml?branch=main&label=Build%20%26%20Gates&logo=githubactions&logoColor=cdd6f4&color=cba6f7&style=flat-square)](https://github.com/earnerbaymalay/synapseOS/actions/workflows/build-iso.yml)
[![Verification Gates](https://img.shields.io/badge/Gates-276%20checks-3fb950?style=flat-square&logo=shield&logoColor=ffffff)](build/verify-gates.sh)
[![Release](https://img.shields.io/github/v/release/earnerbaymalay/synapseOS?include_prereleases&label=Latest%20Release&color=74c7ec&style=flat-square)](https://github.com/earnerbaymalay/synapseOS/releases)
[![Rolling Base](https://img.shields.io/badge/Rolling%20Base-Arch%20Linux-1793d1?style=flat-square&logo=archlinux&logoColor=ffffff)](https://archlinux.org)
[![Kernel](https://img.shields.io/badge/Kernel-linux--cachyos%20(BORE)-fab387?style=flat-square&logo=linux&logoColor=ffffff)](https://github.com/CachyOS/linux-cachyos)
[![Telemetry](https://img.shields.io/badge/Telemetry-0%20(Prime%20Directive)-f38ba8?style=flat-square&logo=privatedivision&logoColor=ffffff)](#-the-prime-directive-zero-telemetry-sovereignty)
[![License](https://img.shields.io/badge/License-MIT%20%2F%20GPLv3-d4dae2?style=flat-square)](LICENSE)

<br/>

<img src="docs/assets/synapseos-banner.png" alt="SynapseOS Monolithic Banner" width="100%"/>

<br/>

SynapseOS breaks the telemetry paradigm. Built on the high-throughput CachyOS BORE kernel and an EndeavourOS-style Arch foundation, it runs AI models directly on your own hardware. No telemetry, no token meters, and nothing leaves the machine unless you choose a cloud model.

<img src="docs/assets/synapseos-teaser.gif" alt="Animated concept render: a SynapseOS laptop booting into its neural HUD" width="480"/>
<br/><sub><i>Concept render</i></sub>

[**60-Second Virtual Test Drive**](#-test-drive-in-60-seconds-no-usb-required) • [**Install in 3 Steps**](#-get-started-in-3-steps) • [**System Architecture**](#-system-architecture--subsystems) • [**Hardware Support**](#-supported-hardware-matrix) • [**Documentation**](docs/)

</div>

### The Sovereign Architecture

<table>
<tr>
<td width="44%" valign="top">
<img src="docs/assets/synapseos-super-space.gif" alt="Animated concept render: Super+Space summons the assistant over a terminal showing TELEMETRY: 0" width="100%"/>
<sub><i>Concept render</i></sub>
</td>
<td valign="top">

- **Silicon-Resident AI (`Super + Space`):** One keystroke opens the Command HUD, answered by a local Ollama model built on x86-64-v3 (AVX2/BMI2) optimized packages. Cloud Claude is strictly opt-in.
- **The Prime Directive:** Hardware MAC randomization, Quad9 DNS-over-TLS (`9.9.9.9:853`), RFC 4941 IPv6 privacy addresses, and a default-drop inbound firewall.
- **BORE Responsiveness:** CPU scheduling keeps terminal and UI threads responsive even while local inference saturates every core.
- **Btrfs Foundation:** Installs onto a Btrfs subvolume layout by default, ready for snapshot-based rollback.

</td>
</tr>
</table>

---

## ⚡ Why SynapseOS? (The Plain-English Breakdown)

Modern commercial operating systems increasingly treat your hardware as a client terminal to harvest data, deliver unsolicited promotions, and charge ongoing subscriptions for basic intelligence features.

**SynapseOS turns the paradigm inside-out:**

* 🧠 **Your AI Lives on Your Silicon**: Tap **`Super + Space`** from any screen to summon your local AI assistant. Query documentation, generate code, draft technical reports, and execute system commands. The weights run **100% locally on your CPU and GPU via resident Ollama models**—no internet connection required, zero token meters, and total privacy on airplane mode.
* 🛡️ **The Prime Directive (Zero Telemetry)**: Every network interface enforces hardware MAC address randomization. IPv6 privacy extensions (RFC 4941) are active by default. Outbound DNS queries are encrypted over TLS via Quad9 (`9.9.9.9:853`), and system daemons operate with a default-drop inbound firewall posture.
* 🚀 **Instantaneous Response (BORE Scheduler & AVX2)**: Utilizing `linux-cachyos` with the **Burst-Oriented Response Enhancer (BORE)**, interactive terminal typing and UI animations retain zero-latency priority even during 100% CPU multi-threaded local AI inference or kernel compilation.
* 🛡️ **Btrfs Foundation**: Installs onto a Btrfs subvolume layout by default. Automatic per-update snapshots with boot-menu rollback (snapper + snap-pac + grub-btrfs) are planned but not shipped yet.
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

Want to test SynapseOS right now without touching your hard drive or flashing a USB stick? You can run it inside a virtual machine in under a minute:

### Option A: Linux & macOS (Quick Virtual Machine / QEMU Walkthrough)

Most operating systems do not come with `qemu` pre-installed. You can install it in seconds using your system's package manager, or use a zero-terminal GUI like **GNOME Boxes** (Linux) or **UTM** (macOS).

> [!NOTE]
> **On Windows?** Jump directly to **[Option B: Windows (VirtualBox, Hyper-V, or winget QEMU)](#option-b-windows-virtualbox-hyper-v--winget-qemu-walkthrough)**. Linux commands like `sudo apt` will fail in Windows PowerShell. If using WSL2, enter `wsl` first before running apt commands.

#### Step 1: Install QEMU on Linux / macOS (If not already installed)

Run the command for your operating system terminal:

* **Ubuntu / Debian / Linux Mint (Bash / Zsh)**:
  ```bash
  sudo apt update && sudo apt install -y qemu-system-x86 qemu-utils
  ```
* **Arch Linux / CachyOS / Manjaro**:
  ```bash
  sudo pacman -S --needed qemu-desktop
  ```
* **Fedora / RHEL**:
  ```bash
  sudo dnf install -y qemu-kvm
  ```
* **macOS (via Homebrew)**:
  ```bash
  brew install qemu
  ```

> [!TIP]
> **Prefer a graphical app without terminal commands?**
> * **Linux**: Install **GNOME Boxes** (`sudo apt install gnome-boxes` or `sudo pacman -S gnome-boxes`), click **+** (New VM), click *Select a file*, and choose `synapseos-x86_64.iso`.
> * **macOS**: Download free **[UTM](https://mac.getutm.app)**, select *Create a New Virtual Machine > Virtualize > Linux*, and select `synapseos-x86_64.iso`.

#### Step 2: Download & Launch SynapseOS in One Command

Once QEMU is installed, copy and paste this into your terminal:

```bash
# 1. Download the latest verified ISO:
curl -LO https://github.com/earnerbaymalay/synapseOS/releases/latest/download/synapseos-x86_64.iso

# 2. Launch the accelerated virtual machine:
# On Linux (Hardware KVM acceleration):
qemu-system-x86_64 \
  -enable-kvm -m 8G -smp 4 -cpu host \
  -vga virtio -display gtk,gl=on \
  -audiodev pa,id=snd0 -device intel-hda -device hda-duplex,audiodev=snd0 \
  -cdrom synapseos-x86_64.iso -boot d

# On macOS (Hardware HVF acceleration):
# qemu-system-x86_64 -accel hvf -m 8G -smp 4 -cpu host -vga virtio -display default -cdrom synapseos-x86_64.iso -boot d
```

#### What happens next:
1. **Boot**: The virtual machine window opens immediately and plays the authentic 3D liquid chrome boot loading sequence.
2. **Desktop**: Within 10 seconds, you are on the SynapseOS desktop in Live Mode.
3. **Controls**:
   - Tap **`Ctrl + Alt`** (or **`Ctrl + Alt + G`**) at any time to release your mouse cursor back to your host system.
   - Tap **`Ctrl + Alt + F`** to toggle fullscreen.
4. **Try Local AI**: Press **`Super + Space`** (the `Windows` key + `Space`) to summon the Synapse Command HUD and prompt the local model.
5. **Exit**: Simply close the VM window when you're done. No traces or persistent files are left on your computer.

---

### Option B: Windows (VirtualBox, Hyper-V & winget QEMU Walkthrough)

You can test SynapseOS on Windows using any of these free methods:

#### Method 1: Install QEMU on Windows via winget (PowerShell)
If you prefer a lightweight terminal-launched VM directly in Windows:

1. Open **PowerShell** (no administrator rights needed) and install QEMU:
   ```powershell
   winget install SoftwareFreedomConservancy.QEMU
   ```
2. Download `synapseos-x86_64.iso` from [GitHub Releases](https://github.com/earnerbaymalay/synapseOS/releases).
3. Launch QEMU with Windows Hypervisor acceleration (WHPX):
   ```powershell
   & "C:\Program Files\qemu\qemu-system-x86_64.exe" -accel whpx -m 8G -smp 4 -cdrom synapseos-x86_64.iso -boot d
   ```

#### Method 2: Using VirtualBox (Recommended for Graphical Controls)
1. **Download**: Grab `synapseos-x86_64.iso` from our [Releases](https://github.com/earnerbaymalay/synapseOS/releases).
2. **Create VM**:
   - Open VirtualBox and click **New**.
   - Name: `SynapseOS` • Type: `Linux` • Version: `Arch Linux (64-bit)`.
   - **Hardware**: Set Base Memory to **`8192 MB`** (8 GB) and Processors to **`4 CPUs`** (minimum 2).
   - **Hard Disk**: Select *"Do not add a virtual hard disk"* if you only want to test the live ISO (or create a 30 GB disk if you want to test the installer).
3. **Configure Display**:
   - Go to **Settings > Display**.
   - Set Video Memory to **`128 MB`** and check **Enable 3D Acceleration**.
4. **Attach ISO & Start**:
   - Under **Settings > Storage**, click the optical drive icon and select `synapseos-x86_64.iso`.
   - Click **Start**! Within seconds, you are in the live Cyberdeck environment.
   - Tap the **Right `Ctrl`** key to release the mouse back to Windows.

#### Method 3: Using Hyper-V (Windows 11/10 Pro & Enterprise)
1. Open **Hyper-V Manager** and click **Quick Create**.
2. Select **Local Installation Source**, click **Change Installation Source**, and select `synapseos-x86_64.iso`.
3. Uncheck *"This machine will run Windows"*.
4. Under **More Options**, ensure Memory is set to at least `8192 MB`.
5. Click **Create Virtual Machine** and launch!

---

## 🚀 Get Started in 3 Steps

SynapseOS runs natively on standard laptops, workstations, and custom desktops (Dell Latitude, ThinkPad, Framework, ASUS ROG, HP, Razer, Intel/AMD/NVIDIA).

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

## ⚙️ System Architecture & Subsystems

SynapseOS replaces complex legacy distributions with four tightly integrated architectural layers designed for speed, privacy, and local intelligence:

### Layer 1: Low-Latency Silicon & Kernel
* **Kernel**: `linux-cachyos` with the **Burst-Oriented Response Enhancer (BORE)** scheduler and dynamic EEVDF. Interactive terminal typing, desktop compositing, and audio threads never stutter, even during 100% CPU multi-threaded LLM token generation.
* **Microarchitecture Binaries**: Compiled targeting `x86-64-v3` microarchitecture with AVX2, FMA3, and BMI2 vectorization.
* **Aggressive Memory Compression**: 8 GB ZRAM block device compressed with `zstd` (`vm.swappiness=180`, `page-cluster=0`, `vfs_cache_pressure=50`).
* **Dynamic Thermal Governor**: Dedicated neural governor (`synapse-governor.service`) elevating CPU Energy Performance Preference (EPP) to `performance` during model generation, then stepping down to `balance_power` during idle.

### Layer 2: Base Distribution & Stealth Network Posture
* **Rolling Arch Base**: Rolling synchronization with upstream Arch Linux repositories, transparent package management, and systemd isolation.
* **Hardware Anonymization**: NetworkManager automatically randomizes MAC addresses on every Wi-Fi scan and connection.
* **Encrypted DNS & IPv6 Privacy**: Outbound DNS queries route via Quad9 DNS-over-TLS (`9.9.9.9:853` via systemd-resolved) with RFC 4941 temporary IPv6 addresses.
* **Time Machine Rollbacks**: Every `pacman` update captures a read-only Btrfs snapshot into `/.snapshots`. If an update ever fails, roll back to the previous working state in 5 seconds directly from the bootloader.

### Layer 3: Sovereign AI Core & Context Firewall
* **Local Loopback Gateway**: `synapse-core` daemon listening exclusively on `127.0.0.1:8000` with bearer-token authentication and DNS-rebinding protection.
* **Bidirectional Context Firewall**: Automatically intercepts prompts and redacts private SSH/GPG keys, high-entropy tokens, MAC addresses, and private IPs before prompts reach model weights.
* **Lossless Token Squashing**: Built-in `/usr/bin/squash` utility compresses repetitive compiler traces and terminal dumps, preserving semantic meaning while dramatically reducing context memory usage.
* **Resident Neural Models**: Resident Ollama engine running quantized local models (`qwen2.5-coder:latest`) directly on CPU AVX2 and Vulkan GPU memory with 24-hour keepalive.

### Layer 4: Cyberdeck Interface & Presentation
* **Dual Compositor Choice**: Ultra-fast XFCE 4.20 with `picom dual_kawase` glass blur, alongside an optional hardware-accelerated Sway Wayland tiling session.
* **First-Boot Setup**: Boot goes straight into a full-screen setup wizard (`synapse-welcome --oobe`): create your account, pick a look (the wallpaper behind it is the live preview), choose a local or cloud AI assistant, review live privacy status, then land on the login screen with your account selected. No account is created by the installer; a single argument-less root helper (`synapse-oobe-apply`) creates it and removes the setup session afterwards.
* **Dedicated Claude & Multi-Model AI Console**: Integrated directly into onboarding with Anthropic API key configuration, Claude 3.7 Sonnet / Opus model targeting, and live interactive query testing.
* **12-Toggle Modular Combo Matrix**: Interactive cyberdeck hardware, privacy, and kernel switches (Prime Directive stealth MAC, Quad9 DoT, strict firewall drop, volatile RAM scrub, Ollama daemon, vector memory, GPU tensor boost, BORE scheduler, ZRAM filesystem, 64-sample audio).
* **Qt6 Chamfered HUD**: Standalone `Super + Space` command HUD for instant AI chatting, calculations, file search, and app launching.
* **Hardware-Accelerated Terminal**: GPU-rendered Kitty terminal with JetBrains Mono Nerd Font and `ble.sh` syntax highlighting.
* **Authentic 3D Chrome Aesthetics**: Four metallic vector icon suites (*Liquid Chrome*, *Smoked Obsidian*, *Radial Tungsten*, *Aerospace Billet*) and custom embossed SDDM greeter.

---

## 🛠️ Building & Verifying from Source

The entire distribution image is fully reproducible and audited against **270 strict engineering quality gates**.

### 1. Verification Gate Harness (270/270 Passing)
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

## 🗺️ Roadmap & Engineering Milestones

* **Phase 1–5**: Core daemons, BORE kernel, cyberdeck styling, live archiso profile, Calamares Btrfs.
* **Phase 6–7**: V4 visual identity, 3D liquid chrome boot loading sequence, Material You HUD ecosystem, token squasher.
* **Phase 8**: Clean 2.9 GB ISO compilation, `synapse-hardware` CLI orchestration, 279/279 engineering gate verification, release `v0.1.0-alpha.2`.
* **Phase 9.1 (Active)**: Dynamic PL1/PL2 CPU thermal and neural governor (`synapse-governor`).
* **Phase 9.2 (Upcoming)**: Kernel-level eBPF secret leak interceptor and Vulkan compute offloading.
* **Phase 10 (Q2 2027)**: Peer-to-peer encrypted WireGuard/Libp2p brain synchronization and LAN inference offloading.
* **Phase 11**: Optional Ostree / Composefs read-only immutable root filesystem mode.
* **Phase 12**: Open-source CAD cyberdeck chassis hardware specifications.

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
