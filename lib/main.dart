// lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'localization/app_localizations.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'providers/premium_provider.dart';
import 'providers/text_scale_provider.dart';
import 'providers/bold_text_provider.dart';
import 'controllers/prayer_controller.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/home_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/settings_hub_screen_v2.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await AuthService.instance.initializeGoogleSignIn();
  await initializeDateFormatting('en');
  await initializeDateFormatting('bn');
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
        ChangeNotifierProvider<TextScaleProvider>(create: (_) => TextScaleProvider()),
        ChangeNotifierProvider<BoldTextProvider>(create: (_) => BoldTextProvider()),
        ChangeNotifierProvider<PremiumProvider>(create: (_) => PremiumProvider()..checkPremiumStatus()),
        ChangeNotifierProvider<AudioService>(create: (_) => AudioService()),
        ChangeNotifierProvider<PrayerController>(create: (_) => PrayerController()),
      ],
      child: const NurVerseApp(),
    ),
  );
}

class NurVerseApp extends StatelessWidget {
  const NurVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final textScale = context.watch<TextScaleProvider>();
    final boldText = context.watch<BoldTextProvider>();

    return MaterialApp(
      title: 'NurVerse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: settings.isAmoledMode ? AppTheme.amoledTheme : AppTheme.darkTheme,
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          final mediaQuery = MediaQuery.of(context);
          final platformScale = mediaQuery.textScaler.textScaleFactor;
          final combinedScale = (platformScale * textScale.scale).clamp(0.70, 2.0).toDouble();
          final baseTheme = Theme.of(context);
          final textTheme = baseTheme.textTheme;
          final effectiveTextTheme = boldText.isBold
              ? textTheme.copyWith(
                  bodyLarge: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  bodyMedium: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  bodySmall: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                  labelMedium: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
                  labelSmall: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                  titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  titleSmall: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  headlineLarge: textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                  headlineMedium: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  headlineSmall: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  displayLarge: textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                  displayMedium: textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold),
                  displaySmall: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
                )
              : textTheme;

          return Theme(
            data: baseTheme.copyWith(textTheme: effectiveTextTheme),
            child: MediaQuery(
              data: mediaQuery.copyWith(textScaler: TextScaler.linear(combinedScale)),
              child: const AuthGate(),
            ),
          );
        },
      ),
    );
  }
}

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
    if (index < 0 || index > 5) return;
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleSystemBack() async {
    if (!mounted) return;
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<SettingsProvider>();

    final screens = [
      HomeScreen(onNavigateTab: _onNavigateTab),
      const PrayerScreen(),
      const QuranScreen(),
      const HadithScreen(),
      const ToolsScreen(),
      const SettingsHubScreenV2(),
    ];

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        body: IndexedStack(
          key: ValueKey<String>('language-${settings.languageCode}'),
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            border: Border(top: BorderSide(color: context.borderColor, width: 0.5)),
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
              BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: l10n.home),
              BottomNavigationBarItem(icon: const Icon(Icons.mosque_outlined), activeIcon: const Icon(Icons.mosque), label: l10n.prayer),
              BottomNavigationBarItem(icon: const Icon(Icons.menu_book_outlined), activeIcon: const Icon(Icons.menu_book), label: l10n.quran),
              BottomNavigationBarItem(icon: const Icon(Icons.auto_stories_outlined), activeIcon: const Icon(Icons.auto_stories), label: l10n.hadith),
              BottomNavigationBarItem(icon: const Icon(Icons.grid_view_outlined), activeIcon: const Icon(Icons.grid_view), label: l10n.tools),
              BottomNavigationBarItem(icon: const Icon(Icons.more_horiz_outlined), activeIcon: const Icon(Icons.more_horiz), label: l10n.more),
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
