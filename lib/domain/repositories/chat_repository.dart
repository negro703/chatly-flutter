import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/message.dart';

/// Abstract repository for chat/messaging operations.
///
/// This contract is pure Dart with no external framework dependencies.
abstract class ChatRepository {
  /// Sends a text message in the specified chat.
  ///
  /// The [encryptedText] should contain the E2EE-encrypted content.
  /// Returns the created [Message] on success or [Failure] on error.
  Future<Result<Message>> sendMessage({
    required String chatId,
    required String senderId,
    required String encryptedText,
    String? replyToMessageId,
    String? mediaUrl,
    String? mediaType,
    String? voiceNoteUrl,
    int? voiceNoteDuration,
  });

  /// Retrieves messages for a chat with pagination.
  ///
  /// [lastMessageId] is used for cursor-based pagination.
  /// Returns a list of [Message] on success or [Failure] on error.
  Future<Result<List<Message>>> getMessages({
    required String chatId,
    String? lastMessageId,
    int limit = 30,
  });

  /// Streams real-time message updates for a chat.
  /// Returns the full list of messages on each update.
  Stream<List<Message>> getMessagesStream(String chatId);

  /// Streams typing indicator updates for a chat.
  Stream<Map<String, dynamic>> getTypingStatusStream(String chatId);

  /// Updates typing indicator for a user in a chat.
  Future<void> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  });

  /// Streams online status for a user.
  Stream<bool> getOnlineStatusStream(String userId);

  /// Marks a message as read by the recipient.
  Future<Result<void>> markAsRead(String messageId);

  /// Marks a message as delivered to the recipient.
  Future<Result<void>> markAsDelivered(String messageId);

  /// Deletes a message for everyone.
  Future<Result<void>> deleteMessage(String messageId);

  /// Edits a message text.
  Future<Result<Message>> editMessage({
    required String messageId,
    required String newEncryptedText,
  });

  /// Clears all messages in a chat room.
  Future<Result<void>> clearChat(String chatId);

  /// Updates a chat room's name and/or image.
  Future<Result<void>> updateChatRoom({
    required String chatId,
    String? roomName,
    String? roomImage,
  });
}
