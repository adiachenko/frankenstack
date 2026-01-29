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
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/adiachenko/frankenstack:latest \
  --push ./docker

# Clear dangling build cache
docker buildx prune -f
```
