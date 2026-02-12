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
    restart: on-failure
```

Gotchas:

- Unhandled exceptions during the boot process (e.g. missing `APP_KEY`, dependencies, etc.) can cause the container to exit when starting the worker.
- Always use a **restart** policy for automatic recovery in worker mode (see example compose.yml above).
- You may need to run commands like `composer install` via **run** instead of **exec** because container will be killed on exception due to missing dependencies. See [Running CLI Commands](https://frankenstack.vercel.app/reference/running-cli-commands/) for more details.
