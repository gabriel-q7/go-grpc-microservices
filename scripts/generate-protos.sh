#!/bin/bash

# Proto generation script for all services
# Requires: protoc, protoc-gen-go, protoc-gen-go-grpc

set -e

# Add Go bin to PATH
export PATH="$PATH:$(go env GOPATH)/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Generating gRPC stubs from proto files ===${NC}"

# Check if protoc is installed
if ! command -v protoc &> /dev/null; then
    echo -e "${RED}Error: protoc is not installed${NC}"
    echo "Install with: sudo apt-get install -y protobuf-compiler (Ubuntu/Debian)"
    echo "or: brew install protobuf (macOS)"
    exit 1
fi

# Check if protoc-gen-go is installed
if ! command -v protoc-gen-go &> /dev/null; then
    echo -e "${YELLOW}Installing protoc-gen-go...${NC}"
    go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
fi

# Check if protoc-gen-go-grpc is installed
if ! command -v protoc-gen-go-grpc &> /dev/null; then
    echo -e "${YELLOW}Installing protoc-gen-go-grpc...${NC}"
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
fi

# Create output directory if it doesn't exist
mkdir -p gen/go

# Generate proto files for each service
echo -e "${GREEN}Generating user service protos...${NC}"
protoc --go_out=gen/go --go_opt=paths=source_relative \
    --go-grpc_out=gen/go --go-grpc_opt=paths=source_relative \
    -I protos \
    protos/user/v1/user.proto

echo -e "${GREEN}Generating payment service protos...${NC}"
protoc --go_out=gen/go --go_opt=paths=source_relative \
    --go-grpc_out=gen/go --go-grpc_opt=paths=source_relative \
    -I protos \
    protos/payment/v1/payment.proto

echo -e "${GREEN}Generating auth service protos...${NC}"
protoc --go_out=gen/go --go_opt=paths=source_relative \
    --go-grpc_out=gen/go --go-grpc_opt=paths=source_relative \
    -I protos \
    protos/auth/v1/auth.proto

echo -e "${GREEN}=== Proto generation complete! ===${NC}"
echo -e "Generated files in: ${YELLOW}gen/go/${NC}"
