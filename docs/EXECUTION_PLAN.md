# PalexusOS Live Compilation & Release Execution Plan

This document defines the four-stage execution pipeline (`Stage A` – `Stage D`) transitioning PalexusOS (formerly SynapseOS) from its engineering verification gate baseline into native package compilation, Archiso staging, live ISO image generation, QEMU/KVM validation, and release tagging.

---

## Stage A — Local Custom Repository & Native Package Compilation (`[palexusos]`)

Compile all native PalexusOS packages into the local `[palexusos]` repository (`out/repo/`) and generate the signed/indexed Pacman database (`palexusos.db.tar.gz`):

1. **`palexus-core` (`packages/core/palexus-core/PKGBUILD`)**:
   - Compiles the Rust `/usr/bin/palexus` runtime gateway with `-C target-cpu=x86-64-v3 -C opt-level=3 -C codegen-units=1`.
   - Bundles `palexus.service` (system unit on `127.0.0.1:8000`), `palexus-sync.service`, `palexus-sync.timer` (30-minute Obsidian knowledge distillation), `/etc/palexus/config.toml`, and shell completions.
2. **`llm-quickfire-panel` (`packages/desktop/llm-quickfire-panel/PKGBUILD`)**:
   - Packages `/usr/bin/quickfire`, `/usr/bin/quickfire-theme`, command palette aliases (`agy-palette`, `llm-quickfire-panel`), curated color palettes (Catppuccin Mocha Mauve, Tokyo Night, Nord, Cyberpunk, …), and `/etc/xdg/autostart/llm-quickfire-panel.desktop`.
3. **`palexus-themes`, `palexus-greeter`, `palexus-plymouth`, `palexus-hud` (`packages/desktop/`)**:
   - 14 wallpaper/theme variants, `palexus-theme` switcher, torus screensaver; the `palexusos` Qt6 SDDM greeter at `/usr/share/sddm/themes/palexusos`, Plymouth boot splash, and `palexus-hud` command suite.
4. **Repository Indexing**:
   - Run `repo-add -R out/repo/palexusos.db.tar.gz out/repo/*.pkg.tar.*`.
   - Sync `out/repo/` into `build/archiso/airootfs/var/cache/palexusos-repo/` and `/var/cache/palexusos-repo/` for `mkarchiso`.

---

## Stage B — Sync Overlays, CachyOS Mirrorlists & Validate Archiso Staging

1. **RootFS Overlay Synchronization (`./build/build-iso.sh --dry-run`)**:
   - Sync `overlay/etc/` into `build/archiso/airootfs/etc/` (including `99-palexusos.conf` ZRAM/BBR sysctl, `zram-generator.conf`, NetworkManager MAC randomization & RFC 4941 IPv6 stealth posture, Quad9 DoT `resolved.conf.d`, `picom.conf`, and `sddm.conf.d`).
   - Sync `overlay/etc/skel/` into `build/archiso/airootfs/etc/skel/`.
   - Stage Calamares installer configs (`packages/installer/calamares/`) into `build/archiso/airootfs/etc/palexusos/calamares/` (copied over `/etc/calamares` by `customize_airootfs.sh` after pacstrap).
2. **CachyOS Mirrorlists & Keyring Preparation**:
   - Verify `/etc/pacman.d/cachyos-mirrorlist` and `/etc/pacman.d/cachyos-v3-mirrorlist` are staged in both `overlay/etc/pacman.d/` and `build/archiso/airootfs/etc/pacman.d/`.
   - Ensure `customize_airootfs.sh` initializes the Pacman keyring and imports/locally signs the CachyOS signing key (`F3B607488DB35A47`).

---

## Stage C — Live ISO Compilation & QEMU/KVM Boot Verification

1. **ISO Generation**:
   - Execute `sudo ./build/build-iso.sh` to invoke `mkarchiso -v -w /var/tmp/palexusos-archiso-work -o ./out ./build/archiso`.
   - Verify output artifact `out/palexusos-YYYY.MM.DD-x86_64.iso`.
2. **QEMU/KVM Live Boot Test**:
   - Boot the generated ISO using `qemu-system-x86_64 -enable-kvm -m 4096 -smp 4 -cdrom out/palexusos-*.iso`.
   - Verify `systemd-boot` $\rightarrow$ `linux-cachyos` kernel $\rightarrow$ `palexusos` SDDM greeter $\rightarrow$ XFCE/Sway desktop session with `palexus.service` and `palexus-hud` active.

---

## Stage D — Checksums & Release Tagging (`v0.2.0-alpha`)

1. Generate `out/SHA256SUMS` and `out/SHA512SUMS` for the ISO image.
2. Re-run `./build/verify-gates.sh` to confirm 269/269 passing checks and clean Git status.
3. Tag `v0.2.0-alpha` to trigger `.github/workflows/build-iso.yml` automated release publishing.
