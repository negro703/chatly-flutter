import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/user.dart';
import 'package:our_chat/domain/repositories/auth_repository.dart';

/// Use case for updating the user's profile.
///
/// Allows updating display name and/or photo URL.
class UpdateProfileUseCase {
  /// Creates a new [UpdateProfileUseCase] with the given [repository].
  const UpdateProfileUseCase({required this.repository});

  final AuthRepository repository;

  /// Executes the profile update.
  ///
  /// Returns the updated [User] on success or [Failure] on error.
  Future<Result<User>> call({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) {
    return repository.updateProfile(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }
}