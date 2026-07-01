import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/message.dart';
import 'package:our_chat/domain/repositories/chat_repository.dart';

/// Use case for retrieving messages with pagination.
///
/// Single responsibility: handle message retrieval business logic.
class GetMessagesUseCase {
  /// Creates a new [GetMessagesUseCase] with the given [repository].
  const GetMessagesUseCase({required this.repository});

  /// The chat repository to use.
  final ChatRepository repository;

  /// Executes retrieving messages for a chat.
  ///
  /// [lastMessageId] enables cursor-based pagination.
  /// Returns a list of [Message] on success or [Failure] on error.
  Future<Either<Failure, List<Message>>> call({
    required String chatId,
    String? lastMessageId,
    int limit = 30,
  }) async {
    return repository.getMessages(
      chatId: chatId,
      lastMessageId: lastMessageId,
      limit: limit,
    );
  }

  /// Returns a stream of real-time messages for the given chat.
  /// Returns the full list of messages on each update.
  Stream<List<Message>> messagesStream(String chatId) {
    return repository.getMessagesStream(chatId);
  }

  /// Returns a stream of typing indicators for the given chat.
  Stream<Map<String, dynamic>> typingStatusStream(String chatId) {
    return repository.getTypingStatusStream(chatId);
  }

  /// Returns a stream of online status for the given user.
  Stream<bool> onlineStatusStream(String userId) {
    return repository.getOnlineStatusStream(userId);
  }
}