# Benchmark PHP Extension Memory Overhead

Measure the RSS and VmSize memory overhead of each PHP extension against a clean FrankenPHP base image.

## What to measure

Benchmark all extensions listed in `AGENTS.md` under the "PHP extensions" section:

- **Always-on** extensions (no env var control)
- **Opt-in** extensions (controlled via `PHP_EXT_*`)

Use `dunglas/frankenphp:latest` as the baseline image. Note that opcache is normally built into FrankenPHP and included in the baseline — skip measuring it separately.

## How to measure

For each extension:

1. Start a fresh container from the baseline image
2. Install the extension using `install-php-extensions`
3. Read `/proc/self/status` to extract `VmRSS` and `VmSize`
4. Calculate overhead by subtracting the baseline (image with no extensions added)

Run measurements in parallel where possible to reduce total benchmark time.

## Categorization

Present results sorted by RSS overhead using these thresholds:

| Category | RSS Overhead  |
| -------- | ------------- |
| Minimal  | <500 kB       |
| Light    | 500 kB – 1 MB |
| Medium   | 1–3 MB        |
| Heavy    | >3 MB         |

## Output

Save results to `maintainers/benchmark-extensions.result.md` with:

- Date of measurement
- Baseline RSS/VmSize values
- Per-extension overhead table (include extension type: always-on vs opt-in)
- Summary totals by extension type (approximate and for comparison only; per-extension deltas are not strictly additive due to shared pages)

## Background

- **RSS (Resident Set Size):** Actual physical RAM used — this is the metric to optimize
- **VmSize:** Virtual address space mapped (includes shared libraries not yet paged in) — informational only

## Scope

Results are approximate snapshots intended for default vs opt-in decisions and relative comparisons, not scientific benchmarking.
