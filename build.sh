#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# SHAHEEN-YS — Unified Build Script
#
# Modes:
#   ./build.sh              — Railway deployment build (default)
#   ./build.sh --docker     — Build all Docker images for SHAHEEN-YS
#   ./build.sh --docker --no-cache  — Force clean Docker build
# ============================================================

# ── Parse arguments ──────────────────────────────────────────
MODE="railway"
DOCKER_ARGS=""
for arg in "$@"; do
  case $arg in
    --docker)    MODE="docker" ;;
    --no-cache)  DOCKER_ARGS="--no-cache" ;;
  esac
done

# ============================================================
# DOCKER MODE — Build all SHAHEEN-YS platform images
# ============================================================
if [ "$MODE" = "docker" ]; then
  echo "[build] Building SHAHEEN-YS Docker images..."

  COMPOSE_FILE="$(dirname "$0")/docker-compose.yml"
  if [ ! -f "$COMPOSE_FILE" ]; then
    echo "[build] ERROR: docker-compose.yml not found at $COMPOSE_FILE"
    exit 1
  fi

  # Build all services that have a build context
  docker compose -f "$COMPOSE_FILE" build $DOCKER_ARGS --parallel

  echo "[build] Docker build completed successfully"
  exit 0
fi

# ============================================================
# RAILWAY MODE — Python/Django build (original behaviour)
# ============================================================

# Railway build script for web_service
# Runs during Railway deployment build phase

cd source/web_service

echo "[build] Installing Python dependencies..."
pip install --upgrade pip poetry
poetry config virtualenvs.create false
poetry install --no-root --no-interaction --no-ansi

echo "[build] Verifying Django setup..."
python manage.py check

echo "[build] Build completed successfully"
