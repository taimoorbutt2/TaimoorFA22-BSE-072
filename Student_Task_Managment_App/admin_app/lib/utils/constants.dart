
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF3B00FF); // Neon Indigo
  static const accent = Color(0xFFFF2E63); // Neon Coral
  static const background = Color(0xFF1A1A2E); // Dark Neon Gray
  static const border = Color(0xFF4A4E69); // Neon Gray
  static const inputBackground = Color(0xFF4A4E69); // Neon Gray
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF040222), Color(0xFF17146C)], // Blue to Cyan
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFF1976D2)], // White to Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStrings {
  static const appName = 'Admin Task';
  static const dashboardTitle = 'Admin Dashboard';
}
