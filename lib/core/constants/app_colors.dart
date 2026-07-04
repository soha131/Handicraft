import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Terracotta / Clay colors
  static const Color primary = Color(0xFFC86B45);
  static const Color primaryLight = Color(0xFFE59C7D);
  static const Color primaryDark = Color(0xFF9E4B28);

  // Secondary Sage Green colors
  static const Color secondary = Color(0xFF5F7A61);
  static const Color secondaryLight = Color(0xFF8FA892);
  static const Color secondaryDark = Color(0xFF3B4E3C);

  // Accent Gold / Mustard
  static const Color accent = Color(0xFFDDB05B);

  // Background colors
  static const Color bgLight = Color(0xFFFAF6F0);
  static const Color bgDark = Color(0xFF161819);

  // Surface colors
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF222527);

  // Text colors
  static const Color textMainLight = Color(0xFF2D2E2E);
  static const Color textSubLight = Color(0xFF757575);
  static const Color textMainDark = Color(0xFFE0E0E0);
  static const Color textSubDark = Color(0xFF9E9E9E);

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFD88965)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient artisanGradient = LinearGradient(
    colors: [primary, Color(0xFFE09A5F), Color(0xFFDDB05B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
