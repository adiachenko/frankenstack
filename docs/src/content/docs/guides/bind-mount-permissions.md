---
title: Linux Permissions
sidebar:
  order: 8
---

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
