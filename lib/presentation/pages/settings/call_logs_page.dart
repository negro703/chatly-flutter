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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
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
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No call history',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your call history will appear here',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                itemCount: logs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCallColor(log).withValues(alpha: 0.2),
                      child: Icon(
                        _getCallIcon(log),
                        color: _getCallColor(log),
                      ),
                    ),
                    title: Text(
                      log.isIncoming ? log.callerName : log.receiverName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          _getCallIcon(log),
                          size: 14,
                          color: _getCallColor(log),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDate(log.startedAt)} ${_formatTime(log.startedAt)}',
                        ),
                        if (log.durationSeconds > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(${log.formattedDuration})',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: log.callType == CallLogType.video
                        ? const Icon(Icons.videocam, size: 20)
                        : const Icon(Icons.phone, size: 20),
                    onTap: () {
                      // TODO: Initiate a call to this contact
                    },
                  );
                },
              );
            case CallLogsError(message: final message):
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadCallLogs,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}