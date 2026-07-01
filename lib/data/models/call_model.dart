import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:our_chat/domain/entities/call.dart';

/// Data model for call with JSON serialization for Firestore.
class CallModel extends Call {
  const CallModel({
    required super.id,
    required super.callerId,
    required super.calleeId,
    required super.callType,
    required super.status,
    required super.startedAt,
    super.endedAt,
    super.durationSeconds,
    super.isIncoming,
  });

  /// Creates a [CallModel] from a Firestore document.
  factory CallModel.fromJson(Map<String, dynamic> json, String id) {
    return CallModel(
      id: id,
      callerId: json['callerId'] as String? ?? '',
      calleeId: json['calleeId'] as String? ?? '',
      callType: json['callType'] == 'video' ? CallType.video : CallType.voice,
      status: _parseStatus(json['status'] as String? ?? ''),
      startedAt:
          (json['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endedAt: (json['endedAt'] as Timestamp?)?.toDate(),
      durationSeconds: json['durationSeconds'] as int?,
      isIncoming: json['isIncoming'] as bool? ?? false,
    );
  }

  /// Converts this [CallModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'callerId': callerId,
      'calleeId': calleeId,
      'callType': callType == CallType.video ? 'video' : 'voice',
      'status': _statusToString(status),
      'startedAt': startedAt,
      if (endedAt != null) 'endedAt': endedAt,
      if (durationSeconds != null) 'durationSeconds': durationSeconds,
      'isIncoming': isIncoming,
    };
  }

  /// Parses a [CallStatus] from a string.
  static CallStatus _parseStatus(String status) {
    switch (status) {
      case 'initiated':
        return CallStatus.initiated;
      case 'ringing':
        return CallStatus.ringing;
      case 'ongoing':
        return CallStatus.ongoing;
      case 'ended':
        return CallStatus.ended;
      case 'missed':
        return CallStatus.missed;
      case 'rejected':
        return CallStatus.rejected;
      default:
        return CallStatus.initiated;
    }
  }

  /// Converts a [CallStatus] to a string.
  static String _statusToString(CallStatus status) {
    switch (status) {
      case CallStatus.initiated:
        return 'initiated';
      case CallStatus.ringing:
        return 'ringing';
      case CallStatus.ongoing:
        return 'ongoing';
      case CallStatus.ended:
        return 'ended';
      case CallStatus.missed:
        return 'missed';
      case CallStatus.rejected:
        return 'rejected';
    }
  }
}