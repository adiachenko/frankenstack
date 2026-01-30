---
title: Classic vs Worker Mode
sidebar:
  order: 3
---

In classic mode, PHP boots fresh for each request. This is the traditional PHP execution model.

- Best for: Simple, reliable deployments; applications with potential memory leaks; maximum compatibility with the wider PHP ecosystem.
- Trade-off: Slower performance due to per-request bootstrap

In worker mode, FrankenPHP keeps PHP workers alive between requests, eliminating bootstrap overhead.

- Best for: High-throughput applications, latency-sensitive APIs, workloads that benefit from warm state (e.g. cached config, routes, services), and environments tuned for long-running PHP processes.
- Trade-off: Requires discipline around memory management and request isolation; not all libraries are safe for persistent workers; debugging and reload semantics are more complex.
