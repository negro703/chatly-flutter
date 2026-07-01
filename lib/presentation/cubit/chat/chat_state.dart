import 'package:equatable/equatable.dart';

import 'package:our_chat/domain/entities/message.dart';

/// States for the chat cubit.
sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial chat state.
final class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Messages are being loaded.
final class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Messages loaded successfully.
final class ChatLoaded extends ChatState {
  const ChatLoaded({
    required this.messages,
    this.hasMore = true,
    this.typingStatus,
    this.receiverIsOnline = false,
  });

  final List<Message> messages;
  final bool hasMore;
  final Map<String, dynamic>? typingStatus;
  final bool receiverIsOnline;

  /// Creates a copy of this state with the given fields replaced.
  ChatLoaded copyWith({
    List<Message>? messages,
    bool? hasMore,
    Map<String, dynamic>? typingStatus,
    bool? receiverIsOnline,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      typingStatus: typingStatus ?? this.typingStatus,
      receiverIsOnline: receiverIsOnline ?? this.receiverIsOnline,
    );
  }

  @override
  List<Object?> get props => [messages, hasMore, typingStatus, receiverIsOnline];
}

/// A new message has arrived in real-time.
final class ChatMessageReceived extends ChatState {
  const ChatMessageReceived({required this.message});

  final Message message;

  @override
  List<Object?> get props => [message];
}

/// Message is being sent.
final class ChatSending extends ChatState {
  const ChatSending();
}

/// Message sent successfully.
final class ChatMessageSent extends ChatState {
  const ChatMessageSent({required this.message});

  final Message message;

  @override
  List<Object?> get props => [message];
}

/// Chat error occurred.
final class ChatError extends ChatState {
  const ChatError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}