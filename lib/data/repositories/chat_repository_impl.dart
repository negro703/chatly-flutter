import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:our_chat/core/error/exceptions.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/core/network/network_info.dart';
import 'package:our_chat/data/datasources/chat_remote_data_source.dart';
import 'package:our_chat/domain/entities/message.dart';
import 'package:our_chat/domain/repositories/chat_repository.dart';

/// Implementation of [ChatRepository] using Firestore data source.
class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  final ChatRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Result<Message>> sendMessage({
    required String chatId,
    required String senderId,
    required String encryptedText,
    String? replyToMessageId,
    String? mediaUrl,
    String? mediaType,
    String? voiceNoteUrl,
    int? voiceNoteDuration,
  }) async {
    if (!await networkInfo.isConnected) {
      return left(NetworkFailure.noInternet());
    }

    try {
      final messageData = {
        'chatId': chatId,
        'senderId': senderId,
        'encryptedText': encryptedText,
        'timestamp': DateTime.now(),
        'isRead': false,
        'isDelivered': false,
        'isEdited': false,
        'isDeleted': false,
        if (replyToMessageId != null)
          'replyToMessageId': replyToMessageId,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
        if (mediaType != null) 'mediaType': mediaType,
        if (voiceNoteUrl != null) 'voiceNoteUrl': voiceNoteUrl,
        if (voiceNoteDuration != null) 'voiceNoteDuration': voiceNoteDuration,
      };

      final messageModel = await remoteDataSource.sendMessage(messageData);
      return right(messageModel);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<List<Message>>> getMessages({
    required String chatId,
    String? lastMessageId,
    int limit = 30,
  }) async {
    if (!await networkInfo.isConnected) {
      return left(NetworkFailure.noInternet());
    }

    try {
      final messages = await remoteDataSource.getMessages(
        chatId: chatId,
        lastMessageId: lastMessageId,
        limit: limit,
      );
      return right(messages);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Stream<List<Message>> getMessagesStream(String chatId) {
    return remoteDataSource.getMessagesStream(chatId);
  }

  @override
  Stream<Map<String, dynamic>> getTypingStatusStream(String chatId) {
    return remoteDataSource.getTypingStatusStream(chatId);
  }

  @override
  Future<void> updateTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await remoteDataSource.updateTypingStatus(
      chatId: chatId,
      userId: userId,
      isTyping: isTyping,
    );
  }

  @override
  Stream<bool> getOnlineStatusStream(String userId) {
    return remoteDataSource.getOnlineStatusStream(userId);
  }

  @override
  Future<Result<void>> markAsRead(String messageId) async {
    try {
      await remoteDataSource.markAsRead(messageId);
      return right(null);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<void>> markAsDelivered(String messageId) async {
    try {
      await remoteDataSource.markAsDelivered(messageId);
      return right(null);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<void>> deleteMessage(String messageId) async {
    try {
      await remoteDataSource.deleteMessage(messageId);
      return right(null);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<Message>> editMessage({
    required String messageId,
    required String newEncryptedText,
  }) async {
    try {
      final messageModel = await remoteDataSource.editMessage(
        messageId: messageId,
        newEncryptedText: newEncryptedText,
      );
      return right(messageModel);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<void>> clearChat(String chatId) async {
    if (!await networkInfo.isConnected) {
      return left(NetworkFailure.noInternet());
    }

    try {
      await remoteDataSource.clearChat(chatId);
      return right(null);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<void>> updateChatRoom({
    required String chatId,
    String? roomName,
    String? roomImage,
  }) async {
    if (!await networkInfo.isConnected) {
      return left(NetworkFailure.noInternet());
    }

    try {
      await remoteDataSource.updateChatRoom(
        chatId: chatId,
        roomName: roomName,
        roomImage: roomImage,
      );
      return right(null);
    } on ServerException catch (_) {
      return left(ServerFailure.internal());
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }
}
