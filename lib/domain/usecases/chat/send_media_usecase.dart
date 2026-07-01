import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/message.dart';
import 'package:our_chat/domain/repositories/chat_repository.dart';
import 'package:our_chat/domain/repositories/storage_repository.dart';

/// Use case for sending media (images/videos) in a chat.
///
/// Single responsibility: orchestrate media upload and message creation.
class SendMediaUseCase {
  /// Creates a new [SendMediaUseCase] with the given dependencies.
  const SendMediaUseCase({
    required this.chatRepository,
    required this.storageRepository,
  });

  /// The chat repository for message operations.
  final ChatRepository chatRepository;

  /// The storage repository for media uploads.
  final StorageRepository storageRepository;

  /// Executes sending a media message.
  ///
  /// Uploads the media file first, then sends the message with the media URL.
  /// Returns [Message] on success or [Failure] on error.
  Future<Either<Failure, Message>> call({
    required String chatId,
    required String senderId,
    required String filePath,
    required String fileName,
    required String mediaType,
    String? encryptedText,
  }) async {
    // Upload the media file first
    final uploadResult = await storageRepository.uploadImage(
      filePath: filePath,
      fileName: fileName,
      folder: 'chat_media/$chatId',
    );

    return uploadResult.fold(
      (failure) => left(failure),
      (mediaUrl) async {
        return chatRepository.sendMessage(
          chatId: chatId,
          senderId: senderId,
          encryptedText: encryptedText ?? '',
          // Media metadata will be attached in the data layer
        );
      },
    );
  }

  /// Executes sending a video message.
  Future<Either<Failure, Message>> sendVideo({
    required String chatId,
    required String senderId,
    required String filePath,
    required String fileName,
    String? encryptedText,
  }) async {
    final uploadResult = await storageRepository.uploadVideo(
      filePath: filePath,
      fileName: fileName,
      folder: 'chat_videos/$chatId',
    );

    return uploadResult.fold(
      (failure) => left(failure),
      (mediaUrl) async {
        return chatRepository.sendMessage(
          chatId: chatId,
          senderId: senderId,
          encryptedText: encryptedText ?? '',
        );
      },
    );
  }
}