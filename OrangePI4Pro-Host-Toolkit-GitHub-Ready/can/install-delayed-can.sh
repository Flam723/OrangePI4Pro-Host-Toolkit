#!/usr/bin/env bash
set -Eeuo pipefail

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/common.sh
source "$TOOLKIT_ROOT/lib/common.sh"

require_root

cat > /usr/local/sbin/can0-delayed-start.sh <<'SCRIPT'
#!/usr/bin/env bash
set -Eeuo pipefail

sleep 15
/usr/sbin/modprobe gs_usb || true

for attempt in $(seq 1 20); do
    if /usr/sbin/ip link show can0 >/dev/null 2>&1; then
        /usr/sbin/ip link set can0 down 2>/dev/null || true
        /usr/sbin/ip link set can0 type can bitrate 1000000 restart-ms 100
        /usr/sbin/ip link set can0 up
        /usr/sbin/ip -details link show can0
        exit 0
    fi
    sleep 2
done

echo "CAN adapter not detected; leaving can0 unconfigured."
exit 0
SCRIPT
chmod 0755 /usr/local/sbin/can0-delayed-start.sh

cat > /etc/systemd/system/can0-delayed.service <<'UNIT'
[Unit]
Description=Delayed CAN0 startup for Orange Pi 4 Pro
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/can0-delayed-start.sh
RemainAfterExit=yes
StandardOutput=append:/var/log/can0-delayed.log
StandardError=append:/var/log/can0-delayed.log

[Install]
WantedBy=multi-user.target
UNIT

systemctl daemon-reload
systemctl enable can0-delayed.service
systemctl reset-failed can0-delayed.service 2>/dev/null || true
systemctl restart can0-delayed.service

echo "Delayed CAN startup installed at 1000000 bit/s."
echo "The service waits up to 40 seconds for a USB CAN adapter."
