import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'dua_screen.dart';
import 'home_screen.dart';
import 'prayer_screen.dart';
import 'quran_screen.dart';
import 'settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String? _lastLanguageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    if (_lastLanguageCode != languageCode) {
      _lastLanguageCode = languageCode;
    }

    final pages = <Widget>[
      HomeScreen(key: ValueKey('home-$languageCode')),
      PrayerScreen(key: ValueKey('prayer-$languageCode')),
      QuranScreen(key: ValueKey('quran-$languageCode')),
      DuaScreen(key: ValueKey('dua-$languageCode')),
      SettingsScreen(key: ValueKey('settings-$languageCode')),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        height: 72,
        elevation: 3,
        selectedIndex: _selectedIndex,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        animationDuration: const Duration(milliseconds: 300),
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.mosque_outlined),
            selectedIcon: const Icon(Icons.mosque_rounded),
            label: l10n.prayer,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: l10n.quran,
          ),
          NavigationDestination(
            icon: const Icon(Icons.volunteer_activism_outlined),
            selectedIcon: const Icon(Icons.volunteer_activism_rounded),
            label: l10n.dua,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}