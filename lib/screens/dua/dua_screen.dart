import 'package:flutter/material.dart';

import 'dua_screen_recording_v2.dart' as dua;

/// NurVerse Dua entry screen.
///
/// Creator-only upload controls are removed from the user-facing app.
/// Published Dua audio is distributed through Cloudflare R2, downloaded on
/// demand, and cached locally for offline playback.
class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const dua.DuaScreen();
  }
}
