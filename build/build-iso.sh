#!/usr/bin/env bash
# ==============================================================================
# PalexusOS Live ISO Builder (build/build-iso.sh)
# Synchronizes overlays, optionally builds local PKGBUILDs, and invokes mkarchiso.
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
PROFILE_DIR="${SCRIPT_DIR}/archiso"
AIROOTFS_DIR="${PROFILE_DIR}/airootfs"
OVERLAY_DIR="${REPO_ROOT}/overlay"
CALAMARES_SRC="${REPO_ROOT}/packages/installer/calamares"
# Disk-backed: /tmp is a RAM tmpfs and too small for a full airootfs
WORK_DIR="${WORK_DIR:-/var/tmp/palexusos-archiso-work}"
OUT_DIR="${OUT_DIR:-${REPO_ROOT}/out}"
LOCAL_REPO_DIR="${LOCAL_REPO_DIR:-${OUT_DIR}/repo}"
SYSTEM_REPO_DIR="/var/cache/palexusos-repo"
# Isolated build keyring + pacman.conf: mkarchiso never touches the host keyring or /etc/pacman.d
BUILD_STATE_DIR="/var/lib/palexusos-build"
BUILD_GPGDIR="${BUILD_STATE_DIR}/gnupg"
BUILD_PACMAN_CONF="${BUILD_STATE_DIR}/pacman.conf"
CACHYOS_KEY_FPR="882DCFE48E2051D48E2562ABF3B607488DB35A47"

# Reproducible builds: default SOURCE_DATE_EPOCH to the last git commit timestamp
if [[ -z "${SOURCE_DATE_EPOCH:-}" ]]; then
    SOURCE_DATE_EPOCH="$(git -C "${REPO_ROOT}" log -1 --pretty=%ct 2>/dev/null || date +%s)"
fi
export SOURCE_DATE_EPOCH

DRY_RUN=0
BUILD_PKGS=0

usage() {
    cat << 'EOF'
Usage: ./build/build-iso.sh [OPTIONS]

Options:
  --dry-run, --check   Validate profile, stage overlays, and verify readiness without root/mkarchiso
  --build-pkgs         Build native PKGBUILDs under packages/ and populate local [palexusos] repo
  -w, --work-dir DIR   Set archiso working directory (default: /var/tmp/palexusos-archiso-work)
  -o, --out-dir DIR    Set ISO output directory (default: ./out)
  -h, --help           Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run|--check)
            DRY_RUN=1
            shift
            ;;
        --build-pkgs)
            BUILD_PKGS=1
            shift
            ;;
        -w|--work-dir)
            WORK_DIR="$2"
            shift 2
            ;;
        -o|--out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "[ERROR] Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

echo "==> [PalexusOS ISO Builder] Initializing build pipeline..."
echo "    Repository Root : ${REPO_ROOT}"
echo "    Archiso Profile : ${PROFILE_DIR}"
echo "    Output Directory: ${OUT_DIR}"

# 1. Verify core Archiso profile files exist
REQUIRED_PROFILE_FILES=(
    "${PROFILE_DIR}/profiledef.sh"
    "${PROFILE_DIR}/packages.x86_64"
    "${PROFILE_DIR}/pacman.conf"
    "${PROFILE_DIR}/efiboot/loader/loader.conf"
    "${PROFILE_DIR}/efiboot/loader/entries/01-palexusos-x86_64-linux.conf"
    "${PROFILE_DIR}/syslinux/syslinux.cfg"
    "${AIROOTFS_DIR}/root/customize_airootfs.sh"
)

for req in "${REQUIRED_PROFILE_FILES[@]}"; do
    if [[ ! -f "${req}" ]]; then
        echo "[ERROR] Missing required archiso file: ${req}" >&2
        exit 1
    fi
done

# 2. Synchronize overlay/ into build/archiso/airootfs/etc
# Reset generated staging first (gitignored files only; tracked airootfs files stay)
# so overlay files that were renamed or removed don't linger in the image.
if git -C "${REPO_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "${REPO_ROOT}" clean -fdXq -- "${AIROOTFS_DIR}"
fi
mkdir -p "${AIROOTFS_DIR}/etc"

