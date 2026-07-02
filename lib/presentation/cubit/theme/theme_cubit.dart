import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:our_chat/core/theme/app_theme.dart';
import 'package:our_chat/presentation/cubit/theme/theme_state.dart';

/// Cubit for managing the application theme (Light/Dark).
///
/// Persists the theme choice using SharedPreferences.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(LightTheme(themeData: AppTheme.lightTheme)) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';
  static const String _lightValue = 'light';
  static const String _darkValue = 'dark';

  /// Loads the saved theme from SharedPreferences.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == _darkValue) {
      emit(DarkThemeState(themeData: AppTheme.darkTheme));
    } else {
      emit(LightTheme(themeData: AppTheme.lightTheme));
    }
  }

  /// Toggles between light and dark theme.
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (state is LightTheme) {
      await prefs.setString(_themeKey, _darkValue);
      emit(DarkThemeState(themeData: AppTheme.darkTheme));
    } else {
      await prefs.setString(_themeKey, _lightValue);
      emit(LightTheme(themeData: AppTheme.lightTheme));
    }
  }

  /// Sets the theme to a specific mode.
  Future<void> setTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();

    if (isDark) {
      await prefs.setString(_themeKey, _darkValue);
      emit(DarkThemeState(themeData: AppTheme.darkTheme));
    } else {
      await prefs.setString(_themeKey, _lightValue);
      emit(LightTheme(themeData: AppTheme.lightTheme));
    }
  }

  /// Returns whether the current theme is dark.
  bool get isDarkMode => state is DarkThemeState;
}