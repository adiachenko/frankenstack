# Frankenstack

A FrankenPHP-based Docker image that supports both **classic PHP** and **Laravel Octane**, comes with batteries included, and lets you tweak PHP settings via environment variables.

## Included Tools

- **SQLite 3**: Available for local database testing
- **MySQL 8.4 Client**: For migrations, artisan commands and dumps (supports any MySQL Server ≥ 5.7)
- **PostgreSQL 18 Client**: For migrations, artisan commands and dumps (supports any PostgreSQL Server ≥ 10)
- **SSH Client**: Makes installing private Composer packages over SSH easy
- **Composer 2**: Pre-installed for dependency management
- **Node.js**: Two latest LTS versions (22 and 24) with runtime switching via `NODE_VERSION` env var

## Included PHP Extensions

Extensions (alphabetical):

- `bcmath`, `bz2`, `core`, `ctype`, `curl`, `date`, `dom`, `exif`, `ffi`, `fileinfo`, `filter`, `ftp`, `gd`, `gmp`,
  `hash`, `iconv`, `igbinary`, `imagick`, `intl`, `json`, `ldap`, `libxml`, `lz4`, `mbstring`, `memcached`, `mongodb`,
  `mysqlnd`, `opcache`, `openssl`, `pcntl`, `pcov`, `pcre`, `pdo`, `pdo_mysql`, `pdo_pgsql`, `pdo_sqlite`, `phar`,
  `posix`, `random`, `readline`, `redis`, `reflection`, `session`, `simplexml`, `sockets`, `sodium`, `spl`, `sqlite3`,
  `standard`, `tokenizer`, `uv`, `xdebug`, `xml`, `xmlreader`, `xmlwriter`, `zip`, `zlib`

## Quick Start

Create `docker-compose.yml` file in your Laravel project:

```sh
services:
  app:
    image: frankenstack
    environment:
      - PHP_ENV: development
    ports:
      - 8000:80
    volumes:
      - ./:/opt/project
```

By default, frankenstack runs the app server in [classic](https://frankenphp.dev/docs/classic/) mode which is similar to PHP-FPM with Nginx.

## Worker Mode (requires Laravel Octane)

To run the app server in worker mode, set `FRANKENPHP_MODE` environment variable:

```sh
services:
  app:
    image: frankenstack
    environment:
      - PHP_ENV: development
      - FRANKENPHP_MODE: worker
    ports:
      - 8000:80
    volumes:
      - ./:/opt/project
```

## Classic vs Worker Mode

In classic mode, PHP boots fresh for each request. This is the traditional PHP execution model.

- Best for: Simple, reliable deployments; applications with potential memory leaks; maximum compatibility with the wider PHP ecosystem.
- Trade-off: Slower performance due to per-request bootstrap

In worker mode, FrankenPHP keeps PHP workers alive between requests, eliminating bootstrap overhead.

- Best for: High-throughput applications, latency-sensitive APIs, workloads that benefit from warm state (e.g. cached config, routes, services), and environments tuned for long-running PHP processes.
- Trade-off: Requires discipline around memory management and request isolation; not all libraries are safe for persistent workers; debugging and reload semantics are more complex.

## Environment Variables

### Application Settings

| Variable            | Default                                     |
| ------------------- | ------------------------------------------- |
| `FRANKENPHP_MODE`   | `classic` (also supports `worker`)          |
| `FRANKENPHP_WORKER` | `/opt/project/public/frankenphp-worker.php` |
| `REQUEST_TIMEOUT`   | `60` (seconds)                              |
| `NODE_VERSION`      | `24` (also supports `22`)                   |

`REQUEST_TIMEOUT` sets PHP’s `max_execution_time` and Caddy’s `read_body` (+5s) and `write` (+10s) timeouts. The added buffer prevents Caddy from closing connections before PHP can return errors.

### PHP Settings

Set `PHP_ENV` environment variable to `development` to switch to dev-friendly defaults. `PHP_ENV` defaults to `production`.

`PHP_ENV` applies these defaults (unless specific setting is explicitly overridden):

| Environment Defaults (`PHP_ENV`)  | `production`            | `development`                              |
| --------------------------------- | ----------------------- | ------------------------------------------ |
| `PHP_DISPLAY_ERRORS`              | `Off`                   | `On`                                       |
| `PHP_DISPLAY_STARTUP_ERRORS`      | `Off`                   | `On`                                       |
| `PHP_ERROR_REPORTING`             | `E_ALL & ~E_DEPRECATED` | `E_ALL`                                    |
| `PHP_XDEBUG_MODE`                 | `off`                   | `debug,develop`                            |
| `PHP_OPCACHE_VALIDATE_TIMESTAMPS` | `0`                     | `1`                                        |
| `FRANKENPHP_WORKER_WATCH`         | empty                   | `/opt/project/**/*.php,/opt/project/.env*` |

> If `FRANKENPHP_WORKER_WATCH` is set, workers automatically restart when matching files change. Useful for development to avoid having to restart workers manually; leave empty in production to avoid overhead.

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

## SSH for Private Composer Packages

The image supports downloading private Composer packages via SSH with two modes:

1. **Agent Forwarding** (macOS/Linux) - Forward your host's SSH agent into the container
2. **Key Secret** (All platforms) - Mount an SSH key file as a Docker secret

### macOS / Linux (Agent Forwarding)

Technically more secure, but limited in compatibility:

```yaml
services:
  app:
    image: frankenstack
    volumes:
      - ./:/opt/project
      - ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}
    environment:
      SSH_AUTH_SOCK: ${SSH_AUTH_SOCK}
```

### Windows / CI / Universal settings (Key Secret)

If you're on a team with Windows devs, this is your go-to:

```yaml
services:
  app:
    image: frankenstack
    volumes:
      - ./:/opt/project
    secrets:
      - ssh_key

secrets:
  ssh_key:
    file: ~/.ssh/id_ed25519
```

For encrypted keys, add passphrase to `.env` (gitignored):

```yaml
environment:
  SSH_KEY_PASSPHRASE: ${SSH_KEY_PASSPHRASE:-}
```

### Self-hosted Git (Custom known_hosts)

Using a self-hosted Git server? Mount a `known_hosts` file as a secret and set `SSH_KNOWN_HOSTS=''` to disable `ssh-keyscan`. The entrypoint will use your mounted `known_hosts` and won’t rely on TOFU.

## Running CLI Commands

If the server fails to start (e.g., due to a missing vendor directory or PHP error), you can run Composer or Artisan commands directly:

```bash
# Install dependencies
docker compose run --rm app composer install

# Run artisan commands
docker compose run --rm app php artisan migrate

# Open a shell for debugging
docker compose run --rm app bash
```

These commands spin up a temporary container, execute the command, and exit—bypassing the FrankenPHP server entirely.

## Creating Images

> **TODO**: Document multi-platform builds with pushes to GitHub container registry

```bash
docker build -t frankenstack ./docker
```
