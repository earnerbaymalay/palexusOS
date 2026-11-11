# Kanban

Plan the project here. Each card can start a Parallel Code task.

## Backlog

- [ ] Build, verify and tag the first PalexusOS ISO
  Run `./build/build-iso.sh --build-pkgs`, the gate harness, pytest and the QEMU smoke test, walk through a Calamares install in a VM, then update `ROADMAP.md` and tag `v0.2.0-alpha`. Remove stale `out/repo/synapse-*` packages and the old `synapseos` database first.
  - [ ] `out/palexusos-<date>-x86_64.iso` boots to the greeter and desktop under UEFI
  - [ ] Installed system boots, has no live user or NOPASSWD sudoers, and `palexus.service` is active
  - [ ] Release has the ISO, checksums and signatures attached
  depends: Rebrand the CI workflow and add release checksums
  depends: Rebrand the pytest suites
  depends: Sign the package repository and the ISO
  depends: Add a scripted QEMU boot smoke test
  depends: Rebrand docs, agent rules and editor config
  group: release
- [ ] Finish and test the PL1/PL2 thermal governor (Milestone 9.1)
  `packages/desktop/palexus-hud/palexus-governor` already polls Ollama `/api/ps` and switches EPP, but the roadmap item is unchecked. Add real PL1/PL2 switching (RAPL `intel-rapl` constraints, with the existing `throttled` path as fallback), distinguish inference from background compilation, make limits configurable in `/etc/palexus/governor.toml`, and harden `palexus-governor.service` (`ProtectSystem`, `NoNewPrivileges`, only the sysfs paths it writes). Add `tests/test_governor.py` using a fake sysfs tree.
  - [ ] Unit tests cover idle, inference and compile states against fake sysfs
  - [ ] Daemon exits cleanly and restores defaults on SIGTERM
  - [ ] Makes no network request other than loopback Ollama
  depends: Commit the in-progress rebrand working tree as the baseline
  related: Rebrand system overlay configs and the AMOLED theme
  group: hardware
- [ ] Design spike: eBPF secret leak interceptor (Milestone 9.2)
  Write `docs/EBPF_SECRET_INTERCEPTOR.md` only. Decide the hook point (cgroup/skb egress, sock_ops, or LSM), how plaintext is inspected given TLS (uprobes on OpenSSL/GnuTLS versus pre-encryption only), pattern set (`sk-*`, PEM headers, OpenSSH private keys), false-positive handling, kernel config requirements on `linux-cachyos`, and how it reuses the patterns in the upstream daemon's `firewall.rs`.
  - [ ] Document names one recommended hook point with its limits stated
  - [ ] Lists required kernel options and the toolchain (aya or libbpf)
  - [ ] Breaks implementation into follow-up cards
  related: Rebrand docs, agent rules and editor config
  group: hardware
- [ ] Implement the eBPF secret leak interceptor package
  New package `packages/core/palexus-ebpf-guard/` (PKGBUILD, loader, systemd unit) following the design document. Default mode is log-only with an enforce switch; add it to `build/archiso/packages.x86_64` and a gate check.
  - [ ] A test that sends a fake PEM private key over a local socket is blocked in enforce mode
  - [ ] Ordinary HTTPS traffic is unaffected
  - [ ] Package builds in a clean chroot
  depends: Design spike: eBPF secret leak interceptor (Milestone 9.2)
  group: hardware
- [ ] Vulkan offload profiler for integrated graphics (Milestone 9.3)
  Add `packages/desktop/palexus-hud/palexus-vulkan-probe`: detect Intel/AMD integrated GPUs through `vulkaninfo`, benchmark a small quantized model with and without GPU layers through Ollama, and write the faster setting to `overlay/etc/systemd/system/ollama.service.d/` style drop-in under `/etc`. Add the Mesa Vulkan drivers to `packages.x86_64`, install the script in the HUD PKGBUILD, and expose the result in the `palexus-settings` AI Engine tab.
  - [ ] Falls back to CPU without error when no Vulkan device exists
  - [ ] Result is shown in settings and survives reboot
  - [ ] Parsing logic has unit tests with recorded `vulkaninfo` output
  depends: Rename leftover Synapse assets inside the palexus-* packages
  related: Rebrand the archiso profile and bootloader entries
  group: hardware
