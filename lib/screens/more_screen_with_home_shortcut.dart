import 'package:flutter/material.dart';

import 'settings_hub_screen_v4.dart';

/// Canonical Settings entry point kept for legacy navigation references.
/// The active Settings implementation is SettingsHubScreenV4.
class MoreScreenWithHomeShortcut extends StatelessWidget {
  const MoreScreenWithHomeShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsHubScreenV4();
  }
}
