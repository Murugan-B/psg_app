import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Palette mapped directly from React Native constants/index.js
  static const Color primary = Color(0xFF2D2F8E);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  
  static const Color text = Color(0xFF1E293B);
  static const Color muted = Color(0xFF64748B);
  
  static const Color background = Color(0xFFF5F6FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  // Additional variants extracted from styling analysis
  static const Color primaryDark = Color(0xFF1A1C6B);
  static const Color primaryLight = Color(0xFFE8EAF6);
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // Status Colors (specifically mapped for Attendance/Stock)
  static const Color statusPresent = success;
  static const Color statusLate = warning;
  static const Color statusAbsent = danger;
  
  static const Color transparent = Colors.transparent;
}
