# Testing PalexusOS in a VM

Two ways to boot an ISO:

| | Linux host | Windows host |
|---|---|---|
| Script | `build/test-iso-boot.sh` (QEMU + KVM) | `build/hyperv-vm.ps1` (Hyper-V) |
| Live boot smoke test | yes, headless or `--gui` | yes |
| Full install to a disk | no | yes (40 GB virtual disk, rollback checkpoint) |
| Admin rights | no | yes (the script asks Windows for elevation) |

## 1. Build the ISO on Windows (Arch in WSL)

```powershell
wsl --install archlinux --no-launch
wsl -d archlinux -u root -e bash -lc "pacman -Syu --noconfirm --needed archiso git base-devel sudo rust ffmpeg"
wsl -d archlinux -u root -e bash -lc "git clone https://github.com/earnerbaymalay/palexusOS.git /srv/palexusOS"
wsl -d archlinux -u root -e bash -lc "cd /srv/palexusOS && ./build/build-iso.sh --build-pkgs"
```

Clone into `/srv`, not `/root`: the package build runs as an unprivileged `builder` user that cannot enter `/root`. Keep the window open until the build ends. WSL stops the distro, and the build with it, once
no window is attached. The ISO lands in `/srv/palexusOS/out/`. Hyper-V can't read `\\wsl$`
paths, so copy the ISO to a normal folder:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\VMs\iso" | Out-Null
Copy-Item \\wsl$\archlinux\srv\palexusOS\out\palexusos-*.iso "$env:USERPROFILE\VMs\iso\"
```

Keep the ISO outside `VMs\PalexusOS-Test`, because `-Action Remove` deletes that folder.

## 2. Create and boot the VM

```powershell
.\build\hyperv-vm.ps1 -Action Create -IsoPath "$env:USERPROFILE\VMs\iso\palexusos-<date>-x86_64.iso"
.\build\hyperv-vm.ps1 -Action Start
```

Defaults: Generation 2 (UEFI), Secure Boot off, 4 vCPUs, 4 GB static RAM, 40 GB dynamic disk,
"Default Switch" networking (NAT, internet works). Each value has a parameter (`-Cpus`,
`-MemoryGB`, `-DiskGB`, `-SwitchName`).

Create also makes a checkpoint named `clean`, so `-Action Reset` puts the VM back to an empty
disk with the ISO first. Use it between install attempts.

## 3. What to check

Live session:
- [ ] Boot menu appears; the default entry reaches the Plymouth animation and then the desktop.
- [ ] Live autologin lands in Sway. Hyper-V has no 3D GPU, so this checks the software-render path.
- [ ] Welcome app shows "Try or Install" (the live session is detected through `/run/archiso`).
- [ ] Waybar's install button starts Calamares as root; the welcome page's Next button is enabled.

Install (Calamares):
- [ ] Plain ext4 install, then `-Action BootDisk`, then the installed system boots to the first-boot wizard.
- [ ] `-Action Reset`, then an encrypted (LUKS) install: the passphrase prompt is drawn on the splash and unlocks.
- [ ] Optional packs offline vs online: an install never stops with a formatted disk and no bootloader.
- [ ] After install: no Calamares, no "Install" Waybar button, and `Super+C` opens the calculator.

First boot:
- [ ] The wizard creates the account and the light tier installs `qwen2.5-coder:1.5b`.
- [ ] If the wizard is killed, the tty2 recovery (`palexus-oobe-recovery`) still lets you log in.
- [ ] The splash hands off to SDDM without a black flash.

## 4. Commands

| Command | Does |
|---|---|
| `-Action Status` | State, boot order, checkpoints |
| `-Action Start` | Start and open the console window |
| `-Action BootDisk` | Disk first, ISO ejected (after an install) |
| `-Action BootIso -IsoPath ...` | ISO back in and first (live retest, reinstall) |
| `-Action Reset` | Back to the `clean` checkpoint |
| `-Action Remove` | Delete the VM and its disk (asks first; `-Force` skips the question) |
