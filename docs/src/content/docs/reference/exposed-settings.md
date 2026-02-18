---
title: Exposed Settings
sidebar:
  order: 1
---

### Application Settings

| Variable                  | Default                                     |
| ------------------------- | ------------------------------------------- |
| `FRANKENPHP_MODE`         | `classic` (also supports `worker`)          |
| `FRANKENPHP_WORKER`       | `/opt/project/public/frankenphp-worker.php` |
| `FRANKENPHP_WORKERS`      | unset (defaults to `2 x CPU cores`)         |
| `FRANKENPHP_MAX_REQUESTS` | unset (no limit)                            |
| `FRANKENPHP_WORKER_WATCH` | empty (`PHP_ENV=development` sets defaults) |
| `REQUEST_TIMEOUT`         | `60` (seconds)                              |
| `NODE_VERSION`            | `24` (also supports `22`)                   |

`REQUEST_TIMEOUT` sets PHP’s `max_execution_time` and Caddy’s `read_body` (+5s) and `write` (+10s) timeouts. The added buffer prevents Caddy from closing connections before PHP can return errors.

**`FRANKENPHP_WORKER_WATCH`** configures file patterns that trigger worker restarts (one pattern per line).

```yaml
environment:
  # Default development value for FRANKENPHP_WORKER_WATCH
  FRANKENPHP_WORKER_WATCH: |
    /opt/project/**/*.php
    /opt/project/**/*.{yaml,yml}
    /opt/project/.env*
```

### PHP Settings

Set `PHP_ENV` environment variable to `development` to switch to dev-friendly defaults. `PHP_ENV` defaults to `production`.

`PHP_ENV` applies these defaults (unless specific setting is explicitly overridden):

| Environment Defaults (`PHP_ENV`)  | `production`            | `development`   |
| --------------------------------- | ----------------------- | --------------- |
| `PHP_DISPLAY_ERRORS`              | `off`                   | `on`            |
| `PHP_DISPLAY_STARTUP_ERRORS`      | `off`                   | `on`            |
| `PHP_ERROR_REPORTING`             | `E_ALL & ~E_DEPRECATED` | `E_ALL`         |
| `PHP_XDEBUG_MODE`                 | `off`                   | `debug,develop` |
| `PHP_OPCACHE_VALIDATE_TIMESTAMPS` | `0`                     | `1`             |

**Xdebug** is available automatically in "classic" mode and with trigger in "worker" mode in `development` environment.

Other PHP settings:

| Variable                              | Default                            |
| ------------------------------------- | ---------------------------------- |
| `PHP_MEMORY_LIMIT`                    | `256M`                             |
| `PHP_POST_MAX_SIZE`                   | `8M`                               |
| `PHP_UPLOAD_MAX_SIZE`                 | `2M`                               |
| `PHP_OPCACHE_MEMORY_CONSUMPTION`      | `256`                              |
| `PHP_OPCACHE_MAX_ACCELERATED_FILES`   | `20000`                            |
| `PHP_OPCACHE_INTERNED_STRINGS_BUFFER` | `16`                               |
| `PHP_XDEBUG_START_WITH_REQUEST`       | classic: `yes` / worker: `trigger` |
| `PHP_XDEBUG_START_UPON_ERROR`         | classic: `yes` / worker: `default` |
| `PHP_XDEBUG_CLIENT_HOST`              | `host.docker.internal`             |
| `PHP_XDEBUG_CLIENT_PORT`              | `9003`                             |

> Xdebug defaults are different in `worker` mode because it can cause workers to hang during boot unless explicitly triggered. For Herd-like "always on" debugging, use classic mode.

### Opt-in PHP Extensions

Some heavy or specialized PHP extensions are disabled by default to reduce memory footprint. To enable an opt-in extension, set its environment variable to `on` (for example, `PHP_EXT_INTL=on` enables the intl extension).

> `PHP_EXT_ALL=on` enables all opt-in extensions. Individial overrides below can disable specific extensions even if `PHP_EXT_ALL=on`.

| Variable            | Default |
| ------------------- | ------- |
| `PHP_EXT_BZ2`       | off     |
| `PHP_EXT_FFI`       | off     |
| `PHP_EXT_FTP`       | off     |
| `PHP_EXT_GD`        | off     |
| `PHP_EXT_IMAGICK`   | off     |
| `PHP_EXT_INTL`      | off     |
| `PHP_EXT_LDAP`      | off     |
| `PHP_EXT_MEMCACHED` | off     |
| `PHP_EXT_MONGODB`   | off     |
| `PHP_EXT_SOCKETS`   | off     |
| `PHP_EXT_UV`        | off     |
| `PHP_EXT_XDEBUG`    | off     |

Boolean values accept multiple formats (case-insensitive): `1`, `on`, `true`, `yes` to enable; `0`, `off`, `false`, `no` to disable. This matches PHP's native ini parsing behavior.

### SSH Settings

| Variable             | Default                               |
| -------------------- | ------------------------------------- |
| `SSH_KNOWN_HOSTS`    | `github.com,gitlab.com,bitbucket.org` |
| `SSH_KEY_PASSPHRASE` | -                                     |

### Caddy

The base FrankenPHP image can generate local HTTPS certificates automatically, but **frankenstack** defaults to conventional HTTP on `:80` for better compatibility with common Docker tooling and reverse-proxy setups.

Use these variables to configure hostnames and opt into TLS behavior:

| Variable              | Default |
| --------------------- | ------- |
| `SERVER_NAME`         | `:80`   |
| `CADDY_TLS_MODE`      | `off`   |
| `CADDY_TLS_CERT_FILE` | -       |
| `CADDY_TLS_KEY_FILE`  | -       |
| `CADDY_ACME_EMAIL`    | -       |

Start with `SERVER_NAME`:

- Keep `:80` for local/development HTTP.
- Set your real hostname (for example `app.example.com`) for production domains.

Then choose `CADDY_TLS_MODE`:

- `off`: HTTP-only mode. This also disables Caddy automatic HTTPS.
- `auto`: Caddy-managed certificates (typically ACME/Let's Encrypt). Set `SERVER_NAME` to your domain, publish `80` and `443`, and optionally set `CADDY_ACME_EMAIL`.
- `file`: use certificate and key files from `CADDY_TLS_CERT_FILE` and `CADDY_TLS_KEY_FILE`. Both files are required and must be readable.

For more details on production custom-domain setups (Let's Encrypt, Cloudflare Origin CA, and Cloudflare-only origin hardening), see [Production Usage](https://frankenstack.vercel.app/guides/production-usage/).
