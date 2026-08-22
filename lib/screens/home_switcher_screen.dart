import 'package:flutter/material.dart';

import '../services/home_mode_service.dart';
import 'home_screen.dart';
import 'simple_home_screen_v10.dart';

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
          return SimpleHomeScreenV10(onNavigateTab: widget.onNavigateTab);
        }

        return HomeScreen(onNavigateTab: widget.onNavigateTab);
      },
    );
  }
}
