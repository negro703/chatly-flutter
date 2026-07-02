import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:our_chat/domain/entities/call_log.dart';

/// Data model for call log with JSON serialization for Firestore.
class CallLogModel extends CallLog {
  const CallLogModel({
    required super.id,
    required super.callerId,
    required super.callerName,
    required super.receiverId,
    required super.receiverName,
    required super.callType,
    required super.status,
    required super.startedAt,
    required super.participants,
    super.callerPhotoUrl,
    super.receiverPhotoUrl,
    super.endedAt,
    super.durationSeconds,
  });

  /// Creates a [CallLogModel] from a [CallLog] entity.
  factory CallLogModel.fromEntity(CallLog callLog) {
    return CallLogModel(
      id: callLog.id,
      callerId: callLog.callerId,
      callerName: callLog.callerName,
      receiverId: callLog.receiverId,
      receiverName: callLog.receiverName,
      callType: callLog.callType,
      status: callLog.status,
      startedAt: callLog.startedAt,
      participants: callLog.participants,
      callerPhotoUrl: callLog.callerPhotoUrl,
      receiverPhotoUrl: callLog.receiverPhotoUrl,
      endedAt: callLog.endedAt,
      durationSeconds: callLog.durationSeconds,
    );
  }

  /// Creates a [CallLogModel] from a Firestore document.
  factory CallLogModel.fromJson(Map<String, dynamic> json, String id) {
    return CallLogModel(
      id: id,
      callerId: json['callerId'] as String? ?? '',
      callerName: json['callerName'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
      receiverName: json['receiverName'] as String? ?? '',
      callType: json['callType'] == 'video'
          ? CallLogType.video
          : CallLogType.voice,
      status: _parseStatus(json['status'] as String? ?? ''),
      startedAt:
          (json['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participants: _parseParticipants(json['participants']),
      callerPhotoUrl: json['callerPhotoUrl'] as String?,
      receiverPhotoUrl: json['receiverPhotoUrl'] as String?,
      endedAt: (json['endedAt'] as Timestamp?)?.toDate(),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
    );
  }

  /// Converts this [CallLogModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      if (callerPhotoUrl != null) 'callerPhotoUrl': callerPhotoUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      if (receiverPhotoUrl != null) 'receiverPhotoUrl': receiverPhotoUrl,
      'callType': callType == CallLogType.video ? 'video' : 'voice',
      'status': _statusToString(status),
      'startedAt': startedAt,
      if (endedAt != null) 'endedAt': endedAt,
      'durationSeconds': durationSeconds,
      'participants': participants,
    };
  }

  /// Parses a [CallLogStatus] from a string.
  static CallLogStatus _parseStatus(String status) {
    switch (status) {
      case 'answered':
        return CallLogStatus.answered;
      case 'missed':
        return CallLogStatus.missed;
      case 'rejected':
        return CallLogStatus.rejected;
      case 'outgoing':
        return CallLogStatus.outgoing;
      default:
        return CallLogStatus.answered;
    }
  }

  /// Converts a [CallLogStatus] to a string.
  static String _statusToString(CallLogStatus status) {
    switch (status) {
      case CallLogStatus.answered:
        return 'answered';
      case CallLogStatus.missed:
        return 'missed';
      case CallLogStatus.rejected:
        return 'rejected';
      case CallLogStatus.outgoing:
        return 'outgoing';
    }
  }

  /// Parses the participants list from Firestore JSON.
  static List<String> _parseParticipants(dynamic participantsJson) {
    if (participantsJson is List) {
      return participantsJson.cast<String>();
    }
    return [];
  }
}