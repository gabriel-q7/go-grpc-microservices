SHELL := /bin/bash

# Start all services with Docker Compose
up:
	docker-compose up -d

# Stop all services
down:
	docker-compose down

# Stop all services and remove volumes
down-volumes:
	docker-compose down -v

# Build all service images
build:
	docker-compose build

# View logs from all services
logs:
	docker-compose logs -f

# View logs from a specific service (e.g., make logs-service SERVICE=usersvc)
logs-service:
	docker-compose logs -f $(SERVICE)

# Restart all services
restart:
	docker-compose restart

# Restart a specific service (e.g., make restart-service SERVICE=usersvc)
restart-service:
	docker-compose restart $(SERVICE)

# Rebuild and restart all services
rebuild:
	docker-compose up -d --build

# Show status of all services
ps:
	docker-compose ps

# Execute a shell in a service container (e.g., make shell SERVICE=usersvc)
shell:
	docker-compose exec $(SERVICE) /bin/sh

# Connect to PostgreSQL database
db-shell:
	docker-compose exec postgres psql -U postgres

# Clean up everything (containers, volumes, images)
clean:
	docker-compose down -v --rmi local