- [ ] Fix desktop look: theme coverage, login screen, dead shortcuts
  issue: https://github.com/earnerbaymalay/synapseOS/pull/2
  related: Rebrand the archiso profile and bootloader entries
  group: desktop
- [ ] Fix first-boot setup recovery, live detection and HUD AI actions
  issue: https://github.com/earnerbaymalay/synapseOS/pull/3
  related: Rebrand the live-image customize hook and the Calamares modules together
  group: desktop

## In progress

## Review

## Done

- [x] Add a scripted QEMU boot smoke test
  Create `build/test-iso-boot.sh` that boots the newest `out/palexusos-*.iso` headless under QEMU/KVM with OVMF, watches the serial console for the graphical target and `palexus.service` becoming active, and exits non-zero on timeout. Base the approach on `build/test-plymouth-container.sh` (also rename its old-brand references). Add a matching gate entry that is skipped when no ISO is present.
  - [x] Script exits 0 against a good ISO and non-zero against a truncated one
  - [x] Runs without a display and without root
  - [x] Documented in `docs/RELEASE_CHANNELS.md`
  depends: Rebrand the verification gate harness
  related: Make the ISO build reproducible
  group: testing

- [x] Sign the package repository and the ISO
  The local repo is added with `repo-add` unsigned and the ISO ships without a signature. Add optional signing to `build/build-iso.sh`, driven by a `PALEXUS_GPG_KEY` environment variable: `repo-add --sign`, detached `.sig` for the ISO and checksum files. Set an explicit `SigLevel` for the `[palexusos]` repo in both pacman configs. Never store key material in the repo; document the CI secret in `docs/RELEASE_CHANNELS.md`.
  - [x] With the variable set, repo database, ISO and checksums each have a valid signature
  - [x] Without it the build still succeeds and prints a clear unsigned warning
  - [x] No key or secret is added to Git
  depends: Make the ISO build reproducible
  group: release

- [x] Make the ISO build reproducible
  Add `SOURCE_DATE_EPOCH` handling to `build/build-iso.sh` (default to the last commit time) and pass it through to `mkarchiso` and `makepkg`, and pin the upstream daemon source in `packages/core/palexus-core/PKGBUILD` to a tag or commit instead of `#branch=main`. Record the resolved commit and package versions in `out/BUILD_MANIFEST.txt`.
  - [x] Two builds from the same commit produce the same package list and manifest
  - [x] `palexus-core` no longer tracks a moving branch
  - [x] Manifest is written next to the ISO and not committed
  depends: Rebrand build-iso.sh and remove the host-specific path
  group: release

- [x] Rebrand the CI workflow and add release checksums
  In `.github/workflows/build-iso.yml` rename the workflow, step, artifact (`palexusos-live-iso`) and release names. Add `pytest tests/` to the `verify-gates` job (dependencies are already installed there). Generate `SHA512SUMS` alongside `SHA256SUMS` and upload both. Stop publishing a release on every push to `main`; publish only for `v*` tags.
  - [x] Workflow passes `actionlint`
  - [x] Verify job runs shellcheck, gates, pytest and the dry-run build
  - [x] Tag builds attach the ISO, `SHA256SUMS` and `SHA512SUMS`
  depends: Rebrand the verification gate harness
  related: Rebrand the pytest suites
  group: release

