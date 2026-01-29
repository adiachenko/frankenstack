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
