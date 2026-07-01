import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:our_chat/domain/entities/message.dart';

/// Data model for message with JSON serialization for Firestore.
class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.chatId,
    required super.timestamp,
    super.text,
    super.encryptedText,
    super.mediaUrl,
    super.mediaType,
    super.voiceNoteUrl,
    super.voiceNoteDuration,
    super.isRead,
    super.isDelivered,
    super.isEdited,
    super.isDeleted,
    super.editedAt,
    super.replyToMessageId,
  });

  /// Creates a [MessageModel] from a Firestore document.
  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      senderId: json['senderId'] as String? ?? '',
      chatId: json['chatId'] as String? ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      text: json['text'] as String?,
      encryptedText: json['encryptedText'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
      mediaType: json['mediaType'] as String?,
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      voiceNoteDuration: json['voiceNoteDuration'] as int?,
      isRead: json['isRead'] as bool? ?? false,
      isDelivered: json['isDelivered'] as bool? ?? false,
      isEdited: json['isEdited'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      editedAt: (json['editedAt'] as Timestamp?)?.toDate(),
      replyToMessageId: json['replyToMessageId'] as String?,
    );
  }

  /// Converts this [MessageModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'chatId': chatId,
      'timestamp': timestamp,
      if (text != null) 'text': text,
      if (encryptedText != null) 'encryptedText': encryptedText,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
      if (mediaType != null) 'mediaType': mediaType,
      if (voiceNoteUrl != null) 'voiceNoteUrl': voiceNoteUrl,
      if (voiceNoteDuration != null) 'voiceNoteDuration': voiceNoteDuration,
      'isRead': isRead,
      'isDelivered': isDelivered,
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      if (editedAt != null) 'editedAt': editedAt,
      if (replyToMessageId != null) 'replyToMessageId': replyToMessageId,
    };
  }
}