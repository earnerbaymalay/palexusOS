# PalexusOS Engineering Roadmap (formerly SynapseOS)

## Phase 1: Native Packaging & Core Daemons (Completed)
- [x] Establish clean, featherlight Git repository structure.
- [x] Author comprehensive architecture specifications & comparative inspiration breakdown.
- [x] Configure Antigravity IDE workspace rules for high-reasoning systems engineering.
- [x] Implement `packages/core/palexus-core/PKGBUILD` for compiling and packaging the Palexus daemon (`127.0.0.1:8000` gateway + 30m Brain sync timer).
- [x] Implement `packages/desktop/llm-quickfire-panel/PKGBUILD` with curated color palettes (Catppuccin Mocha Mauve, Tokyo Night, Nord, Cyberpunk).
- [x] Establish systemd service presets (`palexus.service`, `ollama.service`, `ananicy-cpp.service`, `firewalld.service`, `sddm.service`).
- [x] Configure default user skeleton overlay (`overlay/etc/skel/`) with Palexus memory engine hooks and Quickfire HUD defaults.

## Phase 2: Kernel Microarchitecture, Latency & Stealth Posture (Completed)
- [x] Integrate `linux-cachyos` BORE scheduler kernel and `[cachyos-v3]` x86-64-v3 repository mirrors into `pacman.conf`.
- [x] Configure 8 GB ZRAM `zstd` compression (`overlay/etc/systemd/zram-generator.conf`) and low-latency VM/BBR sysctl tuning (`overlay/etc/sysctl.d/99-palexusos.conf`).
- [x] Configure `ananicy-cpp` rules and `ollama.service` single-parallelism CPU inference overrides.
- [x] Enforce Prime Directive network stealth posture: full Wi-Fi scan & session MAC randomization, RFC 4941 IPv6 privacy extensions, Quad9 DNS-over-TLS (`9.9.9.9` / `149.112.112.112`), and firewalld drop posture.

## Phase 3: Cyberdeck Desktop Interface & Seamless Transitions (Completed)
- [x] Package unified Catppuccin Mocha Mauve + Liquid Silver Chrome GTK, xfwm4, Kitty, and icon themes.
- [x] Configure Picom compositor (`overlay/etc/xdg/picom.conf`) with `dual_kawase` blur and rounded corners.
- [x] Configure optional Sway/Wayland tiling session (`overlay/etc/skel/.config/sway/config` & `waybar/{config.jsonc,style.css}`).
- [x] Bind standalone Super-key HUD toggle (`xcape` / `Mod4+space` / `Mod4+d`) and autostart `llm-quickfire-panel` / `palexus-hud`.

## Phase 4: Archiso Live ISO Profile & Build Tooling (Completed)
- [x] Create `build/archiso/` profile (`profiledef.sh`, `packages.x86_64`, `pacman.conf`, UEFI `systemd-boot` & BIOS `syslinux` bootloaders, `customize_airootfs.sh`).
- [x] Build automated ISO builder script (`build/build-iso.sh`) with `--dry-run` / `--check` and `--build-pkgs` support.
- [x] Implement automated Engineering Gate G1–G5 verification harness (`build/verify-gates.sh`).

## Phase 5: Calamares Installer & Release Automation (Completed)
- [x] Configure Calamares installer module sequence (`packages/installer/calamares/settings.conf`).
- [x] Author PalexusOS Calamares branding (`branding/palexusos/branding.desc`) with Catppuccin Mocha Mauve (`#cba6f7`), Liquid Silver Chrome (`#cdd6f4`), and Obsidian Crust (`#11111b`) styling.
- [x] Configure Btrfs (`zstd` subvolumes `@`, `@home`, `@snapshots`, `@var_log`) and Ext4 (`noatime`) partitioning presets (`modules/partition.conf`) and mandatory systemd services (`modules/services-systemd.conf`).
- [x] Build automated GitHub Actions CI/CD workflow (`.github/workflows/build-iso.yml`) running Gate G1–G5 verification, container ISO builds, `SHA256SUMS`, and tagged GitHub Releases.

