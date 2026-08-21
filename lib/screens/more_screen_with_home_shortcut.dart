import 'package:flutter/material.dart';

import 'home_mode_settings_screen.dart';
import 'more_screen.dart';

class MoreScreenWithHomeShortcut extends StatelessWidget {
  const MoreScreenWithHomeShortcut({super.key});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final primary = Theme.of(context).colorScheme.primary;

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
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primary.withValues(alpha: .16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard_customize_rounded, size: 18, color: primary),
                    const SizedBox(width: 6),
                    Text(
                      isEnglish ? 'Home Screen' : 'হোম স্ক্রিন',
                      style: TextStyle(
                        color: primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
