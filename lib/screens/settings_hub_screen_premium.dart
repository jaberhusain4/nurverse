import 'package:flutter/material.dart';

import 'canonical_settings_screen.dart';

/// Backward-compatible entry point.
/// Premium and all regular settings are handled by the canonical screen.
class SettingsHubScreenPremium extends StatelessWidget {
  const SettingsHubScreenPremium({super.key});

  @override
  Widget build(BuildContext context) {
    return const CanonicalSettingsScreen();
  }
}
