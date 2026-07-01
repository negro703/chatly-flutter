import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/message.dart';
import 'package:our_chat/domain/repositories/chat_repository.dart';

/// Use case for sending a chat message.
///
/// Single responsibility: handle sending a message with business validation.
class SendMessageUseCase {
  /// Creates a new [SendMessageUseCase] with the given [repository].
  const SendMessageUseCase({required this.repository});

  /// The chat repository to use.
  final ChatRepository repository;

  /// Executes sending a message.
  ///
  /// The [encryptedText] parameter is the E2EE-encrypted message content
  /// that will be transmitted to the server.
  ///
  /// Returns [Message] on success or [Failure] on error.
  Future<Either<Failure, Message>> call({
    required String chatId,
    required String senderId,
    required String encryptedText,
    String? replyToMessageId,
    String? mediaUrl,
    String? mediaType,
    String? voiceNoteUrl,
    int? voiceNoteDuration,
  }) async {
    return repository.sendMessage(
      chatId: chatId,
      senderId: senderId,
      encryptedText: encryptedText,
      replyToMessageId: replyToMessageId,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      voiceNoteUrl: voiceNoteUrl,
      voiceNoteDuration: voiceNoteDuration,
    );
  }
}