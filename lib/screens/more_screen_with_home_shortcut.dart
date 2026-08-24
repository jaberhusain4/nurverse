import 'package:flutter/material.dart';

import 'settings_hub_screen_premium.dart';

/// Canonical Settings entry point kept for legacy navigation references.
/// The Settings screen owns the single Home Screen option and the Premium hero.
class MoreScreenWithHomeShortcut extends StatelessWidget {
  const MoreScreenWithHomeShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsHubScreenPremium();
  }
}
