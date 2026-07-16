# Contributing

Contributions are welcome.

## Before opening a pull request

1. Open an issue for substantial behavioral changes.
2. Keep Bash scripts compatible with Debian Bookworm.
3. Use `set -Eeuo pipefail` for executable scripts.
4. Use full paths for administrative commands when normal user PATH may omit `/sbin` or `/usr/sbin`.
5. Do not hard-code `/boot`; use shared boot-directory detection.
6. Run:

```bash
make check
```

7. Document hardware and boot layout used for testing.

## Commit style

Use short imperative subjects, for example:

```text
Fix delayed CAN startup without adapter
Add microSD boot layout detection
```
