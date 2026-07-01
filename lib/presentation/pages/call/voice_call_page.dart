import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/core/constants/app_strings.dart';
import 'package:our_chat/presentation/cubit/call/call_cubit.dart';
import 'package:our_chat/presentation/cubit/call/call_state.dart';

/// Voice call page with WebRTC integration.
class VoiceCallPage extends StatelessWidget {
  const VoiceCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context
          .read<CallCubit>()
          ..startCall(calleeId: 'user2', isVideo: false),
      child: BlocBuilder<CallCubit, CallState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surfaceDark,
            body: SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Caller avatar
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Calling...',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state is CallOutgoing
                        ? 'Ringing...'
                        : state is CallConnected
                            ? 'Connected'
                            : 'Voice Call',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Call controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CallControlButton(
                        icon: Icons.mic,
                        label: AppStrings.mute,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 40),
                      _CallControlButton(
                        icon: Icons.call_end,
                        label: AppStrings.endCall,
                        color: AppColors.error,
                        onPressed: () {
                          context.read<CallCubit>().endCall();
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(width: 40),
                      _CallControlButton(
                        icon: Icons.volume_up,
                        label: AppStrings.speaker,
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CallControlButton extends StatelessWidget {
  const _CallControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: (color ?? AppColors.textSecondary)
              .withValues(alpha: 0.2),
          child: IconButton(
            icon: Icon(icon, color: color ?? AppColors.textOnPrimary),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
