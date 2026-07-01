import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/user.dart';

/// Abstract repository for authentication operations.
///
/// This contract is pure Dart with no external framework dependencies.
abstract class AuthRepository {
  /// Logs in with email and password.
  ///
  /// Returns [User] on success or [Failure] on error.
  Future<Result<User>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Logs in with phone number and password.
  ///
  /// Returns [User] on success or [Failure] on error.
  Future<Result<User>> loginWithPhone({
    required String phoneNumber,
    required String password,
  });

  /// Registers a new user with email and password.
  ///
  /// Returns [User] on success or [Failure] on error.
  Future<Result<User>> register({
    required String email,
    required String password,
    required String displayName,
  });

  /// Logs out the current user.
  ///
  /// Returns `null` on success or [Failure] on error.
  Future<Result<void>> logout();

  /// Returns the currently authenticated user, or `null` if not logged in.
  Future<User?> getCurrentUser();

  /// Checks if a user is currently authenticated.
  Future<bool> isAuthenticated();

  /// Sends a password reset email.
  Future<Result<void>> resetPassword(String email);
}