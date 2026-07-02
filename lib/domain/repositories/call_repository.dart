import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/call.dart';
import 'package:our_chat/domain/entities/call_log.dart';

/// Abstract repository for voice and video call operations.
///
/// This contract is pure Dart with no external framework dependencies.
abstract class CallRepository {
  /// Initiates a call to another user.
  ///
  /// Returns the created [Call] on success or [Failure] on error.
  Future<Result<Call>> initiateCall({
    required String callerId,
    required String calleeId,
    required CallType callType,
  });

  /// Accepts an incoming call.
  Future<Result<Call>> acceptCall(String callId);

  /// Rejects an incoming call.
  Future<Result<Call>> rejectCall(String callId);

  /// Ends an ongoing call.
  Future<Result<Call>> endCall(String callId);

  /// Streams call events for a specific user.
  Stream<Call> getCallStream(String userId);

  /// Retrieves the call history for a user.
  Future<Result<List<Call>>> getCallHistory({
    required String userId,
    int limit = 20,
    String? lastCallId,
  });

  // ========================================
  // Call Logs (Persistent History)
  // ========================================

  /// Creates a new call log entry.
  Future<Result<CallLog>> createCallLog(CallLog callLog);

  /// Retrieves call logs for a user with pagination.
  Future<Result<List<CallLog>>> getCallLogs({
    required String userId,
    int limit = 20,
    String? lastCallId,
    DateTime? lastCallDate,
  });

  /// Streams call logs for a user in real-time.
  Stream<List<CallLog>> getCallLogsStream(String userId);
}
