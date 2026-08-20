import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../controllers/prayer_controller.dart';
import '../providers/settings_provider.dart';
import '../services/date_service.dart';
import '../services/jamaat_service.dart';
import '../services/last_read_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/current_prayer_premium_card.dart';
import '../widgets/home/continue_reading_card.dart';
import '../widgets/home/daily_content_section.dart';
import '../widgets/home/islamic_info_card.dart';
import '../widgets/home/islamic_ornamental_background.dart';
import '../widgets/home/live_prayer_restriction_card.dart';
import '../widgets/home/prayer_timeline_card.dart';
import '../widgets/home/top_header.dart';
import 'prayer/jamaat_settings_screen.dart';
import 'qibla/qibla_screen.dart';
import 'quran/onudhabon_quran_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'dua/dua_screen.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/tasbih_screen.dart';
import 'tools/zakat_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateTab;
  const HomeScreen({super.key, this.onNavigateTab});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Timer? _clockTimer;
  String _currentTime = '';
  Map<String, dynamic>? _lastRead;
  bool _lastReadLoading = true;

  @override
  void initState() {
    super.initState();
    _updateClock();
    _loadLastRead();
    JamaatService.initialize().then((_) { if (mounted) setState(() {}); });
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) _updateClock(); });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _updateClock() {
    final now = DateTime.now();
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final value = '${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period';
    if (_currentTime == value) return;
    setState(() => _currentTime = value);
  }

  Future<void> refreshForBack() => _refreshHome();

  Future<void> _loadLastRead() async {
    try {
      final data = await LastReadService.getLastRead();
      if (!mounted) return;
      setState(() { _lastRead = data; _lastReadLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _lastRead = null; _lastReadLoading = false; });
    }
  }

  Future<void> _refreshHome() async {
    final controller = context.read<PrayerController>();
    await controller.refreshLocation();
    await _loadLastRead();
    if (mounted) setState(() {});
  }

  String _greeting(String languageCode) {
    final hour = DateTime.now().hour;
    if (languageCode == 'en') { if (hour < 12) return 'Good Morning'; if (hour < 18) return 'Good Afternoon'; return 'Good Evening'; }
    if (languageCode == 'ar') return hour < 12 ? 'صباح الخير' : 'مساء الخير';
    if (hour < 12) return 'শুভ সকাল'; if (hour < 15) return 'শুভ দুপুর'; if (hour < 18) return 'শুভ বিকেল'; return 'শুভ সন্ধ্যা';
  }
