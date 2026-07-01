/// Centralized spacing and dimension constants for consistent UI.
abstract class AppDimensions {
  AppDimensions._(); // Private constructor to prevent instantiation

  // --- Padding ---
  static const double paddingXXS = 4;
  static const double paddingXS = 8;
  static const double paddingS = 12;
  static const double paddingM = 16;
  static const double paddingL = 20;
  static const double paddingXL = 24;
  static const double paddingXXL = 32;
  static const double paddingXXXL = 48;

  // --- Margin ---
  static const double marginXS = 4;
  static const double marginS = 8;
  static const double marginM = 12;
  static const double marginL = 16;
  static const double marginXL = 24;

  // --- Border Radius ---
  static const double radiusXS = 4;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusRound = 999;

  // --- Icon Sizes ---
  static const double iconXS = 16;
  static const double iconS = 20;
  static const double iconM = 24;
  static const double iconL = 28;
  static const double iconXL = 32;
  static const double iconXXL = 40;

  // --- Avatar Sizes ---
  static const double avatarXS = 24;
  static const double avatarS = 32;
  static const double avatarM = 40;
  static const double avatarL = 48;
  static const double avatarXL = 56;
  static const double avatarXXL = 80;

  // --- Button Sizes ---
  static const double buttonHeight = 48;
  static const double buttonHeightL = 56;
  static const double buttonMinWidth = 120;

  // --- Input Fields ---
  static const double inputHeight = 48;
  static const double inputBorderWidth = 1.5;

  // --- Chat UI ---
  static const double chatBubbleMaxWidth = 0.75;
  static const double chatInputMinHeight = 48;
  static const double chatInputMaxHeight = 120;
  static const double voiceNoteHeight = 40;

  // --- App Bar ---
  static const double appBarHeight = 56;
  static const double appBarHeightCollapsed = 48;

  // --- Bottom Sheet ---
  static const double bottomSheetRadius = 20;

  // --- Dividers ---
  static const double dividerThickness = 0.5;

  // --- Shadows ---
  static const double shadowElevationS = 1;
  static const double shadowElevationM = 3;
  static const double shadowElevationL = 8;

  // --- Animations ---
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationPageTransition = Duration(milliseconds: 300);
}