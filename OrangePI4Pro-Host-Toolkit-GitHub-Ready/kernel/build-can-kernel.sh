#!/usr/bin/env bash
set -Eeuo pipefail
require_root

detect_boot_layout || { echo "Unable to detect boot directory."; exit 1; }
echo "Detected Orange Pi boot directory: $BOOTDIR"
echo "Detected boot layout: $BOOT_LAYOUT"

EXPECTED_RUNNING="5.15.147-sun60iw2"
NEW_RELEASE="5.15.147-sun60iw2-can"
BRANCH="orange-pi-5.15-sun60iw2"
REPO="https://github.com/orangepi-xunlong/linux-orangepi.git"
REAL_USER="${SUDO_USER:-orangepi}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
BUILD_ROOT="$REAL_HOME/kernel-5.15-build"
SRC="$BUILD_ROOT/linux-orangepi"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$BOOTDIR/orangepi4pro-backups/$STAMP"
LOG="$REAL_HOME/orangepi4pro-kernel-build-$STAMP.log"
TEMP_CONFIG_LINK="/boot/config-$NEW_RELEASE"
exec > >(tee -a "$LOG") 2>&1

cleanup() { [[ -L "$TEMP_CONFIG_LINK" ]] && rm -f "$TEMP_CONFIG_LINK" || true; }
trap cleanup EXIT

CURRENT_KERNEL="$(uname -r)"
[[ "$CURRENT_KERNEL" == "$NEW_RELEASE" ]] && { echo "CAN kernel already running."; exit 0; }
[[ "$CURRENT_KERNEL" == "$EXPECTED_RUNNING" ]] || { echo "Expected $EXPECTED_RUNNING; found $CURRENT_KERNEL"; exit 1; }
[[ -r /proc/config.gz ]] || { echo "/proc/config.gz unavailable"; exit 1; }
ROOTDEV_BEFORE="$(grep '^rootdev=' "$BOOTDIR/orangepiEnv.txt" || true)"
[[ -n "$ROOTDEV_BEFORE" ]] || { echo "rootdev missing"; exit 1; }

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y git build-essential bc bison flex libssl-dev libelf-dev dwarves libncurses-dev device-tree-compiler u-boot-tools initramfs-tools rsync kmod file
install -d -o "$REAL_USER" -g "$REAL_USER" "$BUILD_ROOT"

if [[ -d "$SRC/.git" ]]; then
  sudo -u "$REAL_USER" git -C "$SRC" fetch --depth 1 origin "$BRANCH"
  sudo -u "$REAL_USER" git -C "$SRC" reset --hard "origin/$BRANCH"
  sudo -u "$REAL_USER" git -C "$SRC" clean -fdx
else
  rm -rf "$SRC"
  sudo -u "$REAL_USER" git clone --depth 1 -b "$BRANCH" "$REPO" "$SRC"
fi

cd "$SRC"
zcat /proc/config.gz > .config
chown "$REAL_USER:$REAL_USER" .config
sudo -u "$REAL_USER" scripts/config --enable CAN
sudo -u "$REAL_USER" scripts/config --enable CAN_RAW
sudo -u "$REAL_USER" scripts/config --enable CAN_DEV
sudo -u "$REAL_USER" scripts/config --module CAN_BCM
sudo -u "$REAL_USER" scripts/config --enable CAN_GW
sudo -u "$REAL_USER" scripts/config --module CAN_GS_USB
sudo -u "$REAL_USER" scripts/config --module CAN_VCAN
sudo -u "$REAL_USER" scripts/config --set-str LOCALVERSION "-sun60iw2-can"
sudo -u "$REAL_USER" scripts/config --disable LOCALVERSION_AUTO
: > .scmversion
chown "$REAL_USER:$REAL_USER" .scmversion
sudo -u "$REAL_USER" make ARCH=arm64 olddefconfig >/dev/null
ACTUAL_RELEASE="$(sudo -u "$REAL_USER" make -s ARCH=arm64 kernelrelease)"
[[ "$ACTUAL_RELEASE" == "$NEW_RELEASE" ]] || { echo "Expected $NEW_RELEASE; got $ACTUAL_RELEASE"; exit 1; }

JOBS="$(nproc)"; (( JOBS > 4 )) && JOBS=4
sudo -u "$REAL_USER" bash -o pipefail -c "make ARCH=arm64 -j$JOBS Image modules dtbs 2>&1 | tee '$SRC/build-5.15-can.log'"
test -f arch/arm64/boot/Image
test -f drivers/net/can/usb/gs_usb.ko

make ARCH=arm64 modules_install
depmod -a "$NEW_RELEASE"
mkdir -p "$BACKUP"
cp -a "$BOOTDIR/uImage" "$BACKUP/"
cp -a "$BOOTDIR/uInitrd" "$BACKUP/"
cp -a "$BOOTDIR/orangepiEnv.txt" "$BACKUP/"
cp -a "$BOOTDIR/boot.cmd" "$BACKUP/" 2>/dev/null || true
cp -a "$BOOTDIR/boot.scr" "$BACKUP/" 2>/dev/null || true

cp .config "$BOOTDIR/config-$NEW_RELEASE"
cp arch/arm64/boot/Image "$BOOTDIR/Image-$NEW_RELEASE"
mkimage -A arm -O linux -T kernel -C none -a 0x41000000 -e 0x41000000 -n "Linux $NEW_RELEASE" -d arch/arm64/boot/Image "$BOOTDIR/uImage-$NEW_RELEASE"

[[ "$BOOTDIR" != "/boot" ]] && ln -sfn "$BOOTDIR/config-$NEW_RELEASE" "$TEMP_CONFIG_LINK"
rm -f "$BOOTDIR/initrd.img-$NEW_RELEASE"
/usr/sbin/mkinitramfs -o "$BOOTDIR/initrd.img-$NEW_RELEASE" "$NEW_RELEASE"
mkimage -A arm -O linux -T ramdisk -C gzip -n "uInitrd $NEW_RELEASE" -d "$BOOTDIR/initrd.img-$NEW_RELEASE" "$BOOTDIR/uInitrd-$NEW_RELEASE"
file "$BOOTDIR/uImage-$NEW_RELEASE" | grep -q 'Linux/ARM'
file "$BOOTDIR/uInitrd-$NEW_RELEASE" | grep -q 'Linux/ARM'

[[ ! -L "$BOOTDIR/uImage" ]] && mv "$BOOTDIR/uImage" "$BOOTDIR/uImage.stock-backup"
ln -sfn "uImage-$NEW_RELEASE" "$BOOTDIR/uImage"
ln -sfn "uInitrd-$NEW_RELEASE" "$BOOTDIR/uInitrd"
ROOTDEV_AFTER="$(grep '^rootdev=' "$BOOTDIR/orangepiEnv.txt" || true)"
[[ "$ROOTDEV_AFTER" == "$ROOTDEV_BEFORE" ]] || { cp -a "$BACKUP/orangepiEnv.txt" "$BOOTDIR/orangepiEnv.txt"; echo "rootdev changed; restored"; exit 1; }
sync

echo
echo "=========================================="
echo "OrangePI4Pro CAN Kernel Build Complete"
echo "=========================================="
echo "Kernel:         $NEW_RELEASE"
echo "Boot directory: $BOOTDIR"
echo "Boot layout:    $BOOT_LAYOUT"
echo "Backup:         $BACKUP"
echo "Log:            $LOG"
echo
echo "Next: sudo reboot"
echo "After reboot: uname -r && orangepi4pro doctor"
echo "=========================================="
