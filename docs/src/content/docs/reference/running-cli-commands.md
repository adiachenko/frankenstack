---
title: Running CLI Commands
sidebar:
  order: 3
---

If the server fails to start (e.g., due to a missing vendor directory or PHP error), you can run Composer or Artisan commands directly:

```bash
# Install dependencies
docker compose run --rm app composer install

# Run artisan commands
docker compose run --rm app php artisan migrate

# Open a shell for debugging
docker compose run --rm app bash
```

These commands spin up a temporary container, execute the command, and exit—bypassing the FrankenPHP server entirely.
