# PalexusOS — Release Channels & Update Streams

> **Surgical precision. Zero friction.**  
> Continuous delivery model, release channel definitions, and snapshot-guarded update cycles.

---

## 1. Release Channel Architecture

PalexusOS combines the rapid innovation of Arch Linux rolling packages with deterministic engineering gates. To serve both production mission-critical workstations and bleeding-edge testers, PalexusOS provides three distinct release streams:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        RELEASE CHANNELS                                │
│                                                                        │
│  [Nightly / Git CI]   -->   [Canary / Dev]   -->   [Stable Channel]    │
│  Continuous Builds          Bi-Weekly ISOs         Quarterly Milestones│
│  Git commit HEAD            Staged Testing         Signed SHA256 / GPG │
└────────────────────────────────────────────────────────────────────────┘
```

| Dimension | Stable Channel (`main`) | Canary / Dev Channel (`canary`) | Nightly Stream (`staging-ci`) |
| :--- | :--- | :--- | :--- |
| **Target Audience** | Primary development workstations, daily drivers | Testers, contributors, hardware porting | Automated headless CI test matrix |
| **Release Cadence** | Quarterly ISO milestones + verified updates | Bi-weekly ISO snapshots | Headless container build per commit |
| **Kernel Stream** | Vetted `linux-cachyos` BORE (LTS or pinned) | Latest upstream `linux-cachyos` BORE | Bleeding-edge kernel branch |
| **Verification Gate** | **100% Pass** across all 254 checks + QEMU | Automated gate pass + basic smoke test | Dry-run & container compilation |
| **Package Repository** | `[palexusos]` (GPG-signed database) | `[palexusos-testing]` | Local chroot builds |
| **Rollback Safety** | Automated Btrfs pre-update snapshot (`snap-pac`) | Automated Btrfs pre-update snapshot | Manual volume rollback |

---

## 2. Channel Descriptions

### 2.1 Stable Channel (`palexusos-stable`)
- **Recommended for 95% of users.**
- Delivers polished, fully signed ISO releases (e.g., `v0.1.0-alpha.2`, `v0.1.0-beta`, `v1.0`).
- Packages under `[palexusos]` are audited and cryptographically signed with detached GPG signatures.
- Updates arrive via regular `pacman -Syu`.

### 2.2 Canary / Dev Channel (`palexusos-canary`)
- Built directly from active feature branches in the `synapseOS` repository.
- Receives experimental HUD widgets, bleeding-edge PipeWire latency configurations, and early microarchitecture flags.
- ISO images are uploaded bi-weekly as GitHub Pre-Releases marked with tag suffix `-canary`.

### 2.3 Nightly Stream (`palexusos-nightly`)
- Headless automated builds triggered on every push to `main` and scheduled daily at 02:00 UTC via GitHub Actions.
- Produces ephemeral ISO artifacts retained for 14 days under the GitHub Actions **Artifacts** tab.
- Used by automated verification harnesses to prevent regression leaks into the stable repository.

---

## 3. Configuring Repositories in `/etc/pacman.conf`

The package repository stream is governed by `/etc/pacman.conf`:

### Default (Stable Channel):
```ini
[palexusos]
SigLevel = Required DatabaseOptional
Server = https://raw.githubusercontent.com/earnerbaymalay/synapseOS/main/out/repo

