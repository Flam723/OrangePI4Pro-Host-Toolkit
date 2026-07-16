#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="/opt/orangepi4pro"
# shellcheck source=../lib/common.sh
source "$ROOT/lib/common.sh"

failures=0
warnings=0
check_ok(){ ok "$*"; }
check_warn(){ warn "$*"; warnings=$((warnings+1)); }
check_fail(){ fail "$*"; failures=$((failures+1)); }

echo "OrangePI4Pro End-to-End Verification v$(cat "$ROOT/VERSION")"
echo

if detect_boot_layout; then
    check_ok "Boot directory: $BOOTDIR"
    check_ok "Boot layout: $BOOT_LAYOUT"
else
    check_fail "Boot directory detection failed"
fi

[[ "$(arch_name)" == "aarch64" ]] && check_ok "Architecture is aarch64" || check_fail "Architecture is $(arch_name)"
[[ "$(kernel_name)" == "5.15.147-sun60iw2-can" ]] && check_ok "CAN kernel is running" || check_fail "Kernel is $(kernel_name)"

if module_loaded gs_usb; then
    check_ok "gs_usb is loaded"
elif module_available gs_usb; then
    check_warn "gs_usb is installed but not loaded"
else
    check_fail "gs_usb is missing"
fi

if ip link show can0 >/dev/null 2>&1; then
    check_ok "can0 exists"
    [[ "$(can_bitrate)" == "1000000" ]] && check_ok "CAN bitrate is 1000000" || check_fail "CAN bitrate mismatch"
    state="$(can_state)"
    [[ -n "$state" ]] && check_ok "CAN state: $state" || check_warn "CAN state unavailable"
else
    check_warn "can0 is missing"
fi

service_active klipper && check_ok "Klipper active" || check_warn "Klipper inactive"
service_active moonraker && check_ok "Moonraker active" || check_warn "Moonraker inactive"

HOME_DIR="$(getent passwd "${SUDO_USER:-$USER}" | cut -d: -f6)"
if ip link show can0 >/dev/null 2>&1 \
   && [[ -x "$HOME_DIR/klippy-env/bin/python" ]] \
   && [[ -f "$HOME_DIR/klipper/scripts/canbus_query.py" ]]; then
    out="$("$HOME_DIR/klippy-env/bin/python" "$HOME_DIR/klipper/scripts/canbus_query.py" can0 2>&1 || true)"
    if grep -q 'Found canbus_uuid=' <<<"$out"; then
        check_ok "CAN query succeeded"
        grep 'Found canbus_uuid=' <<<"$out"
    else
        check_warn "No CAN UUID found"
    fi
else
    check_warn "Klipper CAN query unavailable until can0 is running"
fi

echo
if (( failures > 0 )); then
    echo "[FAIL] $failures failure(s), $warnings warning(s)"
    exit 1
elif (( warnings > 0 )); then
    echo "[WARN] Passed with $warnings warning(s)"
else
    echo "[ OK ] End-to-end verification passed"
fi
