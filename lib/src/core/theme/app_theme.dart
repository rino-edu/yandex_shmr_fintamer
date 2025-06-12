import 'package:flutter/material.dart';
import 'package:fintamer/src/core/constants/app_constants.dart';

abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.white,
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
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
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
    );
  }
}
