---
title: Laravel Octane
sidebar:
  order: 3
---

To run the app server in worker mode, set `FRANKENPHP_MODE` environment variable:

> Always use a **restart** policy (see below) for automatic recovery in worker mode. Containers may crash on unhandled exceptions otherwise.

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
