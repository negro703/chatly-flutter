import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/user.dart';
import 'package:our_chat/domain/repositories/auth_repository.dart';

/// Use case for logging in a user with email or phone number.
///
/// Single responsibility: handle authentication login business logic.
class LoginUseCase {
  /// Creates a new [LoginUseCase] with the given [repository].
  const LoginUseCase({required this.repository});

  /// The authentication repository to use.
  final AuthRepository repository;

  /// Executes login with email and password.
  ///
  /// Returns [User] on success or [Failure] on error.
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    return repository.loginWithEmail(
      email: email,
      password: password,
    );
  }

  /// Executes login with phone number and password.
  ///
  /// Returns [User] on success or [Failure] on error.
  Future<Either<Failure, User>> loginWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    return repository.loginWithPhone(
      phoneNumber: phoneNumber,
      password: password,
    );
  }
}