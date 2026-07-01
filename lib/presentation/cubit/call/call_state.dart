import 'package:equatable/equatable.dart';

/// States for the call cubit.
sealed class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

/// No active call.
final class CallIdle extends CallState {
  const CallIdle();
}

/// An incoming call is being received.
final class CallIncoming extends CallState {
  const CallIncoming({required this.callerId, required this.isVideo});

  final String callerId;
  final bool isVideo;

  @override
  List<Object?> get props => [callerId, isVideo];
}

/// Outgoing call is in progress.
final class CallOutgoing extends CallState {
  const CallOutgoing({required this.calleeId, required this.isVideo});

  final String calleeId;
  final bool isVideo;

  @override
  List<Object?> get props => [calleeId, isVideo];
}

/// Call is connected and ongoing.
final class CallConnected extends CallState {
  const CallConnected({required this.isVideo});

  final bool isVideo;

  @override
  List<Object?> get props => [isVideo];
}

/// Call has ended.
final class CallEnded extends CallState {
  const CallEnded({this.durationSeconds});

  final int? durationSeconds;

  @override
  List<Object?> get props => [durationSeconds];
}

/// Call error occurred.
final class CallError extends CallState {
  const CallError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}