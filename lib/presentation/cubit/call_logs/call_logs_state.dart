import 'package:equatable/equatable.dart';

import 'package:our_chat/domain/entities/call_log.dart';

/// States for the call logs cubit.
sealed class CallLogsState extends Equatable {
  const CallLogsState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class CallLogsInitial extends CallLogsState {
  const CallLogsInitial();
}

/// Call logs are being loaded.
final class CallLogsLoading extends CallLogsState {
  const CallLogsLoading();
}

/// Call logs loaded successfully.
final class CallLogsLoaded extends CallLogsState {
  const CallLogsLoaded({required this.callLogs});

  final List<CallLog> callLogs;

  @override
  List<Object?> get props => [callLogs];
}

/// Error loading call logs.
final class CallLogsError extends CallLogsState {
  const CallLogsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}