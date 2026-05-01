package main

import (
	"context"
	"fmt"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/health"
	"google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/reflection"

	"example.com/monorepo/gen/go/user/v1"
	"example.com/monorepo/libs/platform/db"
	"example.com/monorepo/services/usersvc/internal/repository"
	"example.com/monorepo/services/usersvc/internal/service"
)

const (
	serviceName = "usersvc"
	servicePort = ":50051"
)

func main() {
	// Set up structured logging
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	}))
	slog.SetDefault(logger)

	logger.Info("Starting user service", "service", serviceName, "port", servicePort)

	// Create context with cancellation
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Validate environment variables
	dsn := os.Getenv("DATABASE_URL")
	if dsn == "" {
		logger.Error("DATABASE_URL environment variable is not set")
		os.Exit(1)
	}

	// Initialize database connection
	logger.Info("Connecting to database")
	pool, err := db.New(ctx, dsn)
	if err != nil {
		logger.Error("Failed to connect to database", "error", err)
		os.Exit(1)
	}
	defer pool.Close()

	// Test database connection
	if err := pool.Ping(ctx); err != nil {
		logger.Error("Failed to ping database", "error", err)
		os.Exit(1)
	}
	logger.Info("Database connection established")

	// Initialize repository and service
	userRepo := repository.NewUserRepository(pool)
	userService := service.NewUserService(userRepo, logger)

	// Set up gRPC server
	grpcServer := grpc.NewServer()

	// Register UserService
	userpb.RegisterUserServiceServer(grpcServer, userService)
	logger.Info("UserService registered")

	// Register health check service
	healthServer := health.NewServer()
	grpc_health_v1.RegisterHealthServer(grpcServer, healthServer)
	healthServer.SetServingStatus(serviceName, grpc_health_v1.HealthCheckResponse_SERVING)
	logger.Info("Health check service registered")

	// Register reflection service (for grpcurl)
	reflection.Register(grpcServer)
	logger.Info("Reflection service registered")

	// Set up TCP listener
	lis, err := net.Listen("tcp", servicePort)
	if err != nil {
		logger.Error("Failed to listen", "error", err)
		os.Exit(1)
	}

	// Start gRPC server in a goroutine
	serverErrors := make(chan error, 1)
	go func() {
		logger.Info("gRPC server listening", "address", servicePort)
		if err := grpcServer.Serve(lis); err != nil {
			serverErrors <- fmt.Errorf("failed to serve: %w", err)
		}
	}()

	// Set up signal handling for graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	// Wait for shutdown signal or error
	select {
	case err := <-serverErrors:
		logger.Error("Server error", "error", err)
		os.Exit(1)
	case sig := <-sigChan:
		logger.Info("Received shutdown signal", "signal", sig)

		// Mark service as not serving
		healthServer.SetServingStatus(serviceName, grpc_health_v1.HealthCheckResponse_NOT_SERVING)

		// Graceful shutdown with timeout
		logger.Info("Starting graceful shutdown")
		shutdownCtx, shutdownCancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer shutdownCancel()

		// Stop accepting new requests
		grpcServer.GracefulStop()

		// Wait for shutdown to complete or timeout
		done := make(chan struct{})
		go func() {
			grpcServer.GracefulStop()
			close(done)
		}()

		select {
		case <-done:
			logger.Info("Graceful shutdown completed")
		case <-shutdownCtx.Done():
			logger.Warn("Graceful shutdown timed out, forcing stop")
			grpcServer.Stop()
		}

		logger.Info("Service stopped")
	}
}

