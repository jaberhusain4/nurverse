import 'package:flutter/material.dart';

import 'dua_r2_upload_screen.dart';
import 'dua_screen_recording_v2.dart' as dua;

/// NurVerse Dua entry screen.
///
/// The cloud-upload control is intentionally an owner/creator tool for the
/// current migration of locally recorded master audio. It can be removed after
/// the recordings are published to R2.
class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const dua.DuaScreen(),
        Positioned(
          right: 16,
          bottom: 18,
          child: SafeArea(
            child: FloatingActionButton.small(
              heroTag: 'nurverse_dua_r2_upload',
              tooltip: 'Creator audio upload',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const DuaR2UploadScreen(),
                  ),
                );
              },
              child: const Icon(Icons.cloud_upload_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