if [[ -d "${OVERLAY_DIR}/etc" ]]; then
    echo "==> Syncing ${OVERLAY_DIR}/etc -> ${AIROOTFS_DIR}/etc ..."
    cp -af "${OVERLAY_DIR}/etc/." "${AIROOTFS_DIR}/etc/"
elif [[ -d "${OVERLAY_DIR}" ]]; then
    echo "==> Syncing ${OVERLAY_DIR} -> ${AIROOTFS_DIR}/etc ..."
    cp -af "${OVERLAY_DIR}/." "${AIROOTFS_DIR}/etc/"
else
    echo "==> [WARN] No overlay/ directory found yet; continuing with base airootfs."
fi

if [[ -d "${OVERLAY_DIR}/skel" ]]; then
    echo "==> Syncing ${OVERLAY_DIR}/skel -> ${AIROOTFS_DIR}/etc/skel ..."
    mkdir -p "${AIROOTFS_DIR}/etc/skel"
    cp -af "${OVERLAY_DIR}/skel/." "${AIROOTFS_DIR}/etc/skel/"
fi

if [[ -d "${OVERLAY_DIR}/usr" ]]; then
    echo "==> Syncing ${OVERLAY_DIR}/usr -> ${AIROOTFS_DIR}/usr ..."
    mkdir -p "${AIROOTFS_DIR}/usr"
    cp -af "${OVERLAY_DIR}/usr/." "${AIROOTFS_DIR}/usr/"
fi

# 3. Stage Calamares installer configurations into airootfs
if [[ -d "${CALAMARES_SRC}" ]]; then
    # Staged aside: cachyos-calamares owns /etc/calamares/*, so pacstrap would hit file
    # conflicts. customize_airootfs.sh copies this over /etc/calamares after packages install.
    echo "==> Staging Calamares configuration into ${AIROOTFS_DIR}/etc/palexusos/calamares ..."
    rm -rf "${AIROOTFS_DIR}/etc/calamares"
    mkdir -p "${AIROOTFS_DIR}/etc/palexusos/calamares"
    cp -af "${CALAMARES_SRC}/." "${AIROOTFS_DIR}/etc/palexusos/calamares/"
fi

