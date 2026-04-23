#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"

docker compose up -d db

until docker compose exec -T db pg_isready -U olist -d olist >/dev/null 2>&1; do
  sleep 1
done

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -f /workspace/sql/01_create_schema.sql
docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -f /workspace/sql/04_create_views.sql

echo "Database schema and views are ready."
