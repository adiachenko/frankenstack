# Frankenstack

[![PHP 8.5](https://img.shields.io/badge/PHP-8.5-777BB4?logo=php&logoColor=white)](https://github.com/adiachenko/frankenstack/pkgs/container/frankenstack/versions?filters%5Bversion_type%5D=tagged)
[![PHP 8.4](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php&logoColor=white)](https://github.com/adiachenko/frankenstack/pkgs/container/frankenstack/versions?filters%5Bversion_type%5D=tagged)
[![GHCR](https://img.shields.io/badge/images-ghcr.io-blue?logo=github)](https://github.com/adiachenko/frankenstack/pkgs/container/frankenstack)
[![Build Image](https://github.com/adiachenko/frankenstack/actions/workflows/build-image.yml/badge.svg)](https://github.com/adiachenko/frankenstack/actions/workflows/build-image.yml)

Running Laravel on **FrankenPHP** is fast — but the setup can get fiddly.

Frankenstack gives you a single, Laravel-ready Docker image that supports:

- 🧱 **Classic** mode (FPM-style): each request is handled in isolation, with no memory shared between requests
- ⚡️ **Worker** mode (Laravel Octane): keeps the app running between requests for maximum throughput

Batteries included with sensible defaults, configurable via environment variables.

## Documentation

See [**frankenstack.vercel.app**](https://frankenstack.vercel.app/)
