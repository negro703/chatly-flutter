import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:our_chat/core/error/exceptions.dart';
import 'package:our_chat/data/models/call_log_model.dart';

/// Remote data source for call logs stored in Firestore.
class CallLogRemoteDataSource {
  /// Creates a new [CallLogRemoteDataSource] with the given [firestore].
  CallLogRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  /// Collection reference for call logs.
  CollectionReference get _callLogsRef =>
      _firestore.collection('call_logs');

  /// Creates a new call log entry in Firestore.
  Future<CallLogModel> createCallLog(CallLogModel callLog) async {
    try {
      final docRef = _callLogsRef.doc(callLog.id);
      await docRef.set(callLog.toJson());
      return callLog;
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Retrieves call logs for a specific user with pagination.
  ///
  /// Returns a list of [CallLogModel] ordered by [startedAt] descending.
  Future<List<CallLogModel>> getCallLogs({
    required String userId,
    int limit = 20,
    String? lastCallId,
    DateTime? lastCallDate,
  }) async {
    try {
      Query query = _callLogsRef
          .where('participants', arrayContains: userId)
          .orderBy('startedAt', descending: true)
          .limit(limit);

      // Cursor-based pagination
      if (lastCallId != null && lastCallDate != null) {
        query = query.startAfter([lastCallDate]);
      }

      final snapshot = await query.get();

      return snapshot.docs.map((doc) {
        return CallLogModel.fromJson(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Streams call logs for a specific user in real-time.
  Stream<List<CallLogModel>> getCallLogsStream(String userId) {
    try {
      return _callLogsRef
          .where('participants', arrayContains: userId)
          .orderBy('startedAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return CallLogModel.fromJson(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();
      });
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Updates the status of a call log entry.
  Future<void> updateCallLogStatus({
    required String callLogId,
    required String status,
    int? durationSeconds,
    DateTime? endedAt,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
      };
      if (durationSeconds != null) {
        updateData['durationSeconds'] = durationSeconds;
      }
      if (endedAt != null) {
        updateData['endedAt'] = endedAt;
      }

      await _callLogsRef.doc(callLogId).update(updateData);
    } catch (e) {
      throw ServerException.internal();
    }
  }
}