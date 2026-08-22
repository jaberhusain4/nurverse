import 'simple_home_screen_v11.dart';

/// Canonical Home Screen entry point.
///
/// Keeps the public HomeScreen API stable for MainNavigation/MainShell while
/// delegating the UI to the current Simple Home implementation.
class HomeScreen extends SimpleHomeScreenV11 {
  const HomeScreen({super.key, super.onNavigateTab});
}
