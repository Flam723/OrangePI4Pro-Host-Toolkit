#!/usr/bin/env bash
set -Eeuo pipefail

ok()   { printf '[ OK ] %s\n' "$*"; }
warn() { printf '[WARN] %s\n' "$*"; }
fail() { printf '[FAIL] %s\n' "$*"; }
info() { printf '[INFO] %s\n' "$*"; }

require_root() {
    [[ ${EUID:-$(id -u)} -eq 0 ]] || { echo "Run with sudo."; exit 1; }
}

arch_name() { uname -m; }
kernel_name() { uname -r; }
root_source() { findmnt -n -o SOURCE / 2>/dev/null || true; }
boot_source() { findmnt -n -o SOURCE /boot 2>/dev/null || true; }

detect_bootdir() {
    local candidate
    local -a candidates=(
        "/boot"
        "/boot/boot"
        "/media/mmcboot/boot"
        "/mnt/sdboot/boot"
    )

    for candidate in "${candidates[@]}"; do
        if [[ -f "$candidate/orangepiEnv.txt" \
           && -f "$candidate/boot.cmd" \
           && -f "$candidate/boot.scr" \
           && -e "$candidate/uImage" \
           && -e "$candidate/uInitrd" ]]; then
            BOOTDIR="$candidate"
            export BOOTDIR
            return 0
        fi
    done

    return 1
}

detect_boot_layout() {
    detect_bootdir || return 1
    local rs bs
    rs="$(root_source)"
    bs="$(boot_source)"

    if [[ "$BOOTDIR" == "/boot/boot" ]]; then
        BOOT_LAYOUT="microSD boot + separate root"
    elif [[ "$BOOTDIR" == "/boot" && -n "$bs" && "$bs" == "$rs" ]]; then
        BOOT_LAYOUT="single-device boot/root"
    elif [[ "$BOOTDIR" == "/boot" ]]; then
        BOOT_LAYOUT="separate /boot + root"
    else
        BOOT_LAYOUT="recovery/custom mount"
    fi
    export BOOT_LAYOUT
}

module_loaded() {
    local module="$1"
    lsmod | awk -v m="$module" '$1==m{found=1} END{exit !found}'
}

module_available() {
    local module="$1"
    module_loaded "$module" || /usr/sbin/modinfo "$module" >/dev/null 2>&1
}

service_active() {
    systemctl is-active --quiet "$1"
}

can_bitrate() {
    ip -details link show can0 2>/dev/null | awk '/bitrate/{print $2; exit}'
}

can_state() {
    ip -details link show can0 2>/dev/null | awk '/can state/{print $3; exit}'
}
