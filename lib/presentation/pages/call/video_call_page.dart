import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/core/constants/app_dimensions.dart';
import 'package:our_chat/core/constants/app_strings.dart';
import 'package:our_chat/presentation/cubit/call/call_cubit.dart';
import 'package:our_chat/presentation/cubit/call/call_state.dart';

/// Video call page with WebRTC integration and camera preview.
class VideoCallPage extends StatelessWidget {
  const VideoCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context
          .read<CallCubit>()
          ..startCall(calleeId: 'user2', isVideo: true),
      child: BlocBuilder<CallCubit, CallState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surfaceDark,
            body: SafeArea(
              child: Column(
                children: [
                  // Remote video placeholder
                  Expanded(
                    child: ColoredBox(
                      color: AppColors.surfaceDark,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            Text(
                              state is CallOutgoing
                                  ? AppStrings.calling
                                  : state is CallConnected
                                      ? AppStrings.inCall
                                      : AppStrings.ringing,
                              style: const TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state is CallConnected
                                  ? 'Video call connected'
                                  : 'Video Call',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Local video preview (PiP)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      child: Container(
                        width: 100,
                        height: 150,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          border: Border.all(
                            color: AppColors.textOnPrimary
                                .withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.videocam,
                            size: 40,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Call controls
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                      vertical: AppDimensions.paddingL,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CallControlButton(
                          icon: Icons.mic,
                          label: AppStrings.mute,
                          onPressed: () {},
                        ),
                        _CallControlButton(
                          icon: Icons.switch_camera,
                          label: AppStrings.switchCamera,
                          onPressed: () {},
                        ),
                        _CallControlButton(
                          icon: Icons.call_end,
                          label: AppStrings.endCall,
                          color: AppColors.error,
                          onPressed: () {
                            context.read<CallCubit>().endCall();
                            Navigator.pop(context);
                          },
                        ),
                        _CallControlButton(
                          icon: Icons.volume_up,
                          label: AppStrings.speaker,
                          onPressed: () {},
                        ),
                        _CallControlButton(
                          icon: Icons.videocam,
                          label: AppStrings.video,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Reusable call control button for video/voice call pages.
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
          radius: 24,
          backgroundColor: (color ?? AppColors.textSecondary)
              .withValues(alpha: 0.2),
          child: IconButton(
            icon: Icon(icon, color: color ?? AppColors.textOnPrimary, size: 22),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
