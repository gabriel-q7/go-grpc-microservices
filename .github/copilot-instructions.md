# Go gRPC Microservices Copilot Instructions

## Architecture Overview
This is a Go-based microservices monorepo with three services: `usersvc`, `paymentsvc`, and `authsvc`. Each service communicates via gRPC and uses separate PostgreSQL databases (`users_db`, `payments_db`, `auth_db`).

- **Shared Libraries**: `libs/platform` contains common utilities like database connections using `pgx/v5`.
- **Generated Code**: gRPC stubs are in `gen/go`, generated from `.proto` files in `protos/`.
- **Deployment**: Docker Compose for local development and orchestration.

## Key Patterns
- **Multi-Module Go**: Use `replace` directives in `go.mod` for local dependencies (e.g., `replace example.com/monorepo/libs/platform => ../../libs/platform`).
- **Proto Structure**: Services defined in `protos/{service}/v1/{service}.proto` with `go_package` pointing to `gen/go`.
- **Service Layout**: Each service in `services/{service}/` with `cmd/{service}/main.go` and Dockerfile.
- **Database**: Single Postgres instance with per-service databases; connect via `DATABASE_URL` env var.

## Development Workflow
- **Start Services**: `make up` starts all services with Docker Compose; `make down` stops them.
- **Build & Deploy**: `make build` builds Docker images; `make rebuild` rebuilds and restarts all services.
- **Logs**: `make logs` shows all service logs; `make logs-service SERVICE=usersvc` shows specific service logs.
- **Restart**: `make restart` restarts all services; `make restart-service SERVICE=usersvc` restarts a specific service.
- **Environment**: Services expect `DATABASE_URL` for Postgres connection, configured in `compose.yml`.
- **gRPC Ports**: Services exposed on `localhost:50051` (usersvc), `localhost:50052` (paymentsvc), `localhost:50053` (authsvc).

## Conventions
- **Imports**: Use module paths like `example.com/monorepo/libs/platform/db` for shared code.
- **Error Handling**: Follow Go idioms; services are minimal stubs currently.
- **Naming**: Snake_case in protos (e.g., `user_id`), camelCase in Go responses.
- **Dependencies**: Pin versions in `go.mod`; use `pgx/v5` for Postgres.

## Examples
- **Adding a Service Method**: Define in `protos/{service}/v1/{service}.proto`, regenerate with `protoc`, implement in service `main.go`.
- **Database Query**: Use `libs/platform/db` pool: `pool, err := db.New(ctx, dsn)`.
- **Service Update**: Modify service code, then run `make rebuild` or `make restart-service SERVICE={service}`.

Focus on gRPC-first design, shared platform libs, and Docker Compose for local development.</content>
<parameter name="filePath">/home/big4tech/Documentos/personal/go-grpc-microservices/.github/copilot-instructions.md