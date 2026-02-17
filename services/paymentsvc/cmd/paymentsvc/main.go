package main

import (
	"context"
	"net"
	"google.golang.org/grpc"
	"example.com/monorepo/libs/platform/db"
	"os"
)

func main() {
	ctx := context.Background()
	dsn := os.Getenv("DATABASE_URL")
	_, _ = db.New(ctx, dsn)

	lis, _ := net.Listen("tcp", ":50052")
	s := grpc.NewServer()
	s.Serve(lis)
}
