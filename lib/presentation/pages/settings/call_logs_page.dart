import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/domain/entities/call_log.dart';
import 'package:our_chat/presentation/cubit/auth/auth_cubit.dart';
import 'package:our_chat/presentation/cubit/auth/auth_state.dart';
import 'package:our_chat/presentation/cubit/call_logs/call_logs_cubit.dart';
import 'package:our_chat/presentation/cubit/call_logs/call_logs_state.dart';

/// Page for displaying call history logs.
///
/// Uses Material 3 design with clean layout and proper padding.
class CallLogsPage extends StatefulWidget {
  const CallLogsPage({super.key});

  @override
  State<CallLogsPage> createState() => _CallLogsPageState();
}

class _CallLogsPageState extends State<CallLogsPage> {
  @override
  void initState() {
    super.initState();
    _loadCallLogs();
  }

  void _loadCallLogs() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<CallLogsCubit>().loadCallLogs(userId: authState.user.id);
    }
  }

  IconData _getCallIcon(CallLog log) {
    if (log.isMissed) {
      return log.callType == CallLogType.video
          ? Icons.videocam_off
          : Icons.phone_missed;
    }
    if (log.isIncoming) {
      return log.callType == CallLogType.video
          ? Icons.videocam
          : Icons.call_received;
    }
    return log.callType == CallLogType.video
        ? Icons.videocam
        : Icons.call_made;
  }

  Color _getCallColor(CallLog log) {
    if (log.isMissed) return AppColors.error;
    if (log.isIncoming) return AppColors.accent;
    return AppColors.primary;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  String _formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        centerTitle: true,
      ),
      body: BlocBuilder<CallLogsCubit, CallLogsState>(
        builder: (context, state) {
          switch (state) {
            case CallLogsInitial():
              return const Center(child: Text('No call history'));
            case CallLogsLoading():
              return const Center(child: CircularProgressIndicator());
            case CallLogsLoaded(callLogs: final logs):
              if (logs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.phone,
                            size: 48,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No call history',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your call history will appear here',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: logs.length,
                separatorBuilder: (_, _) => const Divider(
                  height: 1,
                  indent: 80,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          _getCallColor(log).withValues(alpha: 0.15),
                      child: Icon(
                        _getCallIcon(log),
                        color: _getCallColor(log),
                        size: 22,
                      ),
                    ),
                    title: Text(
                      log.isIncoming ? log.callerName : log.receiverName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          _getCallIcon(log),
                          size: 14,
                          color: _getCallColor(log),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_formatDate(log.startedAt)} ${_formatTime(log.startedAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (log.durationSeconds > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              log.formattedDuration,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        log.callType == CallLogType.video
                            ? Icons.videocam
                            : Icons.phone,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      // TODO: Initiate a call to this contact
                    },
                  );
                },
              );
            case CallLogsError(message: final message):
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        message,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _loadCallLogs,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}