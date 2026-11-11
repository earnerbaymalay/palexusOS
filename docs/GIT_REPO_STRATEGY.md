# Git Repository Strategy for Large-Scale OS Distribution Projects

Building a Linux distribution involves managing multiple distinct layers: upstream source code, package recipes, root filesystem overlays, installer images, and documentation. If not structured properly, OS git repositories quickly swell into gigabytes of bloated history.

This document outlines the **Clean Git Architecture** for PalexusOS.

---

## 1. The Core Anti-Patterns in OS Repositories

1. **Tracking Binary ISOs or RootFS Tarballs in Git**:
   - Committing a 2GB `.iso` file or `rootfs.tar.gz` permanently bloats `.git/objects` forever, making `git clone` painful for all contributors.
2. **Monorepo Bloat with External Upstream Dependencies**:
   - Inlining huge third-party software trees directly into git commits rather than maintaining clean package recipes (`PKGBUILD`).
3. **Tracking Machine-Local Build States**:
   - Committing chroot mount points, pacman package caches, or local GPG keys.

---

## 2. The Clean Repository Structure

PalexusOS strictly adopts the **Metadata-as-Code** pattern used by Arch Linux, Debian, and Fedora:

```
palexusOS/
├── .cursor/skills/             # Workspace skills (palexusos-iso-build)
├── .vscode/                    # IDE tasks and settings
├── docs/                       # Architecture, research papers, specifications
│   ├── ARCHITECTURE.md
│   ├── RESEARCH_SYNAPSE_INTEGRATION.md
│   ├── INSPIRATIONS_ANALYSIS.md
│   └── GIT_REPO_STRATEGY.md
├── build/                      # Build orchestration (Code only, no artifacts)
│   ├── archiso/                # archiso profile (profiledef.sh, packages.x86_64)
│   ├── build-iso.sh            # Automated chroot & ISO generation script
│   └── verify-gates.sh         # Engineering gate verification harness
├── packages/                   # Native Arch PKGBUILD recipes
│   ├── core/
│   │   └── palexus-core/       # PKGBUILD building Palexus daemon from git
│   └── desktop/
│       ├── palexus-hud/        # Command HUD & utilities
│       ├── palexus-themes/     # Palettes, wallpapers, screensaver
│       ├── palexus-greeter/    # SDDM Qt6 theme
│       ├── palexus-plymouth/   # Plymouth boot splash
│       └── llm-quickfire-panel/# Quickfire floating panel
├── overlay/                    # System root overlay (/etc, /usr/share skeleton)
│   ├── etc/
│   │   ├── palexus/
│   │   ├── sysctl.d/
│   │   └── systemd/
│   └── skel/                   # Default user profile dotfiles
├── AGENTS.md                   # Agent Prime Directive & guidelines
├── GEMINI.md                   # Gemini workspace rules
├── README.md                   # Distribution overview & getting started
└── ROADMAP.md                  # Milestone tracking
```

---

## 3. Git Release & Artifact Pipeline

To keep the repository featherlight (< 10 MB total size):

```mermaid
flowchart LR
    REPO["palexusOS Git Repo (<10MB)"] -->|Tag: v0.1.0| CI["CI / Local Build Runner"]
    CI -->|makepkg in arch-nspawn| PKG["Binary Packages (.pkg.tar.zst)"]
    CI -->|mkarchiso| ISO["PalexusOS Bootable ISO (.iso)"]
    PKG --> R2["External Package Repository ([palexusos])"]
    ISO --> GH["GitHub Releases / Object Storage CDN"]
```

- **Git Tracks Only Source & Metadata**: PKGBUILD recipes, systemd unit files, config templates, and documentation.
- **Binaries Live in the Package Repository**: Built `.pkg.tar.zst` packages are pushed to a signed Pacman repository, never into Git.
- **ISOs Live in Release Assets**: Built ISO images are uploaded to GitHub Release assets or an S3/Cloudflare R2 bucket with SHA256 checksums.

---

## 4. Branching & Contribution Model

- `main`: Production-ready, verified package recipes and ISO profile definitions.
- `staging`: Integration branch where package updates are tested in chroots before promoting to main.
- `feat/*`: Topic branches for specific subsystems (e.g. `feat/cachy-kernel-hook`, `feat/palexus-daemon-preset`).
- **Commit Standards**: Conventional Commits (`feat(kernel):`, `fix(sddm):`, `docs(arch):`) to enable automated changelog generation and semantic release tagging.
