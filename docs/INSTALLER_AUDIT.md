# Installer audit: Calamares (Phase 1, "before")

- **Scope:** `packages/installer/calamares/` plus everything it depends on: ISO staging, live-session launchers, the first-boot hand-off and package availability.
- **Branch:** `onboarding-redesign` @ `4909dd4`
- **Date:** 2026-11-11
- **Status:** read-only so far; nothing has been changed.

**Legend:** ✅ fine · ⚠️ works but weak · ❌ broken · 👻 dead config
**Evidence tags:**
- **[verified]**: checked against the real `cachyos-calamares` 3.4.2-4 package or live repo databases
- **[read]**: from the config alone
- **[VM]**: needs a test install to confirm

---

## Progress (branch `installer-fixes`)

| # | Status | Notes |
|---|---|---|
| I1 | ✅ fixed | `grubcfg` runs right before `bootloader`, with a PalexusOS `grubcfg.conf` |
| I2 | ✅ fixed, VM check pending | Launched via `sudo -E /usr/bin/calamares`, only when `/run/archiso` exists. This also fixes the INSTALL button and the `Super+C` half of I6. |
| I3 | ✅ fixed | `packages` now runs last |
| I4 | ✅ fixed | `responder` removed. Every other pack package was confirmed to exist in Arch `extra`. |
| I5 | ✅ fixed | `xfsprogs` and `f2fs-tools` added to the ISO |

| I6 | ✅ fixed | New `shellprocess@removelive` step uninstalls `cachyos-calamares` and `mkinitcpio-archiso` right after the bootloader |
| I7 | ✅ fixed | ISO pins `cachyos-calamares` (3.4.2, the build these configs were checked against) |
| I8 | ✅ fixed | Text-mode fallback on tty2 (`palexus-oobe-recovery` + service). It runs only while setup is pending, sends the request on stdin to the same validated helper, and is disabled by `--finalize`. Documented in the README (Ctrl+Alt+F2). |
| I9 | ✅ fixed | Pack renamed "Python Scripting Libraries" with only the 2 packages it adds. The packs page says packs need internet. |
| I10 | ✅ fixed | Six unbacked slideshow claims reworded |
| I11 | ✅ fixed | Duplicate subvolume/mount config removed from `partition.conf`; the test and gate now check `mount.conf` |
| I12 | ✅ fixed | Unused `users.conf` removed |
| I13 | ✅ documented | Note in `mount.conf` on how a future snapper setup must treat `/.snapshots` |
| I14 | not changed | Calamares shrinks its window to fit the screen, so 960×620 shouldn't overflow. Confirm in a VM at 800×600. |
| I15 | ✅ fixed | Version strings agree |
| Line endings | ✅ fixed | `.gitattributes` forces LF. Proven: a clone made with `core.autocrlf=true` gets LF scripts on this branch and CRLF on `onboarding-redesign`. |

- **Gates:** 293/293 on a clean Linux clone (8 checks added for I1–I5, and more since). Run against the pre-fix files, the I1–I5 checks fail as intended.
- **Pytest:** 45/46; 7 new tests for the tty2 fallback. The one failure is the old HUD test (`test_hud_backend_signals_and_launch`), not the installer.
- **Still open:** a real install in a VM, especially for I2 (root launch under Wayland), the encrypted-install path of I1, I8 on real hardware, and I14.

---

## 1. Blockers: an install fails or the result doesn't boot

| # | Problem | Effect | Evidence |
|---|---|---|---|
| I1 | **No `grubcfg` step in the install sequence.** | **Encrypted installs:** GRUB never gets `GRUB_ENABLE_CRYPTODISK=y` or `rd.luks.uuid`, so the bootloader step fails or the system can't unlock root at boot. **All installs:** no `splash` on the kernel line, so the PalexusOS boot animation never shows after install. The `quiet splash nowatchdog` in `bootloader.conf` is ignored for GRUB. | [verified] `grubcfg/main.py:192,225,289` is the only code that writes these settings. `bootloader/main.py:140-217` uses `kernelParams` only for systemd-boot, limine and rEFInd. `settings.conf:24-43` has no `grubcfg`. No `/etc/default/grub` ships anywhere in the repo. |
| I2 | **The installer is launched as the normal live user.** The Waybar button, `Super+I` and `Super+C` all run `calamares -d`, with no `sudo` or `pkexec`. | `welcome.conf` makes "running as root" a *required* check, so Next stays disabled and the install can't start. The `-d` flag also opens Calamares in debug mode. | [read]+[VM] `overlay/etc/skel/.config/waybar/config.jsonc:51`, `sway/config:63-64`, `welcome.conf:17,22`. `cachyos-calamares` ships no self-elevating wrapper [verified]. |
| I3 | **The packages step runs *before* the bootloader step.** | If an optional pack fails to download or install, Calamares stops with the disk already formatted and no bootloader: an unbootable machine. | [read] `settings.conf:41-42` |
| I4 | **An optional pack names a package that doesn't exist.** `responder` (in "Pentest Heavy & RF Stack") is not in Arch or CachyOS. | Ticking that pack on an online install hits I3: the install fails and the disk is left unbootable. | [verified] Arch package search plus the CachyOS repo databases |
| I5 | **XFS and F2FS are offered, but their tools aren't on the ISO.** | Picking either filesystem fails at the format step. | [verified] `partition.conf:21` vs `build/archiso/packages.x86_64`: no `xfsprogs` or `f2fs-tools`, though both exist in the repos |

## 2. Wrong after install

