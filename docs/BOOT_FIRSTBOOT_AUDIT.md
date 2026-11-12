# Boot screen and first-boot setup audit

Branch `boot-firstboot-fixes` from `main` @ `17814cf`. Audited 2026-11-12.

**Evidence tags:**
- **[verified]**: checked against a real upstream package or source
- **[read]**: from the code alone
- **[VM]**: needs a real boot to confirm

## Summary

**The boot animation is wired correctly.** The installed system gets the Plymouth hook from Calamares, the theme from both the package and the overlay, and `splash` from `grubcfg`. No boot bugs were found; the open questions are polish, listed under Decisions.

**First-boot setup had three real bugs:**
- The welcome wizard can never tell it's running on the live USB, so the "Try or Install" screen never appears, and the live session offers to download AI models into RAM.
- If account creation fails half-way, you can't retry with the same username.
- If the setup window crashes, you land on a login screen with no account and no hint about the tty2 fallback.

**The HUD's "Ask AI" and three menu entries never worked.** They call shell aliases that only exist in interactive terminals. This is also why the old HUD test failed: the test expected the earlier code, and the newer code is broken.

## Fixed on this branch

| # | Fix |
|---|---|
| F1 | Live session detected by `/run/archiso` |
| F2 | A half-created account is removed on failure, so the retry works |
| F3 | `palexus-oobe-wizard` restarts the wizard up to 3 times, then shows a swaynag telling you to press Ctrl+Alt+F2 |
| F4 | The tty2 text setup suggests `palexus`, the same as the wizard |
| F5 | `--finalize` removes `/var/lib/palexus/oobe-seed` |
| H1, H2, T1 | HUD calls `ollama run` directly with the prompt as an argument; menu entries no longer use aliases; the stale test is updated and now also covers injection |

- **Checks:** `verify-gates.sh` passes 300/300, pytest 55/55 and ShellCheck is clean, all run in WSL on the branch's LF files.
- **Regression check:** against the original files, the 6 new gates and 8 tests fail.

## Boot screen

| Item | Status | Evidence |
|---|---|---|
| Frames extracted from `palexus-boot.mp4` and named to match the script (`frame-0000.png` …) | ✅ | `PKGBUILD:27-29` (`-start_number 0`), `palexusos.script.in:31-36` |
| Installed initramfs gets the `plymouth` hook, before `sd-encrypt` | ✅ [verified] | `cachyos-calamares` 3.4.2 `initcpiocfg/main.py:152-154` adds it whenever `plymouth` is in the target |
| Installed kernel line gets `splash` | ✅ [verified] | `grubcfg/main.py:173-174,225-226`; `grubcfg` is in the install sequence since PR #1 |
| Theme selected on install and upgrade, with retired themes migrated | ✅ | `palexus-plymouth.install`, `overlay/etc/plymouth/plymouthd.conf:4` |
| Initramfs rebuilt after theme changes, once per transaction | ✅ | `95-palexus-plymouth.hook:7-14` |
| Live entries pass `splash` (systemd-boot and syslinux); live initramfs has `kms plymouth` | ✅ | `efiboot/loader/entries/01-…conf:5`, `syslinux.cfg:16,22`, `archiso.conf:3` |
| LUKS passphrase and questions drawn on the splash | ✅ [VM] | `palexusos.script.in:66-109` |

## First-boot setup

| # | Problem | Effect | Evidence |
|---|---|---|---|
| F1 | ❌ The wizard detects the live session with `/etc/sudoers.d/00-palexus-live`, but `/etc/sudoers.d` is root-only (0750). | As the live user the check is always false. Live mode, with its Try/Install choice and "Install from the bar" hint, never shows. The live session defaults to downloading AI models. | [verified] Arch `sudo` 1.9.17.p2-7 ships `etc/sudoers.d/` as 000750. `palexus-welcome:39,317,345` |
| F2 | ❌ No rollback if account creation fails after `useradd`. | The retry is rejected with "username already taken", leaving a half-made account. | [read] `palexus-oobe-apply` `apply()` / `create_account()` |
| F3 | ❌ If the wizard crashes or can't load, the setup session ends with no retry and no message. | SDDM shows a login screen with no usable account. The tty2 fallback exists, but nothing tells you about it. | [read] `oobe-sway.conf:9` |
| F4 | ⚠️ The text fallback suggests computer name `palexusos`; the wizard suggests `palexus`. | Inconsistent defaults. | [read] `palexus-oobe-recovery`, `palexus-welcome:338` |
| F5 | ⚠️ `--finalize` leaves `/var/lib/palexus/oobe-seed` behind. | A leftover from the live session. | [read] `palexus-oobe-apply` `finalize()`; `shellprocess@cleanup.conf:14` |
| H1 | ❌ The HUD "Ask AI" runs `source ~/.bashrc; ask-qwen "<prompt>"` in a non-interactive shell. `.bashrc` returns at once for non-interactive shells, and `ask-qwen` is an alias anyway. | Every AI prompt from the HUD fails with "command not found". The prompt is also pasted inside double quotes, so a `"` breaks it and `$(…)` would run. | [read] `palexus-hud:51-55`; `overlay/etc/skel/.bashrc:6,142` |
| H2 | ❌ HUD menu entries `ask-qwen`, `ask-llama` and `squash` call `.bashrc` aliases inside `kitty bash -c`. | The same "command not found". | [read] `Main.qml:282,283,329` |
| T1 | ❌ `test_hud_backend_signals_and_launch` failed. | The test expected the pre-`bf51d87` `launch()`. Commit `bf51d87` changed `launch()` without updating the test, and in doing so broke H1. Both are now fixed. | `tests/test_ui_ux.py:107-135` |

## Decisions for you

1. **No "safe graphics" live boot entry.** There is no `nomodeset` / no-splash entry for machines whose GPU fails with KMS or Plymouth. Add one?
2. **The HUD and the `ask-qwen` alias use `qwen2.5-coder:latest`, but the wizard's "light" tier installs `qwen2.5-coder:1.5b`.** On a light-tier machine the first HUD question silently starts a large download. Should the HUD use whichever coder model the user installed?
3. **Initramfs size.** The animation is about 22 MB of frames inside every initramfs, with `xz -9e` on the live ISO. That means slower kernel updates and ISO builds. Keep the length and resolution as they are?
4. **"Copy to RAM" boot entry** passes fewer options than the main entry (no `nowatchdog`, `audit=0`, `systemd.show_status=auto`). Make them match?
5. **[VM] Splash-to-login hand-off.** Whether the last frame holds until SDDM appears, or flashes black, needs a real boot.

## Outside this branch's scope (noted for the desktop-look work)
- `overlay/etc/skel/.bashrc` defines the `ask-*` helpers only for interactive shells. Anything else that calls them non-interactively will fail the same way.
