# OrangePI4Pro Host Toolkit

[![Release](https://img.shields.io/badge/release-v3.1.0-blue.svg)](./releases/v3.1.0.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Shell Validation](https://img.shields.io/badge/shell-bash-green.svg)](./.github/workflows/shellcheck.yml)

A free, open-source deployment and diagnostics toolkit for an **Orange Pi 4 Pro** used as a **Klipper host with USB-to-CAN bridge support**.

Version **3.1.0** was validated on two physical Orange Pi 4 Pro systems with both supported storage layouts:

- NVMe root with boot files at `/boot`
- microSD boot + NVMe root with boot files at `/boot/boot`

## Features

- Builds and installs the CAN-enabled `5.15.147-sun60iw2-can` kernel
- Detects `/boot` and `/boot/boot` automatically
- Preserves `orangepiEnv.txt` and creates timestamped kernel backups
- Installs delayed `can0` startup at 1,000,000 bit/s
- Tolerates disconnected CAN hardware during startup
- Provides status, doctor, verification, backup, report, and rollback commands
- Detects `gs_usb`, CAN bitrate/state, Klipper, Moonraker, and CAN UUIDs

## Supported platform

- Orange Pi 4 Pro
- Allwinner A733 / `sun60iw2`
- Debian 12 Bookworm official Orange Pi image
- Stock kernel: `5.15.147-sun60iw2`
- CAN kernel: `5.15.147-sun60iw2-can`
- `gs_usb` compatible USB-to-CAN bridge, including Klipper USB-to-CAN bridge firmware

The kernel builder intentionally refuses unsupported boards and unexpected running kernels.

## Quick start

Download the release archive, then run:

```bash
tar -xzf OrangePI4Pro-v3.1.0.tar.gz
cd OrangePI4Pro-v3.1.0
sudo ./install.sh
```

Check the host:

```bash
orangepi4pro status
orangepi4pro doctor
orangepi4pro verify
```

On a stock kernel, build the CAN-enabled kernel:

```bash
sudo orangepi4pro kernel-build
sudo reboot
```

After reboot:

```bash
uname -r
sudo orangepi4pro can-install
orangepi4pro doctor
orangepi4pro verify
```

## Commands

```text
orangepi4pro version
orangepi4pro status
orangepi4pro doctor
orangepi4pro verify
sudo orangepi4pro kernel-build
sudo orangepi4pro kernel-rollback
sudo orangepi4pro can-install
sudo orangepi4pro can-reset
sudo orangepi4pro backup
sudo orangepi4pro report
```

## Documentation

- [Installation](docs/INSTALLATION.md)
- [CAN kernel](docs/CAN-KERNEL.md)
- [Boot layouts](docs/BOOT-LAYOUTS.md)
- [Command reference](docs/COMMANDS.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [NVMe boot appendix](docs/NVME-BOOT-APPENDIX.md)
- [Release notes](releases/v3.1.0.md)

## Safety

The kernel builder modifies boot files. It creates a timestamped backup before activation and verifies that `rootdev` in `orangepiEnv.txt` does not change. Read the installation and rollback documentation before running it.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. Free to use, modify, and redistribute. See [LICENSE](LICENSE).

## Disclaimer

This is an independent community project and is not affiliated with Orange Pi, Klipper, Moonraker, or their maintainers.
