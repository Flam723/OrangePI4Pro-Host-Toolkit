# Supported Boot Layouts

The toolkit detects the directory containing `orangepiEnv.txt`, `boot.cmd`, `boot.scr`, `uImage`, and `uInitrd`.

## Layout A: NVMe root with boot files at `/boot`

```text
/
└── boot/
    ├── orangepiEnv.txt
    ├── uImage
    └── uInitrd
```

Toolkit output:

```text
Boot directory: /boot
Boot layout: separate /boot + root
```

## Layout B: microSD boot + NVMe root

The microSD root filesystem is mounted at `/boot`, so its actual boot directory is nested:

```text
/boot/
└── boot/
    ├── orangepiEnv.txt
    ├── uImage
    └── uInitrd
```

Toolkit output:

```text
Boot directory: /boot/boot
Boot layout: microSD boot + separate root
```
