import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeBox = 'theme_settings';
  static const String _darkModeKey = 'isDarkMode';

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    useMaterial3: true,
    cardColor: Colors.white,
    scaffoldBackgroundColor: Colors.blue.shade50,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black87),
      titleMedium: TextStyle(color: Colors.black87),
      bodySmall: TextStyle(color: Colors.black54),
      labelSmall: TextStyle(color: Colors.white),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.blueGrey,
    brightness: Brightness.dark,
    useMaterial3: true,
    cardColor: Colors.blueGrey.shade800,
    scaffoldBackgroundColor: Colors.blueGrey.shade900,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blueGrey.shade800,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      labelSmall: TextStyle(color: Colors.white),
    ),
  );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    var box = await Hive.openBox(_themeBox);
    _isDarkMode = box.get(_darkModeKey, defaultValue: false);
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    var box = await Hive.openBox(_themeBox);
    await box.put(_darkModeKey, _isDarkMode);
  }
}