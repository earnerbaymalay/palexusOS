# PalexusOS — Release Channels & Update Streams

> **Surgical precision. Zero friction.**  
> Continuous delivery model, release channel definitions, and snapshot-guarded update cycles.

---

## 1. Release Channel Architecture

PalexusOS (formerly SynapseOS) combines the rapid innovation of Arch Linux rolling packages with deterministic engineering gates. To serve both production mission-critical workstations and bleeding-edge testers, PalexusOS provides three distinct release streams:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        RELEASE CHANNELS                                │
├────────────────────────────────────────────────────────────────────────┤
│  [Nightly / Git CI]   -->   [Canary / Dev]   -->   [Stable Channel]    │
│  Continuous Builds          Bi-Weekly ISOs         Quarterly Milestones│
│  Git commit HEAD            Staged Testing         Signed SHA256 / GPG │
└────────────────────────────────────────────────────────────────────────┘
```

```markdown
| Dimension | Stable Channel (`main`) | Canary / Dev Channel (`canary`) | Nightly Stream (`staging-ci`) |
| :--- | :--- | :--- | :--- |
| **Target Audience** | Primary development workstations, daily drivers | Testers, contributors, hardware porting | Automated headless CI test matrix |
| **Release Cadence** | Quarterly ISO milestones + verified updates | Bi-weekly ISO snapshots | Headless container build per commit |
| **Kernel Stream** | Vetted `linux-cachyos` BORE (LTS or pinned) | Latest upstream `linux-cachyos` BORE | Bleeding-edge kernel branch |
| **Verification Gate** | **100% Pass** across all 269 checks + QEMU | Automated gate pass + basic smoke test | Dry-run & container compilation |
| **Package Repository** | `[palexusos]` (GPG-signed database) | `[palexusos-testing]` | Local chroot builds |
| **Rollback Safety** | Automated Btrfs pre-update snapshot (`snap-pac`) | Automated Btrfs pre-update snapshot | Manual volume rollback |
```

---

## 2. Channel Descriptions

### 2.1 Stable Channel (`palexusos-stable`)
- **Recommended for 95% of users.**
- Delivers polished, fully signed ISO releases (e.g., `v0.2.0-alpha`, `v0.2.0-beta`, `v1.0`).
- Packages under `[palexusos]` are audited and cryptographically signed with detached GPG signatures.
- Updates arrive via regular `pacman -Syu`.

### 2.2 Canary / Dev Channel (`palexusos-canary`)
- Built directly from active feature branches in the `palexusOS` repository.
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

## 5. Cryptographic Signing & CI Secret Configuration

PalexusOS guarantees supply-chain integrity through end-to-end cryptographic signing of release ISOs, checksum manifests, and local repository databases.

### 5.1 Key Isolation Architecture (Prime Directive)
- **Zero Key Material in Git**: Private GPG keys must never be committed to the repository or stored in unencrypted scratch files.
- **Repository Trust**: Repository databases and binary packages use `SigLevel = Optional DatabaseOptional` in `/etc/pacman.conf`. When signatures are present, pacman verifies them against trusted keys; local unsigned testing packages remain functional when building without a signing key.

### 5.2 Signing Pipeline (`build/build-iso.sh`)
The build pipeline is driven by the `PALEXUS_GPG_KEY` environment variable:
- **When `PALEXUS_GPG_KEY` is set** (e.g. key ID, fingerprint, or email):
  - `repo-add` signs the repository database (`palexusos.db.tar.gz.sig`) via `--sign --key "${PALEXUS_GPG_KEY}"`.
  - Detached GPG signatures (`.sig`) are generated for the live ISO image (`palexusos-<version>-x86_64.iso.sig`), `SHA256SUMS.sig`, and `SHA512SUMS.sig`.
  - The signing key ID is recorded in `out/BUILD_MANIFEST.txt`.
- **When `PALEXUS_GPG_KEY` is unset**:
  - The build script outputs a clear warning: `==> [WARN] PALEXUS_GPG_KEY not set; package repository and ISO will be unsigned.`
  - The build succeeds cleanly, producing unsigned images suitable for local development and rapid test iteration.

### 5.3 CI Secret Configuration (GitHub Actions)
For production and release tag builds, signing keys are securely passed to GitHub Actions runners via Repository Secrets:
1. **Secret Names**:
   - `PALEXUS_GPG_PRIVATE_KEY`: ASCII-armored export of the release signing private key (`gpg --armor --export-secret-keys <KEY-ID>`).
   - `PALEXUS_GPG_KEY_ID`: Key ID or fingerprint (e.g., `882DCFE48E2051D48E2562ABF3B607488DB35A47`).
   - `PALEXUS_GPG_PASSPHRASE` (Optional): Passphrase if the exported private key is encrypted.
2. **Runner Ingestion**:
   The workflow imports the private key into an ephemeral runner keyring via `gpg --import`, exports `PALEXUS_GPG_KEY="${PALEXUS_GPG_KEY_ID}"`, and cleans up the keyring upon job termination.

### 5.4 End-User Verification Instructions
Users downloading PalexusOS release media can verify authenticity before flashing:
```bash
# 1. Download release ISO, checksums, and detached signatures
# 2. Import the official PalexusOS Release Signing Key:
gpg --recv-keys <PALEXUS_RELEASE_KEY_FPR>

# 3. Verify the checksum manifest signature:
gpg --verify SHA256SUMS.sig SHA256SUMS

# 4. Verify ISO integrity against the signed manifest:
sha256sum -c SHA256SUMS

# 5. Alternatively, verify the detached ISO signature directly:
gpg --verify palexusos-*.iso.sig palexusos-*.iso
```