[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
```

### Switching to Canary / Testing Channel:
```ini
[palexusos-testing]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/earnerbaymalay/synapseOS/canary/out/repo

[palexusos]
SigLevel = Required DatabaseOptional
Server = https://raw.githubusercontent.com/earnerbaymalay/synapseOS/main/out/repo
```

---

## 4. Automated Rollback & Snapper Integration

PalexusOS installs with Btrfs snapshot hooks pre-activated in pacman (`/usr/share/libalpm/hooks/00-snapper-pre.hook`):
1. **Pre-Transaction Snapshot**: Before `pacman` removes, modifies, or writes a single package file, a read-only Btrfs snapshot of the root subvolume (`@`) is captured into `@snapshots`.
2. **Post-Transaction Snapshot**: A paired snapshot is captured after completion, recording the exact filesystem delta.

### How to Roll Back a Failed Update:

#### Method 1: Graphical Bootloader Menu
1. Reboot the computer.
2. In the GRUB menu, highlight **PalexusOS Snapshots**.
3. Select the snapshot taken right before your last update.
4. The system boots into a pristine, read-only copy of the working state.
5. Launch terminal and run `sudo snapper rollback` to make the current state permanent, then reboot.

#### Method 2: Command Line Rollback
```bash
# 1. View snapshot history with timestamps and descriptions:
sudo snapper list

# 2. Revert root subvolume to snapshot #14:
sudo snapper rollback 14

# 3. Reboot into restored state:
sudo reboot
```

---

## 5. Artifact Signing & Cryptographic Verification

All production release artifacts (ISO images, package databases, and checksum lists) are cryptographically signed using GPG detached signatures (`.sig`).

### 5.1 Build Pipeline Signing (`PALEXUS_GPG_KEY`)

The ISO build toolchain (`build/build-iso.sh`) supports automated cryptographic signing driven by the `PALEXUS_GPG_KEY` environment variable:

- **When `PALEXUS_GPG_KEY` is set**:
  - Native package repositories are signed during `repo-add`:
    ```bash
    repo-add --sign --key "$PALEXUS_GPG_KEY" -R out/repo/palexusos.db.tar.gz out/repo/*.pkg.tar.*
    ```
  - The Live ISO image is signed with a detached signature:
    ```bash
    gpg --batch --yes --detach-sign --default-key "$PALEXUS_GPG_KEY" --output out/palexusos-<version>-x86_64.iso.sig out/palexusos-<version>-x86_64.iso
    ```
  - Release checksum files (`SHA256SUMS` and `SHA512SUMS`) are signed:
    ```bash
    gpg --batch --yes --detach-sign --default-key "$PALEXUS_GPG_KEY" --output out/SHA256SUMS.sig out/SHA256SUMS
    ```
- **When `PALEXUS_GPG_KEY` is unset**:
  - `build/build-iso.sh` proceeds in development mode without `--sign`.
  - Emits a diagnostic notice: `[WARN] PALEXUS_GPG_KEY unset: repository and ISO will be unsigned (development mode)`.

> [!SECURITY]
> **Key Security**: Never commit private keys or credentials to Git. In CI/CD pipelines (e.g. GitHub Actions), import the key into the runner's GPG keyring from an encrypted repository secret (`PALEXUS_GPG_KEY_ARMORED`) and export `PALEXUS_GPG_KEY` with the signing key fingerprint.

---

### 5.2 Package Repository Signature Policy (`pacman.conf`)

In `/etc/pacman.conf` and `build/archiso/pacman.conf`, the `[palexusos]` repository directive defaults to:
```ini
[palexusos]
SigLevel = Optional TrustAll
Server = file:///var/cache/palexusos-repo
```
- **Development / Local Builds**: Uses `Optional TrustAll` so that unsigned or self-built packages can be tested immediately without managing keyring trust.
- **Production Deployment**: Once the PalexusOS official signing key is imported and signed into the pacman keyring (`pacman-key --add ... && pacman-key --lsign-key ...`), enforce strict cryptographic verification by switching to:
```ini
[palexusos]
SigLevel = Required DatabaseOptional
Server = https://packages.palexusos.org/stable/x86_64
```

---

### 5.3 Verifying Release Artifacts

Before booting or installing a downloaded ISO, always verify its integrity and authenticity.

#### Step 1: Import PalexusOS Release Signing Key
Import the official PalexusOS Release Engineering GPG public key:
```bash
gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys <PALEXUSOS_RELEASE_KEY_FINGERPRINT>
```

#### Step 2: Verify the Checksums File Signature
Verify that `SHA256SUMS` was signed by the official PalexusOS release key:
```bash
gpg --verify SHA256SUMS.sig SHA256SUMS
```
Expected output:
```text
gpg: Signature made ... using RSA key <PALEXUSOS_RELEASE_KEY_FINGERPRINT>
gpg: Good signature from "PalexusOS Release Engineering <releases@palexusos.org>" [full]
```

#### Step 3: Validate ISO Checksums
Check the SHA-256 hash of the downloaded ISO:
```bash
sha256sum --check --ignore-missing SHA256SUMS
```
Expected output:
```text
palexusos-2026.11.12-x86_64.iso: OK
```

#### Step 4: Verify the ISO Detached Signature Directly
Alternatively or in addition, verify the detached signature directly against the ISO file:
```bash
gpg --verify palexusos-2026.11.12-x86_64.iso.sig palexusos-2026.11.12-x86_64.iso
```
Expected output:
```text
gpg: Good signature from "PalexusOS Release Engineering <releases@palexusos.org>"
```

---

## 6. Automated QEMU Boot Smoke Testing

To guarantee that generated ISO images boot reliably on bare metal and hypervisors, PalexusOS includes a dedicated headless virtual machine smoke test harness: `build/test-iso-boot.sh`.

The test runs without root privileges, launches QEMU with UEFI firmware (OVMF), connects to the virtual serial console, and monitors boot milestones until the live user target is reached.

### 6.1 Boot Milestones Monitored

The smoke test observes three progressive boot convergence milestones:
1. **Milestone 1 — Kernel Initialization**: Detection of Linux kernel banner, EDK II UEFI boot loader, or EFI stub (`vmlinuz-linux-cachyos`).
2. **Milestone 2 — System Services**: systemd daemon convergence and startup of the core AI runtime (`palexus.service`).
3. **Milestone 3 — Live Target**: Live login prompt reachability or graphical target convergence (`PalexusOS Live` / `palexus-live`).

### 6.2 Running Locally

```bash
# 1. Verify host prerequisites (QEMU, OVMF firmware, KVM accessibility):
./build/test-iso-boot.sh --check

# 2. Dry-run verification (validates tools and outputs planned QEMU command):
./build/test-iso-boot.sh --dry-run

# 3. Execute live boot test against newest generated ISO in out/:
./build/test-iso-boot.sh

# 4. Target a specific ISO image with custom timeout and memory allocation:
./build/test-iso-boot.sh --iso out/palexusos-2026.11.12-x86_64.iso --timeout 90 --memory 4096 --smp 4

# 5. Monitor a custom boot marker:
./build/test-iso-boot.sh --marker "palexus.service"
```

### 6.3 Release Pipeline Integration

In continuous integration and release workflows:
- **Gate G4 Pre-flight**: `./build/verify-gates.sh` automatically runs `./build/test-iso-boot.sh --check` to verify that the build environment satisfies virtualization prerequisites.
- **Nightly & Canary Packaging**: After `mkarchiso` finishes ISO generation in `build/build-iso.sh`, CI runners invoke:
  ```bash
  ./build/test-iso-boot.sh --timeout 150 --iso out/palexusos-*.iso
  ```
  Only ISO images that pass the boot smoke test are uploaded to the GitHub Releases portal or promoted to the Stable channel.

