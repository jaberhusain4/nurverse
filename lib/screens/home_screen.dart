import 'package:flutter/material.dart';

import 'simple_home_screen_v10.dart';

/// Canonical Home Screen entry point.
///
/// Keeps the public HomeScreen API stable for MainNavigation/MainShell while
/// delegating the actual UI to the latest complete Simple Home implementation.
class HomeScreen extends SimpleHomeScreenV10 {
  const HomeScreen({super.key, super.onNavigateTab});
}
