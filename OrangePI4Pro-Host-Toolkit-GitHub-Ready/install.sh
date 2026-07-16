#!/usr/bin/env bash
set -Eeuo pipefail
[[ $EUID -eq 0 ]] || { echo "Run with sudo: sudo ./install.sh"; exit 1; }
SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST=/opt/orangepi4pro
STAMP="$(date +%Y%m%d-%H%M%S)"
[[ -d "$DEST" ]] && cp -a "$DEST" "/opt/orangepi4pro-backup-before-v3.1.0-$STAMP"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -a "$SRC"/. "$DEST"/
rm -f "$DEST"/*.tar.gz "$DEST"/*.zip
find "$DEST" -type f -name '*.sh' -exec chmod 0755 {} +
chmod 0755 "$DEST/bin/orangepi4pro"
ln -sfn "$DEST/bin/orangepi4pro" /usr/local/bin/orangepi4pro
ln -sfn "$DEST/diagnostics/verify-host.sh" /usr/local/bin/orangepi4pro-verify

echo "OrangePI4Pro Host Toolkit v3.1.0 installed."
echo "Run:"
echo "  orangepi4pro status"
echo "  orangepi4pro doctor"
echo "  orangepi4pro verify"
