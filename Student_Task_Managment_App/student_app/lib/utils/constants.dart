import 'package:flutter/material.dart';

class AppColors {
  static const primary = Colors.teal;
  static const accent = Color(0xFFFF6F61); // Coral
  static const background = Color(0xFFF5F7FA); // Light gray
  static const border = Color(0xFFD1D5DB); // Gray border
  static const inputBackground = Color(0xFFEFF3F6); // Light input background
  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F06F4), Color(0xFF07FBE0)], // Blue to Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)], // Pink to Orange
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

}

class AppStrings {
  static const appName = 'Student Task Tracker';
  static const homeTagline = 'Stay on Top of Your Tasks!';
  static const homeDescription =
      'Track your assignments, monitor your progress, and earn streaks for completing tasks on time.';
}