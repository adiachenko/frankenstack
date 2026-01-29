---
title: Introduction
sidebar:
  order: 1
---

Running Laravel on **FrankenPHP** is fast — but the setup can get fiddly.

Frankenstack gives you a single, Laravel-ready Docker image that supports:

- 🧱 **classic** (FPM-style) request-per-boot execution
- ⚡️ **worker** (Laravel Octane) mode for high-throughput apps

Batteries included with sensible defaults, configurable via environment variables.

## Included Tools

- **SQLite 3**: Available for local database testing
- **MySQL 8.4 Client**: For migrations, artisan commands and dumps (supports any MySQL Server ≥ 5.7)
- **PostgreSQL 18 Client**: For migrations, artisan commands and dumps (supports any PostgreSQL Server ≥ 10)
- **SSH Client**: For some SSH-based Git operations (GitHub/GitLab can use tokens via `COMPOSER_AUTH`)
- **Composer 2**: Pre-installed for dependency management
- **Node.js**: Two latest LTS versions (22 and 24) with runtime switching via `NODE_VERSION` env var

## Included PHP Extensions

Extensions (alphabetical):

- `bcmath`, `bz2`, `core`, `ctype`, `curl`, `date`, `dom`, `exif`, `ffi`, `fileinfo`, `filter`, `ftp`, `gd`, `gmp`,
  `hash`, `iconv`, `igbinary`, `imagick`, `intl`, `json`, `ldap`, `libxml`, `lz4`, `mbstring`, `memcached`, `mongodb`,
  `mysqlnd`, `opcache`, `openssl`, `pcntl`, `pcov`, `pcre`, `pdo`, `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`, `phar`,
  `posix`, `random`, `readline`, `redis`, `reflection`, `session`, `simplexml`, `sockets`, `sodium`, `spl`, `sqlite3`,
  `standard`, `tokenizer`, `uv`, `xdebug`, `xml`, `xmlreader`, `xmlwriter`, `zip`, `zlib`

## Version Support

Frankenstack tracks the **two most recent PHP major versions**. Each supported version has a dedicated branch and a corresponding image tag (e.g., `8.4`, `8.5`). As new PHP versions are released, we update these tags in place—so pulling `ghcr.io/adiachenko/frankenstack:8.5` always gets you the latest build for that major version.

When a PHP version reaches end-of-life or falls out of our support window, its tag is frozen and remains available for historical use, but receives no further updates. This keeps the tagging scheme simple while ensuring you can always pin to a specific major version without surprises.
