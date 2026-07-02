import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/core/constants/app_strings.dart';
import 'package:our_chat/presentation/cubit/auth/auth_cubit.dart';
import 'package:our_chat/presentation/cubit/auth/auth_state.dart';
import 'package:our_chat/presentation/cubit/call_logs/call_logs_cubit.dart';
import 'package:our_chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:our_chat/presentation/cubit/profile/profile_cubit.dart';
import 'package:our_chat/presentation/cubit/theme/theme_cubit.dart';
import 'package:our_chat/presentation/cubit/theme/theme_state.dart';
import 'package:our_chat/presentation/pages/settings/call_logs_page.dart';
import 'package:our_chat/presentation/pages/settings/edit_profile_page.dart';

/// Settings page with profile management, theme switching, and more.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    final chatIdController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the Chat ID to clear all messages:'),
            const SizedBox(height: 16),
            TextField(
              controller: chatIdController,
              decoration: const InputDecoration(
                hintText: 'Chat ID',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              final chatId = chatIdController.text.trim();
              if (chatId.isNotEmpty) {
                Navigator.of(ctx).pop();
                context.read<ChatCubit>().clearChat(chatId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat cleared successfully')),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final themeCubit = context.watch<ThemeCubit>();
    final isDarkMode = themeCubit.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
      ),
      body: ListView(
        children: [
          // Profile Section
          _buildSection(
            context,
            title: AppStrings.profile,
            items: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.textOnPrimary,
                        )
                      : null,
                ),
                title: Text(user?.displayName ?? 'User Name'),
                subtitle: Text(user?.email ?? 'Online'),
                trailing: const Icon(Icons.edit),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<ProfileCubit>(),
                        child: const EditProfilePage(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),

          // Call History
          _buildSection(
            context,
            title: 'Call History',
            items: [
              ListTile(
                leading: const Icon(Icons.history, color: AppColors.accent),
                title: const Text('Call Logs'),
                subtitle: const Text('View your call history'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<CallLogsCubit>(),
                        child: const CallLogsPage(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),

          // Appearance Section
          _buildSection(
            context,
            title: 'Appearance',
            items: [
              SwitchListTile(
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: isDarkMode ? Colors.amber : AppColors.accent,
                ),
                title: const Text('Dark Mode'),
                value: isDarkMode,
                onChanged: (_) => themeCubit.toggleTheme(),
              ),
            ],
          ),
          const Divider(),

          // Security Section
          _buildSection(
            context,
            title: AppStrings.security,
            items: [
              ListTile(
                leading: const Icon(Icons.lock, color: AppColors.accent),
                title: const Text(AppStrings.encryptionKey),
                subtitle: const Text('End-to-end encrypted'),
                trailing: const Icon(Icons.verified, color: AppColors.accent),
                onTap: () {},
              ),
            ],
          ),
          const Divider(),

          // Notifications
          _buildSection(
            context,
            title: AppStrings.notifications,
            items: [
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Push Notifications'),
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
          const Divider(),

          // Data Management
          _buildSection(
            context,
            title: 'Data',
            items: [
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: AppColors.error),
                title: const Text('Clear Chat'),
                subtitle: const Text('Delete all messages in a chat'),
                onTap: () => _showClearChatDialog(context),
              ),
            ],
          ),
          const Divider(),

          // OTA Update Section
          _buildSection(
            context,
            title: 'Updates',
            items: [
              ListTile(
                leading: const Icon(Icons.system_update, color: AppColors.info),
                title: const Text(AppStrings.checkForUpdates),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You are using the latest version'),
                    ),
                  );
                },
              ),
            ],
          ),
          const Divider(),

          // About
          _buildSection(
            context,
            title: AppStrings.about,
            items: [
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text(AppStrings.appName),
                subtitle: Text('Version 1.0.0'),
              ),
            ],
          ),
          const Divider(),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutConfirmation(context),
              icon: const Icon(Icons.logout),
              label: const Text(AppStrings.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...items,
      ],
    );
  }
}