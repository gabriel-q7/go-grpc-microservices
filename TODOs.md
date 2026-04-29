# Go gRPC Microservices - TODOs

## 🚨 Critical (Must-Have)

### Proto Generation & Code
- [ ] Generate gRPC stubs from proto files (gen/go is empty)
- [ ] Create proto generation script (`scripts/generate-protos.sh`)
- [ ] Add Makefile target for proto generation (`make proto`)
- [ ] Implement gRPC server registration in all services
- [ ] Implement actual RPC handlers for:
  - [ ] UserService.GetUser
  - [ ] PaymentService.CreatePayment
  - [ ] AuthService.Login

### Service Implementation
- [ ] Add proper error handling in services (currently ignoring all errors)
- [ ] Add structured logging (consider zerolog or zap)
- [ ] Implement graceful shutdown with signal handling
- [ ] Add context cancellation support
- [ ] Validate environment variables on startup
- [ ] Add connection retry logic for database

### Database
- [ ] Create database schemas/tables for each service
  - [ ] users table (id, email, password_hash, created_at, updated_at)
  - [ ] payments table (id, user_id, amount, status, created_at)
  - [ ] auth_tokens table (id, user_id, token, expires_at, created_at)
- [ ] Add database migrations tool (golang-migrate or goose)
- [ ] Implement actual database queries in services

## 🔧 High Priority

### Testing
- [ ] Add unit tests for database operations
- [ ] Add unit tests for service handlers
- [ ] Add integration tests with testcontainers
- [ ] Add end-to-end tests
- [ ] Set up test coverage reporting
- [ ] Add CI/CD pipeline with automated testing

### Documentation
- [X] Improve README
- [ ] Add API documentation for each service
- [ ] Add architecture diagrams (sequence diagrams)
- [ ] Document database schemas
- [ ] Add contributing guidelines

### Observability
- [ ] Add health check endpoints (gRPC health protocol)
- [ ] Add Prometheus metrics
- [ ] Add distributed tracing (OpenTelemetry/Jaeger)
- [ ] Add request/response logging middleware
- [ ] Add panic recovery middleware

## 📈 Medium Priority

### gRPC Enhancements
- [ ] Add gRPC reflection for easier debugging
- [ ] Add gRPC middleware for authentication
- [ ] Add gRPC middleware for request validation
- [ ] Add rate limiting
- [ ] Add circuit breakers for service-to-service calls

### API Gateway
- [ ] Add gRPC-Gateway for REST API exposure
- [ ] Generate Swagger/OpenAPI documentation
- [ ] Add CORS configuration
- [ ] Add API versioning strategy

### Security
- [ ] Implement JWT token generation/validation in authsvc
- [ ] Add password hashing (bcrypt)
- [ ] Add TLS/mTLS support
- [ ] Add service-to-service authentication
- [ ] Add API key validation
- [ ] Add input sanitization

### Service Features
- [ ] Implement user registration (CreateUser RPC)
- [ ] Implement user update/delete operations
- [ ] Add payment validation logic
- [ ] Add payment status tracking
- [ ] Add token refresh mechanism
- [ ] Implement logout functionality

## 🎯 Low Priority / Future

### Advanced Features
- [ ] Add service mesh (Istio/Linkerd) integration
- [ ] Implement event-driven architecture with message queue
- [ ] Add caching layer (Redis)
- [ ] Add read replicas for database
- [ ] Implement CQRS pattern
- [ ] Add GraphQL federation layer
- [ ] Add WebSocket support

### Developer Experience
- [ ] Add hot-reload for local development
- [ ] Add mock generators for testing
- [ ] Create CLI tool for common operations
- [ ] Add code generation for new services
- [ ] Add pre-commit hooks (golangci-lint, gofmt)
- [ ] Add VSCode debugging configurations

### Performance
- [ ] Add connection pooling optimization
- [ ] Implement request batching where appropriate
- [ ] Add response caching
- [ ] Add database query optimization
- [ ] Add load testing suite
- [ ] Profile and optimize hot paths

## ✅ Completed
- [X] Create agents file
- [X] Basic project structure
- [X] Docker Compose setup
- [X] Basic proto definitions
- [X] Service stubs
- [X] Platform library for database connections
- [X] Comprehensive README
- [X] Makefile with Docker Compose commands

---

## Notes
- Proto generation is the most critical blocker - services won't compile without generated code
- Service implementations are minimal stubs - they listen but don't handle requests
- No error handling or logging currently implemented
- Database tables need to be created before services can work properly