- [x] Rebrand docs, agent rules and editor config
  Text-only pass over `ROADMAP.md`, `AGENTS.md`, `GEMINI.md`, `IDE_HANDOVER.md`, `docs/*.md`, `.cursor/**` (rename `.cursor/skills/synapseos-iso-build`), `.vscode/tasks.json`, `synapseos.code-workspace` (rename to `palexusos.code-workspace`), and `.gitignore` comments/paths. Delete the superseded `docs/assets/synapseos-banner.png` and make `generate_banner.py` write `palexus-banner.png`. Leave `docs/RESEARCH_SYNAPSE_INTEGRATION.md` content about the upstream Synapse project intact and keep completed roadmap history readable (add a one-line "formerly SynapseOS" note rather than rewriting history). Leave `.gitmodules` and GitHub URLs unchanged until the repository itself is renamed.
  - [x] README, AGENTS.md and docs describe the product as PalexusOS with `palexus-*` commands
  - [x] No doc links to a file that no longer exists
  - [x] Paths quoted in docs match the renamed files
  depends: Commit the in-progress rebrand working tree as the baseline
  group: docs

- [x] Rebrand the pytest suites
  `tests/test_iso_profile.py` uses either-name fallbacks and old paths (`synapse-greeter`, `10-synapseos.conf`, `iso_name="synapseos"`, live user `synapse`); `tests/test_ui_ux.py` loads `packages/desktop/synapse-hud/synapse-hud` etc. and asserts old titles and icon theme names. Point both at the `palexus-*` paths and names, remove the fallbacks so the tests assert the new brand only, and rename the test classes.
  - [x] `pytest tests/` passes with no skips caused by missing paths
  - [x] No `or "…synapseos…"` fallback assertions remain
  depends: Rebrand the verification gate harness
  group: testing

- [x] Rebrand the verification gate harness
  `build/verify-gates.sh` has ~80 old-name references and zero new ones, so it currently checks paths that no longer exist (`packages/core/synapse-core/PKGBUILD`, `overlay/etc/sysctl.d/99-synapseos.conf`, `sddm.conf.d/10-synapseos.conf`, `branding/synapseos`, `synapseos.script.in`, `synapse-boot.mp4`, wallpaper names, icon theme names, the `[synapseos]` repo and boot entry). Rewrite every path and expected string to the names produced by the rebrand cards. Add one new gate that fails if a tracked file outside an explicit allowlist (upstream `synapse` source name, compatibility symlinks/provides, `components/` submodules, historical docs) contains `synapse`.
  - [x] `./build/verify-gates.sh` reports 0 failures and 0 warnings
  - [x] The leftover-name gate fails when a stray `synapseos` string is added
  - [x] `shellcheck build/verify-gates.sh` is clean
  depends: Rebrand build-iso.sh and remove the host-specific path
  depends: Rebrand the live-image customize hook and the Calamares modules together
  depends: Rebrand the user skeleton overlay
  depends: Rebrand system overlay configs and the AMOLED theme
  depends: Rename leftover Synapse assets inside the palexus-* packages
  group: testing

- [x] Rename leftover Synapse assets inside the palexus-* packages
  Package directories were renamed but assets were not. In `packages/desktop/palexus-themes` rename the 14 `synapse-*.jpg` wallpapers to `palexus-*.jpg` and fix `source=`, the install loop, and `sha256sums` (run `updpkgsums`). In `palexus-hud` and `palexus-plymouth` rename `synapse_chrome_*` images, and the four `icons/Synapse-*` themes to `Palexus-*` including `index.theme` names, `synapse-*.svg` app icons, `generate_icons.py`, `generate_spinning_chrome.py`, `Welcome.qml`/`palexus-welcome` defaults and `palexus-settings`. Fix user-visible strings ("Synapse Command HUD", "Synapse Settings", "Synapse Notes", `palexus-governor.service` description, greeter `metadata.desktop`/`theme.conf`). Keep the existing `provides`/`conflicts` and `synapse-*` compatibility symlinks; set `url=` consistently. Bump each `pkgrel`.
  - [x] `find packages -iname '*synapse*'` returns nothing tracked
  - [x] Each touched PKGBUILD passes `makepkg --verifysource` and `namcap`
  - [x] Remaining `synapse` strings in `packages/desktop` are only compatibility symlinks/provides
  depends: Commit the in-progress rebrand working tree as the baseline
  group: desktop

