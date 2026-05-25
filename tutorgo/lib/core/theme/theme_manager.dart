import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);

    if (saved != null) {
      _themeMode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } else {
      // 👇 First install → system theme follow
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    await prefs.setString(_themeKey, value ? 'dark' : 'light');

    notifyListeners();
  }
}
