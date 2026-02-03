# PHP Extension Memory Overhead Benchmarks

Measured on `dunglas/frankenphp:latest` (2026-02-02).

**Baseline (raw image):** RSS: 24,360 kB | VmSize: 60,268 kB

## Results by Category

### Minimal (<500 kB RSS)

| Extension | Type      | RSS Overhead | VmSize Overhead |
| --------- | --------- | ------------ | --------------- |
| opcache   | always-on | ~0 kB        | ~0 kB           |
| pcntl     | always-on | +28 kB       | +172 kB         |
| exif      | always-on | +32 kB       | +204 kB         |
| igbinary  | always-on | +32 kB       | +200 kB         |
| bcmath    | always-on | +36 kB       | +148 kB         |
| pcov      | always-on | +60 kB       | +140 kB         |
| bz2       | opt-in    | +68 kB       | +276 kB         |
| pdo_mysql | always-on | +92 kB       | +176 kB         |
| lz4       | always-on | +96 kB       | +532 kB         |
| ldap      | opt-in    | +136 kB      | +268 kB         |
| ftp       | opt-in    | +148 kB      | +152 kB         |
| pdo_pgsql | always-on | +172 kB      | +628 kB         |
| gmp       | always-on | +192 kB      | +156 kB         |
| ffi       | opt-in    | +232 kB      | +328 kB         |
| sockets   | opt-in    | +316 kB      | +504 kB         |
| zip       | always-on | +388 kB      | +660 kB         |

### Light (500 kB – 1 MB RSS)

| Extension | Type      | RSS Overhead | VmSize Overhead |
| --------- | --------- | ------------ | --------------- |
| xdebug    | opt-in    | +608 kB      | +656 kB         |
| uv        | opt-in    | +728 kB      | +1,128 kB       |
| redis     | always-on | +916 kB      | +1,404 kB       |

### Medium (1–3 MB RSS)

| Extension | Type   | RSS Overhead | VmSize Overhead |
| --------- | ------ | ------------ | --------------- |
| memcached | opt-in | +1,864 kB    | +3,436 kB       |

### Heavy (>3 MB RSS)

| Extension | Type   | RSS Overhead | VmSize Overhead |
| --------- | ------ | ------------ | --------------- |
| gd        | opt-in | +4,548 kB    | +26,676 kB      |
| intl      | opt-in | +4,592 kB    | +41,492 kB      |
| imagick   | opt-in | +5,032 kB    | +13,904 kB      |
| mongodb   | opt-in | +5,084 kB    | +8,140 kB       |

## Summary

| Type                 | Total RSS Overhead | Extension Count |
| -------------------- | ------------------ | --------------- |
| Always-on            | ~2.1 MB            | 12              |
| Opt-in (all enabled) | ~23.3 MB           | 12              |

## Key Findings

1. **Always-on extensions are well-chosen** — all 12 combined add only ~2.1 MB RSS
2. **redis is the heaviest always-on** at ~916 kB, but essential for Laravel queues/caching
3. **The "heavy four"** (gd, intl, imagick, mongodb) account for ~19.3 MB combined
4. **intl has the largest VmSize** (~41 MB) due to ICU libraries, but only ~4.5 MB RSS until used

## Methodology

See [benchmark-extensions.prompt.md](./benchmark-extensions.prompt.md) for the benchmark procedure.
