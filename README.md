# Go gRPC Microservices Monorepo

A production-ready microservices monorepo built with Go, gRPC, and Docker. Three independent services communicate via gRPC, each backed by its own PostgreSQL database, orchestrated with Docker Compose.

## 📋 Overview

This project demonstrates a modern microservices architecture with:
- **Service isolation**: Each service is independently deployable
- **Shared platform library**: Common utilities for database connections and logging
- **gRPC communication**: Type-safe, fast inter-service communication
- **Docker Compose**: Simple orchestration for local development and testing
- **Multi-module Go**: Organized monorepo structure with clear boundaries

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Client Applications                   │
└──────────┬──────────────┬──────────────┬─────────────────┘
           │              │              │
    ┌──────▼─────┐ ┌──────▼─────┐ ┌──────▼─────┐
    │  usersvc   │ │ paymentsvc │ │  authsvc   │
    │ :50051     │ │ :50052     │ │ :50053     │
    └──────┬─────┘ └──────┬─────┘ └──────┬─────┘
           │              │              │
    ┌──────┴──────────────┴──────────────┴──────┐
    │        PostgreSQL (Single Instance)       │
    │  ┌───────────┬─────────────┬──────────┐   │
    │  │ users_db  │ payments_db │ auth_db  │   │
    │  └───────────┴─────────────┴──────────┘   │
    └──────────────────────────────────────────┘
```

## 📦 Services

| Service | Port | Responsibility | Database |
|---------|------|---|---|
| **usersvc** | 50051 | User management and profiles | `users_db` |
| **paymentsvc** | 50052 | Payment processing and transactions | `payments_db` |
| **authsvc** | 50053 | Authentication and token management | `auth_db` |

### Available RPCs

**UserService** (`user.v1.UserService`)
- `GetUser(GetUserRequest) -> GetUserResponse` - Retrieve user by ID

**PaymentService** (`payment.v1.PaymentService`)
- `CreatePayment(CreatePaymentRequest) -> CreatePaymentResponse` - Create a new payment

**AuthService** (`auth.v1.AuthService`)
- `Login(LoginRequest) -> LoginResponse` - User login with email/password

## 🛠️ Tech Stack

- **Language**: Go 1.22
- **RPC Framework**: gRPC with Protocol Buffers
- **Database**: PostgreSQL 16 (pgx/v5)
- **Container**: Docker with multi-stage builds (distroless base)
- **Orchestration**: Docker Compose

## 📁 Project Structure

```
.
├── Makefile                           # Build, deploy, and cluster management
├── README.md                          # This fileservice management
├── docker-compose.yml                 # Docker Compose orchestration
├── README.md                          # This file
├── TODOs.md                           # Project roadmap
├── scripts/
│   └── init.sql                       # Database initialization script
├── protos/                            # Protocol Buffer definitions
│   ├── auth/v1/auth.proto
│   ├── payment/v1/payment.proto
│   └── user/v1/user.proto
├── gen/                               # Generated gRPC code
│   └── go/                            # Go generated stubs
├── libs/                              # Shared platform libraries
│   └── platform/
│       ├── db/                        # PostgreSQL connection utilities
│       └── go.mod
└── services/                          # Microservices
    ├── authsvc/
    │   ├── Dockerfile
    │   ├── go.mod
    │   └── cmd/authsvc/main.go
    ├── paymentsvc/
    │   ├── Dockerfile
    │   ├── go.mod
    │   └── cmd/paymentsvc/main.go
    └── usersvc/
        ├── Dockerfile
        ├── go.mod
        └── cmd/usersvc/main.go

## 🚀 Getting Started

### Prerequisites

- Docker & Docker Daemon running
- Docker Daemon running
- Go 1.22+
- protoc (for regenerating proto files)

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd go-grpc-microservices
   ```

2. **Start all services**
   ```bash
   make up
   ```
   This builds and starts all services (PostgreSQL, usersvc, paymentsvc, authsvc) in Docker containers.

3. **Verify deployment**
   ```bash
   make ps
   ```
   Shows the status of all running services.

4. **View logs**
   ```bash
   make logs
   # Or for a specific service:
   make logs-service SERVICE=usersvc
   ```

### Quick Commands

```bash
# Start services
make up

