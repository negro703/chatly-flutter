import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/domain/entities/call_log.dart';
import 'package:our_chat/domain/usecases/call_logs/add_call_log_usecase.dart';
import 'package:our_chat/domain/usecases/call_logs/get_call_logs_usecase.dart';
import 'package:our_chat/presentation/cubit/call_logs/call_logs_state.dart';

/// Cubit for managing call logs state.
class CallLogsCubit extends Cubit<CallLogsState> {
  CallLogsCubit({
    required this.getCallLogsUseCase,
    required this.addCallLogUseCase,
  }) : super(const CallLogsInitial());

  final GetCallLogsUseCase getCallLogsUseCase;
  final AddCallLogUseCase addCallLogUseCase;

  StreamSubscription<List<CallLog>>? _callLogsSubscription;

  /// Loads call logs for a specific user.
  Future<void> loadCallLogs({required String userId}) async {
    emit(const CallLogsLoading());

    final result = await getCallLogsUseCase.call(userId: userId);

    result.fold(
      (failure) => emit(CallLogsError(message: failure.message)),
      (logs) => emit(CallLogsLoaded(callLogs: logs)),
    );
  }

  /// Loads more call logs for pagination.
  Future<void> loadMoreCallLogs({required String userId}) async {
    final currentState = state;
    if (currentState is! CallLogsLoaded) return;

    final lastLog = currentState.callLogs.isNotEmpty
        ? currentState.callLogs.last
        : null;

    final result = await getCallLogsUseCase.call(
      userId: userId,
      lastCallId: lastLog?.id,
      lastCallDate: lastLog?.startedAt,
    );

    result.fold(
      (failure) => emit(CallLogsError(message: failure.message)),
      (logs) => emit(
        CallLogsLoaded(
          callLogs: [...currentState.callLogs, ...logs],
        ),
      ),
    );
  }

  /// Subscribes to real-time call log updates.
  void subscribeToCallLogs({required String userId}) {
    _callLogsSubscription?.cancel();
    _callLogsSubscription =
        getCallLogsUseCase.callLogsStream(userId).listen((logs) {
      if (!isClosed) {
        emit(CallLogsLoaded(callLogs: logs));
      }
    });
  }

  /// Adds a new call log entry.
  Future<void> addCallLog({required CallLog callLog}) async {
    final result = await addCallLogUseCase.call(callLog: callLog);

    result.fold(
      (failure) => emit(CallLogsError(message: failure.message)),
      (_) {
        // The stream subscription will automatically update the list
        // if subscribeToCallLogs is active. Otherwise, reload.
      },
    );
  }

  @override
  Future<void> close() {
    _callLogsSubscription?.cancel();
    return super.close();
  }
}