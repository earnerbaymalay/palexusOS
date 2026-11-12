#!/usr/bin/env bash
# ==============================================================================
# PalexusOS Archiso Post-Install RootFS Customization Hook
# Executed inside the chroot during mkarchiso image generation.
# ==============================================================================
set -euo pipefail

echo "[PalexusOS] Configuring locale, timezone, and hostname..."
sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "palexusos" > /etc/hostname

# Merge staged /overlay/etc if present inside airootfs
if [[ -d /overlay/etc ]]; then
    echo "[PalexusOS] Merging /overlay/etc into root filesystem..."
    cp -af /overlay/etc/. /etc/
    rm -rf /overlay
fi

# Apply PalexusOS Calamares config over the cachyos-calamares defaults
if [[ -d /etc/palexusos/calamares ]]; then
    echo "[PalexusOS] Installing Calamares configuration..."
    cp -af /etc/palexusos/calamares/. /etc/calamares/
    rm -rf /etc/palexusos/calamares
fi

# Ensure experimental xfce-wayland session is removed so SDDM cleanly offers XFCE (X11) and Sway
rm -f /usr/share/wayland-sessions/xfce-wayland.desktop

# Create live user 'palexus' with passwordless sudo for live environment
# (live-only: Calamares shellprocess@cleanup deletes both on install)
if ! id -u palexus >/dev/null 2>&1; then
    echo "[PalexusOS] Creating live user 'palexus'..."
    useradd -m -G wheel,video,audio,input,network,storage,wireshark -s /bin/bash palexus
    passwd -d palexus
fi

install -d -m 0750 /etc/sudoers.d
cat << 'EOF' > /etc/sudoers.d/00-palexus-live
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/00-palexus-live

# Boot straight into the live desktop, no login prompt for the passwordless live user
install -d -m 0755 /etc/sddm.conf.d
cat << 'EOF' > /etc/sddm.conf.d/00-palexus-live.conf
[Autologin]
User=palexus
Session=sway.desktop
Relogin=false
EOF

# Ensure /etc/skel is synced into /home/palexus
if [[ -d /etc/skel ]]; then
    cp -af /etc/skel/. /home/palexus/
    chown -R palexus:palexus /home/palexus
fi

# Set default systemd target to graphical
echo "[PalexusOS] Setting default target to graphical.target..."
systemctl set-default graphical.target

# Enable core system, security, performance, and AI services
SERVICES=(
    "sddm.service"
    "NetworkManager.service"
    "systemd-resolved.service"
    "firewalld.service"
    "ananicy-cpp.service"
    "ollama.service"
    "palexus.service"
)

for svc in "${SERVICES[@]}"; do
    echo "[PalexusOS] Enabling service: ${svc}"
    systemctl enable "${svc}" 2>/dev/null || ln -sf "/usr/lib/systemd/system/${svc}" "/etc/systemd/system/multi-user.target.wants/${svc}" || true
done

# NetworkManager owns networking. Mask wait-online units to eliminate 30-60s boot stalls
# on live media or offline connections (network-online.target proceeds without holding boot).
systemctl disable systemd-networkd.service systemd-networkd.socket 2>/dev/null || true
systemctl mask systemd-networkd-wait-online.service NetworkManager-wait-online.service 2>/dev/null || true

# Ensure SDDM display-manager symlink is established
ln -sf /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service

# /etc/resolv.conf -> systemd-resolved stub (Quad9 DoT) ships as a symlink in the profile
# airootfs: inside arch-chroot it is bind-mounted from the build host and can't be replaced.

# Pacman Keyring: generated per boot on a tmpfs, never at build time, so no two
# PalexusOS machines share a pacman master signing key. `--populate` picks up the
# CachyOS key (F3B607488DB35A47) from the cachyos-keyring package; no keyserver fetch.
# Calamares (shellprocess@cleanup) removes these units and builds a fresh keyring on install.
echo "[PalexusOS] Installing per-boot pacman keyring units..."
rm -rf /etc/pacman.d/gnupg
cat << 'EOF' > /etc/systemd/system/etc-pacman.d-gnupg.mount
[Unit]
Description=Temporary /etc/pacman.d/gnupg directory

[Mount]
What=tmpfs
Where=/etc/pacman.d/gnupg
Type=tmpfs
Options=mode=0755,noswap
EOF
cat << 'EOF' > /etc/systemd/system/pacman-init.service
[Unit]
Description=Initializes Pacman keyring
Requires=etc-pacman.d-gnupg.mount
After=etc-pacman.d-gnupg.mount
BindsTo=etc-pacman.d-gnupg.mount

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/pacman-key --init
ExecStart=/usr/bin/pacman-key --populate

[Install]
WantedBy=multi-user.target
EOF
systemctl enable pacman-init.service

echo "[PalexusOS] customize_airootfs.sh completed successfully."
