import 'simple_home_screen_v10.dart';

/// V11 entry point.
///
/// V11 currently reuses the complete, compiling V10 implementation rather
/// than keeping a broken/truncated duplicate. This keeps the Home architecture
/// stable while the visual hero can be evolved safely in one place.
class SimpleHomeScreenV11 extends SimpleHomeScreenV10 {
  const SimpleHomeScreenV11({super.key, super.onNavigateTab});
}
