#!/bin/bash

# Run all microservice tests
# This script executes all test files in the tests directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║   gRPC Microservices Test Suite       ║"
echo "╔════════════════════════════════════════╗"
echo -e "${NC}"
echo ""

# Check if services are running
echo -e "${YELLOW}Checking if services are running...${NC}"
echo ""

check_service() {
    local host=$1
    local service_name=$2
    
    if nc -z localhost $(echo $host | cut -d: -f2) 2>/dev/null; then
        echo -e "${GREEN}✓ ${service_name} is running on ${host}${NC}"
        return 0
    else
        echo -e "${RED}✗ ${service_name} is NOT running on ${host}${NC}"
        return 1
    fi
}

SERVICES_OK=true

check_service "localhost:50051" "User Service" || SERVICES_OK=false
check_service "localhost:50052" "Payment Service" || SERVICES_OK=false
check_service "localhost:50053" "Auth Service" || SERVICES_OK=false

echo ""

if [ "$SERVICES_OK" = false ]; then
    echo -e "${RED}Error: Some services are not running!${NC}"
    echo -e "${YELLOW}Start services with: make up${NC}"
    exit 1
fi

echo -e "${GREEN}All services are running!${NC}"
echo ""
echo "========================================"
echo ""

# Run User Service tests
if [ -f "${SCRIPT_DIR}/test-usersvc.sh" ]; then
    echo -e "${BLUE}Running User Service Tests...${NC}"
    bash "${SCRIPT_DIR}/test-usersvc.sh"
    echo ""
else
    echo -e "${YELLOW}Warning: test-usersvc.sh not found${NC}"
fi

# Run Auth Service tests
if [ -f "${SCRIPT_DIR}/test-authsvc.sh" ]; then
    echo -e "${BLUE}Running Auth Service Tests...${NC}"
    bash "${SCRIPT_DIR}/test-authsvc.sh"
    echo ""
else
    echo -e "${YELLOW}Warning: test-authsvc.sh not found${NC}"
fi

# Run Payment Service tests
if [ -f "${SCRIPT_DIR}/test-paymentsvc.sh" ]; then
    echo -e "${BLUE}Running Payment Service Tests...${NC}"
    bash "${SCRIPT_DIR}/test-paymentsvc.sh"
    echo ""
else
    echo -e "${YELLOW}Warning: test-paymentsvc.sh not found${NC}"
fi

echo -e "${BLUE}"
echo "╔════════════════════════════════════════╗"
echo "║   All Tests Complete                   ║"
echo "╚════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
echo -e "${GREEN}Test suite finished successfully!${NC}"
echo ""
echo "Next steps:"
echo "  • Review test output above for any failures"
echo "  • Check service logs: make logs"
echo "  • View specific service logs: make logs-service SERVICE=usersvc"
echo ""
