import 'package:our_chat/core/error/failures.dart';

/// Abstract repository for file/media storage operations.
///
/// This contract is pure Dart with no external framework dependencies.
abstract class StorageRepository {
  /// Uploads an image file to storage.
  ///
  /// Returns the download URL on success or [Failure] on error.
  Future<Result<String>> uploadImage({
    required String filePath,
    required String fileName,
    String? folder,
  });

  /// Uploads a video file to storage.
  ///
  /// Returns the download URL on success or [Failure] on error.
  Future<Result<String>> uploadVideo({
    required String filePath,
    required String fileName,
    String? folder,
  });

  /// Uploads a voice note audio file to storage.
  ///
  /// Returns the download URL on success or [Failure] on error.
  Future<Result<String>> uploadVoiceNote({
    required String filePath,
    required String fileName,
    String? folder,
  });

  /// Uploads a generic document file to storage.
  ///
  /// Returns the download URL on success or [Failure] on error.
  Future<Result<String>> uploadDocument({
    required String filePath,
    required String fileName,
    String? folder,
  });

  /// Deletes a file from storage by its URL.
  Future<Result<void>> deleteFile(String fileUrl);

  /// Gets the download URL for a file.
  Future<Result<String>> getDownloadUrl(String filePath);
}