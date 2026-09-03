import 'package:flutter/material.dart';

import 'canonical_settings_screen.dart';

/// Backward-compatible entry point for older imports.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CanonicalSettingsScreen();
  }
}
