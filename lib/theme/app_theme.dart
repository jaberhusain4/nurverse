// lib/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppColors {
  static const Color seaBlue = Color(0xFF0EA5E9);
  static const Color seaBlueDark = Color(0xFF0284C7);
  static const Color softAqua = Color(0xFF7DD3FC);

  static const Color backgroundLight = Color(0xFFF4F8FC);
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0x140EA5E9);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);

  static const Color backgroundDark = Color(0xFF07141F);
  static const Color cardDark = Color(0xFF112535);
  static const Color borderDark = Color(0x220EA5E9);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB8C7D6);

  static const Color amoledBackground = Colors.black;
  static const Color amoledCard = Color(0xFF0B0B0B);
  static const Color amoledBorder = Color(0x220EA5E9);

  static const Color primary = seaBlue;
  static const Color textPrimary = textPrimaryLight;
  static const Color textSecondary = textSecondaryDark;
  static const Color card = cardLight;
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFEF4444);
}

class AppRadius {
  static const double card = 20.0;
  static const double button = 16.0;
  static const double dialog = 24.0;
  static const double sheet = 30.0;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

extension ThemeBuildContext on BuildContext {
  ThemeData get appTheme => Theme.of(this);

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  bool get isAmoled =>
      Theme.of(this).scaffoldBackgroundColor == AppColors.amoledBackground;

  Color get cardColor {
    if (isAmoled) return AppColors.amoledCard;
    return isDark ? AppColors.cardDark : AppColors.cardLight;
  }

  Color get borderColor {
    if (isAmoled) return AppColors.amoledBorder;
    return isDark ? AppColors.borderDark : AppColors.borderLight;
  }

  Color get primaryTextColor =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

  Color get secondaryTextColor =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
}

class AppTheme {
  // Locked NurVerse typography hierarchy.
  // Body = 16, secondary = 14, labels = 13/12.
  // Headers/titles are intentionally larger than body text.
  // TextScaleProvider applies the user's global scale to the whole app.
  // Quran Arabic/translation typography remains feature-specific.
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 32, height: 1.2, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: AppColors.textPrimaryLight, fontSize: 28, height: 1.2, fontWeight: FontWeight.w700),
    displaySmall: TextStyle(color: AppColors.textPrimaryLight, fontSize: 24, height: 1.25, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 24, height: 1.25, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: AppColors.textPrimaryLight, fontSize: 22, height: 1.3, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(color: AppColors.textPrimaryLight, fontSize: 20, height: 1.3, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 20, height: 1.3, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: AppColors.textPrimaryLight, fontSize: 18, height: 1.35, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16, height: 1.35, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(color: AppColors.textPrimaryLight, fontSize: 16, height: 1.5),
    bodySmall: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14, height: 1.45),
    labelLarge: TextStyle(color: AppColors.textPrimaryLight, fontSize: 14, height: 1.3, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(color: AppColors.textPrimaryLight, fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12, height: 1.3, fontWeight: FontWeight.w500),
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 32, height: 1.2, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 28, height: 1.2, fontWeight: FontWeight.w700),
    displaySmall: TextStyle(color: AppColors.textPrimaryDark, fontSize: 24, height: 1.25, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 24, height: 1.25, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 22, height: 1.3, fontWeight: FontWeight.w700),
    headlineSmall: TextStyle(color: AppColors.textPrimaryDark, fontSize: 20, height: 1.3, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 20, height: 1.3, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 18, height: 1.35, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, height: 1.35, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, height: 1.5),
    bodySmall: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14, height: 1.45),
    labelLarge: TextStyle(color: AppColors.textPrimaryDark, fontSize: 14, height: 1.3, fontWeight: FontWeight.w600),
    labelMedium: TextStyle(color: AppColors.textPrimaryDark, fontSize: 13, height: 1.3, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12, height: 1.3, fontWeight: FontWeight.w500),
  );

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color border,
    required Color primary,
    required Color secondary,
    required TextTheme textTheme,
    required Color textPrimary,
    required Color textSecondary,
    required Color appBarBackground,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
        secondary: secondary,
        onSecondary: brightness == Brightness.dark ? Colors.black : Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: card,
        onSurface: textPrimary,
      ),
      fontFamily: 'Noto Sans Bengali',
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 13,
        unselectedFontSize: 13,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: card,
        contentTextStyle: TextStyle(color: textPrimary, fontSize: 14, height: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData get lightTheme => _theme(
        brightness: Brightness.light,
        background: AppColors.backgroundLight,
        card: AppColors.cardLight,
        border: AppColors.borderLight,
        primary: AppColors.seaBlueDark,
        secondary: AppColors.seaBlue,
        textTheme: _lightTextTheme,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
        appBarBackground: AppColors.backgroundLight,
      );

  static ThemeData get darkTheme => _theme(
        brightness: Brightness.dark,
        background: AppColors.backgroundDark,
        card: AppColors.cardDark,
        border: AppColors.borderDark,
        primary: AppColors.seaBlue,
        secondary: AppColors.softAqua,
        textTheme: _darkTextTheme,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
        appBarBackground: AppColors.backgroundDark,
      );

  static ThemeData get amoledTheme => _theme(
        brightness: Brightness.dark,
        background: AppColors.amoledBackground,
        card: AppColors.amoledCard,
        border: AppColors.amoledBorder,
        primary: AppColors.seaBlue,
        secondary: AppColors.softAqua,
        textTheme: _darkTextTheme,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
        appBarBackground: AppColors.amoledBackground,
      );
}
