"""Boot 1 and Boot 4: every live boot menu has a matching Copy to RAM and Safe graphics entry."""

import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
ARCHISO = REPO_ROOT / "build" / "archiso"
SYSLINUX = ARCHISO / "syslinux" / "syslinux.cfg"
ENTRIES = ARCHISO / "efiboot" / "loader" / "entries"
SAFE_ADDS = {"nomodeset", "plymouth.enable=0"}
SAFE_DROPS = {"quiet", "splash"}


def syslinux_entries():
    entries, label = {}, None
    for line in SYSLINUX.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line.startswith("LABEL "):
            label = line.split(None, 1)[1]
        elif line.startswith("APPEND ") and label:
            entries[label] = line.split(None, 1)[1].split()
    return entries


def systemd_boot_entries():
    entries = {}
    for conf in sorted(ENTRIES.glob("*.conf")):
        text = conf.read_text(encoding="utf-8")
        opts = re.search(r"^options\s+(.*)$", text, re.M)
        entries[conf.name] = opts.group(1).split() if opts else []
    return entries


def check_menu(main, ram, safe):
    # Copy to RAM: exactly the main entry's options, plus copytoram
    assert ram == main + ["copytoram"]
    # Safe graphics: the main entry's options without the splash, plus nomodeset
    assert SAFE_ADDS <= set(safe)
    assert not SAFE_DROPS & set(safe)
    assert [o for o in safe if o not in SAFE_ADDS] == [o for o in main if o not in SAFE_DROPS]


def test_syslinux_entries_match_main():
    e = syslinux_entries()
    assert "splash" in e["select"]
    check_menu(e["select"], e["ram"], e["safe"])


def test_systemd_boot_entries_match_main():
    e = systemd_boot_entries()
    assert "splash" in e["01-palexusos-x86_64-linux.conf"]
    check_menu(e["01-palexusos-x86_64-linux.conf"],
               e["02-palexusos-x86_64-linux-copytoram.conf"],
               e["03-palexusos-x86_64-linux-safe-graphics.conf"])


def test_bios_and_uefi_menus_boot_the_same_options():
    s, u = syslinux_entries(), systemd_boot_entries()
    assert s["select"] == u["01-palexusos-x86_64-linux.conf"]


def test_iso_uses_only_these_boot_loaders():
    # If GRUB is ever added to the ISO, it needs the same three entries
    profile = (ARCHISO / "profiledef.sh").read_text(encoding="utf-8")
    modes = re.findall(r"'((?:bios|uefi)[^']*)'", profile)
    assert modes and all(".syslinux." in m or ".systemd-boot." in m for m in modes), modes


def test_safe_graphics_live_session_falls_back_to_xfce():
    script = (ARCHISO / "airootfs" / "root" / "customize_airootfs.sh").read_text(encoding="utf-8")
    assert "ConditionKernelCommandLine=nomodeset" in script
    assert "Session=xfce.desktop" in script
    assert "systemctl enable palexus-safe-graphics.service" in script
    packages = (ARCHISO / "packages.x86_64").read_text(encoding="utf-8").split()
    assert {"xf86-video-vesa", "xf86-video-fbdev", "xfce4"} <= set(packages)
