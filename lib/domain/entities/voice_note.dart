import 'package:equatable/equatable.dart';

/// Represents a voice note recording.
class VoiceNote extends Equatable {
  /// Creates a new [VoiceNote] instance.
  const VoiceNote({
    required this.id,
    required this.senderId,
    required this.chatId,
    required this.fileUrl,
    required this.durationSeconds,
    required this.createdAt,
    this.isPlayed = false,
  });

  /// Unique identifier for the voice note.
  final String id;

  /// ID of the user who recorded the voice note.
  final String senderId;

  /// ID of the chat this voice note belongs to.
  final String chatId;

  /// URL of the voice note audio file.
  final String fileUrl;

  /// Duration of the voice note in seconds.
  final int durationSeconds;

  /// When the voice note was created/sent.
  final DateTime createdAt;

  /// Whether the voice note has been played by the recipient.
  final bool isPlayed;

  @override
  List<Object?> get props => [
        id,
        senderId,
        chatId,
        fileUrl,
        durationSeconds,
        createdAt,
        isPlayed,
      ];
}