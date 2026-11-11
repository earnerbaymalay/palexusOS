#!/usr/bin/env bash
# shellcheck disable=SC2034
# PalexusOS Archiso Profile Definition

iso_name="palexusos"
iso_label="PALEXUSOS_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="PalexusOS Project <https://github.com/earnerbaymalay/palexusos>"
iso_application="PalexusOS Live/Installation DVD"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="palexusos"
buildmodes=('iso')
bootmodes=(
    'bios.syslinux.mbr'
    'bios.syslinux.eltorito'
    'uefi-x64.systemd-boot.esp'
    'uefi-x64.systemd-boot.eltorito'
)
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'zstd' '-Xcompression-level' '15' '-b' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
    ["/etc/shadow"]="0:0:400"
    ["/etc/gshadow"]="0:0:400"
    ["/root"]="0:0:750"
    ["/root/customize_airootfs.sh"]="0:0:755"
)
