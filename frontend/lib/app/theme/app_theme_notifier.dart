import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý ThemeMode toàn app, lưu preference vào SharedPreferences.
/// Inject vào MaterialApp qua ListenableBuilder.
class AppThemeNotifier extends ChangeNotifier {
  AppThemeNotifier._();

  static final AppThemeNotifier instance = AppThemeNotifier._();

  static const _key = 'stayz_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  bool get isDarkRaw => _mode == ThemeMode.dark;

  bool isDark(BuildContext context) {
    if (_mode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _mode == ThemeMode.dark;
  }

  /// Gọi một lần khi app khởi động, trước runApp.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    _mode = switch (stored) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    // Không notifyListeners — chưa có listener nào vào thời điểm này.
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      switch (mode) {
        ThemeMode.dark => 'dark',
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
      },
    );
    notifyListeners();
  }

  Future<void> toggle(BuildContext context) async {
    final currentlyDark = isDark(context);
    await setMode(currentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}
