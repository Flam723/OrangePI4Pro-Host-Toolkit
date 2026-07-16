#!/usr/bin/env bash
set -Eeuo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo: sudo ./uninstall.sh"
    exit 1
fi

systemctl disable --now can0-delayed.service 2>/dev/null || true
rm -f /etc/systemd/system/can0-delayed.service
rm -f /usr/local/sbin/can0-delayed-start.sh
rm -f /usr/local/bin/orangepi4pro
rm -rf /opt/orangepi4pro
systemctl daemon-reload

echo "OrangePI4Pro Host Toolkit removed."
echo "Kernel and boot files were not changed. Use kernel rollback before uninstalling if required."
