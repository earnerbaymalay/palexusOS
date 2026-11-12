# PalexusOS Session Handover

**Updated:** 2026-11-12
**Repository:** `https://github.com/earnerbaymalay/palexusOS`
**Branch with this work:** `cleanup/post-rebrand-fixes` (cut from `main` at `47a244d`)

This file is the single current-status note. `IDE_HANDOVER.md` and `GEMINI.md`
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

- All gates, pytest and ShellCheck pass on `cleanup/post-rebrand-fixes`.
- `main` has been failing CI since the rebrand merge. The causes are fixed on
  the branch above; CI has not yet run against it.
- The newest local ISO (`out/palexusos-2026.11.12-x86_64.iso`) was built
  **before** this branch. It boots under UEFI in QEMU to the login screen.
  No ISO has been built from this branch yet.

## 2. What the cleanup branch fixed

Regressions introduced by `47a244d`:

| Area | Problem | Fix |
| :--- | :--- | :--- |
| `overlay/etc/skel/.bashrc`, `shell-welcome.sh` | Welcome script was loaded from one developer's home path, and its interactive check ran `exit`, which would close every new terminal | Load from `$HOME`; return instead of exit; ask the shell question once |
| Sway config | `Super+Space` / `Super+D` moved from the Command HUD to rofi; two keys bound twice | HUD restored; rofi list on `Super+Shift+D`; `Super+E` opens Files; duplicates removed |
| Greeter `Main.qml` | Brand text colour changed; PKGBUILD checksum stale (package would not build) | Colour restored; checksum and `pkgrel` updated |
| `palexus-screensaver` | `--mode matrix` crashed on its first frame; PKGBUILD checksum stale | Mode rewritten on the existing rain engine; checksum and `pkgrel` updated |
| `overlay/usr/share/backgrounds/` | 14 wallpapers duplicated from `palexus-themes` | Duplicates removed; the five new 4K wallpapers kept |
| `README.md` | Inline code spans blanked; install and architecture sections dropped | Previous README restored |
| `tools/wave-pipeline.sh` | Hard-coded home paths; old project name | Paths derived from the checkout; rebranded |

Older problems found on the way:

| Area | Problem | Fix |
| :--- | :--- | :--- |
| `build/test-iso-boot.sh` | Passed after ~4 s on seeing the boot-menu title, before any kernel loaded | Requires a real `login:` prompt or graphical target; defaults raised to 4096 MB / 300 s |
| `build/test-iso-boot.sh` | Did not know Arch's firmware file name (`OVMF_CODE.4m.fd`), so the CI ISO job failed its prerequisite check | Path added |
| CI workflow | Every job, including pull-request runs, held a write token | Write access limited to the release job |

## 3. Open items

### 3.1 The visual rebrand is not done

The rename covered text only. These shipped images still show the old
wordmark, and the brand gate cannot see it because it only searches text:

- All 14 wallpapers in `packages/desktop/palexus-themes/` (lettering on the
  monolith, tower and carbon plate). The login screen shows the default one.
- `packages/installer/calamares/branding/palexusos/background.png` and
  `palexusos-welcome.png`.
- `palexus_chrome_logo.png`, `master_plate_960.png` and the spinning chrome
  animations in `packages/desktop/palexus-hud/` and `palexus-plymouth/`.
- `packages/desktop/palexus-plymouth/palexus-boot.mp4` (the boot animation).

The five 4K wallpapers added in `47a244d` carry no wordmark.

### 3.2 Boot animation: waiting on a choice

Twelve candidate boot videos were rendered in an earlier session and collected
in a player outside the repository, at `~/Desktop/boot_video_player/index.html`.
Once one is chosen:

1. Re-render it with the PALEXUS wordmark (generators: `build/videos/`,
   `build/blender/generate_palexus_boot_videos.py`).
2. Replace `packages/desktop/palexus-plymouth/palexus-boot.mp4`, re-extract
   frames and check tick timing in `palexusos.script.in`.
3. Bump `pkgrel`, rebuild the package and the ISO, and confirm visually with
   `./build/test-iso-boot.sh --gui`.

### 3.3 Smaller items

- `README.md` links to a `LICENSE` file and shows an "MIT / GPLv3" badge, but
  the repository has no `LICENSE` file.
- The GitHub repository description still uses the old project name.
- Remote branches `rebrand/palexusos` and
  `task/work-through-the-tasks-listed-on-the-75b059` are fully merged into
  `main` and can be deleted.
- The login screen prints `PalexusOS 0.1.0-alpha`; the latest tag is
  `v0.2.0-alpha`.
- The live image does not ship `fish`, `fastfetch` or `lolcat`, so the shell
  welcome falls back to its plain banner and never offers the shell choice.
- `palexus-core` lists `etc/palexus/config.toml` as a backup file that the
  package does not contain (makepkg warning in CI).
- One unit fails during live boot: the loopback attach for `/dev/sr0`. Boot
  continues; cause not investigated.
