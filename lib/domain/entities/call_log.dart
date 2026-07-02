import 'package:equatable/equatable.dart';

/// Represents the status of a call log entry.
enum CallLogStatus {
  /// Call was answered.
  answered,

  /// Call was missed.
  missed,

  /// Call was rejected.
  rejected,

  /// Call was outgoing.
  outgoing,
}

/// Represents the type of a call log entry.
enum CallLogType {
  /// Voice call.
  voice,

  /// Video call.
  video,
}

/// Represents a single entry in the call history log.
class CallLog extends Equatable {
  /// Creates a new [CallLog] instance.
  const CallLog({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.callType,
    required this.status,
    required this.startedAt,
    required this.participants,
    this.callerPhotoUrl,
    this.receiverPhotoUrl,
    this.endedAt,
    this.durationSeconds = 0,
  });

  /// Unique identifier for the call log entry.
  final String id;

  /// ID of the user who initiated the call.
  final String callerId;

  /// Display name of the caller.
  final String callerName;

  /// Photo URL of the caller.
  final String? callerPhotoUrl;

  /// ID of the user who received the call.
  final String receiverId;

  /// Display name of the receiver.
  final String receiverName;

  /// Photo URL of the receiver.
  final String? receiverPhotoUrl;

  /// Type of call (voice or video).
  final CallLogType callType;

  /// Status of the call.
  final CallLogStatus status;

  /// When the call started.
  final DateTime startedAt;

  /// When the call ended.
  final DateTime? endedAt;

  /// Duration of the call in seconds.
  final int durationSeconds;

  /// List of user IDs that participated in this call.
  ///
  /// Used for Firestore queries with `arrayContains`.
  final List<String> participants;

  /// Whether this call was incoming for the current user.
  bool get isIncoming => status != CallLogStatus.outgoing;

  /// Whether this call was missed.
  bool get isMissed => status == CallLogStatus.missed;

  /// Formatted duration string (e.g., "5:30").
  String get formattedDuration {
    if (durationSeconds <= 0) return '';
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        id,
        callerId,
        callerName,
        callerPhotoUrl,
        receiverId,
        receiverName,
        receiverPhotoUrl,
        callType,
        status,
        startedAt,
        endedAt,
        durationSeconds,
        participants,
      ];
}