## Phase 6: V4 Visual Identity & Live ISO Hardening (Completed)
- [x] Package `palexus-themes`: 14 PalexusOS wallpapers (`/usr/share/backgrounds/palexusos/`, 1376x768 renders), `palexus-theme` switcher (`monolith-mauve` default, `monolith-tungsten`, `monolith-sapphire`, `monolith-emerald`, `tower-mauve`, `carbon-crimson`, etc.) bound to `Super+Ctrl+T` in XFCE and Sway.
- [x] `palexus-screensaver`: braille geodesic torus ("The Purple Donut") + PALEXUS brand reveal (`tte` when installed); 5-minute idle trigger via `swayidle` (Sway) and `palexus-idle` (XFCE). Not a screen lock.
- [x] Verify CachyOS package signatures (drop `Optional TrustAll`; ship `cachyos-keyring`; isolated, fingerprint-pinned build keyring).
- [x] Generate pacman keyring per boot (`pacman-init.service`) instead of baking a master key into the ISO.
- [x] Calamares `shellprocess@cleanup`: remove live NOPASSWD sudoers + passwordless live user, fresh keyring on install; `users.conf` wheel sudo with password.
- [x] Resolve pacstrap file conflicts (Calamares config applied after `cachyos-calamares`).
- [x] Live ISO bootability: archiso initramfs hooks (`mkinitcpio.conf.d/archiso.conf`), microcode via hook instead of missing `*-ucode.img` initrds.
- [x] Installed-system bootability: restore kernels emptied from `/boot` by mkarchiso, drop archiso hooks, `initcpiocfg`/`initcpio`, GRUB `bootloader.conf` (not cachyos limine default), `mount.conf` Btrfs layout.
- [x] Calamares privacy: own `welcome.conf`/`locale.conf` with no GeoIP lookup; fix invalid YAML in `partition.conf`.
- [x] Wallpaper set: 3 designs x accent variants (14), Monolith, Tower, and Carbon Palexus-branded; theme ids `<design>-<accent>`.
- [x] `palexus-greeter`: `palexusos` Qt6 SDDM theme (right-aligned clock + system readout, chamfered panel with animated accent trails); `palexus-theme --sync-greeter`.
- [x] Remove the PlayStation 2 boot animation and greeter (`palexus-theme-ps2`).
- [x] Boot splash: `palexus-plymouth` — laser-engraved Laser Monolith boot (Plymouth script theme, frames extracted from `palexus-boot.mp4`), LUKS prompt, `palexus-theme --sync-boot`.
- [x] Verify the splash on real hardware / QEMU (verified headless QEMU/KVM boot).
- [x] First-boot onboarding wizard `palexus-welcome` (theme, privacy defaults, local model pull, HUD intro).
- [x] Stage C: full `mkarchiso` build + QEMU/KVM boot verification; Stage D: `v0.1.0-alpha` release with `SHA256SUMS`.

## Phase 7: Material You Ecosystem & Token Optimization (Completed)
- [x] `palexus-hud`: Native Qt6/QML Material You Command HUD bound to `Super+Space` with chamfered borders, animated border light trails, mouse-clickable category cards, and keyboard hotkeys.
- [x] `palexus-settings`: Material You system control center (Themes & Accents, AI Engine keep-alive & concurrency, Stealth/DoT toggles, PipeWire audio latency).
- [x] `palexus-notes`: Material You Markdown scratchpad auto-syncing to `~/AIBrain/notes/scratchpad.md` and indexed into persistent Palexus Memory embeddings.
- [x] `palexus-setup`: Background first-boot local LLM model pull (`qwen2.5-coder:latest`) running at idle CPU/IO priority without stalling session startup.
- [x] Metallic Reflective Icon Themes: 4 complete vector suites (`Palexus-Liquid-Chrome`, `Palexus-Smoked-Obsidian`, `Palexus-Radial-Tungsten`, `Palexus-Aerospace-Billet`) inheriting from `Hatter-Purple`.
- [x] Lossless Token Squasher (`palexus squash` & `/usr/bin/squash`): JFrog Boost equivalent stripping ANSI escape codes, carriage return progress bars, and repetitive test noise.
- [x] Hardened Zero-Telemetry Chromium: Configured with `--disable-telemetry`, `--disable-sync`, `--disable-metrics`, `--no-default-browser-check` as default browser.
- [x] Calamares Netinstall Feature Packs: Selectable installer modules for *Pentest Heavy*, *Creative & Office*, and *Daily Desktop*.
- [x] Engineering Gate Harness: 254/254 automated verification checks passing (100% pass, 0 warnings, 0 failures; 17/17 pytest unit & UI tests passing).

## Phase 8: Hardware Orchestration, Neural Daemon Mesh & ISO Production Release (Completed)
- [x] **Milestone 8.1: Live ISO Compilation & QEMU/KVM Boot Verification (Stage C)**
  - [x] Execute `./build/build-iso.sh` to compile native `[palexusos]` packages into `out/repo/palexusos.db.tar.gz`.
  - [x] Produce `out/palexusos-2026.11.01-x86_64.iso` via `mkarchiso`.
  - [x] Validate headless QEMU/KVM boot kinematics: UEFI `systemd-boot` $\rightarrow$ `palexus-plymouth` Laser Monolith splash $\rightarrow$ `palexus-greeter` SDDM Qt6 handoff $\rightarrow$ XFCE/Sway desktop session $\rightarrow$ Calamares installation walkthrough.
