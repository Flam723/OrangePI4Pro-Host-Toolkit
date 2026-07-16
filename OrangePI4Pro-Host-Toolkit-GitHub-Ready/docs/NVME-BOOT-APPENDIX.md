# Appendix: NVMe Boot Compatibility

A specific NVMe may work reliably under Linux but fail during early SPI/U-Boot boot. The validated workaround is:

- Keep the microSD installed for boot files.
- Place the root filesystem, Klipper stack, applications, logs, and storage on NVMe.
- Use the `/boot/boot` layout supported by this toolkit.

## Symptoms

- Power LED and Ethernet activity, but no DHCP address
- No SSH
- NVMe mounts and passes filesystem checks when booted from microSD
- Another NVMe boots successfully in the same board

## Recommended checks

```bash
findmnt /
findmnt /boot
lsblk -f
cat /boot/boot/orangepiEnv.txt
sudo e2fsck -fn /dev/nvme0n1p1
```

Fully remove power after SPI or NVMe changes before retesting.
