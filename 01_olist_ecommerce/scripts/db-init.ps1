$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

Set-Location $root

docker compose up -d db

do {
    Start-Sleep -Seconds 1
    $ready = docker compose exec -T db pg_isready -U olist -d olist
} until ($LASTEXITCODE -eq 0)

docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -f /workspace/sql/01_create_schema.sql
docker compose exec -T db psql -U olist -d olist -v ON_ERROR_STOP=1 -f /workspace/sql/04_create_views.sql

Write-Host "Database schema and views are ready."
