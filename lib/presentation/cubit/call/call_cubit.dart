import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/presentation/cubit/call/call_state.dart';

/// Cubit for managing call state (WebRTC signaling).
class CallCubit extends Cubit<CallState> {
  CallCubit() : super(const CallIdle());

  /// Initiates an outgoing call.
  Future<void> startCall({
    required String calleeId,
    required bool isVideo,
  }) async {
    emit(CallOutgoing(calleeId: calleeId, isVideo: isVideo));
    // TODO: Implement WebRTC offer creation and signaling
  }

  /// Accepts an incoming call.
  Future<void> acceptCall() async {
    final current = state;
    if (current is CallIncoming) {
      emit(CallConnected(isVideo: current.isVideo));
      // TODO: Implement WebRTC answer creation
    }
  }

  /// Rejects an incoming call.
  Future<void> rejectCall() async {
    emit(const CallIdle());
    // TODO: Implement call rejection signaling
  }

  /// Ends the current call.
  Future<void> endCall({int? durationSeconds}) async {
    emit(CallEnded(durationSeconds: durationSeconds));
    // TODO: Implement call end signaling
    await Future<void>.delayed(const Duration(seconds: 1));
    emit(const CallIdle());
  }

  /// Sets call as connected.
  void onCallConnected({required bool isVideo}) {
    emit(CallConnected(isVideo: isVideo));
  }

  /// Handles call errors.
  void onCallError(String message) {
    emit(CallError(message: message));
  }
}
