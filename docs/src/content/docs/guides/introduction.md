---
title: Introduction
description: Laravel-ready FrankenPHP Docker image with classic and worker modes, configurable PHP settings, and bundled tooling for local and production use.
sidebar:
  order: 1
---

Running <span style="color: #FF2D20; font-weight: bold;">Laravel</span> on <a href="https://frankenphp.dev/" target="_blank"><strong>FrankenPHP</strong></a> is fast — but the setup can get fiddly.

Frankenstack gives you a single, Laravel-ready <span style="color: #2496ED; font-weight: bold;">Docker</span> image that supports:

- 🧱 **Classic** mode (FPM-style): requests are handled in isolation, with no memory shared between them
- ⚡️ **Worker** mode (Laravel Octane): keeps the app running between requests for maximum throughput

"Batteries included" with sensible defaults, configurable via environment variables.

:::caution[Docker Experience Required]
Frankenstack is designed to provide a robust PHP image for people familiar with Docker. It does NOT cover Docker Compose basics or the installation and management of services like MySQL, Redis, and others—these are outside the project's scope. If you're new to Docker, start with <a href="https://laravel.com/docs/sail" target="_blank">Laravel Sail</a> first.
:::

## Included Tools

- **SQLite 3**: Available for local database development and testing
- **MySQL 9.7 Client**: For some artisan commands like `db` and `schema:dump` (any MySQL Server ≥ 8.0)
- **PostgreSQL 18 Client**: For some artisan commands like `db` and `schema:dump` (any Postgres ≥ 10)
- **SSH Client**: For some SSH-based Git operations in Composer/NPM (if you can't use tokens)
- **Composer 2**: Pre-installed for PHP dependency management
- **Node.js, NPM, pnpm**: Two latest LTS versions (22 and 24) are included, with runtime switching via the `NODE_VERSION` environment variable.

## Included PHP Extensions

Installed extensions:

- `bcmath`, `bz2`, `core`, `ctype`, `curl`, `date`, `dom`, `exif`, `ffi`, `fileinfo`, `filter`, `ftp`, `gd`, `gmp`,
  `hash`, `iconv`, `igbinary`, `imagick`, `intl`, `json`, `ldap`, `libxml`, `lz4`, `mbstring`, `memcached`, `mongodb`,
  `mysqlnd`, `opcache`, `openssl`, `pcntl`, `pcov`, `pcre`, `pdo`, `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`, `phar`,
  `posix`, `random`, `readline`, `redis`, `reflection`, `session`, `simplexml`, `sockets`, `sodium`, `spl`, `sqlite3`,
  `standard`, `tokenizer`, `uv`, `xdebug`, `xml`, `xmlreader`, `xmlwriter`, `zip`, `zlib`

Some of the extensions are disabled by default, but can be enabled via env (see [Opt-in PHP Extensions](https://frankenstack.vercel.app/reference/exposed-settings/#opt-in-php-extensions)):

- `bz2`, `ffi`, `ftp`, `gd`, `imagick`, `intl`, `ldap`, `memcached`, `mongodb`, `sockets`, `uv`, `xdebug`
