#!/bin/bash

# Database migration script
# Requires: golang-migrate

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Database configuration
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="postgres"
DB_PASS="postgres"
DB_NAME="users_db"
DB_URL="postgres://${DB_USER}:${DB_PASS}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=disable"

MIGRATIONS_DIR="services/usersvc/migrations"

# Check if migrate is installed
if ! command -v migrate &> /dev/null; then
    echo -e "${YELLOW}Installing golang-migrate...${NC}"
    go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
    export PATH="$PATH:$(go env GOPATH)/bin"
fi

# Check if migrations directory exists
if [ ! -d "$MIGRATIONS_DIR" ]; then
    mkdir -p "$MIGRATIONS_DIR"
    echo -e "${GREEN}Created migrations directory: $MIGRATIONS_DIR${NC}"
fi

# Parse command
COMMAND=$1
shift || true

case "$COMMAND" in
    up)
        echo -e "${GREEN}Running migrations up...${NC}"
        migrate -path "$MIGRATIONS_DIR" -database "$DB_URL" up
        echo -e "${GREEN}Migrations completed successfully!${NC}"
        ;;
    down)
        echo -e "${YELLOW}Rolling back migrations...${NC}"
        migrate -path "$MIGRATIONS_DIR" -database "$DB_URL" down 1
        echo -e "${GREEN}Rollback completed!${NC}"
        ;;
    force)
        VERSION=$1
        if [ -z "$VERSION" ]; then
            echo -e "${RED}Error: Version required for force command${NC}"
            echo "Usage: ./migrate.sh force <version>"
            exit 1
        fi
        echo -e "${YELLOW}Forcing version to $VERSION...${NC}"
        migrate -path "$MIGRATIONS_DIR" -database "$DB_URL" force "$VERSION"
        echo -e "${GREEN}Version forced!${NC}"
        ;;
    version)
        echo -e "${GREEN}Current migration version:${NC}"
        migrate -path "$MIGRATIONS_DIR" -database "$DB_URL" version
        ;;
    create)
        NAME=$1
        if [ -z "$NAME" ]; then
            echo -e "${RED}Error: Migration name required${NC}"
            echo "Usage: ./migrate.sh create <migration_name>"
            exit 1
        fi
        echo -e "${GREEN}Creating migration: $NAME${NC}"
        migrate create -ext sql -dir "$MIGRATIONS_DIR" -seq "$NAME"
        echo -e "${GREEN}Migration files created in $MIGRATIONS_DIR${NC}"
        ;;
    *)
        echo -e "${RED}Unknown command: $COMMAND${NC}"
        echo ""
        echo "Usage: ./migrate.sh <command>"
        echo ""
        echo "Commands:"
        echo "  up           - Run all pending migrations"
        echo "  down         - Rollback the last migration"
        echo "  force <ver>  - Force database version (use with caution)"
        echo "  version      - Show current migration version"
        echo "  create <name> - Create a new migration file"
        exit 1
        ;;
esac
