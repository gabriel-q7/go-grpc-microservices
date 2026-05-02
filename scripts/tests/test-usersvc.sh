#!/bin/bash

# User Service Tests
# Requires grpcurl: https://github.com/fullstorydev/grpcurl
# Install: brew install grpcurl (macOS) or go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

set -e

HOST="localhost:50051"
SERVICE="user.v1.UserService"

echo "========================================"
echo "Testing User Service (${HOST})"
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

# Test 2: List methods for UserService
echo -e "${YELLOW}[TEST 2]${NC} List UserService methods"
grpcurl -plaintext ${HOST} list ${SERVICE} || echo -e "${RED}Failed to list methods${NC}"
echo ""

# Test 3: Describe UserService
echo -e "${YELLOW}[TEST 3]${NC} Describe UserService"
grpcurl -plaintext ${HOST} describe ${SERVICE} || echo -e "${RED}Failed to describe service${NC}"
echo ""

# Test 4: CreateUser
echo -e "${YELLOW}[TEST 4]${NC} CreateUser - Create a new user"
USER_RESPONSE=$(grpcurl -plaintext -d '{
  "email": "test@example.com",
  "password": "securepassword123"
}' ${HOST} ${SERVICE}/CreateUser) || echo -e "${RED}Failed to create user${NC}"

echo "${USER_RESPONSE}"
# Extract user_id from response (assuming jq is available)
if command -v jq &> /dev/null; then
    USER_ID=$(echo "${USER_RESPONSE}" | jq -r '.userId // .user_id')
    echo -e "${GREEN}✓ User created with ID: ${USER_ID}${NC}"
else
    USER_ID="1" # Fallback if jq not available
    echo -e "${YELLOW}Note: Install jq for better output parsing${NC}"
fi
echo ""

# Test 5: GetUser
echo -e "${YELLOW}[TEST 5]${NC} GetUser - Retrieve user by ID"
grpcurl -plaintext -d "{
  \"user_id\": \"${USER_ID}\"
}" ${HOST} ${SERVICE}/GetUser || echo -e "${RED}Failed to get user${NC}"
echo ""

# Test 6: UpdateUser
echo -e "${YELLOW}[TEST 6]${NC} UpdateUser - Update user email"
grpcurl -plaintext -d "{
  \"user_id\": \"${USER_ID}\",
  \"email\": \"updated@example.com\"
}" ${HOST} ${SERVICE}/UpdateUser || echo -e "${RED}Failed to update user${NC}"
echo ""

# Test 7: GetUser (verify update)
echo -e "${YELLOW}[TEST 7]${NC} GetUser - Verify email was updated"
grpcurl -plaintext -d "{
  \"user_id\": \"${USER_ID}\"
}" ${HOST} ${SERVICE}/GetUser || echo -e "${RED}Failed to get user${NC}"
echo ""

# Test 8: UpdateUser with password
echo -e "${YELLOW}[TEST 8]${NC} UpdateUser - Update password only"
grpcurl -plaintext -d "{
  \"user_id\": \"${USER_ID}\",
  \"password\": \"newsecurepassword456\"
}" ${HOST} ${SERVICE}/UpdateUser || echo -e "${RED}Failed to update password${NC}"
echo ""

# Test 9: DeleteUser
echo -e "${YELLOW}[TEST 9]${NC} DeleteUser - Delete the user"
grpcurl -plaintext -d "{
  \"user_id\": \"${USER_ID}\"
}" ${HOST} ${SERVICE}/DeleteUser || echo -e "${RED}Failed to delete user${NC}"
echo ""

# Test 10: GetUser (should fail or return not found)
echo -e "${YELLOW}[TEST 10]${NC} GetUser - Verify user was deleted (should fail)"
grpcurl -plaintext -d "{
  \"user_id\": \"${USER_ID}\"
}" ${HOST} ${SERVICE}/GetUser 2>&1 || echo -e "${GREEN}✓ User successfully deleted (not found)${NC}"
echo ""

echo -e "${GREEN}========================================"
echo "User Service Tests Complete"
echo "========================================${NC}"
