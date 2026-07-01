import 'package:flutter/material.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/core/constants/app_dimensions.dart';
import 'package:our_chat/core/constants/app_strings.dart';

/// Chat input bar with text field and send button.
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    required this.controller,
    required this.onSend,
    super.key,
    this.onAttach,
    this.hintText = AppStrings.typeMessage,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback? onAttach;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (onAttach != null)
              IconButton(
                icon: const Icon(Icons.attach_file),
                color: AppColors.textSecondary,
                onPressed: onAttach,
              ),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.divider,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.accent,
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.textOnPrimary),
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
