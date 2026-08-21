import 'package:flutter/material.dart';

import 'home_mode_settings_screen.dart';
import 'more_screen.dart';

class MoreScreenWithHomeShortcut extends StatelessWidget {
  const MoreScreenWithHomeShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        const MoreScreen(),
        Positioned(
          top: top + 7,
          right: 12,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HomeModeSettingsScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: .16),
                  ),
                ),
                child: Icon(
                  Icons.dashboard_customize_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
