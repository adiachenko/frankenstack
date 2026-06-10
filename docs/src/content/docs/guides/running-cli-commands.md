---
title: Running CLI Commands
sidebar:
  order: 5
---

Normally, you can run CLI commands on a container using the `docker compose exec`:

```bash
# Install dependencies
docker compose exec app composer install

# Run artisan commands
docker compose exec app php artisan migrate

# Open a shell for debugging
docker compose exec app bash
```

However, if the server fails to start (e.g., due to a missing vendor directory or PHP error), you can run Composer or Artisan commands directly:

```bash
# Install dependencies
docker compose run --rm app composer install

# Run artisan commands
docker compose run --rm app php artisan migrate

# Open a shell for debugging
docker compose run --rm app bash
```

These commands spin up a temporary container, execute the command, and exit—bypassing the FrankenPHP server entirely which might be useful when using the container in worker mode.
