---
title: Introduction
sidebar:
  order: 1
---

Running Laravel on **FrankenPHP** is fast — but the setup can get fiddly.

Frankenstack gives you a single, Laravel-ready Docker image that supports:

- 🧱 **Classic** mode (FPM-style): each request is handled in isolation, with no memory shared between requests
- ⚡️ **Worker** mode (Laravel Octane): keeps the app running between requests for maximum throughput

Batteries included with sensible defaults, configurable via environment variables.

## Included Tools

- **SQLite 3**: Available for local database development and testing
- **MySQL 8.4 Client**: For some artisan commands like `db` and `schema:dump` (for MySQL Server ≥ 5.7)
- **PostgreSQL 18 Client**: For some artisan commands like `db` and `schema:dump` (for Postgres ≥ 10)
- **SSH Client**: For some SSH-based Git operations in Composer/NPM (unless you can use tokens)
- **Composer 2**: Pre-installed for dependency management
- **Node.js, NPM**: Two latest LTS versions (22 and 24) are included, with runtime switching via the `NODE_VERSION` environment variable. **Yarn** and **pnpm** are available via Corepack when the selected Node version includes it.

## Included PHP Extensions

Extensions (alphabetical):

- `bcmath`, `bz2`, `core`, `ctype`, `curl`, `date`, `dom`, `exif`, `ffi`, `fileinfo`, `filter`, `ftp`, `gd`, `gmp`,
  `hash`, `iconv`, `igbinary`, `imagick`, `intl`, `json`, `ldap`, `libxml`, `lz4`, `mbstring`, `memcached`, `mongodb`,
  `mysqlnd`, `opcache`, `openssl`, `pcntl`, `pcov`, `pcre`, `pdo`, `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`, `phar`,
  `posix`, `random`, `readline`, `redis`, `reflection`, `session`, `simplexml`, `sockets`, `sodium`, `spl`, `sqlite3`,
  `standard`, `tokenizer`, `uv`, `xdebug`, `xml`, `xmlreader`, `xmlwriter`, `zip`, `zlib`

The following extensions are disabled by default, but can be enabled via environment variables (see [Opt-in PHP Extensions](https://frankenstack.vercel.app/reference/exposed-settings/#opt-in-php-extensions)):

- `bz2`, `ffi`, `ftp`, `gd`, `imagick`, `intl`, `ldap`, `memcached`, `mongodb`, `sockets`, `uv`, `xdebug`
