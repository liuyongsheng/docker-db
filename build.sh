#!/usr/bin/env bash
set -euo pipefail

REGISTRY="liuys36"

MYSQL_TAG="$REGISTRY/mysql:8.0-slim"
MSSQL_TAG="$REGISTRY/mssql:2017-slim"
PG_TAG="$REGISTRY/postgres:17-slim"

echo "=== 构建 MySQL 8.0 Slim ==="
docker build -t "$MYSQL_TAG" -f Dockerfile.mysql .

echo ""
echo "=== 构建 MSSQL 2017 Slim ==="
docker build -t "$MSSQL_TAG" -f Dockerfile.mssql .

echo ""
echo "=== 构建 PostgreSQL 17 Slim ==="
docker build -t "$PG_TAG" -f Dockerfile.pg .

echo ""
echo "=== 构建完成 ==="
echo ""
echo "镜像列表:"
docker images "$REGISTRY/mysql" "$REGISTRY/mssql" "$REGISTRY/postgres" --format 'table {{.Repository}}:{{.Tag}}\t{{.Size}}'

echo ""
echo "大小对比:"
echo "  MySQL:  $(docker images mysql:8.0                      --format '{{.Size}}')  →  $(docker images "$MYSQL_TAG" --format '{{.Size}}')"
echo "  MSSQL:  $(docker images softwareplant/mssql:clean-2017-mcr-jira-9-arm64 --format '{{.Size}}')  →  $(docker images "$MSSQL_TAG" --format '{{.Size}}')"
echo "  PG:     $(docker images postgres:17                    --format '{{.Size}}')  →  $(docker images "$PG_TAG" --format '{{.Size}}')"
