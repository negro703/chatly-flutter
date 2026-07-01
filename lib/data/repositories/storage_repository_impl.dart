import 'package:dartz/dartz.dart';

import 'package:our_chat/core/error/exceptions.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/data/datasources/storage_remote_data_source.dart';
import 'package:our_chat/domain/repositories/storage_repository.dart';

/// Implementation of [StorageRepository] using Firebase Storage data source.
class StorageRepositoryImpl implements StorageRepository {
  StorageRepositoryImpl({required this.remoteDataSource});

  final StorageRemoteDataSource remoteDataSource;

  @override
  Future<Result<String>> uploadImage({
    required String filePath,
    required String fileName,
    String? folder,
  }) async {
    try {
      final url = await remoteDataSource.uploadImage(
        filePath: filePath,
        fileName: fileName,
        folder: folder,
      );
      return right(url);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<String>> uploadVideo({
    required String filePath,
    required String fileName,
    String? folder,
  }) async {
    try {
      final url = await remoteDataSource.uploadVideo(
        filePath: filePath,
        fileName: fileName,
        folder: folder,
      );
      return right(url);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<String>> uploadVoiceNote({
    required String filePath,
    required String fileName,
    String? folder,
  }) async {
    try {
      final url = await remoteDataSource.uploadVoiceNote(
        filePath: filePath,
        fileName: fileName,
        folder: folder,
      );
      return right(url);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<String>> uploadDocument({
    required String filePath,
    required String fileName,
    String? folder,
  }) async {
    try {
      final url = await remoteDataSource.uploadDocument(
        filePath: filePath,
        fileName: fileName,
        folder: folder,
      );
      return right(url);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<void>> deleteFile(String fileUrl) async {
    try {
      await remoteDataSource.deleteFile(fileUrl);
      return right(null);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<String>> getDownloadUrl(String filePath) async {
    try {
      final url = await remoteDataSource.getDownloadUrl(filePath);
      return right(url);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }
}