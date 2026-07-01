import 'package:equatable/equatable.dart';

/// Represents the type of a call.
enum CallType {
  /// Voice call.
  voice,

  /// Video call.
  video,
}

/// Represents the state of a call.
enum CallStatus {
  /// Call has been initiated.
  initiated,

  /// Call is currently ringing.
  ringing,

  /// Call is in progress.
  ongoing,

  /// Call has ended.
  ended,

  /// Call was missed.
  missed,

  /// Call was rejected.
  rejected,
}

/// Represents a voice or video call between users.
class Call extends Equatable {
  /// Creates a new [Call] instance.
  const Call({
    required this.id,
    required this.callerId,
    required this.calleeId,
    required this.callType,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.isIncoming = false,
  });

  /// Unique identifier for the call.
  final String id;

  /// ID of the user who initiated the call.
  final String callerId;

  /// ID of the user who received the call.
  final String calleeId;

  /// Type of call (voice or video).
  final CallType callType;

  /// Current status of the call.
  final CallStatus status;

  /// When the call was started.
  final DateTime startedAt;

  /// When the call ended.
  final DateTime? endedAt;

  /// Duration of the call in seconds.
  final int? durationSeconds;

  /// Whether the call was incoming for the current user.
  final bool isIncoming;

  @override
  List<Object?> get props => [
        id,
        callerId,
        calleeId,
        callType,
        status,
        startedAt,
        endedAt,
        durationSeconds,
        isIncoming,
      ];
}