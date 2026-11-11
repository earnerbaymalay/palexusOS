# PalexusOS System Architecture Specification

## 1. Vision & Core Philosophy

**PalexusOS** is an AI-native rolling Linux operating system engineered from the ground up for developers, security researchers, and AI-assisted workflows. It synthesizes four distinct paradigms:

| Paradigm | Engineering Source | Core Technical Focus | Distro Implementation |
| :--- | :--- | :--- | :--- |
| **Performance** | CachyOS | Low-latency BORE scheduler & AVX2 binaries | `linux-cachyos` BORE/EEVDF, `x86-64-v3`, 8GB ZRAM `zstd`, `ananicy-cpp` |
| **Arch Simplicity** | EndeavourOS | Transparent rolling package foundation | Clean Arch rolling sync, transparent `pacman.conf`, modular Calamares Btrfs |
| **Cyber Aesthetic** | Omarchy | Terminal-first monospace HUD & metallic themes | Kitty + `ble.sh`, Catppuccin Mocha Mauve + Liquid Chrome, dual compositors |
| **AI Subsystem** | Palexus Native | Offline-first private neural intelligence | `palexus-core` gateway (port 8000), Bidirectional Context Firewall, resident Ollama |

---

## 2. Layered Operating System Stack

```mermaid
flowchart TD
    subgraph UI ["Layer 4: Cyberdeck Interface (Omarchy / Catppuccin)"]
        W["XFCE 4.20 / Sway Wayland Compositor"]
        P["Palexus Command HUD & Live Palette"]
        K["Kitty Terminal with JetBrains Mono & ble.sh"]
    end

    subgraph AI ["Layer 3: Palexus AI Core Subsystem"]
        GW["Palexus Gateway Proxy (localhost:8000)"]
        FW["Bidirectional Context & Secret Firewall"]
        MEM["3-Layer Memory Engine (~/.palexus/memory)"]
        LLM["Resident Local Ollama (qwen2.5-coder / llama3.2)"]
    end

    subgraph OS ["Layer 2: Base Distribution & Tooling (EndeavourOS Style)"]
        ARCH["Upstream Arch Linux Rolling Repositories"]
        PKG["PalexusOS Native Packages (palexus-core, palexus-themes, palexus-hud)"]
        SYS["systemd System & User Services"]
        SEC["Stealth Network Posture (Quad9 DoT, MAC Randomization)"]
    end

    subgraph KERNEL ["Layer 1: Low-Latency High-Throughput Kernel (CachyOS Style)"]
        CK["linux-cachyos (BORE Scheduler, BBR TCP, futex2)"]
        OPT["x86-64-v3 Microarchitecture AVX2/BMI2 Binaries"]
        MEMT["ZRAM 8GB (zstd, swappiness=180, page-cluster=0)"]
        ANAN["ananicy-cpp Auto-Nice Daemon"]
    end

    UI --> AI
    AI --> OS
    OS --> KERNEL
```

---

## 3. Core System Subsystems

### A. Kernel & Microarchitecture Optimization (CachyOS Inspiration)
- **Kernel**: `linux-cachyos` or custom `linux-palexus` built with GCC/Clang with `-O3 -march=x86-64-v3` flags.
- **CPU Scheduling**: BORE (Burst-Oriented Response Enhancer) or EEVDF for zero-latency interactive shell responsiveness even when background compilation or LLM token generation runs at 100% CPU load.
- **Memory & Swap**: 8GB ZRAM compressed with `zstd`. Kernel sysctl parameters:
  - `vm.swappiness = 180`
  - `vm.page-cluster = 0`
  - `vm.vfs_cache_pressure = 50`
- **Networking**: `tcp_bbr` congestion control enabled by default.

### B. Minimalist Arch Foundation (EndeavourOS Inspiration)
- **Base**: Direct rolling synchronization with Arch Linux upstream package repositories.
- **Zero Bloat Policy**: No heavy background telemetry daemons, no unnecessary Flatpak runtimes pre-bundled, no hidden cron scripts.
- **Transparent Pacman Configuration**: Clean `/etc/pacman.conf` with dedicated `[palexusos]` repository overlay taking precedence for optimized binaries and AI packages.
- **Installation**: Modular Calamares installer supporting Btrfs with auto-snapshots, Ext4 with noatime, and ZFS.

### C. Cybernetic Terminal & Desktop Interface (Omarchy Inspiration)
- **Palette & Theme**: Unified Catppuccin Mocha Mauve + Liquid Chrome styling across terminals, GTK, icons, and SDDM.
- **Window Management**: XFCE 4.20 (customized with `Catppuccin-Mauve-Dark` and native Launchpad launcher) + optional Sway/Wayland tiling session.
- **Live HUD & Palette**: Standalone Super-key toggle (`xcape` / `Mod4+space`) opening the searchable Palexus command palette (`palexus-hud`) with instant telemetry monitors.

### D. The Palexus AI Subsystem
- **Core Binary**: `/usr/bin/palexus` built from Rust sources (`packages/core/palexus-core`).
- **System Service**: Managed by systemd (`palexus.service`), exposing a secure loopback gateway with bearer tokens and DNS-rebinding protection.
- **Context Firewall**: Bidirectional inspection verifying that credentials, private keys, and high-entropy secrets are blocked *before* they leave the machine or touch disk.
- **Persistent Agent Memory**: Central storage at `/var/lib/palexus/memory` or `~/.palexus/memory`, with automated distillation to Obsidian.
