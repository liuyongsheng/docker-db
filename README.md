# Database Slim Images

将常用数据库官方镜像瘦身，采用**二阶段构建 + 展平到 scratch**，消除多层开销，减小镜像体积。

## 镜像列表

| 镜像 | 基础镜像 | 瘦身手段 |
|------|----------|----------|
| `liuys36/mysql:8.0-slim` | `mysql:8.0` | 删除 mysqlsh (460MB)、doc/man/locale/yum cache |
| `liuys36/mssql:2017-slim` | `softwareplant/mssql:clean-2017-mcr-jira-9-arm64` | 删除 doc/man/locale/apt cache/log |
| `liuys36/postgres:17-slim` | `postgres:17` | 删除 locale/i18n/perl/doc/apt cache/log |

## 构建

```bash
# 全部构建
./build.sh

# 单独构建
docker build -t liuys36/postgres:17-slim -f Dockerfile.pg .
```

## 使用

```bash
# PostgreSQL
docker run -d \
  --name postgres \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  liuys36/postgres:17-slim

# MySQL
docker run -d \
  --name mysql \
  -e MYSQL_ROOT_PASSWORD=mysecretpassword \
  -p 3306:3306 \
  liuys36/mysql:8.0-slim

# MSSQL
docker run -d \
  --name mssql \
  -e ACCEPT_EULA=Y \
  -e SA_PASSWORD=MyPass@123 \
  -p 1433:1433 \
  liuys36/mssql:2017-slim
```

## 原理

```dockerfile
FROM postgres:17 AS builder     # Stage 1: 从原始镜像删除冗余
RUN rm -rf /usr/share/doc ...

FROM scratch                    # Stage 2: 展平到 scratch
COPY --from=builder / /
```

- **Stage 1** 删掉 doc/man/locale/cache 等运行时不需要的文件
- **Stage 2** 只拷贝文件系统内容，抛弃原始镜像的所有中间层，镜像层数归零
