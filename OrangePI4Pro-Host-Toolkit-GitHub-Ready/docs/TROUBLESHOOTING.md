# Troubleshooting

## `can0` is missing

Check whether the USB CAN bridge is connected and powered:

```bash
lsusb
lsmod | grep gs_usb
ip link show
```

A Klipper USB-to-CAN bridge commonly appears as:

```text
1d50:606f OpenMoko, Inc. Geschwister Schneider CAN adapter
```

Reconnect the adapter, then run:

```bash
sudo systemctl restart can0-delayed.service
sleep 20
ip -details link show can0
```

## CAN service completes without hardware

This is expected. The delayed service waits for the adapter and exits cleanly if none is detected. Connect the adapter and restart the service.

## `gs_usb` module is missing

```bash
uname -r
/usr/sbin/modinfo gs_usb
find /lib/modules/$(uname -r) -name 'gs_usb.ko*'
```

The expected kernel is `5.15.147-sun60iw2-can`.

## Kernel build does not complete

Review the newest log:

```bash
ls -1t ~/orangepi4pro-kernel-build-*.log | head -1
```

Do not reboot unless the builder prints the successful completion summary.

## CAN state

`ERROR-ACTIVE` is the normal healthy state. Investigate `ERROR-PASSIVE` or `BUS-OFF`, including wiring, termination, bitrate, ground reference, and node power.
