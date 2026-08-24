import 'package:flutter/material.dart';

import 'settings_hub_screen_v4.dart';

/// Canonical Settings entry point kept for legacy navigation references.
/// The old overlay Home Screen shortcut is intentionally removed so that
/// Settings owns the Home Screen option in exactly one place.
class MoreScreenWithHomeShortcut extends StatelessWidget {
  const MoreScreenWithHomeShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsHubScreenV4();
  }
}
