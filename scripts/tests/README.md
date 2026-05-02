# gRPC API Test Scripts

This directory contains bash scripts to test the gRPC microservices using `grpcurl`.

## Prerequisites

Install `grpcurl`:

```bash
# macOS
brew install grpcurl

# Linux/Go
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Arch Linux
pacman -S grpcurl
```

Optional (for better JSON parsing):
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# Arch Linux
pacman -S jq
```

## Running Tests

### All Services
Run all tests for all services:
```bash
./scripts/tests/run-all-tests.sh
```

### Individual Services
Test specific services:

```bash
# User Service (port 50051)
./scripts/tests/test-usersvc.sh

# Auth Service (port 50053)
./scripts/tests/test-authsvc.sh

# Payment Service (port 50052)
./scripts/tests/test-paymentsvc.sh
```

## Test Coverage

### User Service (`test-usersvc.sh`)
- ✓ Service discovery and introspection
- ✓ CreateUser - Create new user account
- ✓ GetUser - Retrieve user by ID
- ✓ UpdateUser - Update user email
- ✓ UpdateUser - Update user password
- ✓ DeleteUser - Delete user account
- ✓ Verify deletion

### Auth Service (`test-authsvc.sh`)
- ✓ Service discovery and introspection
- ✓ Login - Valid credentials
- ✓ Login - Invalid credentials (error case)
- ✓ Login - Missing password (error case)
- ✓ Login - Missing email (error case)

### Payment Service (`test-paymentsvc.sh`)
- ✓ Service discovery and introspection
- ✓ CreatePayment - Small amount
- ✓ CreatePayment - Large amount
- ✓ CreatePayment - Zero amount validation
- ✓ CreatePayment - Negative amount (error case)
- ✓ CreatePayment - Missing user_id validation
- ✓ CreatePayment - Empty user_id validation
- ✓ CreatePayment - Bulk sequential payments

## Manual Testing

You can also test endpoints manually with `grpcurl`:

### List available services
```bash
grpcurl -plaintext localhost:50051 list
```

### Describe a service
```bash
grpcurl -plaintext localhost:50051 describe user.v1.UserService
```

### Call an RPC method
```bash
grpcurl -plaintext -d '{
  "email": "test@example.com",
  "password": "secret123"
}' localhost:50051 user.v1.UserService/CreateUser
```

## Service Ports

- **User Service**: `localhost:50051`
- **Payment Service**: `localhost:50052`
- **Auth Service**: `localhost:50053`

## Troubleshooting

### Services not running
If tests fail with connection errors:
```bash
# Start all services
make up

# Check service status
docker compose ps

# View logs
make logs
```

### grpcurl not found
Ensure `grpcurl` is installed and in your PATH:
```bash
which grpcurl
grpcurl --version
```

### Reflection not enabled
If you get "server does not support the reflection API" errors, ensure your gRPC servers have reflection enabled in the service implementation.

## Notes

- Tests use `-plaintext` flag (no TLS) for local development
- Some tests expect specific error responses for validation
- Amounts in PaymentService are in cents (e.g., 1000 = $10.00)
- User passwords are sent as plain text in requests (hashed server-side)
- Tests are designed to be idempotent where possible
