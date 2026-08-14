import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/prayer_screen.dart';
import '../screens/quran_screen.dart';
import '../screens/hadith_screen.dart';
import '../screens/tools_screen.dart';
import '../screens/more_screen.dart';
import 'common/islamic_ornamental_background.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    PrayerScreen(),
    QuranScreen(),
    HadithScreen(),
    ToolsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: IslamicOrnamentalBackground(
          child: IndexedStack(
            key: ValueKey(_index),
            index: _index,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 72,
          elevation: 0,
          backgroundColor: dark ? theme.colorScheme.surface : Colors.white.withValues(alpha: .92),
          indicatorColor: AppColors.seaBlue.withValues(alpha: .18),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.seaBlue, size: 28);
            }
            return IconThemeData(
              color: dark ? Colors.white70 : Colors.grey.shade700,
              size: 24,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.seaBlue
                  : (dark ? Colors.white70 : Colors.grey.shade700),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) {
            setState(() => _index = value);
          },
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.mosque_outlined),
              selectedIcon: Icon(Icons.mosque_rounded),
              label: 'Prayer',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Quran',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Hadith',
            ),
            NavigationDestination(
              icon: Icon(Icons.handyman_outlined),
              selectedIcon: Icon(Icons.handyman_rounded),
              label: 'Tools',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_outlined),
              selectedIcon: Icon(Icons.menu_rounded),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}
