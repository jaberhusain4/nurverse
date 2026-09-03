import 'package:flutter/material.dart';

import '../unified_settings_screen.dart';

/// Backward-compatible entry point.
/// The actual Settings UI lives in UnifiedSettingsScreen so there is only one
/// settings implementation in the app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedSettingsScreen();
  }
}
