---
title: Symfony Framework
sidebar:
  order: 4
---

Symfony works out of the box in classic mode. For **worker** mode, override default `FRANKENPHP_WORKER`:

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    environment:
      PHP_ENV: development
      FRANKENPHP_MODE: worker
      FRANKENPHP_WORKER: /opt/project/public/index.php
    ports:
      - 8000:80
    volumes:
      - ./:/opt/project
    restart: on-failure
```
