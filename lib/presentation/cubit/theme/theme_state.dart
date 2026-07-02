import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// States for the theme cubit.
sealed class ThemeState extends Equatable {
  const ThemeState({required this.themeData});

  final ThemeData themeData;

  @override
  List<Object?> get props => [themeData];
}

/// Light theme state.
final class LightTheme extends ThemeState {
  const LightTheme({required super.themeData});
}

/// Dark theme state.
final class DarkThemeState extends ThemeState {
  const DarkThemeState({required super.themeData});
}