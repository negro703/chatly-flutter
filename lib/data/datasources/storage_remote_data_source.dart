import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:our_chat/core/error/exceptions.dart';

/// Remote data source for file storage via Firebase Storage.
class StorageRemoteDataSource {
  /// Creates a new [StorageRemoteDataSource] with the given [storage].
  StorageRemoteDataSource({required FirebaseStorage storage})
      : _storage = storage;

  final FirebaseStorage _storage;

  /// Reference to the root storage bucket.
  Reference get _rootRef => _storage.ref();

  /// Uploads a file to Firebase Storage.
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    required String folder,
  }) async {
    try {
      final ref = _rootRef.child('$folder/$fileName');
      await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Uploads an image file.
  Future<String> uploadImage({
    required String filePath,
    required String fileName,
    String? folder,
  }) async {
    return uploadFile(
      filePath: filePath,
      fileName: fileName,
      folder: folder ?? 'images',
    );
  }

  /// Uploads a video file.
  Future<String> uploadVideo({
    required String filePath,
    required String fileName,
    String? folder,
  }) async {
    return uploadFile(
      filePath: filePath,
      fileName: fileName,
      folder: folder ?? 'videos',
    );
  }

  /// Uploads a voice note.
  Future<String> uploadVoiceNote({
    required String filePath,
    required String fileName,
    String? folder,
  }) async {
    return uploadFile(
      filePath: filePath,
      fileName: fileName,
      folder: folder ?? 'voice_notes',
    );
  }

  /// Uploads a document.
  Future<String> uploadDocument({
    required String filePath,
    required String fileName,
    String? folder,
  }) async {
    return uploadFile(
      filePath: filePath,
      fileName: fileName,
      folder: folder ?? 'documents',
    );
  }

  /// Deletes a file from storage given its URL.
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Gets a download URL for a file path.
  Future<String> getDownloadUrl(String filePath) async {
    try {
      return await _rootRef.child(filePath).getDownloadURL();
    } catch (e) {
      throw ServerException.internal();
    }
  }
}