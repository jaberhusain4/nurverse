// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Localization
import 'localization/app_localizations.dart';

// Theme
import 'theme/app_theme.dart';

// Providers
import 'providers/settings_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/text_scale_provider.dart';

// Controllers
import 'controllers/prayer_controller.dart';

// Services
import 'services/audio_service.dart';
import 'services/notification_service.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/more_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // FIREBASE
  // ============================================================

  await Firebase.initializeApp();

  // ============================================================
  // DATE LOCALIZATION
  // ============================================================

  await initializeDateFormatting('en');
  await initializeDateFormatting('bn');

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  await NotificationService().init();

  // ============================================================
  // APP
  // ============================================================

  runApp(
    MultiProvider(
      providers: [
        // --------------------------------------------------------
        // SETTINGS
        // --------------------------------------------------------
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),

        // --------------------------------------------------------
        // GLOBAL TEXT SIZE
        // --------------------------------------------------------
        ChangeNotifierProvider<TextScaleProvider>(
          create: (_) => TextScaleProvider(),
        ),

        // --------------------------------------------------------
        // PREMIUM
        // --------------------------------------------------------
        ChangeNotifierProvider<PremiumProvider>(
          create: (_) => PremiumProvider()..checkPremiumStatus(),
        ),

        // --------------------------------------------------------
        // AUDIO
        // --------------------------------------------------------
        ChangeNotifierProvider<AudioService>(create: (_) => AudioService()),

        // --------------------------------------------------------
        // PRAYER
        // --------------------------------------------------------
        ChangeNotifierProvider<PrayerController>(
          create: (_) => PrayerController(),
        ),
      ],
      child: const NurVerseApp(),
    ),
  );
}

// ============================================================================
// NURVERSE APP
// ============================================================================

class NurVerseApp extends StatelessWidget {
  const NurVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();
    final TextScaleProvider textScale = context.watch<TextScaleProvider>();

    return MaterialApp(
      title: 'NurVerse',

      debugShowCheckedModeBanner: false,

      // ============================================================
      // THEME
      // ============================================================
      theme: AppTheme.lightTheme,

      darkTheme:
          settings.isAmoledMode ? AppTheme.amoledTheme : AppTheme.darkTheme,

      themeMode: settings.themeMode,

      // ============================================================
      // LOCALIZATION
      // ============================================================
      locale: settings.locale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ============================================================
      // MAIN NAVIGATION
      // ============================================================
      home: Builder(
        builder: (BuildContext context) {
          final MediaQueryData mediaQuery = MediaQuery.of(context);
          final double platformScale = mediaQuery.textScaler.textScaleFactor;
          final double combinedScale =
              (platformScale * textScale.scale).clamp(0.70, 2.0).toDouble();

          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(combinedScale),
            ),
            child: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}

// ============================================================================
// MAIN NAVIGATION SCREEN
// ============================================================================

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  SettingsProvider? _settingsProvider;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final SettingsProvider settings = context.read<SettingsProvider>();

    // Attach the listener only once.
    if (_settingsProvider != settings) {
      _settingsProvider?.removeListener(_onSettingsChanged);

      _settingsProvider = settings;
      _settingsProvider!.addListener(_onSettingsChanged);

      // PrayerController.updatePrayerAdjustments() recalculates prayer times
      // and notifies listeners. didChangeDependencies can run while the widget
      // tree is being built, so defer the initial synchronization until the
      // current frame has completed.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _settingsProvider != settings) {
          return;
        }

        _syncPrayerSettings(settings);
      });
    }
  }

  // ============================================================
  // SETTINGS → PRAYER CONTROLLER
  // ============================================================

  void _onSettingsChanged() {
    if (!mounted || _settingsProvider == null) {
      return;
    }

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

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigateTab(int index) {
    if (index < 0 || index > 5) {
      return;
    }

    if (_selectedIndex == index) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final SettingsProvider settings = context.watch<SettingsProvider>();

    final bool isBangla = settings.isBangla;

    // ============================================================
    // SCREENS
    // ============================================================

    final List<Widget> screens = [
      // ----------------------------------------------------------
      // 0 — HOME
      // ----------------------------------------------------------
      HomeScreen(onNavigateTab: _onNavigateTab),

      // ----------------------------------------------------------
      // 1 — PRAYER
      // ----------------------------------------------------------
      const PrayerScreen(),

      // ----------------------------------------------------------
      // 2 — QURAN
      // ----------------------------------------------------------
      const QuranScreen(),

      // ----------------------------------------------------------
      // 3 — HADITH
      // ----------------------------------------------------------
      const HadithScreen(),

      // ----------------------------------------------------------
      // 4 — TOOLS
      // ----------------------------------------------------------
      const ToolsScreen(),

      // ----------------------------------------------------------
      // 5 — MORE
      // ----------------------------------------------------------
      const MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),

      // ==========================================================
      // BOTTOM NAVIGATION
      // ==========================================================
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

          // ======================================================
          // NAVIGATION ITEMS
          // ======================================================
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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _settingsProvider?.removeListener(_onSettingsChanged);
    _settingsProvider = null;

    super.dispose();
  }
}
