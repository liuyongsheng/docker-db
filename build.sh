#!/usr/bin/env bash
set -euo pipefail

REGISTRY="liuys36"
PLATFORMS="linux/amd64,linux/arm64"
PUSH=false

for arg in "$@"; do
  case "$arg" in
    --push) PUSH=true ;;
    --help) echo "用法: $0 [--push]" ; exit 0 ;;
  esac
done

MYSQL_TAG="$REGISTRY/mysql:8.0-slim"
MSSQL_TAG="$REGISTRY/mssql:2017-slim"
PG_TAG="$REGISTRY/postgres:17-slim"

build_image() {
  local name="$1" tag="$2" dockerfile="$3"
  echo "=== 构建 $name ==="

  if $PUSH; then
    docker buildx build \
      --platform "$PLATFORMS" \
      -t "$tag" \
      -f "$dockerfile" \
      --push \
      .
  else
    docker buildx build \
      --load \
      -t "$tag" \
      -f "$dockerfile" \
      .
  fi
}

build_image "MySQL 8.0 Slim"   "$MYSQL_TAG" Dockerfile.mysql
build_image "MSSQL 2017 Slim"  "$MSSQL_TAG" Dockerfile.mssql
build_image "PostgreSQL 17 Slim" "$PG_TAG" Dockerfile.pg

if ! $PUSH; then
  echo ""
  echo "=== 构建完成 ==="
  echo ""
  echo "镜像列表:"
  for img in "$REGISTRY/mysql" "$REGISTRY/mssql" "$REGISTRY/postgres"; do
    docker images "$img" --format 'table {{.Repository}}:{{.Tag}}\t{{.Size}}' | awk 'NR==1 && !h{print; h=1} NR>1'
  done
fi
