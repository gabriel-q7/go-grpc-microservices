#!/bin/bash

# Auth Service Tests
# Requires grpcurl: https://github.com/fullstorydev/grpcurl

set -e

HOST="localhost:50053"
SERVICE="auth.v1.AuthService"

echo "========================================"
echo "Testing Auth Service (${HOST})"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if grpcurl is installed
if ! command -v grpcurl &> /dev/null; then
    echo -e "${RED}Error: grpcurl is not installed${NC}"
    echo "Install with: brew install grpcurl (macOS) or go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest"
    exit 1
fi

# Test 1: List available services
echo -e "${YELLOW}[TEST 1]${NC} List available services"
grpcurl -plaintext ${HOST} list || echo -e "${RED}Failed to list services${NC}"
echo ""

# Test 2: List methods for AuthService
echo -e "${YELLOW}[TEST 2]${NC} List AuthService methods"
grpcurl -plaintext ${HOST} list ${SERVICE} || echo -e "${RED}Failed to list methods${NC}"
echo ""

# Test 3: Describe AuthService
echo -e "${YELLOW}[TEST 3]${NC} Describe AuthService"
grpcurl -plaintext ${HOST} describe ${SERVICE} || echo -e "${RED}Failed to describe service${NC}"
echo ""

# Test 4: Login with valid credentials
echo -e "${YELLOW}[TEST 4]${NC} Login - Attempt authentication"
TOKEN_RESPONSE=$(grpcurl -plaintext -d '{
  "email": "test@example.com",
  "password": "securepassword123"
}' ${HOST} ${SERVICE}/Login) || echo -e "${RED}Failed to login${NC}"

echo "${TOKEN_RESPONSE}"
if command -v jq &> /dev/null; then
    TOKEN=$(echo "${TOKEN_RESPONSE}" | jq -r '.token')
    if [ -n "${TOKEN}" ] && [ "${TOKEN}" != "null" ]; then
        echo -e "${GREEN}✓ Login successful, token received${NC}"
        echo "Token: ${TOKEN}"
    else
        echo -e "${RED}✗ Login failed or no token returned${NC}"
    fi
else
    echo -e "${YELLOW}Note: Install jq for better output parsing${NC}"
fi
echo ""

# Test 5: Login with invalid credentials
echo -e "${YELLOW}[TEST 5]${NC} Login - Test with invalid credentials (should fail)"
grpcurl -plaintext -d '{
  "email": "invalid@example.com",
  "password": "wrongpassword"
}' ${HOST} ${SERVICE}/Login 2>&1 || echo -e "${GREEN}✓ Correctly rejected invalid credentials${NC}"
echo ""

# Test 6: Login with missing password
echo -e "${YELLOW}[TEST 6]${NC} Login - Test with missing password (should fail)"
grpcurl -plaintext -d '{
  "email": "test@example.com"
}' ${HOST} ${SERVICE}/Login 2>&1 || echo -e "${GREEN}✓ Correctly rejected missing password${NC}"
echo ""

# Test 7: Login with missing email
echo -e "${YELLOW}[TEST 7]${NC} Login - Test with missing email (should fail)"
grpcurl -plaintext -d '{
  "password": "securepassword123"
}' ${HOST} ${SERVICE}/Login 2>&1 || echo -e "${GREEN}✓ Correctly rejected missing email${NC}"
echo ""

echo -e "${GREEN}========================================"
echo "Auth Service Tests Complete"
echo "========================================${NC}"
