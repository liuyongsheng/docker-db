# Database Slim Images

将常用数据库官方镜像瘦身，采用**二阶段构建 + 展平到 scratch**，消除多层开销，减小镜像体积。

支持 **linux/amd64** 和 **linux/arm64** 双架构构建。

## 镜像列表

| 镜像 | 基础镜像 | 瘦身手段 |
|------|----------|----------|
| `liuys36/mysql:8.0-slim` | `mysql:8.0` | 删除 mysqlsh (460MB)、RPM/dnf/debug/locale/多语言 等 |
| `liuys36/mssql:2017-slim` | amd64: `mcr.microsoft.com/mssql/server:2017-latest`<br>arm64: `softwareplant/mssql:clean-2017-mcr-jira-9-arm64` | 删除 Jira 残留 (278MB)、Python/debug/apt 等 |
| `liuys36/postgres:17-slim` | `postgres:17` | 删除 LLVM (120MB)/perl (41MB)/z3 (26MB)/locale 等 |

## 大小对比

| 镜像 | 原大小 | 瘦身后 | 缩减 |
|------|--------|--------|------|
| MySQL 8.0 | 425MB | ~340MB | ↓20% |
| MSSQL 2017 | 2.23GB | ~1.71GB | ↓23% |
| PostgreSQL 17 | 555MB | ~300MB | ↓46% |

## 构建

### 本地构建（当前架构）

```bash
# 全部构建
./build.sh

# 单独构建
docker buildx build --load -t liuys36/postgres:17-slim -f Dockerfile.pg .
```

### 多架构推送（需 registry）

```bash
# 全部构建并推送双架构
./build.sh --push

# 单独推送
docker buildx build --platform linux/amd64,linux/arm64 -t liuys36/postgres:17-slim -f Dockerfile.pg --push .
```

> 多架构构建需要先创建 buildx builder：`docker buildx create --name multi --use`

## 使用

```bash
# PostgreSQL
docker run -d --name postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 liuys36/postgres:17-slim

# MySQL
docker run -d --name mysql -e MYSQL_ROOT_PASSWORD=mysecretpassword -p 3306:3306 liuys36/mysql:8.0-slim

# MSSQL
docker run -d --name mssql -e ACCEPT_EULA=Y -e SA_PASSWORD=MyPass@123 -p 1433:1433 liuys36/mssql:2017-slim
```

## 原理

```dockerfile
FROM postgres:17 AS builder     # Stage 1: 从原始镜像删除冗余
RUN rm -rf /usr/share/doc ...

FROM scratch                    # Stage 2: 展平到 scratch
COPY --from=builder / /
```

- **Stage 1** 删掉 doc/man/locale/cache/perl/LLVM 等运行时不需要的文件
- **Stage 2** 只拷贝文件系统内容，抛弃原始镜像的所有中间层，镜像层数归零
