#!/usr/bin/env bash
set -Eeuo pipefail

doctor_main() {
    local failures=0
    local warnings=0

    echo "OrangePI4Pro Doctor v$(cat /opt/orangepi4pro/VERSION)"
    echo

    if [[ "$(arch_name)" == "aarch64" ]]; then
        ok "64-bit ARM architecture detected: aarch64"
    else
        fail "Architecture is $(arch_name)"
        ((failures++))
    fi

    if [[ -f /etc/orangepi-release ]]; then
        ok "Orange Pi release metadata detected"
    else
        fail "Orange Pi release metadata missing"
        ((failures++))
    fi

    local root
    root="$(root_source)"
    if [[ "$root" == /dev/nvme* ]]; then
        ok "Root filesystem is on NVMe: $root"
    else
        warn "Root filesystem is not on NVMe: ${root:-unknown}"
        ((warnings++))
    fi

    if detect_boot_layout; then
        ok "Boot directory detected: $BOOTDIR"
        ok "Boot layout: $BOOT_LAYOUT"
    else
        fail "Unable to detect Orange Pi boot directory"
        ((failures++))
    fi

    if [[ "$(kernel_name)" == "5.15.147-sun60iw2-can" ]]; then
        ok "CAN-enabled kernel detected"
    else
        warn "CAN-enabled kernel is not running"
        ((warnings++))
    fi

    if module_loaded gs_usb; then
        ok "gs_usb module is loaded"
    elif module_available gs_usb; then
        warn "gs_usb module is installed but not loaded"
        ((warnings++))
    else
        fail "gs_usb module is missing"
        ((failures++))
    fi

    if ip link show can0 >/dev/null 2>&1; then
        ok "can0 exists"
        local bitrate state
        bitrate="$(can_bitrate)"
        state="$(can_state)"

        if [[ "$bitrate" == "1000000" ]]; then
            ok "CAN bitrate is 1000000"
        elif [[ -z "$bitrate" || "$state" == "STOPPED" ]]; then
            warn "can0 exists but is not configured/running"
            info "Run: sudo orangepi4pro can-install"
            ((warnings++))
        else
            fail "CAN bitrate is ${bitrate:-unknown}"
            ((failures++))
        fi
    else
        warn "can0 is missing"
        info "Connect the USB CAN bridge, then run: sudo orangepi4pro can-install"
        ((warnings++))
    fi

    if systemctl is-enabled --quiet can0-delayed.service 2>/dev/null; then
        ok "Delayed CAN startup is installed"
    else
        warn "Delayed CAN startup is missing"
        ((warnings++))
    fi

    if service_active klipper; then
        ok "Klipper service is active"
    else
        warn "Klipper service is not active"
        ((warnings++))
    fi

    if service_active moonraker; then
        ok "Moonraker service is active"
    else
        warn "Moonraker service is not active"
        ((warnings++))
    fi

    echo
    if (( failures > 0 )); then
        echo "[FAIL] $failures critical failure(s), $warnings warning(s)"
        return 1
    elif (( warnings > 0 )); then
        echo "[WARN] No critical failures; $warnings warning(s)"
    else
        echo "[ OK ] All checks passed"
    fi
}
