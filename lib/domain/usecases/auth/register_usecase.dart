import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/user.dart';
import 'package:our_chat/domain/repositories/auth_repository.dart';

/// Use case for registering a new user.
///
/// Single responsibility: handle user registration business logic.
class RegisterUseCase {
  /// Creates a new [RegisterUseCase] with the given [repository].
  const RegisterUseCase({required this.repository});

  /// The authentication repository to use.
  final AuthRepository repository;

  /// Executes user registration.
  ///
  /// Returns [User] on success or [Failure] on error.
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return repository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}