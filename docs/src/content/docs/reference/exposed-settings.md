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
| `FRANKENPHP_MAX_REQUESTS` | unset (no limit)                            |
| `REQUEST_TIMEOUT`         | `60` (seconds)                              |
| `NODE_VERSION`            | `24` (also supports `22`)                   |

`REQUEST_TIMEOUT` sets PHP’s `max_execution_time` and Caddy’s `read_body` (+5s) and `write` (+10s) timeouts. The added buffer prevents Caddy from closing connections before PHP can return errors.

### PHP Settings

Set `PHP_ENV` environment variable to `development` to switch to dev-friendly defaults. `PHP_ENV` defaults to `production`.

`PHP_ENV` applies these defaults (unless specific setting is explicitly overridden):

| Environment Defaults (`PHP_ENV`)  | `production`            | `development`   |
| --------------------------------- | ----------------------- | --------------- |
| `PHP_DISPLAY_ERRORS`              | `Off`                   | `On`            |
| `PHP_DISPLAY_STARTUP_ERRORS`      | `Off`                   | `On`            |
| `PHP_ERROR_REPORTING`             | `E_ALL & ~E_DEPRECATED` | `E_ALL`         |
| `PHP_XDEBUG_MODE`                 | `off`                   | `debug,develop` |
| `PHP_OPCACHE_VALIDATE_TIMESTAMPS` | `0`                     | `1`             |
| `FRANKENPHP_WORKER_WATCH`         | empty                   | see below       |

**`FRANKENPHP_WORKER_WATCH`** configures file patterns that trigger worker restarts (one pattern per line).

```yaml
environment:
  # Default development value for FRANKENPHP_WORKER_WATCH
  FRANKENPHP_WORKER_WATCH: |
    /opt/project/**/*.php
    /opt/project/**/*.{yaml,yml}
    /opt/project/.env*
```

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

### SSH Settings

| Variable             | Default                               |
| -------------------- | ------------------------------------- |
| `SSH_KNOWN_HOSTS`    | `github.com,gitlab.com,bitbucket.org` |
| `SSH_KEY_PASSPHRASE` | -                                     |

### Caddy

| Variable      | Default |
| ------------- | ------- |
| `SERVER_NAME` | `:80`   |

> The base FrankenPHP image automatically generates a TLS certificate for localhost and enforces HTTPS. This can cause compatibility issues with some Docker tooling (notably reverse proxies and Orbstack), so our defaults adopt a more conventional setup instead. If you want to restore the original behavior, simply set `SERVER_NAME` to `localhost` and add a port mapping for 443.
