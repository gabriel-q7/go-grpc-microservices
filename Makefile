SHELL := /bin/bash

# Start all services with Docker Compose
up:
	docker compose up -d

# Stop all services
down:
	docker compose down

# Stop all services and remove volumes
down-volumes:
	docker compose down -v

# Build all service images
build:
	docker compose build

# View logs from all services
logs:
	docker compose logs -f

# View logs from a specific service (e.g., make logs-service SERVICE=usersvc)
logs-service:
	docker compose logs -f $(SERVICE)

# Restart all services
restart:
	docker compose restart

# Restart a specific service (e.g., make restart-service SERVICE=usersvc)
restart-service:
	docker compose restart $(SERVICE)

# Rebuild and restart all services
rebuild:
	docker compose up -d --build

# Show status of all services
ps:
	docker compose ps

# Execute a shell in a service container (e.g., make shell SERVICE=usersvc)
shell:
	docker compose exec $(SERVICE) /bin/sh

# Connect to PostgreSQL database
db-shell:
	docker compose exec postgres psql -U postgres

# Generate gRPC stubs from proto files
proto:
	@chmod +x scripts/generate-protos.sh
	@./scripts/generate-protos.sh

# Database migrations
migrate-up:
	@chmod +x scripts/migrate.sh
	@./scripts/migrate.sh up

migrate-down:
	@chmod +x scripts/migrate.sh
	@./scripts/migrate.sh down

migrate-create:
	@chmod +x scripts/migrate.sh
	@./scripts/migrate.sh create $(NAME)

# Help target
help:
	@echo "Available targets:"
	@echo "  up              - Start all services"
	@echo "  down            - Stop all services"
	@echo "  down-volumes    - Stop services and remove volumes"
	@echo "  build           - Build all service images"
	@echo "  rebuild         - Rebuild and restart all services"
	@echo "  logs            - View logs from all services"
	@echo "  logs-service    - View logs from specific service (SERVICE=name)"
	@echo "  restart         - Restart all services"
	@echo "  restart-service - Restart specific service (SERVICE=name)"
	@echo "  ps              - Show status of all services"
	@echo "  shell           - Execute shell in service (SERVICE=name)"
	@echo "  db-shell        - Connect to PostgreSQL"
	@echo "  proto           - Generate gRPC stubs from proto files"
	@echo "  migrate-up      - Run database migrations"
	@echo "  migrate-down    - Rollback database migrations"
	@echo "  migrate-create  - Create new migration (NAME=migration_name)"

# Clean up everything (containers, volumes, images)
clean:
	docker compose down -v --rmi local
