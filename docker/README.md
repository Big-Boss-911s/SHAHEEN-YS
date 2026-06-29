# SHAHEEN-YS — docker/ directory

This directory holds shared Docker utilities for the SHAHEEN-YS platform.

## Contents

| File / Dir | Purpose |
|---|---|
| `healthcheck/` | Shared healthcheck base scripts used across services |

## Adding a custom Dockerfile

Place service-specific Dockerfiles under their own named directory at the
repository root (e.g. `backend/Dockerfile`, `continue/Dockerfile`) rather
than in this directory.

The `docker/` directory is for **shared** Docker tooling only.
