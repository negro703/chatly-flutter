import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

import 'package:our_chat/domain/entities/message.dart';
import 'package:our_chat/domain/repositories/chat_repository.dart';
import 'package:our_chat/domain/repositories/storage_repository.dart';
import 'package:our_chat/domain/usecases/chat/get_messages_usecase.dart';
import 'package:our_chat/domain/usecases/chat/send_media_usecase.dart';
import 'package:our_chat/domain/usecases/chat/send_message_usecase.dart';
import 'package:our_chat/domain/usecases/encryption/encrypt_message_usecase.dart';
import 'package:our_chat/presentation/cubit/chat/chat_state.dart';

/// Cubit for managing chat messages and real-time updates.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.sendMediaUseCase,
    required this.encryptMessageUseCase,
    required this.storageRepository,
    required this.chatRepository,
  }) : super(const ChatInitial());

  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final SendMediaUseCase sendMediaUseCase;
  final EncryptMessageUseCase encryptMessageUseCase;
  final StorageRepository storageRepository;
  final ChatRepository chatRepository;
  final Logger _logger = Logger();

  List<Message> _messages = [];
  StreamSubscription<List<Message>>? _messagesSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<bool>? _onlineStatusSubscription;

  /// Loads initial messages for a chat.
  Future<void> loadMessages({
    required String chatId,
    String? lastMessageId,
    int limit = 30,
  }) async {
    emit(const ChatLoading());

    try {
      final result = await getMessagesUseCase(
        chatId: chatId,
        lastMessageId: lastMessageId,
        limit: limit,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load messages: ${failure.message}');
          emit(ChatError(message: failure.message));
        },
        (messages) {
          _logger.i('Loaded ${messages.length} messages for chat: $chatId');
          _messages = messages;
          emit(ChatLoaded(messages: List.from(_messages)));
          _startRealTimeStream(chatId);
        },
      );
    } catch (e) {
      _logger.e('Unexpected error loading messages: $e');
      emit(const ChatError(message: 'Failed to load messages'));
    }
  }

  /// Starts listening to real-time message updates.
  /// The stream now returns the FULL list of messages on each change,
  /// so we simply replace the local list without any clear/reset.
  void _startRealTimeStream(String chatId) {
    _logger.i('Starting real-time stream for chat: $chatId');

    // Cancel existing subscription if any
    _messagesSubscription?.cancel();

    _messagesSubscription = getMessagesUseCase
        .messagesStream(chatId)
        .listen(
          (messages) {
            _logger.i('Received ${messages.length} messages via stream');
            if (messages.isNotEmpty) {
              // Simply replace the local list with the full Firestore list.
              // This ensures we never miss a message and never clear state.
              _messages = messages;
              emit(ChatLoaded(messages: List.from(_messages)));
            }
          },
          onError: (Object error) {
            _logger.e('Stream error: $error');
            emit(ChatError(message: 'Real-time connection failed: $error'));
          },
          onDone: () {
            _logger.i('Stream closed');
          },
        );
  }

  /// Starts listening to typing indicators for the chat.
  void startTypingStream(String chatId) {
    _typingSubscription?.cancel();
    _typingSubscription = getMessagesUseCase
        .typingStatusStream(chatId)
        .listen((typingStatus) {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        emit(currentState.copyWith(typingStatus: typingStatus));
      }
    });
  }

  /// Updates typing indicator for the current user.
  Future<void> updateTypingIndicator({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await chatRepository.updateTypingStatus(
      chatId: chatId,
      userId: userId,
      isTyping: isTyping,
    );
  }

  /// Starts listening to online status for a user.
  void startOnlineStatusStream(String userId) {
    _onlineStatusSubscription?.cancel();
    _onlineStatusSubscription = getMessagesUseCase
        .onlineStatusStream(userId)
        .listen((isOnline) {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        emit(currentState.copyWith(receiverIsOnline: isOnline));
      }
    });
  }

  /// Sends an encrypted message.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    String? recipientPublicKey,
    String? mediaUrl,
    String? mediaType,
    String? voiceNoteUrl,
    int? voiceNoteDuration,
  }) async {
    try {
      // Encrypt the message
      var encryptedText = text;
      if (recipientPublicKey != null && text.isNotEmpty) {
        final encryptResult = await encryptMessageUseCase.encrypt(
          plainText: text,
          recipientId: recipientPublicKey,
        );
        encryptResult.fold(
          (failure) => encryptedText = text,
          (encrypted) => encryptedText = encrypted,
        );
      }

      _logger.i('Sending message to chat: $chatId');
      final result = await sendMessageUseCase(
        chatId: chatId,
        senderId: senderId,
        encryptedText: encryptedText,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        voiceNoteUrl: voiceNoteUrl,
        voiceNoteDuration: voiceNoteDuration,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to send message: ${failure.message}');
          emit(ChatError(message: failure.message));
        },
        (message) {
          _logger.i('Message sent successfully: ${message.id}');
          // The real-time stream will pick up the new message from Firestore
          // and add it to the list automatically. No need to manually append.
        },
      );
    } catch (e) {
      _logger.e('Unexpected error sending message: $e');
      emit(const ChatError(message: 'Failed to send message'));
    }
  }

  /// Sends a media message (image/video).
  Future<void> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String filePath,
    required String fileName,
    required String mediaType,
  }) async {
    try {
      _logger.i('Sending media message: $mediaType');
      final result = await sendMediaUseCase(
        chatId: chatId,
        senderId: senderId,
        filePath: filePath,
        fileName: fileName,
        mediaType: mediaType,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to send media: ${failure.message}');
          emit(ChatError(message: failure.message));
        },
        (message) {
          _logger.i('Media sent successfully: ${message.id}');
          // Real-time stream will pick it up.
        },
      );
    } catch (e) {
      _logger.e('Unexpected error sending media: $e');
      emit(const ChatError(message: 'Failed to send media'));
    }
  }

  /// Sends a voice note message.
  Future<void> sendVoiceNote({
    required String chatId,
    required String senderId,
    required String filePath,
    required String fileName,
    required int durationSeconds,
  }) async {
    try {
      _logger.i('Sending voice note, duration: $durationSeconds seconds');

      // Upload voice note
      final uploadResult = await storageRepository.uploadVoiceNote(
        filePath: filePath,
        fileName: fileName,
        folder: 'voice_notes/$chatId',
      );

      uploadResult.fold(
        (failure) {
          _logger.e('Failed to upload voice note: ${failure.message}');
          emit(ChatError(message: failure.message));
        },
        (voiceNoteUrl) async {
          // Send message with voice note
          final result = await sendMessageUseCase(
            chatId: chatId,
            senderId: senderId,
            encryptedText: '',
            voiceNoteUrl: voiceNoteUrl,
            voiceNoteDuration: durationSeconds,
          );

          result.fold(
            (failure) {
              _logger.e(
                'Failed to send voice note message: ${failure.message}',
              );
              emit(ChatError(message: failure.message));
            },
            (message) {
              _logger.i('Voice note sent successfully: ${message.id}');
              // Real-time stream will pick it up.
            },
          );
        },
      );
    } catch (e) {
      _logger.e('Unexpected error sending voice note: $e');
      emit(const ChatError(message: 'Failed to send voice note'));
    }
  }

  /// Deletes a message (soft delete by marking as deleted).
  Future<void> deleteMessage(String messageId) async {
    try {
      _logger.i('Deleting message: $messageId');

      // Optimistically update local state
      _messages = _messages.map((m) {
        if (m.id == messageId) {
          return m.copyWith(isDeleted: true);
        }
        return m;
      }).toList();

      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        emit(ChatLoaded(
          messages: List.from(_messages),
          hasMore: currentState.hasMore,
          typingStatus: currentState.typingStatus,
          receiverIsOnline: currentState.receiverIsOnline,
        ));
      }

      // Update Firestore to mark as deleted
      final result = await chatRepository.deleteMessage(messageId);

      result.fold(
        (failure) {
          _logger.e('Failed to delete message: ${failure.message}');
        },
        (_) {
          _logger.i('Message deleted successfully');
          // The real-time stream will pick up the Firestore change
          // and update the list accordingly.
        },
      );
    } catch (e) {
      _logger.e('Unexpected error deleting message: $e');
      emit(const ChatError(message: 'Failed to delete message'));
    }
  }

  /// Closes all real-time streams.
  void closeStreams() {
    _logger.i('Closing all real-time streams');
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _typingSubscription?.cancel();
    _typingSubscription = null;
    _onlineStatusSubscription?.cancel();
    _onlineStatusSubscription = null;
  }

  @override
  Future<void> close() {
    closeStreams();
    return super.close();
  }
}