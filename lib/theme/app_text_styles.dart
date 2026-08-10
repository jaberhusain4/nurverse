import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppTextStyles {
  static TextStyle title(BuildContext context) {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: context.primaryTextColor,
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: context.primaryTextColor,
    );
  }

  static TextStyle cardTitle(BuildContext context) {
    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: context.primaryTextColor,
    );
  }

  static TextStyle body(BuildContext context) {
    return TextStyle(fontSize: 14, color: context.primaryTextColor);
  }

  static TextStyle subtitle(BuildContext context) {
    return TextStyle(fontSize: 13, color: context.secondaryTextColor);
  }

  static TextStyle caption(BuildContext context) {
    return TextStyle(fontSize: 11, color: context.secondaryTextColor);
  }

  static TextStyle prayerName(BuildContext context) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: context.primaryTextColor,
    );
  }

  static TextStyle prayerTime(BuildContext context) {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: context.primaryTextColor,
    );
  }
}
