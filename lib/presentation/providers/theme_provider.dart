import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme State
class ThemeState {
  final ThemeMode themeMode;
  final bool useSystemTheme;

  ThemeState({
    this.themeMode = ThemeMode.light,
    this.useSystemTheme = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? useSystemTheme,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
    );
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;
}

/// Theme Notifier
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _themeModeKey = 'theme_mode';
  static const String _useSystemThemeKey = 'use_system_theme';

  ThemeNotifier() : super(ThemeState()) {
    _loadThemePreference();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final useSystemTheme = prefs.getBool(_useSystemThemeKey) ?? false;

      if (useSystemTheme) {
        state = state.copyWith(
          useSystemTheme: true,
          themeMode: ThemeMode.system,
        );
      } else {
        final themeModeString = prefs.getString(_themeModeKey) ?? 'light';
        final themeMode = _stringToThemeMode(themeModeString);
        state = state.copyWith(
          themeMode: themeMode,
          useSystemTheme: false,
        );
      }
    } catch (e) {
      // If loading fails, keep default light theme
      state = ThemeState();
    }
  }

  /// Set theme mode (light/dark)
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeModeToString(mode));
      await prefs.setBool(_useSystemThemeKey, false);

      state = state.copyWith(
        themeMode: mode,
        useSystemTheme: false,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Enable system theme mode
  Future<void> enableSystemTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useSystemThemeKey, true);

      state = state.copyWith(
        useSystemTheme: true,
        themeMode: ThemeMode.system,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  /// Disable system theme mode and set manual mode
  Future<void> disableSystemTheme(ThemeMode manualMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_useSystemThemeKey, false);
      await prefs.setString(_themeModeKey, _themeModeToString(manualMode));

      state = state.copyWith(
        useSystemTheme: false,
        themeMode: manualMode,
      );
    } catch (e) {
      // Handle error silently
    }
  }

  /// Convert ThemeMode to string for storage
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }
}

/// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
