# Antigravity IDE Handover Brief — PalexusOS
*(Formerly SynapseOS)*

**Project:** PalexusOS (`https://github.com/earnerbaymalay/synapseOS`)  
**Maintainer:** earnerbaymalay  
**Handover Status:** Phases 1–7 Complete (**254/254 Verification Gates Passing** | **17/17 pytest UI/UX Passing**); Laser Monolith Plymouth Splash & Branding Review Ready (see [`docs/BRANDING_LASER_BOOT_REVIEW.md`](docs/BRANDING_LASER_BOOT_REVIEW.md))

---

## 1. Completed Foundation (From CLI Session Handover)

All structural specifications, packaging recipes, system overlays, and live ISO build scripts have been authored, linted, and verified:

| Subsystem | Path | Status |
| :--- | :--- | :--- |
| **Core AI Runtime Package** | [`packages/core/palexus-core/PKGBUILD`](packages/core/palexus-core/PKGBUILD) | Ready (`x86-64-v3` Rust build, `palexus.service`, `palexus-sync.timer`) |
| **Palexus Command HUD & Utilities** | [`packages/desktop/palexus-hud/PKGBUILD`](packages/desktop/palexus-hud/PKGBUILD) | Ready (`palexus-hud`, `palexus-welcome`, `palexus-settings`, `palexus-notes`, `palexus-shortcuts`) |
| **LLM Quickfire Panel Package** | [`packages/desktop/llm-quickfire-panel/PKGBUILD`](packages/desktop/llm-quickfire-panel/PKGBUILD) | Ready (`quickfire`, `quickfire-theme`, palettes, XDG autostart) |
| **SDDM Greeter Package** | [`packages/desktop/palexus-greeter/PKGBUILD`](packages/desktop/palexus-greeter/PKGBUILD) | Ready (`palexusos` Qt6 theme: clock + readout, animated accent trails, `10-palexusos.conf`, variant from `palexus-theme --sync-greeter`) |
| **Plymouth Boot Splash** | [`packages/desktop/palexus-plymouth/PKGBUILD`](packages/desktop/palexus-plymouth/PKGBUILD) | Ready (`palexusos` Plymouth DRM/KMS boot splash, `palexus-boot.mp4`) |
| **Kernel, ZRAM & Stealth Overlay** | [`overlay/etc/`](overlay/etc) | Ready (`99-palexusos.conf`, `zram-generator.conf`, MAC randomization, RFC 4941 IPv6, Quad9 DoT) |
| **Cyberdeck Desktop & User Skel** | [`overlay/etc/skel/`](overlay/etc/skel) & [`picom.conf`](overlay/etc/xdg/picom.conf) | Ready (`dual_kawase` blur, Kitty transparency, Sway/Waybar dual-session, `.palexus/config.toml`, `.bashrc`) |
| **Archiso Live Profile** | [`build/archiso/`](build/archiso) & [`build/build-iso.sh`](build/build-iso.sh) | Ready (`linux-cachyos`, UEFI `systemd-boot` + BIOS `syslinux`, `customize_airootfs.sh`) |
| **Calamares Installer** | [`packages/installer/calamares/`](packages/installer/calamares) | Ready (Catppuccin Mauve + Liquid Silver Chrome + Obsidian Crust branding, Btrfs `@`/`@home`/`@snapshots` zstd layout) |
| **Theme Pack & Screensaver** | [`packages/desktop/palexus-themes/`](packages/desktop/palexus-themes) | Ready (14 wallpapers, `palexus-theme` switcher on `Super+Ctrl+T`, geodesic torus `palexus-screensaver`) |
| **Verification Gate Suite** | [`build/verify-gates.sh`](build/verify-gates.sh) | **254/254 Checks Passing** |

---

## 2. Next Execution Objectives in Antigravity IDE

Now that the workspace is open in **Antigravity IDE**, the IDE agent should execute the live build & runtime verification stages:

1. **Stage A — Local Custom Repository & Native Package Compilation (`[palexusos]`)**:
   - Compile `palexus-core`, `palexus-hud`, `palexus-themes`, `palexus-greeter`, `palexus-plymouth`, and `llm-quickfire-panel` using `./build/build-iso.sh --build-pkgs --dry-run` (or `makepkg -sf` in each package dir).
   - Verify the generated `.pkg.tar.zst` archives and local pacman database `out/repo/palexusos.db.tar.gz` via `repo-add`.
2. **Stage B — Sync Overlays & Validate Archiso Staging**:
   - Run `./build/build-iso.sh --dry-run` to populate `build/archiso/airootfs/etc` from `overlay/etc` and `packages/installer/calamares`.
   - Inspect the staged `airootfs` permissions, systemd presets, and CachyOS mirrorlists (`/etc/pacman.d/cachyos-mirrorlist` & `cachyos-v3-mirrorlist`).
3. **Stage C — Live ISO Compilation & QEMU/KVM Boot Verification**:
   - Execute `sudo ./build/build-iso.sh` to produce `out/palexusos-YYYY.MM.DD-x86_64.iso`.
   - Boot the ISO in QEMU/KVM (`PalexusOS: Boot ISO in QEMU/KVM` task in `.vscode/tasks.json`) to verify:
     * UEFI `systemd-boot` splash $\rightarrow$ `linux-cachyos` kernel boot
     * `palexusos` SDDM greeter $\rightarrow$ XFCE 4.20 / Sway desktop handoff (boot splash: `palexus-plymouth` Laser Monolith boot)
     * `palexus-hud` / `quickfire` HUD auto-launch, `palexus.service` health, and Calamares installer launch.
4. **Stage D — Release Tagging (`v0.1.0-alpha`)**:
   - Generate `out/SHA256SUMS`, commit any build refinements, and tag `v0.1.0-alpha` to trigger `.github/workflows/build-iso.yml`.

---

## 3. Quick-Start Prompt for Antigravity IDE Agent

Paste this into the Antigravity IDE agent panel to begin immediately:

> Read `IDE_HANDOVER.md`, `ROADMAP.md`, and `docs/ARCHITECTURE.md`. Run `./build/verify-gates.sh` (254 passing gates), verify the compiled `[palexusos]` repository packages in `out/repo/` (`palexus-core`, `palexus-hud`, `llm-quickfire-panel`, `palexus-themes`, `palexus-greeter`, `palexus-plymouth`, `palexusos.db.tar.gz`) and staged `airootfs` from Stages A & B, then proceed to Stage C & Stage D: build the bootable Live ISO (`./build/build-iso.sh`), verify QEMU/KVM boot, and prepare the `v0.1.0-alpha` release artifacts (`out/SHA256SUMS`).