- [x] Rebrand system overlay configs and the AMOLED theme
  Outside `skel`: in `overlay/etc/pacman.conf` rename the `[synapseos]` repo and server path to `palexusos` (must match `build/archiso/pacman.conf`); update header comments in `overlay/etc/xdg/picom.conf`, `systemd/zram-generator.conf`, `systemd/resolved.conf.d/quad9-dot.conf`, `systemd/system/ollama.service.d/override.conf`, `chromium/default-flags`, and `ananicy.d/00-palexusos/palexusos.rules` (also its process names). Rename `overlay/usr/share/themes/Synapse-AMOLED` and `overlay/etc/skel/.themes/Synapse-AMOLED` to `Palexus-AMOLED` and update every reference (`xfwm4.xml`, `xsettings.xml`, gtk `settings.ini`, theme switcher in `packages/desktop/palexus-themes/palexus-theme`). Do not change any stealth setting values.
  - [x] `grep -ri synapse overlay --exclude-dir=skel` returns nothing
  - [x] Stealth/DoT/sysctl values are byte-identical apart from comments
  - [x] No config references a theme directory that does not exist
  depends: Commit the in-progress rebrand working tree as the baseline
  group: desktop

- [x] Rebrand the user skeleton overlay
  Under `overlay/etc/skel/`: rename `.config/autostart/synapse-setup.desktop` and `synapse-welcome.desktop` to `palexus-*` with `Exec=/usr/bin/palexus-*` and matching `Icon=`; in `.bashrc` point aliases at `palexus`/`palexus-hud`/`palexus-settings`/`palexus-notes`, export `PALEXUS_GATEWAY_URL`/`PALEXUS_CONFIG` while keeping the `SYNAPSE_*` variables as compatibility exports (the upstream daemon may still read them); move `.synapse/config.toml` to `.palexus/config.toml` and update the paths inside it only if the daemon accepts a config path (check `components/synapse-cli`), otherwise keep `.synapse` and document why. Update remaining mentions in `sway/config`, `waybar/config.jsonc`, `waybar/style.css`, `kitty/*.conf`, `quickfire/theme.conf`, `mimeapps.list`, `xfce4-keyboard-shortcuts.xml`, and the gtk/xfwm4/xsettings files.
  - [x] Every `Exec=` and keybinding target exists as a binary installed by a `palexus-*` PKGBUILD
  - [x] `grep -ri synapse overlay/etc/skel` shows only the documented compatibility exports
  - [x] Sway config still binds `Mod4+space` and `Mod4+d` to the HUD
  depends: Commit the in-progress rebrand working tree as the baseline
  group: desktop

- [x] Rebrand the live-image customize hook and the Calamares modules together
  `build/archiso/airootfs/root/customize_airootfs.sh` and `packages/installer/calamares/modules/*.conf` share names and must change in one card: the live user `synapse` -> `palexus` (useradd, `/home/...`, `/etc/sudoers.d/00-palexus-live`), hostname `palexusos`, enabled unit `palexus.service`, and the staged config path `/etc/palexusos/calamares`. In the modules update `shellprocess@cleanup.conf` (sudoers file, `userdel -r`, `/home/<live user>` copy logic), `services-systemd.conf` (`name: "palexus"`), `unpackfs.conf` (`/run/archiso/bootmnt/palexusos/x86_64/airootfs.sfs`), `netinstall.yaml` pack names, and SPDX/header comments in every module plus `settings.conf`. Also check `overlay/etc/sddm.conf.d/10-palexusos.conf` `HideUsers` against the new daemon/live user names.
  - [x] `grep -ri synapse packages/installer/calamares/modules build/archiso/airootfs/root` returns nothing
  - [x] Cleanup module removes exactly the user and sudoers file the hook creates
  - [x] `unpackfs.conf` source path matches `install_dir` in `profiledef.sh`
  depends: Rebrand the archiso profile and bootloader entries
  group: installer
