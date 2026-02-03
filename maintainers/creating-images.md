## Creating Images

For development and testing:

```bash
docker build -t frankenstack ./docker
```

For publishing (clean multi-arch artifact for both ARM and x86):

```bash
# Replace `main` with PHP version target (e.g. `8.5`)
git checkout main

# Replace `latest` with PHP version target (e.g. `8.5`)
# --pull ensures the correct base image is used for the branch
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --pull \
  -t ghcr.io/adiachenko/frankenstack:latest \
  --push ./docker

# Clear dangling build cache
docker buildx prune -f
```

## GitHub Actions tagging

The `Build Image` workflow publishes tags for the version branches (`8.4`, `8.5`) and also publishes `latest` from the branch defined by `LATEST_PHP_BRANCH` in `.github/workflows/build-image.yml`. When a new PHP major becomes the latest, update that value to the new branch name.
