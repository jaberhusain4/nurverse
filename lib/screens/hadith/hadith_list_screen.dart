import 'package:flutter/material.dart';

import '../../services/hadith_service.dart';
import 'localized_hadith_list_screen.dart';

/// Compatibility entry point. The reading UI follows the global app language.
class HadithListScreen extends StatelessWidget {
  final HadithBook book;
  final HadithChapter chapter;

  const HadithListScreen({super.key, required this.book, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return LocalizedHadithListScreen(book: book, chapter: chapter);
  }
}
