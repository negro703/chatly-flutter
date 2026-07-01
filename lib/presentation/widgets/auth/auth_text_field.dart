import 'package:flutter/material.dart';

import 'package:our_chat/core/constants/app_colors.dart';

/// Reusable authentication text field with validation and icon support.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    super.key,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final VoidCallback? onFieldSubmitted;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onFieldSubmitted: (_) => onFieldSubmitted?.call(),
      textInputAction: textInputAction,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }
}
