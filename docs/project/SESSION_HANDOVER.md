# PalexusOS Session Handover

**Updated:** 2026-11-21
**Repository:** `https://github.com/earnerbaymalay/palexusOS`
**Branch:** `main`

This file is the single current-status note. `docs/project/IDE_HANDOVER.md` and `GEMINI.md`
describe the project layout and conventions; they do not track status.

To check the state of a checkout, run these rather than trusting a number
written here:

```bash
./build/verify-gates.sh
pytest tests/
shellcheck build/*.sh build/archiso/profiledef.sh build/archiso/airootfs/root/customize_airootfs.sh
```

---

## 1. Where things stand

- Measured 2026-11-21 in a cloud container on the `fix/open-items-2026-11-21` branch:
  `pytest tests/` 192 passed, 8 skipped; `verify-gates.sh` 356 passed, 1 failed
  (`build/test-iso-boot.sh --check`, because that container has no QEMU/OVMF);
  ShellCheck clean.
- Releases: `v0.2.0-alpha` (2026-11-12, marked Latest) and `v0.2.1-alpha`
  (pre-release). Neither has an ISO attached. The ISO (about 2.9 GB) is over
  GitHub's 2 GiB per-asset limit; `build/split-iso.sh`, `build/join-iso.sh` and
  `build/join-iso.ps1` (`74eb025`) split it for the next tagged build.
- Newest ISO on record: `out/palexusos-2026.11.12-x86_64.iso`, built before
  everything below. No ISO has been built since.

## 2. What landed 2026-11-13 to 2026-11-21

| Date | Change |
| :--- | :--- |
| 11-13 | Wallpapers, HUD plates and 360 assets, Plymouth animation, Calamares art and login chime rebranded (`85015d5`, `d4e7aef`) |
| 11-16 | L7–L9 decisions (#5): greeter follows the desktop theme, picom removed, orca screen reader, safe-graphics and copy-to-RAM boot entries, boot animation "Boot 3" chosen and cut to about 7.4 MB, HUD asks the installed coder model. Hyper-V VM script and WSL build docs. Docs regrouped into audits, guides, design, project |
| 11-19 | Global design system and TokenEconomizer integration |
| 11-20 | Python layer (`palexus/`: TokenRegistry, GateRegistry, DesktopEnvironment, TestOrchestrator), CLIs, packaging, CI and docs. Generated docs then corrected from source |
| 11-21 | CI fixed (#7), Python 3.11+, picom gate (#8), README real renders (#9), MIT `LICENSE` and README brought in line with what ships, greeter no longer hard-codes a version, HUD hotkey fix (#10), README QEMU test drive boots (#11), ISO split/join tools (`74eb025`) |
| 11-21 | `fix/open-items-2026-11-21`: see section 3 |

## 3. Fixed on `fix/open-items-2026-11-21`

| Area | Problem | Fix |
| :--- | :--- | :--- |
| `palexus-core` PKGBUILD | Built the pre-rename `earnerbaymalay/synapse` at `f6cb346` (`-p synapse --bin synapse`), 16 commits behind Palexus Brain | Source is `palexus-brain.git#commit=baaae4c`; builds `-p palexus --bin palexus`; tests `-p palexus -p palexus-core`; `pkgrel` 4 |
| `/usr/bin/squash` | Ran `palexus context squash`; the CLI has no `context` command | Runs `palexus squash` |
| `palexus-core` `backup=` | Listed `etc/palexus/config.toml` and `etc/synapse/config.toml`, which the package does not ship (makepkg warning) | Removed |
| `build/build-iso.sh` | `PALEXUS_CORE_SRC` pre-seed and `BUILD_MANIFEST.txt` still used the `synapse` source name | Use `palexus-brain` |
| Live image | No `fish`, `fastfetch` or `lolcat`, so the shell welcome showed its plain banner and never offered the shell choice | Added to `build/archiso/packages.x86_64` |
| `ROADMAP.md` | Milestones 9.2 (eBPF guard) and 9.3 (Vulkan probe) unchecked though both ship | Ticked, with what shipped |
| `README.md` | Onboarding line named "Claude 3.7 Sonnet / Opus" | Matches `palexus-welcome` (Claude Opus 5.5, key check button, local Ollama default) |
| `docs/ROADMAP.md`, `docs/V0.2.0_IMPLEMENTATION.md`, `CHANGELOG.md` | Python-layer docs used distro-looking versions ("v0.1.0 released, production-ready", "v0.2.0") and unmeasured figures | Marked as `palexus-lib` versions, pointed at the root ROADMAP for distro releases, dropped figures nobody measured, CI matrix corrected to 3.11–3.14 |

## 4. Open items

1. **Build and boot a new ISO.** Nothing after 11-12 has been through
   `./build/build-iso.sh --build-pkgs` and `./build/test-iso-boot.sh --gui`. On
   that boot, confirm the 11-13 rebrand art visually and that `palexus-core`
   builds from `palexus-brain` with `--locked`.
2. **Publish an ISO.** Tag a release so CI builds it and uploads the split parts.
3. **`/dev/sr0` loopback unit fails on live boot.** Boot continues; cause not
   investigated.
4. **Palexus Brain T8.3 (Gate 4):** install on a real machine and run
   onboarding (`palexus-brain/.ai/PLAN.md`).

## 5. Phases ahead

See `ROADMAP.md`: Phase 10 (P2P Brain mesh, remote inference offload),
Phase 11 (optional read-only root), Phase 12 (cyberdeck hardware kit).
