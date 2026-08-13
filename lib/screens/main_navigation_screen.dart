import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'auth/google_login_screen.dart';
import 'home_screen.dart';
import 'prayer_screen.dart';
import 'quran_screen.dart';
import 'hadith_screen.dart';
import 'tools_screen.dart';
import 'more_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  SettingsProvider? _settingsProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final SettingsProvider settings = context.read<SettingsProvider>();

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
    final PrayerController prayerController = context.read<PrayerController>();

    prayerController.updateCalculationSettings(
      calculationMethod: settings.calculationMethod,
      madhhab: settings.madhhab,
    );

    prayerController.updatePrayerAdjustments(settings.prayerAdjustments);
  }

  void _onNavigateTab(int index) {
    if (index < 0 || index > 5) return;
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  Future<void> _openLogin() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const GoogleLoginScreen(),
      ),
    );
  }

  Widget _withAccountButton(Widget child, {required bool home}) {
    return Stack(
      children: [
        child,
        Positioned(
          top: home ? 8 : 4,
          right: 8,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                tooltip: 'Login',
                onPressed: _openLogin,
                icon: const Icon(Icons.account_circle_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final bool isBangla = settings.isBangla;

    final List<Widget> screens = [
      // HomeScreen already owns its notification and account controls.
      // Do NOT wrap it in a Stack with another account button, otherwise
      // a second icon remains fixed above the scrolling header.
      HomeScreen(onNavigateTab: _onNavigateTab),
      const PrayerScreen(),
      const QuranScreen(),
      const HadithScreen(),
      const ToolsScreen(),
      // Keep the Settings account entry for now; unlike Home, MoreScreen
      // does not currently render its own account control.
      _withAccountButton(const MoreScreen(), home: false),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
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
              label: isBangla ? 'হোম' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.mosque_outlined),
              activeIcon: const Icon(Icons.mosque),
              label: isBangla ? 'সালাত' : 'Prayer',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book),
              label: isBangla ? 'কুরআন' : 'Quran',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_stories_outlined),
              activeIcon: const Icon(Icons.auto_stories),
              label: isBangla ? 'হাদিস' : 'Hadith',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined),
              activeIcon: const Icon(Icons.grid_view),
              label: isBangla ? 'টুলস' : 'Tools',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.more_horiz_outlined),
              activeIcon: const Icon(Icons.more_horiz),
              label: isBangla ? 'আরও' : 'More',
            ),
          ],
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
