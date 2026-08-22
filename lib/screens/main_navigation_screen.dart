import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../localization/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'home_switcher_screen.dart';
import 'more_screen_with_home_shortcut.dart';
import 'prayer_screen_v2.dart';
import 'localized_hadith_screen.dart';
import 'quran_screen.dart';
import 'tools_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  int _homeRefreshId = 0;
  SettingsProvider? _settingsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.read<SettingsProvider>();
    if (_settingsProvider != settings) {
      _settingsProvider?.removeListener(_onSettingsChanged);
      _settingsProvider = settings;
      _settingsProvider!.addListener(_onSettingsChanged);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _settingsProvider != settings) return;
        _syncPrayerSettings(settings);
      });
    }
  }

  void _onSettingsChanged() {
    if (!mounted || _settingsProvider == null) return;
    _syncPrayerSettings(_settingsProvider!);
  }

  void _syncPrayerSettings(SettingsProvider settings) {
    final prayerController = context.read<PrayerController>();
    prayerController.updateCalculationSettings(
      calculationMethod: settings.calculationMethod,
      madhhab: settings.madhhab,
    );
    prayerController.updatePrayerAdjustments(settings.prayerAdjustments);
  }

  void _onNavigateTab(int index) {
    if (index < 0 || index > 5 || _selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _handleSystemBack() {
    if (!mounted) return;

    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return;
    }

    setState(() => _homeRefreshId++);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final screens = <Widget>[
      HomeSwitcherScreen(
        key: ValueKey<int>(_homeRefreshId),
        onNavigateTab: _onNavigateTab,
      ),
      const PrayerScreenV2(),
      const QuranScreen(),
      const LocalizedHadithScreen(),
      const ToolsScreen(),
      const MoreScreenWithHomeShortcut(),
    ];

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            border: Border(
              top: BorderSide(color: context.borderColor, width: 0.5),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavigateTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: context.cardColor,
            selectedItemColor: AppColors.seaBlue,
            unselectedItemColor: context.secondaryTextColor,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: l10n.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.mosque_outlined),
                activeIcon: const Icon(Icons.mosque),
                label: l10n.prayer,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu_book_outlined),
                activeIcon: const Icon(Icons.menu_book),
                label: l10n.quran,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.auto_stories_outlined),
                activeIcon: const Icon(Icons.auto_stories),
                label: l10n.hadith,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.grid_view_outlined),
                activeIcon: const Icon(Icons.grid_view),
                label: l10n.tools,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.more_horiz_outlined),
                activeIcon: const Icon(Icons.more_horiz),
                label: l10n.more,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _settingsProvider?.removeListener(_onSettingsChanged);
    _settingsProvider = null;
    super.dispose();
  }
}
