# Installation

## Prerequisites

- Orange Pi 4 Pro
- Official Debian 12 Bookworm image
- Root filesystem on NVMe for the kernel builder
- Working Ethernet connection during initial setup
- `sudo` access

## Base system preparation

```bash
sudo apt update
sudo apt full-upgrade -y
sudo timedatectl set-timezone America/Chicago
sudo apt install -y git curl wget unzip htop nano vim sudo gdisk \
  ca-certificates gnupg lsb-release jq tree rsync \
  build-essential bc bison flex libssl-dev libelf-dev \
  device-tree-compiler u-boot-tools dkms
```

Configure Wi-Fi as a backup connection if desired, but use Ethernet during installation.

## Toolkit installation

```bash
tar -xzf OrangePI4Pro-v3.1.0.tar.gz
cd OrangePI4Pro-v3.1.0
sudo ./install.sh
```

Verify:

```bash
orangepi4pro version
orangepi4pro status
orangepi4pro doctor
```

## Build the CAN kernel

Only run this while the stock kernel is active:

```bash
uname -r
sudo orangepi4pro kernel-build
```

Expected stock kernel:

```text
5.15.147-sun60iw2
```

When the build completes:

```bash
sudo reboot
```

Verify:

```bash
uname -r
```

Expected:

```text
5.15.147-sun60iw2-can
```

## Configure CAN

Connect and power the USB CAN bridge, then run:

```bash
sudo orangepi4pro can-install
sleep 20
orangepi4pro doctor
orangepi4pro verify
```

The expected CAN configuration is 1,000,000 bit/s and `ERROR-ACTIVE` state.
