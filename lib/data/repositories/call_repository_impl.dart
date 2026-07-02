import 'package:dartz/dartz.dart';

import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/data/datasources/call_log_remote_data_source.dart';
import 'package:our_chat/data/models/call_log_model.dart';
import 'package:our_chat/domain/entities/call.dart';
import 'package:our_chat/domain/entities/call_log.dart';
import 'package:our_chat/domain/repositories/call_repository.dart';

/// Implementation of [CallRepository] using Firestore for WebRTC signaling
/// and call log persistence.
class CallRepositoryImpl implements CallRepository {
  CallRepositoryImpl({required CallLogRemoteDataSource callLogRemoteDataSource})
      : _callLogRemoteDataSource = callLogRemoteDataSource;

  final CallLogRemoteDataSource _callLogRemoteDataSource;

  @override
  Future<Result<Call>> initiateCall({
    required String callerId,
    required String calleeId,
    required CallType callType,
  }) async {
    try {
      // TODO: Implement WebRTC signaling via Firestore
      return right(Call(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        callerId: callerId,
        calleeId: calleeId,
        callType: callType,
        status: CallStatus.initiated,
        startedAt: DateTime.now(),
      ));
    } catch (_) {
      return left(CallFailure.connectionFailed());
    }
  }

  @override
  Future<Result<Call>> acceptCall(String callId) async {
    // TODO: Implement call acceptance via Firestore
    return left(CallFailure.connectionFailed());
  }

  @override
  Future<Result<Call>> rejectCall(String callId) async {
    // TODO: Implement call rejection via Firestore
    return left(CallFailure.connectionFailed());
  }

  @override
  Future<Result<Call>> endCall(String callId) async {
    // TODO: Implement call end via Firestore
    return left(CallFailure.connectionFailed());
  }

  @override
  Stream<Call> getCallStream(String userId) {
    // TODO: Implement call stream via Firestore
    return const Stream.empty();
  }

  @override
  Future<Result<List<Call>>> getCallHistory({
    required String userId,
    int limit = 20,
    String? lastCallId,
  }) async {
    return right([]);
  }

  // ========================================
  // Call Logs (Persistent History)
  // ========================================

  @override
  Future<Result<CallLog>> createCallLog(CallLog callLog) async {
    try {
      final model = CallLogModel.fromEntity(callLog);
      final created = await _callLogRemoteDataSource.createCallLog(model);
      return right(created);
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Future<Result<List<CallLog>>> getCallLogs({
    required String userId,
    int limit = 20,
    String? lastCallId,
    DateTime? lastCallDate,
  }) async {
    try {
      final logs = await _callLogRemoteDataSource.getCallLogs(
        userId: userId,
        limit: limit,
        lastCallId: lastCallId,
        lastCallDate: lastCallDate,
      );
      return right(logs);
    } catch (_) {
      return left(ServerFailure.internal());
    }
  }

  @override
  Stream<List<CallLog>> getCallLogsStream(String userId) {
    return _callLogRemoteDataSource.getCallLogsStream(userId);
  }
}