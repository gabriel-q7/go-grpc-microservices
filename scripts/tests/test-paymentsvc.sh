#!/bin/bash

# Payment Service Tests
# Requires grpcurl: https://github.com/fullstorydev/grpcurl

set -e

HOST="localhost:50052"
SERVICE="payment.v1.PaymentService"

echo "========================================"
echo "Testing Payment Service (${HOST})"
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

# Test 2: List methods for PaymentService
echo -e "${YELLOW}[TEST 2]${NC} List PaymentService methods"
grpcurl -plaintext ${HOST} list ${SERVICE} || echo -e "${RED}Failed to list methods${NC}"
echo ""

# Test 3: Describe PaymentService
echo -e "${YELLOW}[TEST 3]${NC} Describe PaymentService"
grpcurl -plaintext ${HOST} describe ${SERVICE} || echo -e "${RED}Failed to describe service${NC}"
echo ""

# Test 4: CreatePayment - Small amount
echo -e "${YELLOW}[TEST 4]${NC} CreatePayment - Process small payment (\$10.00)"
PAYMENT_RESPONSE=$(grpcurl -plaintext -d '{
  "user_id": "user-123",
  "amount": 1000
}' ${HOST} ${SERVICE}/CreatePayment) || echo -e "${RED}Failed to create payment${NC}"

echo "${PAYMENT_RESPONSE}"
if command -v jq &> /dev/null; then
    PAYMENT_ID=$(echo "${PAYMENT_RESPONSE}" | jq -r '.paymentId // .payment_id')
    if [ -n "${PAYMENT_ID}" ] && [ "${PAYMENT_ID}" != "null" ]; then
        echo -e "${GREEN}✓ Payment created with ID: ${PAYMENT_ID}${NC}"
    else
        echo -e "${RED}✗ Payment creation failed or no ID returned${NC}"
    fi
else
    echo -e "${YELLOW}Note: Install jq for better output parsing${NC}"
fi
echo ""

# Test 5: CreatePayment - Large amount
echo -e "${YELLOW}[TEST 5]${NC} CreatePayment - Process large payment (\$1,000.00)"
grpcurl -plaintext -d '{
  "user_id": "user-456",
  "amount": 100000
}' ${HOST} ${SERVICE}/CreatePayment || echo -e "${RED}Failed to create payment${NC}"
echo ""

# Test 6: CreatePayment - Zero amount (should it fail?)
echo -e "${YELLOW}[TEST 6]${NC} CreatePayment - Test with zero amount"
grpcurl -plaintext -d '{
  "user_id": "user-789",
  "amount": 0
}' ${HOST} ${SERVICE}/CreatePayment 2>&1 || echo -e "${YELLOW}Note: Check if zero amount should be allowed${NC}"
echo ""

# Test 7: CreatePayment - Negative amount (should fail)
echo -e "${YELLOW}[TEST 7]${NC} CreatePayment - Test with negative amount (should fail)"
grpcurl -plaintext -d '{
  "user_id": "user-999",
  "amount": -500
}' ${HOST} ${SERVICE}/CreatePayment 2>&1 || echo -e "${GREEN}✓ Correctly rejected negative amount${NC}"
echo ""

# Test 8: CreatePayment - Missing user_id
echo -e "${YELLOW}[TEST 8]${NC} CreatePayment - Test with missing user_id"
grpcurl -plaintext -d '{
  "amount": 5000
}' ${HOST} ${SERVICE}/CreatePayment 2>&1 || echo -e "${YELLOW}Note: Check if user_id validation is required${NC}"
echo ""

# Test 9: CreatePayment - Empty user_id
echo -e "${YELLOW}[TEST 9]${NC} CreatePayment - Test with empty user_id"
grpcurl -plaintext -d '{
  "user_id": "",
  "amount": 5000
}' ${HOST} ${SERVICE}/CreatePayment 2>&1 || echo -e "${YELLOW}Note: Check if empty user_id should be rejected${NC}"
echo ""

# Test 10: CreatePayment - Multiple sequential payments
echo -e "${YELLOW}[TEST 10]${NC} CreatePayment - Multiple sequential payments"
for i in {1..3}; do
    echo "Payment ${i}:"
    grpcurl -plaintext -d "{
      \"user_id\": \"user-bulk-${i}\",
      \"amount\": $((i * 1000))
    }" ${HOST} ${SERVICE}/CreatePayment || echo -e "${RED}Failed payment ${i}${NC}"
    echo ""
done

echo -e "${GREEN}========================================"
echo "Payment Service Tests Complete"
echo "========================================${NC}"
