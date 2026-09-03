import 'package:flutter/material.dart';

import 'unified_settings_screen.dart';

/// Backward-compatible entry point.
/// All settings are rendered by the single canonical Settings screen.
class SettingsHubScreenV4 extends StatelessWidget {
  const SettingsHubScreenV4({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnifiedSettingsScreen();
  }
}
