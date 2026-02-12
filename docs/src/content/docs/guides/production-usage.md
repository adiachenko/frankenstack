---
title: Production Usage
sidebar:
  order: 5
---

Frankenstack defaults to local-friendly HTTP (`SERVER_NAME=:80`) and does not enable production TLS unless you opt in.

Use this guide when you want to run on a real domain with HTTPS.

## Option 1: Let's Encrypt (automatic certificates)

Use this when your domain points to your server and Cloudflare (if enabled) can reach your origin on ports `80` and `443`.

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    environment:
      PHP_ENV: production
      SERVER_NAME: app.example.com
      CADDY_TLS_MODE: auto
      CADDY_ACME_EMAIL: ops@example.com
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./:/opt/project
      - ./storage/frankenstack/caddy/data:/data
      - ./storage/frankenstack/caddy/config:/config
```

Notes:

- `CADDY_TLS_MODE=auto` enables Caddy-managed ACME issuance and renewal.
- Keep `/data` persisted or certificates/accounts will be lost on container recreation.
- Port `80` is still required for common ACME HTTP validation flows.

## Option 2: Cloudflare Origin Certificate (file-based certificates)

Use this when Cloudflare terminates visitor TLS and encrypts traffic to your origin with a Cloudflare Origin CA certificate.

```yaml
services:
  app:
    image: ghcr.io/adiachenko/frankenstack
    environment:
      PHP_ENV: production
      SERVER_NAME: app.example.com
      CADDY_TLS_MODE: file
      CADDY_TLS_CERT_FILE: /certs/origin.crt
      CADDY_TLS_KEY_FILE: /certs/origin.key
    ports:
      - 80:80
      - 443:443
    volumes:
      - ./:/opt/project
      - ./storage/frankenstack/certs:/certs:ro
      - ./storage/frankenstack/caddy/data:/data
      - ./storage/frankenstack/caddy/config:/config
```

Notes:

- In Cloudflare, set SSL/TLS mode to `Full (strict)`.
- Cert/key files are external inputs in this mode. Frankenstack validates they exist and are readable at startup.

## Certificate Storage And Persistence

To avoid multiple root-level folders, keep runtime TLS/Caddy assets under one Laravel-style subtree:

```text
storage/frankenstack/
  caddy/
    data/
    config/
  certs/
```

These files are runtime secrets/state and should not be committed. Add this to your app `.gitignore`:

```text
/storage/frankenstack/
```

- Persist `/data` to keep Caddy certificate state across container restarts/recreates.
- Persist `/config` as recommended for Caddy runtime state.
- For `file` mode, mount certificate files from host storage as read-only.
- A practical Laravel convention is `./storage/frankenstack/...` for all three mounts.

## Renewal Expectations

- `auto` mode: Caddy renews certificates automatically as long as domain validation can reach the origin.
- `file` mode: renewal is external to the container. Rotate files based on your policy, then restart/redeploy the container.

Cloudflare Origin CA supports long validity periods, but you can still rotate more frequently (for example, yearly or every 90 days).

## Restrict Origin To Cloudflare Only

To keep origin access limited to Cloudflare:

1. Set Cloudflare SSL/TLS mode to `Full (strict)`.
2. At firewall/security-group level, allow inbound `80` and `443` only from Cloudflare IP ranges.
3. Deny all other source IPs to `80`/`443`.

References:

- [Cloudflare IP ranges](https://developers.cloudflare.com/fundamentals/concepts/cloudflare-ip-addresses/)
- [Cloudflare Origin CA](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/)

Optional hardening: add [Authenticated Origin Pulls](https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/) on top of IP allowlisting.

## Running Multiple Projects On One Host

If multiple containers on the same host all map host ports `80:80` and `443:443`, only one can start successfully.

Use one of these patterns:

- **Single edge proxy (recommended):** run one public entrypoint on host `80/443` (for example, Caddy/Traefik/Nginx) and route each hostname to app containers on internal/private ports. In this model, TLS is terminated at the edge, so backend app containers should typically use `CADDY_TLS_MODE=off` and should not bind host `80/443`.
- **Cloudflare origin routing:** keep DNS records proxied in Cloudflare and use Origin Rules destination-port overrides to route each hostname to a different origin port on the host. In this model, use Cloudflare SSL mode `Full (strict)` and configure app containers with `CADDY_TLS_MODE=file` (Cloudflare Origin CA cert/key mounted into the container). Ensure your selected visitor-facing port is Cloudflare-proxied and allow Cloudflare source IP ranges to the origin ports you route to.
