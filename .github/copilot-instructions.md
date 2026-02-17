# Go gRPC Microservices Copilot Instructions

## Architecture Overview
This is a Go-based microservices monorepo with three services: `usersvc`, `paymentsvc`, and `authsvc`. Each service communicates via gRPC and uses separate PostgreSQL databases (`users_db`, `payments_db`, `auth_db`).

- **Shared Libraries**: `libs/platform` contains common utilities like database connections using `pgx/v5`.
- **Generated Code**: gRPC stubs are in `gen/go`, generated from `.proto` files in `protos/`.
- **Deployment**: Kubernetes with k3d for local dev, kustomize for manifests in `deploy/kustomize/`.

## Key Patterns
- **Multi-Module Go**: Use `replace` directives in `go.mod` for local dependencies (e.g., `replace example.com/monorepo/libs/platform => ../../libs/platform`).
- **Proto Structure**: Services defined in `protos/{service}/v1/{service}.proto` with `go_package` pointing to `gen/go`.
- **Service Layout**: Each service in `services/{service}/` with `cmd/{service}/main.go` and Dockerfile.
- **Database**: Single Postgres instance with per-service databases; connect via `DATABASE_URL` env var.

## Development Workflow
- **Local Cluster**: `make k3d-up` creates k3d cluster; `make k3d-down` deletes it.
- **Build & Deploy**: `make build` creates Docker images; `make import` loads into k3d; `make apply` deploys via kustomize; `make restart` rolls out updates.
- **Environment**: Services expect `DATABASE_URL` for Postgres connection.
- **gRPC Ports**: Services listen on `:50051` (update for multi-service local dev).

## Conventions
- **Imports**: Use module paths like `example.com/monorepo/libs/platform/db` for shared code.
- **Error Handling**: Follow Go idioms; services are minimal stubs currently.
- **Naming**: Snake_case in protos (e.g., `user_id`), camelCase in Go responses.
- **Dependencies**: Pin versions in `go.mod`; use `pgx/v5` for Postgres.

## Examples
- **Adding a Service Method**: Define in `protos/{service}/v1/{service}.proto`, regenerate with `protoc`, implement in service `main.go`.
- **Database Query**: Use `libs/platform/db` pool: `pool, err := db.New(ctx, dsn)`.
- **Deployment Update**: Modify `deploy/kustomize/base/` or overlays, then `make apply`.

Focus on gRPC-first design, shared platform libs, and k3d/kustomize for local k8s dev.</content>
<parameter name="filePath">/home/big4tech/Documentos/personal/go-grpc-microservices/.github/copilot-instructions.md