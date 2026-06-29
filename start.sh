#!/usr/bin/env bash
# ============================================================
# SHAHEEN-YS — Start Script
#
# Brings up the entire platform in detached mode.
# Usage: ./start.sh [--build] [--fresh]
#   --build   Force a fresh Docker image build before starting
#   --fresh   Remove all volumes and start with a clean state
#             WARNING: --fresh deletes all database data!
# ============================================================
set -euo pipefail

# ── Colour helpers ───────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info()    { echo -e "${CYAN}[SHAHEEN]${NC} $*"; }
success() { echo -e "${GREEN}[SHAHEEN]${NC} $*"; }
warn()    { echo -e "${YELLOW}[SHAHEEN]${NC} $*"; }
error()   { echo -e "${RED}[SHAHEEN]${NC} $*" >&2; }

COMPOSE_FILE="$(dirname "$0")/docker-compose.yml"
DO_BUILD=false
DO_FRESH=false

# ── Parse arguments ──────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --build) DO_BUILD=true ;;
    --fresh) DO_FRESH=true ;;
    *) error "Unknown argument: $arg"; exit 1 ;;
  esac
done

# ── Pre-flight checks ────────────────────────────────────────
if ! command -v docker &>/dev/null; then
  error "Docker is not installed or not in PATH."
  exit 1
fi

if ! docker compose version &>/dev/null; then
  error "Docker Compose v2 is required (docker compose, not docker-compose)."
  exit 1
fi

# ── Copy .env if missing ─────────────────────────────────────
ENV_FILE="$(dirname "$0")/.env"
if [ ! -f "$ENV_FILE" ]; then
  warn ".env not found — copying from .env.example"
  cp "$(dirname "$0")/.env.example" "$ENV_FILE"
  warn "Please review .env and set SECRET_KEY and passwords before continuing."
fi

# ── Fresh start: remove volumes ──────────────────────────────
if $DO_FRESH; then
  warn "⚠️  --fresh: removing all named volumes (database data will be lost)"
  read -r -p "Are you sure? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    docker compose -f "$COMPOSE_FILE" down -v --remove-orphans
    info "Volumes removed."
  else
    info "Aborted."
    exit 0
  fi
fi

# ── Build images ─────────────────────────────────────────────
if $DO_BUILD || $DO_FRESH; then
  info "Building Docker images..."
  docker compose -f "$COMPOSE_FILE" build --parallel
fi

# ── Launch ───────────────────────────────────────────────────
info "Starting SHAHEEN-YS platform..."
docker compose -f "$COMPOSE_FILE" up -d --remove-orphans

# ── Status ───────────────────────────────────────────────────
echo ""
success "✅  SHAHEEN-YS is running!"
echo ""
echo -e "  ${BOLD}Service URLs${NC}"
echo -e "  Django API   →  http://localhost/"
echo -e "  OpenVSCode   →  http://localhost/vscode/"
echo -e "  Gitea        →  http://localhost/gitea/"
echo -e "  OpenHands    →  http://localhost/openhands/"
echo -e "  Continue AI  →  http://localhost/continue/"
echo ""
echo -e "  Run ${CYAN}docker compose logs -f${NC} to tail all service logs."
echo -e "  Run ${CYAN}./healthcheck.sh${NC}    to verify all services."
