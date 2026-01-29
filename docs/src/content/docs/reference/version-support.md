---
title: Version Support
sidebar:
  order: 2
---

Frankenstack tracks the **two most recent PHP major versions**. Each supported version has a dedicated branch and a corresponding image tag (e.g., `8.4`, `8.5`). As new PHP versions are released, we update these tags in place—so pulling `ghcr.io/adiachenko/frankenstack:8.5` always gets you the latest build for that major version.

When a PHP version reaches end-of-life or falls out of our support window, its tag is frozen and remains available for historical use, but receives no further updates. This keeps the tagging scheme simple while ensuring you can always pin to a specific major version without surprises.
