# Command Reference

## `orangepi4pro version`
Prints the installed toolkit version.

## `orangepi4pro status`
Shows architecture, kernel, storage layout, IP addresses, Klipper/Moonraker status, CAN module, CAN interface, bitrate, state, and disk usage.

## `orangepi4pro doctor`
Checks supported architecture/board, storage and boot layout, CAN kernel, `gs_usb`, `can0`, delayed service, Klipper, and Moonraker.

## `orangepi4pro verify`
Runs end-to-end checks and queries CAN UUIDs when Klipper and `can0` are available.

## `sudo orangepi4pro kernel-build`
Builds and installs the CAN-enabled kernel.

## `sudo orangepi4pro kernel-rollback`
Restores the newest boot-file backup.

## `sudo orangepi4pro can-install`
Installs the delayed `can0` systemd service at 1 Mbps.

## `sudo orangepi4pro can-reset`
Reloads `gs_usb` and restarts the delayed CAN service.

## `sudo orangepi4pro backup`
Creates a host/toolkit backup.

## `sudo orangepi4pro report`
Creates a diagnostic support report.
