#!/bin/bash
# ============================================================
# SHAHEEN-YS — PostgreSQL init script
# Creates the dedicated `gitea` database inside the shared
# Postgres instance on first container start.
#
# Docker mounts every *.sh / *.sql file from
# /docker-entrypoint-initdb.d/ and runs them in alphabetical
# order as the postgres superuser on first volume init only.
# ============================================================
set -e

GITEA_DB="${GITEA_DB_NAME:-gitea}"

echo "[init] Checking if database '${GITEA_DB}' exists..."

psql -v ON_ERROR_STOP=1 \
     --username "$POSTGRES_USER" \
     --dbname   "$POSTGRES_DB" <<-EOSQL
    -- Create Gitea database only if it does not exist yet
    SELECT 'CREATE DATABASE "${GITEA_DB}"'
    WHERE NOT EXISTS (
        SELECT FROM pg_database WHERE datname = '${GITEA_DB}'
    )\gexec

    -- Grant full access to the application user
    GRANT ALL PRIVILEGES ON DATABASE "${GITEA_DB}" TO "${POSTGRES_USER}";
EOSQL

echo "[init] Database '${GITEA_DB}' ready."
