---
title: Private Packages
sidebar:
  order: 6
---

## Composer Packages

### Token Authentication

For **GitHub** and **GitLab**, using token-based authentication with `COMPOSER_AUTH` is typically easier than configuring SSH. If your Git hosting provider doesn’t support this method (such as **Bitbucket**), refer to the SSH section below.

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

## NPM Packages

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
