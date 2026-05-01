package service

import (
	"context"
	"errors"
	"log/slog"
	"strings"

	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
	"google.golang.org/protobuf/types/known/timestamppb"

	"example.com/monorepo/gen/go/user/v1"
	"example.com/monorepo/services/usersvc/internal/crypto"
	"example.com/monorepo/services/usersvc/internal/repository"
)

// UserService implements the gRPC UserService server
type UserService struct {
	userpb.UnimplementedUserServiceServer
	repo   *repository.UserRepository
	logger *slog.Logger
}

// NewUserService creates a new UserService instance
func NewUserService(repo *repository.UserRepository, logger *slog.Logger) *UserService {
	return &UserService{
		repo:   repo,
		logger: logger,
	}
}

// CreateUser creates a new user
func (s *UserService) CreateUser(ctx context.Context, req *userpb.CreateUserRequest) (*userpb.CreateUserResponse, error) {
	s.logger.InfoContext(ctx, "Creating user", "email", req.Email)

	// Validate input
	if err := validateEmail(req.Email); err != nil {
		s.logger.WarnContext(ctx, "Invalid email", "email", req.Email, "error", err)
		return nil, status.Error(codes.InvalidArgument, err.Error())
	}

	if req.Password == "" {
		s.logger.WarnContext(ctx, "Empty password provided")
		return nil, status.Error(codes.InvalidArgument, "password cannot be empty")
	}

	// Hash password
	passwordHash, err := crypto.HashPassword(req.Password)
	if err != nil {
		s.logger.ErrorContext(ctx, "Failed to hash password", "error", err)
		return nil, status.Error(codes.Internal, "failed to process password")
	}

	// Create user in database
	user, err := s.repo.CreateUser(ctx, req.Email, passwordHash)
	if err != nil {
		if errors.Is(err, repository.ErrUserAlreadyExists) {
			s.logger.WarnContext(ctx, "User already exists", "email", req.Email)
			return nil, status.Error(codes.AlreadyExists, "user with this email already exists")
		}
		s.logger.ErrorContext(ctx, "Failed to create user", "error", err)
		return nil, status.Error(codes.Internal, "failed to create user")
	}

	s.logger.InfoContext(ctx, "User created successfully", "user_id", user.ID, "email", user.Email)

	return &userpb.CreateUserResponse{
		UserId:    user.ID,
		Email:     user.Email,
		CreatedAt: timestamppb.New(user.CreatedAt),
	}, nil
}

// GetUser retrieves a user by ID
func (s *UserService) GetUser(ctx context.Context, req *userpb.GetUserRequest) (*userpb.GetUserResponse, error) {
	s.logger.InfoContext(ctx, "Getting user", "user_id", req.UserId)

	// Validate input
	if req.UserId == "" {
		s.logger.WarnContext(ctx, "Empty user ID provided")
		return nil, status.Error(codes.InvalidArgument, "user_id cannot be empty")
	}

	// Get user from database
	user, err := s.repo.GetUserByID(ctx, req.UserId)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			s.logger.WarnContext(ctx, "User not found", "user_id", req.UserId)
			return nil, status.Error(codes.NotFound, "user not found")
		}
		s.logger.ErrorContext(ctx, "Failed to get user", "error", err)
		return nil, status.Error(codes.Internal, "failed to get user")
	}

	s.logger.InfoContext(ctx, "User retrieved successfully", "user_id", user.ID)

	return &userpb.GetUserResponse{
		UserId:    user.ID,
		Email:     user.Email,
		CreatedAt: timestamppb.New(user.CreatedAt),
		UpdatedAt: timestamppb.New(user.UpdatedAt),
	}, nil
}

// UpdateUser updates a user's information
func (s *UserService) UpdateUser(ctx context.Context, req *userpb.UpdateUserRequest) (*userpb.UpdateUserResponse, error) {
	s.logger.InfoContext(ctx, "Updating user", "user_id", req.UserId)

	// Validate input
	if req.UserId == "" {
		s.logger.WarnContext(ctx, "Empty user ID provided")
		return nil, status.Error(codes.InvalidArgument, "user_id cannot be empty")
	}

	// Check if at least one field is provided for update
	if req.Email == nil && req.Password == nil {
		s.logger.WarnContext(ctx, "No fields provided for update", "user_id", req.UserId)
		return nil, status.Error(codes.InvalidArgument, "at least one field must be provided for update")
	}

	// Validate email if provided
	if req.Email != nil {
		if err := validateEmail(*req.Email); err != nil {
			s.logger.WarnContext(ctx, "Invalid email", "email", *req.Email, "error", err)
			return nil, status.Error(codes.InvalidArgument, err.Error())
		}
	}

	// Hash password if provided
	var passwordHash *string
	if req.Password != nil && *req.Password != "" {
		hash, err := crypto.HashPassword(*req.Password)
		if err != nil {
			s.logger.ErrorContext(ctx, "Failed to hash password", "error", err)
			return nil, status.Error(codes.Internal, "failed to process password")
		}
		passwordHash = &hash
	}

	// Update user in database (partial update)
	user, err := s.repo.UpdateUserPartial(ctx, req.UserId, req.Email, passwordHash)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			s.logger.WarnContext(ctx, "User not found", "user_id", req.UserId)
			return nil, status.Error(codes.NotFound, "user not found")
		}
		if errors.Is(err, repository.ErrUserAlreadyExists) {
			s.logger.WarnContext(ctx, "Email already in use", "email", *req.Email)
			return nil, status.Error(codes.AlreadyExists, "email already in use by another user")
		}
		s.logger.ErrorContext(ctx, "Failed to update user", "error", err)
		return nil, status.Error(codes.Internal, "failed to update user")
	}

	s.logger.InfoContext(ctx, "User updated successfully", "user_id", user.ID)

	return &userpb.UpdateUserResponse{
		UserId:    user.ID,
		Email:     user.Email,
		UpdatedAt: timestamppb.New(user.UpdatedAt),
	}, nil
}

// DeleteUser deletes a user
func (s *UserService) DeleteUser(ctx context.Context, req *userpb.DeleteUserRequest) (*userpb.DeleteUserResponse, error) {
	s.logger.InfoContext(ctx, "Deleting user", "user_id", req.UserId)

	// Validate input
	if req.UserId == "" {
		s.logger.WarnContext(ctx, "Empty user ID provided")
		return nil, status.Error(codes.InvalidArgument, "user_id cannot be empty")
	}

	// Delete user from database
	err := s.repo.DeleteUser(ctx, req.UserId)
	if err != nil {
		if errors.Is(err, repository.ErrUserNotFound) {
			s.logger.WarnContext(ctx, "User not found", "user_id", req.UserId)
			return nil, status.Error(codes.NotFound, "user not found")
		}
		s.logger.ErrorContext(ctx, "Failed to delete user", "error", err)
		return nil, status.Error(codes.Internal, "failed to delete user")
	}

	s.logger.InfoContext(ctx, "User deleted successfully", "user_id", req.UserId)

	return &userpb.DeleteUserResponse{
		Success: true,
	}, nil
}

// validateEmail performs basic email validation
func validateEmail(email string) error {
	if email == "" {
		return errors.New("email cannot be empty")
	}

	// Basic validation: must contain @ and .
	if !strings.Contains(email, "@") {
		return errors.New("email must contain @")
	}

	if !strings.Contains(email, ".") {
		return errors.New("email must contain a domain")
	}

	// Check email length
	if len(email) > 255 {
		return errors.New("email is too long (max 255 characters)")
	}

	return nil
}