# 4. Optionally build local PalexusOS PKGBUILDs
build_local_packages() {
    echo "==> Building local PalexusOS native packages into ${LOCAL_REPO_DIR}..."
    mkdir -p "${LOCAL_REPO_DIR}"

    # Pre-seed local sources only when not already staged in packages/.../src/
    local sc_dir="${REPO_ROOT}/packages/core/palexus-core"
    if [[ ! -d "${sc_dir}/src/synapse" ]] && [[ -n "${PALEXUS_CORE_SRC:-}" ]] && [[ -d "${PALEXUS_CORE_SRC}" ]]; then
        mkdir -p "${sc_dir}/src"
        cp -al "${PALEXUS_CORE_SRC}" "${sc_dir}/src/synapse"
    fi
    if [[ -d "${sc_dir}/src" ]]; then
        cp -f "${sc_dir}/palexus.service" "${sc_dir}/palexus-sync.service" "${sc_dir}/palexus-sync.timer" "${sc_dir}/src/"
    fi

    local qf_dir="${REPO_ROOT}/packages/desktop/llm-quickfire-panel"
    if [[ ! -d "${qf_dir}/src/llm-quickfire-panel" ]] && [[ -d "${REPO_ROOT}/../llm-quickfire-panel" ]]; then
        mkdir -p "${qf_dir}/src"
        cp -af "${REPO_ROOT}/../llm-quickfire-panel" "${qf_dir}/src/llm-quickfire-panel"
    fi

    local pkg_dirs=(
        "${REPO_ROOT}/packages/core/palexus-core"
        "${REPO_ROOT}/packages/desktop/llm-quickfire-panel"
        "${REPO_ROOT}/packages/desktop/palexus-themes"
        "${REPO_ROOT}/packages/desktop/palexus-greeter"
        "${REPO_ROOT}/packages/desktop/palexus-plymouth"
        "${REPO_ROOT}/packages/desktop/palexus-hud"
    )

    for pkg_dir in "${pkg_dirs[@]}"; do
        if [[ -f "${pkg_dir}/PKGBUILD" ]]; then
            if compgen -G "${pkg_dir}/*.pkg.tar.*" > /dev/null; then
                echo "    -> [CACHED] Package already built in ${pkg_dir}, using existing package..."
                cp -f "${pkg_dir}"/*.pkg.tar.* "${LOCAL_REPO_DIR}/"
                continue
            fi
            echo "    -> Building PKGBUILD in ${pkg_dir}..."
            (
                cd "${pkg_dir}"
                local makepkg_flags=("-sf" "--noconfirm")
                # shellcheck source=/dev/null disable=SC2154  # PKGBUILD is per package; makedepends comes from it
                if [[ -d "${pkg_dir}/src" ]] && [[ -n "$(ls -A "${pkg_dir}/src" 2>/dev/null)" ]]; then
                    makepkg_flags=("-ef" "--noconfirm" "--nodeps")
                elif [[ -z "$( (source ./PKGBUILD; if declare -p makedepends >/dev/null 2>&1 && ((${#makedepends[@]})); then pacman -T "${makedepends[@]}"; fi) || true)" ]]; then
                    # Build tools already present: never install runtime deps on the build host
                    makepkg_flags=("-f" "--noconfirm" "--nodeps")
                fi
                if [[ "${EUID}" -eq 0 ]]; then
                    local build_user="builder"
                    if ! id "${build_user}" >/dev/null 2>&1; then
                        useradd -m -s /bin/bash "${build_user}" 2>/dev/null || build_user="nobody"
                    fi
                    local user_home
                    user_home=$(eval echo ~"${build_user}")
                    mkdir -p "${user_home}/.cargo"
                    chown -R "${build_user}:${build_user}" "${pkg_dir}" "${LOCAL_REPO_DIR}" "${user_home}"
                    if command -v sudo >/dev/null 2>&1; then
                        sudo -H -u "${build_user}" env HOME="${user_home}" CARGO_HOME="${user_home}/.cargo" SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH}" makepkg "${makepkg_flags[@]}"
                    else
                        runuser -u "${build_user}" -- env HOME="${user_home}" CARGO_HOME="${user_home}/.cargo" SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH}" makepkg "${makepkg_flags[@]}"
                    fi
                else
                    SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH}" makepkg "${makepkg_flags[@]}"
                fi
                cp -f ./*.pkg.tar.* "${LOCAL_REPO_DIR}/"
            )
        else
            echo "    -> [SKIP] ${pkg_dir}/PKGBUILD not present."
        fi
    done

    if compgen -G "${LOCAL_REPO_DIR}/*.pkg.tar.*" > /dev/null; then
        if [[ -n "${PALEXUS_GPG_KEY:-}" ]]; then
            echo "==> Signing local repository database with GPG key: ${PALEXUS_GPG_KEY}..."
            repo-add -R --sign --key "${PALEXUS_GPG_KEY}" "${LOCAL_REPO_DIR}/palexusos.db.tar.gz" "${LOCAL_REPO_DIR}"/*.pkg.tar.*
        else
            echo "==> [WARN] PALEXUS_GPG_KEY not set; package repository will be unsigned."
            repo-add -R "${LOCAL_REPO_DIR}/palexusos.db.tar.gz" "${LOCAL_REPO_DIR}"/*.pkg.tar.*
        fi
    fi

}

if [[ "${BUILD_PKGS}" -eq 1 ]]; then
    build_local_packages
fi

# Stage local repository into airootfs so live/installed environment has cached packages
if compgen -G "${LOCAL_REPO_DIR}/*.pkg.tar.*" > /dev/null; then
    mkdir -p "${AIROOTFS_DIR}${SYSTEM_REPO_DIR}"
    cp -af "${LOCAL_REPO_DIR}/." "${AIROOTFS_DIR}${SYSTEM_REPO_DIR}/"
fi

generate_build_manifest() {
    local manifest_file="${OUT_DIR}/BUILD_MANIFEST.txt"
    mkdir -p "${OUT_DIR}"
    echo "==> Recording reproducible build manifest to ${manifest_file}..."
    {
        echo "PalexusOS Build Manifest"
        echo "=============================================================================="
        echo "Build Timestamp (UTC): $(date -u -d "@${SOURCE_DATE_EPOCH}" '+%Y-%m-%d %H:%M:%S UTC' 2>/dev/null || date -u '+%Y-%m-%d %H:%M:%S UTC')"
        echo "SOURCE_DATE_EPOCH:     ${SOURCE_DATE_EPOCH}"
        echo "Git Commit:            $(git -C "${REPO_ROOT}" rev-parse HEAD 2>/dev/null || echo 'unknown')"
        echo "Git Branch:            $(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
        echo "Git Status Clean:      $([[ -z "$(git -C "${REPO_ROOT}" status --porcelain 2>/dev/null)" ]] && echo 'true' || echo 'false')"
        echo "GPG Signing Key:       ${PALEXUS_GPG_KEY:-none (unsigned)}"
        echo ""
        echo "Native Packages:"
        echo "------------------------------------------------------------------------------"
        for pkg_dir in \
            "${REPO_ROOT}/packages/core/palexus-core" \
            "${REPO_ROOT}/packages/desktop/llm-quickfire-panel" \
            "${REPO_ROOT}/packages/desktop/palexus-themes" \
            "${REPO_ROOT}/packages/desktop/palexus-greeter" \
            "${REPO_ROOT}/packages/desktop/palexus-plymouth" \
            "${REPO_ROOT}/packages/desktop/palexus-hud"; do
            if [[ -f "${pkg_dir}/PKGBUILD" ]]; then
                local p_name p_ver p_rel
                p_name="$(grep -E '^[[:space:]]*pkgname=' "${pkg_dir}/PKGBUILD" | head -n1 | cut -d= -f2 | tr -d ' "\047')"
                p_ver="$(grep -E '^[[:space:]]*pkgver=' "${pkg_dir}/PKGBUILD" | head -n1 | cut -d= -f2 | tr -d ' "\047')"
                p_rel="$(grep -E '^[[:space:]]*pkgrel=' "${pkg_dir}/PKGBUILD" | head -n1 | cut -d= -f2 | tr -d ' "\047')"
                printf "  %-25s %s-%s\n" "${p_name}" "${p_ver}" "${p_rel}"
            fi
        done
        echo ""
        echo "Upstream Sources:"
        echo "------------------------------------------------------------------------------"
        echo "  synapse-core upstream: $(grep -E 'synapse::git\+https' "${REPO_ROOT}/packages/core/palexus-core/PKGBUILD" | tr -d ' "')"
    } > "${manifest_file}"
}

# 5. Dry-run check mode (non-root safe)
if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "==> [DRY-RUN] Validating profiledef.sh and customize_airootfs.sh syntax..."
    bash -n "${PROFILE_DIR}/profiledef.sh"
    bash -n "${AIROOTFS_DIR}/root/customize_airootfs.sh"
    generate_build_manifest
    if [[ -n "${PALEXUS_GPG_KEY:-}" ]]; then
        echo "==> [DRY-RUN] GPG signing key configured: ${PALEXUS_GPG_KEY}"
    else
        echo "==> [WARN] PALEXUS_GPG_KEY not set; package repository and ISO will be unsigned."
    fi
    echo "==> [DRY-RUN] Archiso profile, CachyOS mirrorlists & RootFS overlay staged and validated."
    echo "    Would execute: mkarchiso -v -C \"${BUILD_PACMAN_CONF}\" -w \"${WORK_DIR}\" -o \"${OUT_DIR}\" \"${PROFILE_DIR}\""
    exit 0
fi

# 6. Prepare isolated build keyring, build pacman.conf & [palexusos] repo for mkarchiso
prepare_host_build_env() {
    local priv_cmd=()
    if [[ "${EUID}" -ne 0 ]]; then
        priv_cmd=(sudo)
    fi

    "${priv_cmd[@]}" install -d -m 0700 "${BUILD_STATE_DIR}"

    if [[ ! -f "${BUILD_GPGDIR}/pubring.gpg" ]]; then
        echo "==> Initializing isolated build keyring at ${BUILD_GPGDIR}..."
        "${priv_cmd[@]}" pacman-key --gpgdir "${BUILD_GPGDIR}" --init
        "${priv_cmd[@]}" pacman-key --gpgdir "${BUILD_GPGDIR}" --populate archlinux
    fi
    if ! "${priv_cmd[@]}" gpg --homedir "${BUILD_GPGDIR}" --list-keys "${CACHYOS_KEY_FPR}" >/dev/null 2>&1; then
        echo "==> Fetching CachyOS signing key ${CACHYOS_KEY_FPR}..."
        "${priv_cmd[@]}" pacman-key --gpgdir "${BUILD_GPGDIR}" --keyserver hkps://keyserver.ubuntu.com --recv-keys "${CACHYOS_KEY_FPR}"
        "${priv_cmd[@]}" pacman-key --gpgdir "${BUILD_GPGDIR}" --lsign-key "${CACHYOS_KEY_FPR}"
    fi

    echo "==> Writing build pacman.conf to ${BUILD_PACMAN_CONF}..."
    # DisableDownloadTimeout: tolerate slow/tethered links (build-only, not shipped)
    sed -e "/^\[options\]/a GPGDir = ${BUILD_GPGDIR}\nDisableDownloadTimeout" \
        -e "s|^Include = /etc/pacman.d/cachyos|Include = ${OVERLAY_DIR}/etc/pacman.d/cachyos|" \
        "${PROFILE_DIR}/pacman.conf" | "${priv_cmd[@]}" tee "${BUILD_PACMAN_CONF}" >/dev/null

    if [[ -d "${LOCAL_REPO_DIR}" ]]; then
        echo "==> Syncing local [palexusos] repository to ${SYSTEM_REPO_DIR}..."
        "${priv_cmd[@]}" mkdir -p "${SYSTEM_REPO_DIR}"
        "${priv_cmd[@]}" cp -af "${LOCAL_REPO_DIR}/." "${SYSTEM_REPO_DIR}/"
    fi
}

# 7. Execute mkarchiso (requires root privileges)
if ! command -v mkarchiso >/dev/null 2>&1; then
    echo "[ERROR] mkarchiso not found. Install 'archiso' (sudo pacman -S archiso)." >&2
    exit 1
fi

prepare_host_build_env
mkdir -p "${OUT_DIR}"
generate_build_manifest

if [[ "${EUID}" -ne 0 ]]; then
    echo "==> Elevating privileges via sudo to run mkarchiso..."
    sudo env SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH}" mkarchiso -v -C "${BUILD_PACMAN_CONF}" -w "${WORK_DIR}" -o "${OUT_DIR}" "${PROFILE_DIR}"
else
    env SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH}" mkarchiso -v -C "${BUILD_PACMAN_CONF}" -w "${WORK_DIR}" -o "${OUT_DIR}" "${PROFILE_DIR}"
fi

sign_release_artifacts() {
    local iso_files
    shopt -s nullglob
    iso_files=("${OUT_DIR}"/palexusos-*.iso)
    shopt -u nullglob

    if [[ ${#iso_files[@]} -eq 0 ]]; then
        return 0
    fi

    echo "==> Generating SHA256 and SHA512 checksums in ${OUT_DIR}..."
    (
        cd "${OUT_DIR}"
        sha256sum ./palexusos-*.iso > SHA256SUMS
        sha512sum ./palexusos-*.iso > SHA512SUMS
    )

    if [[ -n "${PALEXUS_GPG_KEY:-}" ]]; then
        echo "==> Signing ISO images and checksums with GPG key: ${PALEXUS_GPG_KEY}..."
        for iso in "${iso_files[@]}"; do
            echo "    -> Signing ${iso}..."
            gpg --batch --yes --detach-sign --default-key "${PALEXUS_GPG_KEY}" "${iso}"
        done
        if [[ -f "${OUT_DIR}/SHA256SUMS" ]]; then
            echo "    -> Signing SHA256SUMS..."
            gpg --batch --yes --detach-sign --default-key "${PALEXUS_GPG_KEY}" "${OUT_DIR}/SHA256SUMS"
        fi
        if [[ -f "${OUT_DIR}/SHA512SUMS" ]]; then
            echo "    -> Signing SHA512SUMS..."
            gpg --batch --yes --detach-sign --default-key "${PALEXUS_GPG_KEY}" "${OUT_DIR}/SHA512SUMS"
        fi
    else
        echo "==> [WARN] PALEXUS_GPG_KEY not set; ISO images and checksums will be unsigned."
    fi
}

sign_release_artifacts

echo "==> [PalexusOS ISO Builder] ISO generation complete. Artifacts in ${OUT_DIR}:"
ls -lh "${OUT_DIR}"
