import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isInitialized => _isInitialized;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode();
    notifyListeners();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'light';
    _themeMode = themeString == 'light' ? ThemeMode.light : ThemeMode.dark;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeMode == ThemeMode.light ? 'light' : 'dark');
  }
}
