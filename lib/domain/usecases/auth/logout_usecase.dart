import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/repositories/auth_repository.dart';

/// Use case for logging out the current user.
///
/// Single responsibility: handle user logout business logic.
class LogoutUseCase {
  /// Creates a new [LogoutUseCase] with the given [repository].
  const LogoutUseCase({required this.repository});

  /// The authentication repository to use.
  final AuthRepository repository;

  /// Executes user logout.
  ///
  /// Returns void on success or [Failure] on error.
  Future<Either<Failure, void>> call() async {
    return repository.logout();
  }
}