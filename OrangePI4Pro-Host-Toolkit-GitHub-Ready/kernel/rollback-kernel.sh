#!/usr/bin/env bash
set -Eeuo pipefail
require_root
detect_boot_layout || { echo "Unable to detect boot directory."; exit 1; }
BACKUP_ROOT="$BOOTDIR/orangepi4pro-backups"
LATEST="$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort | tail -1)"
[[ -n "$LATEST" ]] || { echo "No kernel backups found."; exit 1; }
echo "Restoring from $LATEST"
rm -f "$BOOTDIR/uImage" "$BOOTDIR/uInitrd"
cp -a "$LATEST/uImage" "$BOOTDIR/uImage"
cp -a "$LATEST/uInitrd" "$BOOTDIR/uInitrd"
cp -a "$LATEST/orangepiEnv.txt" "$BOOTDIR/orangepiEnv.txt"
[[ -f "$LATEST/boot.cmd" ]] && cp -a "$LATEST/boot.cmd" "$BOOTDIR/boot.cmd"
[[ -f "$LATEST/boot.scr" ]] && cp -a "$LATEST/boot.scr" "$BOOTDIR/boot.scr"
sync
echo "Rollback complete. Reboot when ready."