| # | Problem | Effect | Evidence |
|---|---|---|---|
| I6 | **Calamares stays installed on the finished system.** Nothing removes it or the live-only packages. | The installed desktop keeps an **"INSTALL PALEXUSOS"** Waybar button. `Super+C` opens the installer instead of the calculator. `Super+I` stays bound to it. | [read] cleanup script `shellprocess@cleanup.conf` doesn't remove packages. Waybar shows the button whenever `/usr/bin/calamares` exists (`config.jsonc:48`). Calamares has a `removeuser`/`packages` remove path that isn't used. |
| I7 | **Which Calamares gets installed isn't pinned.** `packages.x86_64` asks for `calamares`, which **19** CachyOS packages provide (3.3.8 to 3.4.2, including limine, refind and systemd-boot variants). | Builds can silently pick a different installer and version. `mount.conf` relies on 3.3+ behaviour. | [verified] `cachyos.db` provides lists. `packages.x86_64:151` |
| I8 | **No recovery if first-boot setup fails.** The installer creates no account and no root password; the first-boot wizard does. | If the wizard can't start (GPU or Wayland problem), there is no way to log in. | [read] `users` module not in the sequence, `users.conf:20` `setRootPassword: false`, `palexus-oobe-arm` |
| I9 | **The default-ticked "Palexus CLI Power Pack" is silently skipped offline**, and its description promises "palexus-cli, memory bridge, doctor" while it actually installs `jq`, `fzf`, `ripgrep`, `bat` and two Python libraries. | Users think they got Palexus tools when they didn't. | [read] `netinstall.yaml:40-51`, `packages.conf:7` |
| I10 | **The slideshow claims things the system doesn't do.** "Instant rollback": no snapper, snap-pac or timeshift is installed. "Single-threaded CPU protection" for Ollama: the config sets 4 threads with 1 parallel request. "Sub-500MB idle" and "guarantees zero-jitter audio": unmeasured. | Misleading during install. | [read] `show.qml:357-395,497-504`. `ollama.service.d/override.conf:9-11` |

## 3. Messy but not breaking

| # | Problem | Evidence |
|---|---|---|
| I11 | 👻 Subvolume layout and mount options are defined twice. `partition.conf`'s copy is ignored by Calamares 3.3+ and has drifted: it forces `ssd` on every disk. | `partition.conf:26-44` vs `mount.conf:27-46` |
| I12 | 👻 `users.conf` is present but the `users` module is never run (by design, since first-boot setup creates the account). | `settings.conf` |
| I13 | ⚠️ `@snapshots` is mounted at `/.snapshots` with no snapshot tool. If snapper is added later, `snapper create-config /` fails because the folder already exists. | `mount.conf:32` |
| I14 | ⚠️ The installer window is fixed at 960×620, so it overflows 800×600 VMs and low-res screens. | `branding.desc:10` |
| I15 | ⚠️ The version string disagrees with itself: "Obsidian Mauve" vs "Catppuccin Mauve". | `branding.desc:16-17` |

## 4. Working as intended ✅

- **No GeoIP, UTC default:** no IP leak during install (`locale.conf`, `welcome.conf`).
- **Live-session cleanup:** removes the passwordless sudo, autologin and live user, and re-keys pacman (`shellprocess@cleanup.conf`).
- **Kernels restored** into `/boot` after mkarchiso empties it, and the live archiso initramfs hooks are dropped.
- **First-boot setup is armed safely:** one root command, no arguments, validated by `visudo`, and it disarms itself (`palexus-oobe-arm`).
- **Btrfs + zstd layout** in `mount.conf`; LUKS2; `umask=0077` on the EFI partition.
- **Squashfs path** matches `profiledef.sh` (`install_dir=palexusos`, `arch=x86_64`).
- **Services enabled exist in shipped packages:** `palexus.service` in palexus-core, plus firewalld, sddm and NetworkManager.

## 5. Tests and checks

| Check | Result |
|---|---|
| `build/verify-gates.sh` on a clean Linux clone | 276/276 pass. But the gates only check that files *contain* text, so none of I1–I10 are caught. Line 532 "Installed systems boot with splash" passes while I1 means they don't. |
| `pytest tests/` on a clean Linux clone | 38/39 pass. 1 failure is in the HUD, not the installer: `test_ui_ux.py::TestPalexusHudQml::test_hud_backend_signals_and_launch` expects an older `Popen` call. |
| Same checks on this Windows checkout | **False failures** (3 under Git Bash, 67 under WSL). `core.autocrlf=true` converts files to CRLF and there is no `.gitattributes`, so `^…$` patterns break. Any ISO built from a Windows checkout would get CRLF shell scripts and PKGBUILDs. |
| Real install in a VM | **Not done.** Needs a built ISO plus QEMU/VirtualBox. I2 and the encrypted-install half of I1 should be confirmed there. |

## 6. Proposed fix order (Phase 2, after your OK)

1. **I1:** add `grubcfg` (with `kernel_params: [quiet, nowatchdog]`) before `bootloader`.
2. **I3:** move `packages` after `bootloader`.
3. **I2:** launch via `sudo -E calamares` (no `-d`); hide the launchers when not in the live session.
4. **I4, I5:** drop `responder`; add `xfsprogs` and `f2fs-tools` to the ISO.
5. **I6:** remove Calamares and other live-only packages at the end of install.
6. **I7:** pin `cachyos-calamares` to an exact package name.
7. **I8:** give first-boot setup a text-mode fallback (decision needed).
8. **I9, I10:** fix the pack description and the slideshow wording.
9. **I11–I15:** tidy up.
10. Add a `.gitattributes` forcing LF.
11. Add gate checks that would have caught I1–I7.
