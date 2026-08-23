import 'package:flutter/material.dart';

import 'settings_hub_screen.dart';

/// Backward-compatible entry point for older navigation references.
/// The canonical Settings UI lives in [SettingsHubScreen].
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsHubScreen();
  }
}