# Stop services
make down

# Rebuild and restart
make rebuild

# View logs
make logs

# Stop services and remove volumes
make down-volumes

# Clean everything (containers, volumes, images)
make clean
```bash
   # Edit protos/{service}/v1/{service}.proto
   # Regenerate stubs
   protoc -I protos \
     --go_out=gen/go \
     --go-grpc_out=gen/go \
     protos/{service}/v1/{service}.proto
   ```
```

3. **Update dependencies**
   ```bash
   # In services/{service}/
   go get -u example.com/monorepo/libs/platform@latest
   go mod tidy
   ```

4. **Rebuild and redeploy**
   ```bash
   make rebuild
   # Or restart specific service:
   make restart-service SERVICE=usersvcd redeploy**
   ```bash
   make build
   make import
   make restart
   ```

### Environment Variables (configured in [docker-compose.yml](docker-compose.yml)):

- `DATABASE_URL`: PostgreSQL connection string
  - Format: `postgres://user:password@host:5432/database_name?sslmode=disable`
  - Automatically configured for each service

### Database Initialization

PostgreSQL is initialized with three databases via [scripts/init.sql](scripts/init.sql):
- `users_db` - for UserService
- `payments_db` - for PaymentService
- `auth_db` - for AuthService

### Accessing Services

Services are exposed on the following ports:
- **usersvc**: `localhost:50051`
- **paymentsvc**: `localhost:50052`
- **authsvc**: `localhost:50053`
- **PostgreSQL**: `localhost:5432`

### Database Access

Connect to PostgreSQL:
```bash
make db-shell
# Or directly:
docker-compose exec postgres psql -U postgres
```

## Adding a New Service

1. **Create proto definition**
   ```bash
   mkdir -p protos/{newservice}/v1
   # Create protos/{newservice}/v1/{newservice}.proto
   ```

2. **Generate stubs**
   ```bash
   protoc -I protos \
     --go_out=gen/go \
     --go-grpc_out=gen/go \
     protos/{newservice}/v1/{newservice}.proto
   ```

3. **Create service directory**
   ```bash
   mkdir -p services/{newservice}/cmd/{newservice}
   ```

4. **Initialize go.mod**
   ```bash
   cd services/{newservice}
   go mod init example.com/monorepo/services/{newservice}
   # Add platform and gen/go as replacements
   ```

5. **Implement main.go**
   - Reference existing services as templates
   - Create Dockerfile using multi-stage build pattern

6. **Update docker-compose.yml**
   - Add service definition
   - Configure environment variables and ports

## 🧪 Testing

Currently, the project includes minimal test coverage. Recommended additions:
- Unit tests for database operations
- gRPC integration tests
- End-to-end tests with test containers

See [TODOs.md](TODOs.md) for planned testing implementation.

## 📊 Monitoring & Troubleshooting

### Check Service Logs
```bash
make logs
# Or for a specific service:
make logs-service SERVICE=usersvc
```

### Verify gRPC Connectivity
```bash
grpcurl -plaintext localhost:50051 list
grpcurl -plaintext localhost:50051 user.v1.UserService/GetUser
```

### Database Connection
```bash
make db-shell
```

## 🗺️ Roadmap

See [TODOs.md](TODOs.md) for planned features:
- Improve README documentation ✓
- Add Swagger/gRPC gateway support
- Comprehensive test coverage
- Authentication interceptors
- Distributed tracing

## 📚 Key Conventions

- **Naming**: Snake_case in Proto messages (e.g., `user_id`), camelCase in Go responses
- **Go Modules**: Each service and library is a separate module with `replace` directives for local dependencies
- **Port Assignment**: 50051-50053 for services (standard gRPC port range)
- **Error Handling**: Services currently use minimal error handling; add proper error strategies in production

## 💡 Next Steps

- Implement actual service business logic
- Add comprehensive error handling and logging
- Set up CI/CD pipeline
- Add API gateway for external clients
- Implement service-to-service authentication
- Set up distributed tracing (Jaeger/OpenTelemetry)
