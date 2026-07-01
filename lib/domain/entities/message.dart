import 'package:equatable/equatable.dart';

/// Represents a chat message with encryption support.
class Message extends Equatable {
  /// Creates a new [Message] instance.
  const Message({
    required this.id,
    required this.senderId,
    required this.chatId,
    required this.timestamp,
    this.text,
    this.encryptedText,
    this.mediaUrl,
    this.mediaType,
    this.voiceNoteUrl,
    this.voiceNoteDuration,
    this.isRead = false,
    this.isDelivered = false,
    this.isEdited = false,
    this.isDeleted = false,
    this.editedAt,
    this.replyToMessageId,
  });

  /// Unique identifier for the message.
  final String id;

  /// ID of the user who sent the message.
  final String senderId;

  /// ID of the chat/conversation this message belongs to.
  final String chatId;

  /// Plain text content (unencrypted, for local display).
  final String? text;

  /// Encrypted text content (sent over the wire).
  final String? encryptedText;

  /// URL of attached media (image/video).
  final String? mediaUrl;

  /// Type of media attached (image, video, document).
  final String? mediaType;

  /// URL of voice note attachment.
  final String? voiceNoteUrl;

  /// Duration of voice note in seconds.
  final int? voiceNoteDuration;

  /// Whether the message has been read by the recipient.
  final bool isRead;

  /// Whether the message has been delivered to the recipient.
  final bool isDelivered;

  /// Whether the message has been edited.
  final bool isEdited;
  
  /// Whether the message has been deleted.
  final bool isDeleted;
  
  /// When the message was sent.
  final DateTime timestamp;

  /// When the message was last edited.
  final DateTime? editedAt;

  /// ID of the message this message is replying to.
  final String? replyToMessageId;

  /// Returns a copy of this message with the given fields replaced.
  Message copyWith({
    String? id,
    String? senderId,
    String? chatId,
    String? text,
    String? encryptedText,
    String? mediaUrl,
    String? mediaType,
    String? voiceNoteUrl,
    int? voiceNoteDuration,
    bool? isRead,
    bool? isDelivered,
    bool? isEdited,
    bool? isDeleted,
    DateTime? timestamp,
    DateTime? editedAt,
    String? replyToMessageId,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      chatId: chatId ?? this.chatId,
      text: text ?? this.text,
      encryptedText: encryptedText ?? this.encryptedText,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      voiceNoteDuration: voiceNoteDuration ?? this.voiceNoteDuration,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        chatId,
        text,
        encryptedText,
        mediaUrl,
        mediaType,
        voiceNoteUrl,
        voiceNoteDuration,
        isRead,
        isDelivered,
        isEdited,
        isDeleted,
        timestamp,
        editedAt,
        replyToMessageId,
      ];
}