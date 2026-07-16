#!/usr/bin/env bash
set -Eeuo pipefail

status_main() {
    local arch kernel root fs ips gsusb canif bitrate state bootdir layout
    arch="$(arch_name)"
    kernel="$(kernel_name)"
    root="$(root_source)"
    fs="$(findmnt -n -o FSTYPE / 2>/dev/null || true)"
    ips="$(hostname -I 2>/dev/null | xargs || true)"
    gsusb="not loaded"; module_loaded gs_usb && gsusb="loaded"
    canif="missing"; ip link show can0 >/dev/null 2>&1 && canif="present"
    bitrate="$(can_bitrate)"; [[ -n "$bitrate" ]] || bitrate="not configured"
    state="$(can_state)"; [[ -n "$state" ]] || state="not available"
    bootdir="unknown"; layout="unknown"
    if detect_boot_layout; then bootdir="$BOOTDIR"; layout="$BOOT_LAYOUT"; fi

    echo "OrangePI4Pro Host Toolkit v$(cat /opt/orangepi4pro/VERSION)"
    echo
    printf '%-20s %s\n' "Architecture:" "$arch"
    printf '%-20s %s\n' "Kernel:" "$kernel"
    printf '%-20s %s\n' "Root device:" "$root"
    printf '%-20s %s\n' "Root filesystem:" "$fs"
    printf '%-20s %s\n' "Boot directory:" "$bootdir"
    printf '%-20s %s\n' "Boot layout:" "$layout"
    printf '%-20s %s\n' "IP address:" "$ips"
    printf '%-20s %s\n' "Klipper:" "$(service_active klipper && echo active || echo inactive)"
    printf '%-20s %s\n' "Moonraker:" "$(service_active moonraker && echo active || echo inactive)"
    printf '%-20s %s\n' "gs_usb:" "$gsusb"
    printf '%-20s %s\n' "CAN interface:" "$canif"
    printf '%-20s %s\n' "CAN bitrate:" "$bitrate"
    printf '%-20s %s\n' "CAN state:" "$state"
    printf '%-20s %s\n' "Disk usage:" "$(df -h / | awk 'NR==2{print $3" / "$2" ("$5")"}')"
}
