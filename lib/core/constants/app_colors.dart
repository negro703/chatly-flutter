import 'package:flutter/material.dart';

/// Central color palette for the entire application.
/// Modern Baby Blue theme with a clean, fresh aesthetic.
abstract class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // --- Primary Palette (Baby Blue) ---
  static const Color primary = Color(0xFFA2C2E8);
  static const Color primaryLight = Color(0xFFB8D4F0);
  static const Color primaryDark = Color(0xFF7BA8D4);

  // --- Accent ---
  static const Color accent = Color(0xFF81C784);
  static const Color accentLight = Color(0xFFA5D6A7);

  // --- Surface & Background ---
  static const Color background = Color(0xFFF0F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A237E);

  // --- Text ---
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF5C6BC0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF9FA8DA);

  // --- Chat Bubbles ---
  static const Color bubbleSent = Color(0xFFA2C2E8);
  static const Color bubbleReceived = Color(0xFFFFFFFF);

  // --- Status & Feedback ---
  static const Color success = Color(0xFF81C784);
  static const Color error = Color(0xFFE57373);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF64B5F6);

  // --- UI Elements ---
  static const Color divider = Color(0xFFE8EAF6);
  static const Color appBar = Color(0xFFA2C2E8);
  static const Color onlineIndicator = Color(0xFF81C784);
  static const Color offlineIndicator = Color(0xFFBDBDBD);

  // --- Gradients ---
  static const List<Color> primaryGradient = [
    Color(0xFFA2C2E8),
    Color(0xFFB8D4F0),
  ];

  static const List<Color> chatBackgroundGradient = [
    Color(0xFFF0F4F8),
    Color(0xFFE8EAF6),
  ];
}
