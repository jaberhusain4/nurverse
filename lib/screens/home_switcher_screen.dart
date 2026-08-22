import 'package:flutter/material.dart';

import '../services/home_mode_service.dart';
import 'home_screen.dart';
import 'simple_home_screen_muslim_day_v2.dart';

class HomeSwitcherScreen extends StatefulWidget {
  const HomeSwitcherScreen({super.key, this.onNavigateTab});

  final Function(int)? onNavigateTab;

  @override
  State<HomeSwitcherScreen> createState() => _HomeSwitcherScreenState();
}

class _HomeSwitcherScreenState extends State<HomeSwitcherScreen> {
  final HomeModeService _service = HomeModeService.instance;

  @override
  void initState() {
    super.initState();
    _service.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _service,
      builder: (context, _) {
        if (!_service.isLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_service.isSimple) {
          return SimpleHomeScreenMuslimDayV2(
            onNavigateTab: widget.onNavigateTab,
          );
        }

        // Informative Home is intentionally locked. Do not modify this path
        // while redesigning Simple Home.
        return HomeScreen(onNavigateTab: widget.onNavigateTab);
      },
    );
  }
}
