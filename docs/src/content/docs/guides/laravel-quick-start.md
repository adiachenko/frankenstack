---
title: Laravel Quick Start
sidebar:
  order: 2
---

Create `compose.yml` file in your Laravel project:

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    environment:
      PHP_ENV: development
    ports:
      - 8000:80
    volumes:
      - ./:/opt/project
```

By default, frankenstack runs the app server in [classic](https://frankenphp.dev/docs/classic/) mode which is similar to PHP-FPM with Nginx.

This quick start is intentionally local/development-focused (plain HTTP on port `80` in-container). For production domains, TLS, certificate persistence, renewal, and Cloudflare hardening, see [Production Usage](https://frankenstack.vercel.app/guides/production-usage/).
