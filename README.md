# Go gRPC Microservices Monorepo

A production-ready microservices monorepo built with Go, gRPC, and Kubernetes. Three independent services communicate via gRPC, each backed by its own PostgreSQL database, deployed on a k3d local cluster using kustomize for infrastructure as code.

## 📋 Overview

This project demonstrates a modern microservices architecture with:
- **Service isolation**: Each service is independently deployable
- **Shared platform library**: Common utilities for database connections and logging
- **gRPC communication**: Type-safe, fast inter-service communication
- **Infrastructure as Code**: Kubernetes manifests with kustomize for environment-based customization
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
- **Database**: PostgreSQL 15+ (pgx/v5)
- **Container**: Docker with multi-stage builds (distroless base)
- **Orchestration**: Kubernetes (k3d for local development)
- **Infrastructure**: Kustomize for manifests management

## 📁 Project Structure

```
.
├── Makefile                           # Build, deploy, and cluster management
├── README.md                          # This file
├── TODOs.md                           # Project roadmap
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
├── services/                          # Microservices
│   ├── authsvc/
│   │   ├── Dockerfile
│   │   ├── go.mod
│   │   └── cmd/authsvc/main.go
│   ├── paymentsvc/
│   │   ├── Dockerfile
│   │   ├── go.mod
│   │   └── cmd/paymentsvc/main.go
│   └── usersvc/
│       ├── Dockerfile
│       ├── go.mod
│       └── cmd/usersvc/main.go
└── deploy/                            # Kubernetes manifests
    └── kustomize/
        ├── base/                      # Base configuration
        │   ├── namespace.yaml
        │   ├── postgres.yaml
        │   └── kustomization.yaml
        └── overlays/
            └── dev/                   # Development environment
                └── kustomization.yaml
```

## 🚀 Getting Started

### Prerequisites

- Docker & Docker Daemon running
- k3d (v5.0+)
- kubectl
- Go 1.22+
- protoc (for regenerating proto files)

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd go-grpc-microservices
   ```

2. **Create k3d cluster**
   ```bash
   make k3d-up
   ```
   This creates a local Kubernetes cluster named `dev` with one server node and disabled traefik/servicelb.

3. **Build Docker images**
   ```bash
   make build
   ```
   Builds `usersvc:dev`, `paymentsvc:dev`, and `authsvc:dev` images.

4. **Import images into k3d**
   ```bash
   make import
   ```
   Loads built images into the k3d cluster.

5. **Deploy services**
   ```bash
   make apply
   ```
   Deploys all services to the `micro` namespace using kustomize.

6. **Verify deployment**
   ```bash
   kubectl get pods -n micro
   kubectl get svc -n micro
   ```

## 📝 Development Workflow

### Making Changes to Services

1. **Modify proto definitions** (if adding/changing RPCs)
   ```bash
   # Edit protos/{service}/v1/{service}.proto
   # Regenerate stubs
   protoc -I protos \
     --go_out=gen/go \
     --go-grpc_out=gen/go \
     protos/{service}/v1/{service}.proto
   ```

2. **Update service implementation**
   ```bash
   # Edit services/{service}/cmd/{service}/main.go
   # Build and test
   docker build -t {service}:dev -f services/{service}/Dockerfile .
   ```

3. **Update dependencies**
   ```bash
   # In services/{service}/
   go get -u example.com/monorepo/libs/platform@latest
   go mod tidy
   ```

4. **Rebuild and redeploy**
   ```bash
   make build
   make import
   make restart
   ```

### Environment Variables

Each service expects the following environment variables:

- `DATABASE_URL`: PostgreSQL connection string
  - Format: `postgres://user:password@host:5432/database_name?sslmode=disable`
  - Set via Kubernetes deployment manifests in `deploy/kustomize/`

### Database Initialization

PostgreSQL is initialized with three databases via `deploy/kustomize/base/postgres.yaml`:
- `users_db` - for UserService
- `payments_db` - for PaymentService
- `auth_db` - for AuthService

To add database migrations, create SQL files in the workspace and update the ConfigMap.

## 🔄 Kubernetes Cluster Management

| Command | Purpose |
|---------|---------|
| `make k3d-up` | Create development k3d cluster |
| `make k3d-down` | Destroy the cluster |
| `make build` | Build all service Docker images |
| `make import` | Import images into k3d |
| `make apply` | Deploy services via kustomize |
| `make restart` | Rolling restart all deployments |

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

6. **Update Makefile**
   - Add build target for new service
   - Update import and restart targets

7. **Create Kubernetes manifests**
   - Add deployment YAML in `deploy/kustomize/base/`
   - Reference in `kustomization.yaml`

## 🧪 Testing

Currently, the project includes minimal test coverage. Recommended additions:
- Unit tests for database operations
- gRPC integration tests
- End-to-end tests with test containers

See [TODOs.md](TODOs.md) for planned testing implementation.

## 📊 Monitoring & Troubleshooting

### Check Service Logs
```bash
kubectl logs -n micro deployment/usersvc -f
kubectl logs -n micro deployment/paymentsvc -f
kubectl logs -n micro deployment/authsvc -f
```

### Port Forwarding for Local Testing
```bash
kubectl port-forward -n micro svc/usersvc 50051:50051
kubectl port-forward -n micro svc/paymentsvc 50052:50052
kubectl port-forward -n micro svc/authsvc 50053:50053
```

### Verify gRPC Connectivity
```bash
grpcurl -plaintext localhost:50051 list
grpcurl -plaintext localhost:50051 user.v1.UserService/GetUser
```

### Database Connection
```bash
kubectl exec -it statefulset/postgres -n micro -- psql -U postgres
```

## 🗺️ Roadmap

See [TODOs.md](TODOs.md) for planned features:
- Improve README documentation ✓
- Add Swagger/gRPC gateway support
- Comprehensive test coverage
- Resource estimation for k8s cluster
- Service mesh integration (future)
- Authentication interceptors
- Distributed tracing

## 📚 Key Conventions

- **Naming**: Snake_case in Proto messages (e.g., `user_id`), camelCase in Go responses
- **Go Modules**: Each service and library is a separate module with `replace` directives for local dependencies
- **Port Assignment**: 50051-50053 for services (standard gRPC port range)
- **Namespace**: All deployments use the `micro` Kubernetes namespace
- **Error Handling**: Services currently use minimal error handling; add proper error strategies in production

## 💡 Next Steps

- Implement actual service business logic
- Add comprehensive error handling and logging
- Set up CI/CD pipeline
- Add API gateway for external clients
- Implement service-to-service authentication
- Set up distributed tracing (Jaeger/OpenTelemetry)
