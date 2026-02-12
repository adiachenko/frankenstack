# Frankenstack Documentation

The docs site is built with [Astro](https://docs.astro.build/) from markdown files, using a lightly customized [Starlight](https://starlight.astro.build/) theme, and automatically published to [**frankenstack.vercel.app**](https://frankenstack.vercel.app/) on push to the `main` branch.

## Scope

This project contains user-facing docs published to `frankenstack.vercel.app`.

- Put public documentation in `docs/src/content/docs/` (`guides/`, `concepts/`, `reference/`).
- Put maintainer-only operational material in the repository-level `maintainers/` directory.
- When documenting behavior or defaults, use `docker/` files as the source of truth.

## Prerequisites

- Node.js 22+ (22 or 24 recommended)

## Local Development

From `docs/`:

```bash
npm install
npm run dev
```

Default local URL: `http://localhost:4321`.

Useful commands:

```bash
npm run format   # format docs + config with Prettier
npm run build    # create production build in docs/dist
npm run preview  # serve the production build locally
```

`npm run preview` serves `docs/dist`, so run `npm run build` first. The `docs/dist` directory is generated output and is not committed.

## Content Structure

Primary content lives in `src/content/docs/`:

- `guides/` for introduction and walkthroughs
- `concepts/` for architecture, behavior, and tradeoffs
- `reference/` for settings, useful commands, and version policy

Navigation is configured in `astro.config.mjs` with autogeneration for those three sections.

## Writing Rules For This Repo

- Keep environment-variable docs aligned with `docker/Dockerfile`, `docker/entrypoint.sh`, and `docker/php/*.ini.tpl`.
- When adding/changing settings, update `src/content/docs/reference/exposed-settings.md`.
- Prefer concise, copy-paste-safe examples (`docker run`, `compose.yml`, env vars).

## Change Checklist

Before opening a PR:

1. Run `npm run format` from `docs/`.
2. Manually spot-check changed pages in `npm run dev`.
