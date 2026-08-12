import 'package:flutter/material.dart';

import '../main_navigation_screen.dart';

/// NurVerse is usable without an account.
/// Authentication is an optional action opened from Home/Settings.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}
