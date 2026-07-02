import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';
import 'package:our_chat/domain/entities/call_log.dart';
import 'package:our_chat/domain/repositories/call_repository.dart';

/// Use case for adding a new call log entry.
///
/// Single responsibility: handle call log creation business logic.
class AddCallLogUseCase {
  /// Creates a new [AddCallLogUseCase] with the given [repository].
  const AddCallLogUseCase({required this.repository});

  /// The call repository to use.
  final CallRepository repository;

  /// Executes adding a new call log entry.
  ///
  /// Returns the created [CallLog] on success or [Failure] on error.
  Future<Either<Failure, CallLog>> call({
    required CallLog callLog,
  }) async {
    return repository.createCallLog(callLog);
  }
}