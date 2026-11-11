---
name: palexusos-iso-build
description: Builds and verifies the PalexusOS live ISO pipeline. Use when running verify-gates, staging archiso overlays, compiling native PKGBUILDs, or preparing a QEMU boot of palexusos.
disable-model-invocation: true
---

# PalexusOS ISO Build

## Quick start

```bash
./build/verify-gates.sh
./build/build-iso.sh --dry-run
```

Full native packages + ISO (root required for `mkarchiso`):

```bash
./build/build-iso.sh --build-pkgs
```

## Stages

1. **A** — `makepkg` `palexus-core`, `llm-quickfire-panel`, `palexus-themes`, `palexus-greeter`, `palexus-plymouth`, `palexus-hud` into `out/repo/`
2. **B** — overlay + Calamares staging into `build/archiso/airootfs/etc` (generated; do not commit)
3. **C** — `sudo mkarchiso` via `build/build-iso.sh`, then QEMU
4. **D** — `out/SHA256SUMS` and tag `v0.2.0-alpha` only when the user asks

## Tracked vs generated

- Track: `packages/**`, `overlay/etc`, `build/archiso/{profiledef.sh,packages.x86_64,pacman.conf,efiboot,syslinux}`, `build/archiso/airootfs/root/customize_airootfs.sh`
- Do not track: `out/`, `*.iso`, `*.pkg.tar.*`, staged `airootfs/etc`

## Gate-checked UI files

- `packages/desktop/palexus-greeter/{Main.qml,theme.conf,metadata.desktop}`
- `packages/desktop/palexus-plymouth/{PKGBUILD,render_frames.py,palexusos.script.in}`
- `packages/desktop/palexus-themes/{PKGBUILD,palexus-theme}`
- `packages/desktop/palexus-hud/{Main.qml,Welcome.qml,palexus-hud}`
- `packages/desktop/llm-quickfire-panel/config/llm-quickfire-panel.desktop`
