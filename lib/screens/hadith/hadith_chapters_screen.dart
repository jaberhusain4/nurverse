import 'package:flutter/material.dart';

import '../../services/hadith_service.dart';
import 'localized_hadith_chapters_screen.dart';

/// Compatibility entry point kept for existing navigation paths.
/// The actual chapter UI is now language-aware and follows Settings.
class HadithChaptersScreen extends StatelessWidget {
  final HadithBook book;

  const HadithChaptersScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return LocalizedHadithChaptersScreen(book: book);
  }
}
