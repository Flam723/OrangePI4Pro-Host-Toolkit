#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(cat "$ROOT/VERSION")"
NAME="OrangePI4Pro-v$VERSION"
DIST="$ROOT/releases"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$DIST" "$TMP/$NAME"
rsync -a --exclude='.git' --exclude='releases/*.tar.gz' --exclude='releases/*.zip' \
    "$ROOT/" "$TMP/$NAME/"

tar -C "$TMP" -czf "$DIST/$NAME.tar.gz" "$NAME"
(
    cd "$TMP"
    zip -qr "$DIST/$NAME.zip" "$NAME"
)
(
    cd "$DIST"
    sha256sum "$NAME.tar.gz" "$NAME.zip" > SHA256SUMS
)

echo "Created:"
echo "  $DIST/$NAME.tar.gz"
echo "  $DIST/$NAME.zip"
echo "  $DIST/SHA256SUMS"
