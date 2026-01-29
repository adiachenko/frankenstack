# AI Guide for Frankenstack

Minimal Docker image built on `dunglas/frankenphp:1.11.1-php8.5.2-trixie` for running Laravel apps mounted at `/opt/project`.

**Features:**

- Classic PHP request model (default) or Laravel Octane worker mode (opt-in)
- Experimental Symfony support (classic and worker modes)
- Runtime-configurable PHP, OPcache, and Xdebug settings via environment variables
- Unified `REQUEST_TIMEOUT` controlling both PHP execution time and Caddy timeouts
- `PHP_ENV` mode (`production`/`development`) with sensible defaults for each

**Bundled tools:** Composer 2, Git, SQLite 3, MySQL 8.4 client, PostgreSQL 18 client, Node.js 22/24 LTS (runtime-switchable)

## Repo Map

- `docker/Dockerfile` – image build, installs dependencies, copies templates, sets default env vars
- `docker/entrypoint.sh` – runtime wiring (timeout calculation, template expansion, worker mode, SSH setup)
- `docker/caddy/Caddyfile` – Caddy/FrankenPHP configuration with env-driven knobs
- `docker/php/*.ini.tpl` – PHP ini templates expanded at runtime via `envsubst`

## Build And Run

- Build: `docker build -t frankenstack ./docker`
- Run (classic): `docker run --rm -p 8080:80 -v ./:/opt/project frankenstack`
- Run (worker): `docker run --rm -p 8080:80 -v ./:/opt/project -e FRANKENPHP_MODE=worker frankenstack`

## Runtime Behavior

**Template expansion:** On container start, `entrypoint.sh` runs `envsubst` over `$PHP_INI_DIR/conf.d/*.tpl`, writes the corresponding `.ini`, and deletes the `.tpl` files. New templates must be copied into the image at build time.

**Timeout consolidation:** `REQUEST_TIMEOUT` (default `60`) drives:

- `PHP_MAX_EXECUTION_TIME` (equals `REQUEST_TIMEOUT`)
- `CADDY_READ_TIMEOUT` (+5s) and `CADDY_WRITE_TIMEOUT` (+10s)
- Note: PHP CLI ignores `max_execution_time`; this design constrains web requests without breaking long-running CLI commands.

**Worker mode:** When `FRANKENPHP_MODE=worker` and `FRANKENPHP_WORKER` exists, the entrypoint configures FrankenPHP to run in worker mode. If the worker script is missing, it falls back to classic mode with a warning. File watching (`FRANKENPHP_WORKER_WATCH`) uses multiline patterns (one per line, with `#` comments); enabled by default in development mode.

## Making Changes

### PHP settings

- Add/update `docker/php/*.ini.tpl` files rather than modifying `php.ini`
- New env-configurable settings need: template entry, default in `Dockerfile` `ENV`, and (if computed) export in `entrypoint.sh` before `process_php_conf_templates`
- Keep timeouts consolidated behind `REQUEST_TIMEOUT`

### Version updates

- **Node.js:** Update `NODE_22_VERSION`/`NODE_24_VERSION` build args in `Dockerfile`. When a new LTS releases, replace the oldest version (build args, installation block, symlinks, entrypoint validation, docs).
- **MySQL:** Update `MYSQL_VERSION` build arg. Uses generic glibc2.28 binaries (amd64/arm64).
- **PostgreSQL:** Update package name in `Dockerfile` (e.g., `postgresql-client-18` → `postgresql-client-19`). Uses PGDG apt repo (amd64/arm64).

### Xdebug

- Runtime overrides via `XDEBUG_MODE` and `XDEBUG_TRIGGER` env vars bypass templated ini values—essential for CLI debugging when container started with `mode=off`
- CLI debugging examples:
  - Running container: `docker compose exec -e XDEBUG_MODE=debug -e XDEBUG_TRIGGER=1 app php artisan ...`
  - Fresh container: `docker compose run --rm -e PHP_XDEBUG_MODE=debug -e XDEBUG_TRIGGER=1 app php artisan ...`
- **Worker mode:** `PHP_XDEBUG_START_WITH_REQUEST=yes` hangs workers (Xdebug blocks waiting for IDE). Always use `trigger` mode with workers. For "always on" debugging, use classic mode.

### SSH

- Opt-in: requires `SSH_AUTH_SOCK` socket or `/run/secrets/ssh_key`
- Agent forwarding: macOS/Linux only; Windows must use key secret mode
- Production: mount `ssh_known_hosts` secret instead of relying on ssh-keyscan (TOFU)

## Quick Verification

```bash
# Node.js
docker run --rm frankenstack node --version
docker run --rm -e NODE_VERSION=22 frankenstack node --version

# Database clients
docker run --rm frankenstack mysql --version
docker run --rm frankenstack psql --version

# PHP settings (production vs development)
docker run --rm frankenstack php -r "var_dump(ini_get('display_errors'), ini_get('xdebug.mode'));"
docker run --rm -e PHP_ENV=development frankenstack php -r "var_dump(ini_get('display_errors'), ini_get('xdebug.mode'));"

# Xdebug override at runtime
docker run --rm -e XDEBUG_MODE=debug frankenstack php -r "var_dump(ini_get('xdebug.mode'));"

# SSH (agent forwarding - macOS/Linux)
docker run --rm -v $SSH_AUTH_SOCK:$SSH_AUTH_SOCK -e SSH_AUTH_SOCK=$SSH_AUTH_SOCK frankenstack ssh -T git@github.com

# SSH (key secret)
docker run --rm -v ~/.ssh/id_ed25519:/run/secrets/ssh_key:ro frankenstack ssh -T git@github.com

# Worker watch patterns
docker run --rm -e $'FRANKENPHP_WORKER_WATCH=/opt/project/**/*.php\n/opt/project/.env*' frankenstack bash -c 'echo "$FRANKENPHP_WORKER_WATCH" | cat -A'
```

## Documentation

User-facing documentation lives in `docs/src/content/docs/`:

- **Guides:** Getting started, Laravel Octane, Symfony, private packages (Composer/NPM auth)
- **Reference:** Exposed settings, classic vs worker mode, CLI commands, version support

When modifying environment variables or adding new settings, consult the exposed settings reference:

@docs/src/content/docs/reference/exposed-settings.md

---

@AGENTS.local.md
