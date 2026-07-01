import 'package:flutter/material.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/core/constants/app_strings.dart';

/// Settings page with OTA update foundation and profile management.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                  child: const Icon(
                    Icons.person,
                    color: AppColors.textOnPrimary,
                  ),
                ),
                title: const Text('User Name'),
                subtitle: const Text('Online'),
                trailing: const Icon(Icons.edit),
                onTap: () {},
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

          // OTA Update Section (Foundation for Shorebird/Firebase Remote Config)
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