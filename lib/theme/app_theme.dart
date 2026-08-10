// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

// ============================================================================
// APP COLORS
// ============================================================================

class AppColors {
  // ==========================================================================
  // BRAND
  // ==========================================================================

  static const Color seaBlue = Color(0xFF0EA5E9);
  static const Color seaBlueDark = Color(0xFF0284C7);
  static const Color softAqua = Color(0xFF7DD3FC);

  // ==========================================================================
  // LIGHT THEME
  // ==========================================================================

  static const Color backgroundLight = Color(0xFFF4F8FC);
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0x140EA5E9);

  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  // ==========================================================================
  // DARK THEME
  // ==========================================================================

  static const Color backgroundDark = Color(0xFF07141F);
  static const Color cardDark = Color(0xFF112535);
  static const Color borderDark = Color(0x220EA5E9);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB8C7D6);

  // ==========================================================================
  // AMOLED
  // ==========================================================================

  static const Color amoledBackground = Colors.black;

  // Slightly lifted surface so cards remain visible on pure black.
  static const Color amoledCard = Color(0xFF0B0B0B);

  static const Color amoledBorder = Color(0x220EA5E9);

  // ==========================================================================
  // COMMON
  // ==========================================================================

  static const Color primary = seaBlue;

  static const Color textPrimary = textPrimaryLight;

  static const Color textSecondary = textSecondaryDark;

  static const Color card = cardLight;

  static const Color warning = Color(0xFFF59E0B);

  static const Color success = Color(0xFF16A34A);

  static const Color error = Color(0xFFEF4444);
}

// ============================================================================
// APP RADIUS
// ============================================================================

class AppRadius {
  static const double card = 20.0;
  static const double button = 16.0;
  static const double dialog = 24.0;
  static const double sheet = 30.0;
}

// ============================================================================
// APP SPACING
// ============================================================================

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

// ============================================================================
// THEME CONTEXT EXTENSIONS
// ============================================================================

extension ThemeBuildContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  bool get isAmoled {
    final theme = Theme.of(this);

    return theme.scaffoldBackgroundColor == AppColors.amoledBackground;
  }

  Color get cardColor {
    if (isAmoled) {
      return AppColors.amoledCard;
    }

    return isDark ? AppColors.cardDark : AppColors.cardLight;
  }

  Color get borderColor {
    if (isAmoled) {
      return AppColors.amoledBorder;
    }

    return isDark ? AppColors.borderDark : AppColors.borderLight;
  }

  Color get primaryTextColor {
    return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  }

  Color get secondaryTextColor {
    return isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
  }
}

// ============================================================================
// APP THEME
// ============================================================================

class AppTheme {
  // ==========================================================================
  // SHARED TEXT THEME
  // ==========================================================================

  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimaryLight),
    displayMedium: TextStyle(color: AppColors.textPrimaryLight),
    displaySmall: TextStyle(color: AppColors.textPrimaryLight),
    headlineLarge: TextStyle(color: AppColors.textPrimaryLight),
    headlineMedium: TextStyle(color: AppColors.textPrimaryLight),
    headlineSmall: TextStyle(color: AppColors.textPrimaryLight),
    titleLarge: TextStyle(color: AppColors.textPrimaryLight),
    titleMedium: TextStyle(color: AppColors.textPrimaryLight),
    titleSmall: TextStyle(color: AppColors.textPrimaryLight),
    bodyLarge: TextStyle(color: AppColors.textPrimaryLight),
    bodyMedium: TextStyle(color: AppColors.textPrimaryLight),
    bodySmall: TextStyle(color: AppColors.textSecondaryLight),
    labelLarge: TextStyle(color: AppColors.textPrimaryLight),
    labelMedium: TextStyle(color: AppColors.textPrimaryLight),
    labelSmall: TextStyle(color: AppColors.textSecondaryLight),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimaryDark),
    displayMedium: TextStyle(color: AppColors.textPrimaryDark),
    displaySmall: TextStyle(color: AppColors.textPrimaryDark),
    headlineLarge: TextStyle(color: AppColors.textPrimaryDark),
    headlineMedium: TextStyle(color: AppColors.textPrimaryDark),
    headlineSmall: TextStyle(color: AppColors.textPrimaryDark),
    titleLarge: TextStyle(color: AppColors.textPrimaryDark),
    titleMedium: TextStyle(color: AppColors.textPrimaryDark),
    titleSmall: TextStyle(color: AppColors.textPrimaryDark),
    bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
    bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
    bodySmall: TextStyle(color: AppColors.textSecondaryDark),
    labelLarge: TextStyle(color: AppColors.textPrimaryDark),
    labelMedium: TextStyle(color: AppColors.textPrimaryDark),
    labelSmall: TextStyle(color: AppColors.textSecondaryDark),
  );

  // ==========================================================================
  // LIGHT THEME
  // ==========================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.light,

      primaryColor: AppColors.seaBlueDark,

      scaffoldBackgroundColor: AppColors.backgroundLight,

      colorScheme: const ColorScheme.light(
        primary: AppColors.seaBlueDark,
        secondary: AppColors.seaBlue,
        surface: AppColors.cardLight,
        error: AppColors.error,
      ),

      fontFamily: 'Noto Sans Bengali',

      textTheme: _lightTextTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryLight),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardLight,
        selectedItemColor: AppColors.seaBlueDark,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(
            color: AppColors.seaBlueDark,
            width: 1.5,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimaryLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ==========================================================================
  // DARK THEME
  // ==========================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      primaryColor: AppColors.seaBlue,

      scaffoldBackgroundColor: AppColors.backgroundDark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.seaBlue,
        secondary: AppColors.softAqua,
        surface: AppColors.cardDark,
        error: AppColors.error,
      ),

      fontFamily: 'Noto Sans Bengali',

      textTheme: _darkTextTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.borderDark,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.seaBlue,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.seaBlue, width: 1.5),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cardDark,
        contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ==========================================================================
  // AMOLED THEME
  // ==========================================================================

  static ThemeData get amoledTheme {
    return ThemeData(
      useMaterial3: true,

      brightness: Brightness.dark,

      primaryColor: AppColors.seaBlue,

      scaffoldBackgroundColor: AppColors.amoledBackground,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.seaBlue,
        secondary: AppColors.softAqua,
        surface: AppColors.amoledCard,
        error: AppColors.error,
      ),

      fontFamily: 'Noto Sans Bengali',

      textTheme: _darkTextTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.amoledBackground,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimaryDark),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.amoledCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.amoledBorder, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.amoledBorder,
        thickness: 1,
        space: 1,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.amoledBackground,
        selectedItemColor: AppColors.seaBlue,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.amoledCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.amoledBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.amoledBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: const BorderSide(color: AppColors.seaBlue, width: 1.5),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.amoledCard,
        contentTextStyle: const TextStyle(color: AppColors.textPrimaryDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
