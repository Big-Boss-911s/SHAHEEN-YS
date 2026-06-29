#!/usr/bin/env bash
# ============================================================
# SHAHEEN-YS — Health Check Script
#
# Checks that every public-facing endpoint is responding.
# Usage: ./healthcheck.sh [--port <PORT>]
#   --port  Override the HTTP port (default: value from .env or 80)
# ============================================================
set -euo pipefail

# ── Colour helpers ───────────────────────────────────────────
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC}  $*"; }
fail() { echo -e "  ${RED}✗${NC}  $*"; }
info() { echo -e "${CYAN}[SHAHEEN]${NC} $*"; }

# ── Parse args ───────────────────────────────────────────────
PORT="${HTTP_PORT:-80}"
while [[ $# -gt 0 ]]; do
  case $1 in
    --port) PORT="$2"; shift 2 ;;
    *) shift ;;
  esac
done

BASE="http://localhost:${PORT}"
PASS=0; FAIL=0

check() {
  local label="$1" url="$2" max="${3:-5}"
  local attempt=0
  while [ $attempt -lt "$max" ]; do
    if curl -sf --max-time 5 "$url" > /dev/null 2>&1; then
      ok "$label  ($url)"
      PASS=$((PASS+1))
      return 0
    fi
    attempt=$((attempt+1))
    sleep 2
  done
  fail "$label  ($url) — did not respond after $max attempts"
  FAIL=$((FAIL+1))
}

echo ""
info "Running health checks against ${BASE} ..."
echo ""

# ── Nginx healthz ────────────────────────────────────────────
check "Nginx (proxy)"         "${BASE}/healthz"

# ── Django REST API ──────────────────────────────────────────
check "Django API"            "${BASE}/health"  5

# ── OpenVSCode Server ────────────────────────────────────────
check "OpenVSCode Server"     "${BASE}/vscode/"        3

# ── Gitea ────────────────────────────────────────────────────
check "Gitea"                 "${BASE}/gitea/"         3

# ── OpenHands ────────────────────────────────────────────────
check "OpenHands"             "${BASE}/openhands/"     3

# ── Continue AI ──────────────────────────────────────────────
check "Continue AI"           "${BASE}/continue/"      3

# ── Container-level checks via docker compose ────────────────
echo ""
info "Docker container status:"
docker compose -f "$(dirname "$0")/docker-compose.yml" ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true

# ── Summary ──────────────────────────────────────────────────
echo ""
if [ "$FAIL" -eq 0 ]; then
  echo -e "${GREEN}All $PASS checks passed.${NC}"
  exit 0
else
  echo -e "${RED}$FAIL check(s) failed, $PASS passed.${NC}"
  exit 1
fi