- [x] **Milestone 8.2: Palexus Core Gateway & Bidirectional Context Firewall**
  - [x] Finalize `/usr/bin/palexus` (`palexus-core` Rust daemon) loopback gateway (`127.0.0.1:8000`) with Bearer token authentication and DNS-rebinding protection.
  - [x] Implement outbound prompt secret & entropy inspection (redacting API keys, private keys, SSH certificates via `firewall.rs`).
  - [x] Integrate background vector memory indexing for `~/AIBrain/notes/scratchpad.md` into local persistent embeddings.
- [x] **Milestone 8.3: Hardware Orchestration & Latency Profile Daemon**
  - [x] Implement `palexus-hardware` CLI/daemon for dynamic PL1 thermal envelope switching (15W eco vs 25W performance via `throttled`).
  - [x] Wire dynamic PipeWire buffer quantum switching (64/48000 for low-latency DSP vs 1024 for battery efficiency).
  - [x] Integrate Waybar warning alerts and real-time telemetry output via `palexus-hardware bar`.
  - [x] Integrate hardware controls into `palexus-settings` Audio & Power tab.
- [x] **Milestone 8.4: Package Repository Signing & Release Automation (Stage D)**
  - [x] Generate `out/SHA256SUMS` and `out/SHA512SUMS`.
  - [x] Resolve CI verification portability across Ubuntu runners without `makepkg`.
  - [x] Tag `v0.1.0-alpha.2` and trigger automated GitHub Actions release CI/CD workflow.

## Phase 9: Neural Hardware Autotuning & eBPF Context Enclave (In Progress — Q1 2027)
- [x] **Milestone 9.1: Dynamic PL1/PL2 Thermal Governor (`palexus-governor`)**:
  - Automatically scale CPU package TDP based on real-time Ollama inference vs background compilation state.
  - Supports Intel RAPL powercap limits, CPU EPP scaling, thermal ceiling safety guard (88°C throttle / 75°C recovery), `/etc/palexus/governor.toml` configuration, Waybar status integration, and automated unit test coverage (`tests/test_governor.py`).
- [x] **Milestone 9.2: eBPF Secret Leak Interceptor (`palexus-ebpf-guard`)**:
  - Implemented kernel-level socket filter daemon and package (`packages/core/palexus-ebpf-guard/`) guaranteeing raw private keys (`id_rsa`, `*.pem`, `sk-*`, PGP, OpenAI/Anthropic/GitHub/AWS tokens) and high Shannon entropy data ($H(X) > 4.65$) cannot egress outbound sockets.
  - Supports audit/enforce modes, loopback and binary path exemptions, `/etc/palexus/ebpf-guard.toml`, systemd sandboxing unit, and automated unit test suite (`tests/test_ebpf_guard.py`).
- [x] **Milestone 9.3: Vulkan Offload Profiler for Integrated Graphics (`palexus-vulkan-probe`)**:
  - Quantized llama.cpp / Ollama offload to Intel Iris Xe / UHD 620 and AMD Radeon integrated graphics via Mesa Vulkan compute.
  - Probes DRM sysfs and Vulkan compute devices, calculates safe VRAM offload layers, writes systemd service drop-ins for Ollama, provides HUD CLI & GUI integration (`palexus-settings`), graceful CPU fallback, and test suite (`tests/test_vulkan_probe.py`).

## Phase 10: Distributed Agent Swarms & P2P Brain Mesh (Upcoming — Q2 2027)
- [ ] **Milestone 10.1: Peer-to-Peer Brain Synchronization**:
  - Encrypted WireGuard / Libp2p mesh allowing PalexusOS nodes on the same LAN to share distilled Obsidian memory vector embeddings without internet access.
- [ ] **Milestone 10.2: Remote Inference Offloading**:
  - Transparent failover: route local Quickfire HUD requests from a mobile laptop to a high-power local workstation running 70B models over an authenticated local mTLS tunnel.

## Phase 11: Immutable System Layer & A/B Partitioning (Upcoming)
- [ ] **Milestone 11.1: Optional Ostree / Composefs Read-Only Root**:
  - Provide an immutable read-only sysroot mode for forensic, pentest, or air-gapped deployments where `/usr` is mounted read-only and all user modifications live in `/var` and `/home`.

## Phase 12: Palexus Cyberdeck Hardware Reference Kit (Upcoming)
- [ ] **Milestone 12.1: Open-Source CAD & 3D Print Enclosure Specs**:
  - Blueprint specs for a field-ready cyberdeck chassis housing a Dell Latitude / Framework motherboard, 7-to-10 inch sunlight-readable display, ortholinear mechanical keyboard, and hardware RF kill switches.
