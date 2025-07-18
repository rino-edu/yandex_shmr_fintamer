import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData lightTheme(Color primaryColor) => ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: AppColors.lightScaffoldBackground,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.primaryColor,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: AppDimensions.navigationBarHeight,
      backgroundColor: AppColors.surfaceContainer,
      indicatorColor: AppColors.secondaryColor,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final style = const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        );
        if (states.contains(WidgetState.selected)) {
          return style.copyWith(
            color: AppColors.selectedNavText,
            fontWeight: FontWeight.w700,
          );
        }
        return style.copyWith(color: AppColors.unselectedNavIcon);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryColor);
        }
        return const IconThemeData(color: AppColors.unselectedNavIcon);
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade300;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade400;
      }),
    ),
  );

  static ThemeData darkTheme(Color primaryColor) => ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: AppColors.darkScaffoldBackground,
    brightness: Brightness.dark,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.grey[900],
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: AppDimensions.navigationBarHeight,
      backgroundColor: AppColors.darkSurfaceContainer,
      indicatorColor: AppColors.secondaryColor.withOpacity(0.8),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final style = const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        );
        if (states.contains(WidgetState.selected)) {
          return style.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
          );
        }
        return style.copyWith(color: AppColors.darkUnselectedNavIcon);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primaryColor);
        }
        return const IconThemeData(color: AppColors.darkUnselectedNavIcon);
      }),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.grey.shade700;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withOpacity(0.5);
        }
        return Colors.grey.shade800;
      }),
    ),
  );
}
