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
import 'package:our_chat/presentation/pages/settings/call_logs_page.dart';
import 'package:our_chat/presentation/pages/settings/edit_profile_page.dart';

/// Settings page with profile management, theme switching, and more.
///
/// Uses Material 3 design with clean layout and proper padding.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthCubit>().logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    final chatIdController = TextEditingController();
    showDialog<void>(
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
              decoration: InputDecoration(
                hintText: 'Chat ID',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
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
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Profile Section
          _buildCard(
            context,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 28,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: user?.photoUrl != null
                      ? NetworkImage(user!.photoUrl!)
                      : null,
                  child: user?.photoUrl == null
                      ? Icon(
                          Icons.person,
                          color: theme.colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                title: Text(
                  user?.displayName ?? 'User Name',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  user?.email ?? 'Online',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(
                  Icons.edit,
                  color: theme.colorScheme.primary,
                ),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
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
          const SizedBox(height: 8),

          // Call History
          _buildCard(
            context,
            children: [
              _buildSectionHeader(context, 'Call History'),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                title: const Text('Call Logs'),
                subtitle: const Text('View your call history'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onTap: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
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
          const SizedBox(height: 8),

          // Appearance Section
          _buildCard(
            context,
            children: [
              _buildSectionHeader(context, 'Appearance'),
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.indigo.withValues(alpha: 0.2)
                        : Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: isDarkMode ? Colors.indigo : Colors.amber,
                  ),
                ),
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle dark theme'),
                value: isDarkMode,
                onChanged: (_) => themeCubit.toggleTheme(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Security Section
          _buildCard(
            context,
            children: [
              _buildSectionHeader(context, AppStrings.security),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.lock,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
                title: const Text(AppStrings.encryptionKey),
                subtitle: const Text('End-to-end encrypted'),
                trailing: Icon(
                  Icons.verified,
                  color: theme.colorScheme.primary,
                ),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Notifications
          _buildCard(
            context,
            children: [
              _buildSectionHeader(context, AppStrings.notifications),
              SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications, color: Colors.blue),
                ),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive message alerts'),
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Data Management
          _buildCard(
            context,
            children: [
              _buildSectionHeader(context, 'Data'),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_sweep, color: AppColors.error),
                ),
                title: const Text('Clear Chat'),
                subtitle: const Text('Delete all messages in a chat'),
                onTap: () => _showClearChatDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Updates Section
          _buildCard(
            context,
            children: [
              _buildSectionHeader(context, 'Updates'),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.system_update, color: Colors.teal),
                ),
                title: const Text(AppStrings.checkForUpdates),
                subtitle: const Text('Version 1.0.0'),
                trailing: Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
          const SizedBox(height: 8),

          // About
          _buildCard(
            context,
            children: [
              _buildSectionHeader(context, AppStrings.about),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                title: const Text(AppStrings.appName),
                subtitle: const Text('Version 1.0.0'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _showLogoutConfirmation(context),
                icon: const Icon(Icons.logout),
                label: const Text(AppStrings.logout),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}