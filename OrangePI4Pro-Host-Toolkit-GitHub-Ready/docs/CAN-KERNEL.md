# CAN Kernel

The builder starts from the running stock Orange Pi kernel configuration and enables:

```text
CONFIG_CAN=y
CONFIG_CAN_RAW=y
CONFIG_CAN_DEV=y
CONFIG_CAN_BCM=m
CONFIG_CAN_GW=y
CONFIG_CAN_GS_USB=m
CONFIG_CAN_VCAN=m
```

The resulting release is:

```text
5.15.147-sun60iw2-can
```

## Build

```bash
sudo orangepi4pro kernel-build
```

The builder:

1. Validates the board, architecture, kernel, root device, and boot directory.
2. Downloads the matching Orange Pi kernel source.
3. Applies CAN options to the running kernel configuration.
4. Builds the kernel, modules, and device trees.
5. Installs modules and creates a matching initramfs.
6. Backs up active boot files.
7. Activates the new `uImage` and `uInitrd` through symlinks.
8. Verifies that `rootdev` did not change.

## Rollback

```bash
sudo orangepi4pro kernel-rollback
sudo reboot
```

Rollback restores the newest timestamped backup under the detected boot directory.
