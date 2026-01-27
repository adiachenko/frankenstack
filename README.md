# Frankenstack

**Laravel**‑focused FrankenPHP Docker image for classic PHP or Octane, batteries included, configurable via env.

## Table of Contents

- [Included Tools](#included-tools)
- [Included PHP Extensions](#included-php-extensions)
- [Version Support](#version-support)
- [Quick Start](#quick-start)
- [Worker Mode (requires Laravel Octane)](#worker-mode-requires-laravel-octane)
- [Classic vs Worker Mode](#classic-vs-worker-mode)
- [Environment Variables](#environment-variables)
  - [Application Settings](#application-settings)
  - [PHP Settings](#php-settings)
  - [SSH Settings](#ssh-settings)
  - [Caddy](#caddy)
- [Private Composer Packages](#private-composer-packages)
  - [Token Authentication](#token-authentication)
    - [GitHub](#github)
    - [GitLab](#gitlab)
  - [SSH Authentication](#ssh-authentication)
    - [macOS / Linux (Agent Forwarding)](#macos--linux-agent-forwarding)
    - [Universal Method (Key Secret)](#universal-method-key-secret)
    - [Self-hosted Git (Custom known_hosts)](#self-hosted-git-custom-known_hosts)
- [Private NPM Packages](#private-npm-packages)
  - [Token Authentication](#token-authentication-1)
    - [GitHub Packages](#github-packages)
    - [GitLab Packages](#gitlab-packages)
  - [SSH Authentication](#ssh-authentication-1)
- [Running CLI Commands](#running-cli-commands)
- [Creating Images](#creating-images)

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

## Quick Start

Create `docker-compose.yml` file in your Laravel project:

```sh
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
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
    image: ghcr.io/adiachenko/frankenstack
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

## Private Composer Packages

### Token Authentication

For **GitHub** and **GitLab**, token-based auth via `COMPOSER_AUTH` is simpler than SSH. Create a Personal Access Token and pass it as an environment variable.

> **Bitbucket** requires OAuth consumer credentials (key + secret) for token auth, making SSH a simpler option (see next article).

#### GitHub

Create a token: GitHub → Settings → Developer settings → Personal access tokens → Generate (classic token, with `repo` scope).

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    volumes:
      - ./:/opt/project
    environment:
      COMPOSER_AUTH: '{"github-oauth":{"github.com":"${GITHUB_TOKEN}"}}'
```

Store token in `.env`:

```
GITHUB_TOKEN=ghp_xxx
```

#### GitLab

Create a token: GitLab → User Settings → Personal access tokens → Generate (with `read_api` and `read_repository` scopes).

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    volumes:
      - ./:/opt/project
    environment:
      COMPOSER_AUTH: '{"gitlab-token":{"gitlab.com":"${GITLAB_TOKEN}"}}'
```

For self-hosted GitLab, replace `gitlab.com` with your instance hostname.

Store token in `.env`:

```
GITLAB_TOKEN=glpat-xxx
```

### SSH Authentication

The image supports downloading private Composer packages via SSH with two modes:

1. **Agent Forwarding** (macOS/Linux) - Forward your host's SSH agent into the container
2. **Key Secret** (All platforms) - Mount an SSH key file as a Docker secret

#### macOS / Linux (Agent Forwarding)

Technically more secure, but limited in OS compatibility:

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    volumes:
      - ./:/opt/project
      - ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK}
    environment:
      SSH_AUTH_SOCK: ${SSH_AUTH_SOCK}
```

#### Universal Method (Key Secret)

If you're on a team with Windows devs, this is your best option:

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
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

#### Self-hosted Git (Custom known_hosts)

Using a self-hosted Git server? Mount a `known_hosts` file as a secret and set `SSH_KNOWN_HOSTS=''` to disable `ssh-keyscan`. The entrypoint will use your mounted `known_hosts` and won't rely on TOFU.

## Private NPM Packages

### Token Authentication

For private npm packages, create a `.npmrc` file in your project root that references an environment variable.

#### GitHub Packages

Create a token: GitHub → Settings → Developer settings → Personal access tokens → Generate (classic token, with `read:packages` scope).

Add `.npmrc` to your project (replace `OWNER` with the GitHub org or username):

```
@OWNER:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}
```

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    volumes:
      - ./:/opt/project
    environment:
      GITHUB_TOKEN: ${GITHUB_TOKEN}
```

#### GitLab Packages

Create a token: GitLab → User Settings → Personal access tokens → Generate (with `read_api` scope).

Add `.npmrc` to your project (replace `OWNER` with your GitLab group or username, and `PROJECT_ID` with your project ID):

```
@OWNER:registry=https://gitlab.com/api/v4/projects/PROJECT_ID/packages/npm/
//gitlab.com/api/v4/projects/PROJECT_ID/packages/npm/:_authToken=${GITLAB_TOKEN}
```

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    volumes:
      - ./:/opt/project
    environment:
      GITLAB_TOKEN: ${GITLAB_TOKEN}
```

For self-hosted GitLab, replace `gitlab.com` with your instance hostname.

### SSH Authentication

NPM supports Git URLs for dependencies. If your `package.json` uses SSH URLs, the same SSH configuration from the Composer section applies—use agent forwarding or key secrets. The main downside of installing an npm package directly from a Git repository is that you effectively lose proper versioning. You must pin to a branch or tag instead of using semver, and installs are no longer based on immutable, registry-hosted tarballs—making builds less reproducible.

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

For development and testing:

```bash
docker build -t frankenstack ./docker
```

For publishing (clean multi-arch artifact for both ARM and x86):

```bash
# Replace `main` with PHP version target (e.g. `8.5`)
git checkout main

# Replace `latest` with PHP version target (e.g. `8.5`)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/adiachenko/frankenstack:latest \
  --push ./docker

# Clear dangling build cache
docker buildx prune -f
```
