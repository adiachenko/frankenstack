---
title: Laravel Octane
sidebar:
  order: 3
---

To run the app server in worker mode, set `FRANKENPHP_MODE` environment variable:

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    environment:
      PHP_ENV: development
      FRANKENPHP_MODE: worker
    ports:
      - 8000:80
    volumes:
      - ./:/opt/project
    restart: unless-stopped
```

Gotchas:

- Unhandled exceptions during the boot process (e.g. missing `APP_KEY`, dependencies, etc.) can cause the container to exit when starting the worker.
- Always use a **restart** policy for automatic recovery in worker mode (see example compose.yml above).
- You may need to run commands like `composer install` via **run** instead of **exec** because container will be killed on exception due to missing dependencies. See [Running CLI Commands](https://frankenstack.vercel.app/reference/running-cli-commands/) for more details.

When `FRANKENPHP_MODE=worker` is set, Octane is launched and managed natively by the container at startup. The runtime lifecycle is controlled using Docker commands instead of artisan `octane` commands:

- Start: container start is the native equivalent of `octane:start`.
- Reload: use `docker compose restart app` (or rely on `FRANKENPHP_WORKER_WATCH` in development).
- Status: use `docker compose ps` (or `docker ps`).
- Stop: use `docker compose stop app` (or `docker stop`).

`octane:start` options exposed by the image:

- `--workers` -> `FRANKENPHP_WORKERS`
- `--max-requests` -> `FRANKENPHP_MAX_REQUESTS`
- `--watch` -> `FRANKENPHP_WORKER_WATCH`
- `--host` / `--port` -> Docker networking (`ports`) and `SERVER_NAME`

See more details in [Exposed Settings](https://frankenstack.vercel.app/reference/exposed-settings/).
