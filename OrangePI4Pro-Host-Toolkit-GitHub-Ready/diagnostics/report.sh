#!/usr/bin/env bash
set -Eeuo pipefail
OUT="${1:-$HOME/orangepi4pro-report-$(date +%Y%m%d-%H%M%S).txt}"
{
  echo "OrangePI4Pro report"
  date
  uname -a
  echo
  findmnt /
  findmnt /boot || true
  echo
  lsblk -f
  echo
  ip -br addr
  ip route
  echo
  ip -details link show can0 2>&1 || true
  echo
  systemctl --no-pager --full status klipper moonraker can0-delayed.service 2>&1 || true
} > "$OUT"
echo "$OUT"
