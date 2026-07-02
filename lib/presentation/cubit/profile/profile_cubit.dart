import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/domain/repositories/storage_repository.dart';
import 'package:our_chat/domain/usecases/auth/update_profile_usecase.dart';
import 'package:our_chat/presentation/cubit/profile/profile_state.dart';

/// Cubit for managing profile editing state.
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.updateProfileUseCase,
    required this.storageRepository,
  }) : super(const ProfileInitial());

  final UpdateProfileUseCase updateProfileUseCase;
  final StorageRepository storageRepository;

  /// Updates the user's display name only.
  Future<void> updateDisplayName({
    required String userId,
    required String displayName,
  }) async {
    emit(const ProfileLoading());

    final result = await updateProfileUseCase(
      userId: userId,
      displayName: displayName,
    );

    result.fold(
      (failure) => emit(
        ProfileError(message: failure.message),
      ),
      (user) => emit(ProfileUpdated(user: user)),
    );
  }

  /// Updates the user's profile photo.
  Future<void> updateProfilePhoto({
    required String userId,
    required String imagePath,
  }) async {
    emit(const ProfileLoading());

    // Upload image to storage first
    final uploadResult = await storageRepository.uploadImage(
      filePath: imagePath,
      fileName: 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      folder: 'profile_images',
    );

    final photoUrl = uploadResult.fold(
      (failure) {
        emit(ProfileError(message: failure.message));
        return null;
      },
      (url) => url,
    );

    if (photoUrl == null) return;

    // Then update Firestore with the photo URL
    final result = await updateProfileUseCase(
      userId: userId,
      photoUrl: photoUrl,
    );

    result.fold(
      (failure) => emit(
        ProfileError(message: failure.message),
      ),
      (user) => emit(ProfileUpdated(user: user)),
    );
  }

  /// Updates both display name and profile photo.
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? imagePath,
  }) async {
    emit(const ProfileLoading());

    String? photoUrl;

    // Upload image if provided
    if (imagePath != null) {
      final uploadResult = await storageRepository.uploadImage(
        filePath: imagePath,
        fileName: 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}',
        folder: 'profile_images',
      );

      final url = uploadResult.fold(
        (failure) {
          emit(ProfileError(message: failure.message));
          return null;
        },
        (url) => url,
      );

      if (url == null) return;
      photoUrl = url;
    }

    // Update Firestore
    final result = await updateProfileUseCase(
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
    );

    result.fold(
      (failure) => emit(
        ProfileError(message: failure.message),
      ),
      (user) => emit(ProfileUpdated(user: user)),
    );
  }

  /// Resets to initial state.
  void reset() {
    emit(const ProfileInitial());
  }
}