- [x] Rebrand build-iso.sh and remove the host-specific path
  In `build/build-iso.sh` rename the work/state/repo paths (`/var/tmp/synapseos-archiso-work`, `/var/cache/synapseos-repo`, `/var/lib/synapseos-build`), the `synapseos.db.tar.gz` repo database, the staged `etc/synapseos/calamares` directory, the boot-entry filename check on line ~82, and all banner/usage text to `palexusos`. Lines ~141-143 hard-link `/home/ebaymlay/work/synapse` into the core package `src/`; replace that with an optional `PALEXUS_CORE_SRC` environment variable so the script is reproducible on other machines and in CI. The upstream daemon checkout directory stays named `synapse` (it is the upstream repo name used by `packages/core/palexus-core/PKGBUILD`).
  - [x] `./build/build-iso.sh --dry-run` exits 0
  - [x] No `/home/ebaymlay` path remains in `build/`
  - [x] `shellcheck build/build-iso.sh` is clean
  depends: Rebrand the archiso profile and bootloader entries
  group: release
- [x] Rebrand the archiso profile and bootloader entries
  `build/archiso/` still carries the old identity. In `profiledef.sh` set `iso_name="palexusos"`, `iso_label="PALEXUSOS_..."`, publisher/application strings and `install_dir="palexusos"`. Rename `efiboot/loader/entries/01-synapseos-x86_64-linux.conf` to `01-palexusos-x86_64-linux.conf` and update `efiboot/loader/loader.conf`, the entry title, and `syslinux/syslinux.cfg` menu text; any `archisobasedir=`/`archisolabel=` parameters must match the new `install_dir` and label. In `build/archiso/pacman.conf` rename the repo section to `[palexusos]` with `Server = file:///var/cache/palexusos-repo`, and update header comments in `packages.x86_64`. Only touch files under `build/archiso/` except `airootfs/root/customize_airootfs.sh` (separate card).
  - [x] `grep -ri synapse build/archiso --exclude-dir=airootfs` returns nothing
  - [x] Boot entries reference the same install dir and label as `profiledef.sh`
  - [x] `packages.x86_64` lists `palexus-core`, `palexus-themes`, `palexus-greeter`, `palexus-plymouth`, `palexus-hud`
  depends: Commit the in-progress rebrand working tree as the baseline
  group: installer
- [x] Commit the in-progress rebrand working tree as the baseline
  The SynapseOS -> PalexusOS rename exists only as ~220 uncommitted changes on branch `rebrand/palexusos` (staged renames plus unstaged edits and untracked files). Card worktrees are created from committed history, so nothing below can see this work until it is committed. This card must be done in the main checkout, not a fresh worktree. Stage the intended files (`overlay/usr/`, `overlay/etc/skel/.themes/`, `.config/gtk-3.0`, `.config/gtk-4.0`, `xfwm4.xml`, `xsettings.xml`, `docs/*AUDIT*.md`, `docs/PALEXUS_BOOT_VIDEO_SUITE.md`, `docs/assets/palexus-banner.png`, `KANBAN.md`, sources under `build/blender` and `build/videos`). Do not commit build output: the old `packages/core/synapse-core`, `packages/desktop/synapse-{greeter,hud,plymouth,themes}` and `packages/installer/calamares/branding/synapseos` paths now hold only ignored leftovers (`src/`, `pkg/`, `*.pkg.tar.zst`, `__pycache__`), and `build/blender/renders`, `*.blend` and `docs/assets/videos` should be checked for size before staging (AGENTS.md: no binary blobs).
  - [x] `git status` is clean apart from ignored files
  - [x] No `*.pkg.tar.zst`, `src/`, `pkg/`, ISO or large render blob is in the commit
  - [x] Branch is pushed or merged so new worktrees contain the `palexus-*` package directories
  group: release
