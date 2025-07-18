import 'package:flutter/material.dart';

abstract class AppColors {
  // Main colors from Figma
  static const Color primaryColor = Color(0xFF2AE881);
  static const Color secondaryColor = Color(0xFFD4FAE6);
  static const Color surfaceContainer = Color(0xFFF3EDF7);
  static const Color selectedNavText = Color(0xFF1D1B20);
  static const Color unselectedNavIcon = Color(0xFF49454F);
  static const Color lightScaffoldBackground = Color(0xFFfef7ff);

  // Dark Theme (placeholders for now)
  static const Color darkScaffoldBackground = Color(0xFF1C1B1F);
  static const Color darkSurfaceContainer = Color(0xFF2B2930);
  static const Color darkUnselectedNavIcon = Color(0xFFCAC4D0);

  // General
  static const Color white = Colors.white;

  static const Color incomeColor = Colors.green;
  static const Color expenseColor = Colors.red;
}

abstract class AppDimensions {
  static const double mainHorizontalPadding = 8.0;
  static const double navigationBarHeight = 80.0;
  static const double scaffoldPadding = 16.0;
}
