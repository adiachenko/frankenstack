---
title: Production Usage
sidebar:
  order: 6
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

> Generate the certificate/key pair (PEM format) in Cloudflare and save both files on the host into `./storage/frankenstack/certs` before starting the container.

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

### Restrict Origin To Cloudflare Only

To keep origin access limited to Cloudflare:

1. Set Cloudflare SSL/TLS mode to `Full (strict)`.
2. At firewall/security-group level, allow inbound `80` and `443` only from Cloudflare IP ranges.
3. Deny all other source IPs to `80`/`443`.

References:

- [Cloudflare IP ranges](https://developers.cloudflare.com/fundamentals/concepts/cloudflare-ip-addresses/)
- [Cloudflare Origin CA](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/)
- [Cloudflare Full (strict) mode](https://developers.cloudflare.com/ssl/origin-configuration/ssl-modes/full-strict/)
- [Cloudflare Origin Rules](https://developers.cloudflare.com/rules/origin-rules/)

Optional hardening: add [Authenticated Origin Pulls](https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/) on top of IP allowlisting.

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

## Running Multiple Projects On One Host

If multiple containers on the same host all map host ports `80:80` and `443:443`, only one can start successfully.

Use one of these patterns:

- **Single edge proxy (recommended):** run one public entrypoint on host `80/443` (for example, Caddy/Traefik/Nginx) and route each hostname to app containers on internal/private ports. In this model, TLS is terminated at the edge, so backend app containers should typically use `CADDY_TLS_MODE=off` and should not bind host `80/443`.
- **Cloudflare origin routing:** keep DNS records proxied in Cloudflare and use Origin Rules destination-port overrides to route each hostname to a different origin port on the host. In this model, use Cloudflare SSL mode `Full (strict)` and configure app containers with `CADDY_TLS_MODE=file` (Cloudflare Origin CA cert/key mounted into the container).

### Cloudflare Origin Rules Recipe (Multiple Projects)

First make sure that both apps are mapped to different ports on the host.

Then in Cloudflare:

1. Ensure both DNS records (`app1.example.com`, `app2.example.com`) are **proxied** (orange cloud).
2. Go to **Rules** -> **Overview** -> **Create rule** -> **Origin Rule**.
3. Create one rule per hostname:
   - Rule name: `app1-origin-port`
   - Expression: `(http.host == "app1.example.com")`
   - Action: override **Destination port** to `8443` (assuming app1 is mapped to port 8443 on the host)
   - Rule name: `app2-origin-port`
   - Expression: `(http.host == "app2.example.com")`
   - Action: override **Destination port** to `9443` (assuming app2 is mapped to port 9443 on the host)
4. Deploy rules and keep hostname-specific rules above any broad catch-all rules.
5. In firewall rules on your origin host, accept inbound traffic on ports 8443/9443 only when the source IP is in Cloudflare’s IP ranges (see https://www.cloudflare.com/ips-v4 and https://www.cloudflare.com/ips-v6); block all other source IPs on those ports. You can also remove rules for allowing inbound traffic on ports 80/443 since they are not needed anymore.

## Bind-Mount Permissions On Native Linux

On native Linux Docker Engine hosts, bind mounts can hit permission issues because processes in the container run as `root` and create root-owned files on the host. Use POSIX ACLs on your project root to keep your deployment user writable access without manual `chown`.

Apply ACL setup before the first `docker compose up -d` (and before any `docker compose run` / `docker compose exec` command that writes into `/opt/project`).

Use your actual host project path and deployment username:

```bash
sudo apt-get update
sudo apt-get install -y acl

# Replace both placeholders with your real values before running the next commands
PROJECT_DIR=/absolute/path/to/your/project
DEPLOY_USER=your-linux-username

# Access ACL for existing files/directories
sudo setfacl -R -m u:${DEPLOY_USER}:rwX "${PROJECT_DIR}"

# Default ACL on directories so newly created files/directories inherit access
sudo find "${PROJECT_DIR}" -type d -exec setfacl -m d:u:${DEPLOY_USER}:rwX {} +
```

Minimal ACL check:

```bash
cd "${PROJECT_DIR}"
docker compose exec app sh -lc 'touch /opt/project/vendor/.acl_probe'
echo "ok" >> vendor/.acl_probe && rm vendor/.acl_probe && echo "ACL check passed"
```

If the last command succeeds without `sudo` or `chown`, ACL is configured correctly for this workflow.
