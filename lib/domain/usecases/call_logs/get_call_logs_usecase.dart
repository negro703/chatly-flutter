import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/call_log.dart';
import 'package:our_chat/domain/repositories/call_repository.dart';

/// Use case for retrieving call logs with pagination.
///
/// Single responsibility: handle call log retrieval business logic.
class GetCallLogsUseCase {
  /// Creates a new [GetCallLogsUseCase] with the given [repository].
  const GetCallLogsUseCase({required this.repository});

  /// The call repository to use.
  final CallRepository repository;

  /// Executes retrieving call logs for a user.
  ///
  /// [lastCallId] and [lastCallDate] enable cursor-based pagination.
  /// Returns a list of [CallLog] on success or [Failure] on error.
  Future<Either<Failure, List<CallLog>>> call({
    required String userId,
    int limit = 20,
    String? lastCallId,
    DateTime? lastCallDate,
  }) async {
    return repository.getCallLogs(
      userId: userId,
      limit: limit,
      lastCallId: lastCallId,
      lastCallDate: lastCallDate,
    );
  }

  /// Returns a stream of real-time call logs for the given user.
  Stream<List<CallLog>> callLogsStream(String userId) {
    return repository.getCallLogsStream(userId);
  }
}