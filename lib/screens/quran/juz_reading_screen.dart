import 'package:flutter/material.dart';

import '../../services/quran_data_service.dart';
import '../../theme/app_theme.dart';

class JuzReadingScreen extends StatelessWidget {
  final int juzNumber;
  const JuzReadingScreen({super.key, required this.juzNumber});

  @override
  Widget build(BuildContext context) {
    final service = QuranDataService.instance;
    final verses = service.getJuzVerses(juzNumber);

    return Scaffold(
      appBar: AppBar(title: Text('পারা $juzNumber'), centerTitle: true),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: verses.length,
          itemBuilder: (context, index) {
            final (surahNumber, surahName, v) = verses[index];
            final showSurahHeader =
                index == 0 || verses[index - 1].$1 != surahNumber;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showSurahHeader)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    child: Text(
                      'সূরা $surahName',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.seaBlueDark),
                    ),
                  ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: Theme.of(context).dividerColor,
                      child: Text('${v.number}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  v.arabic,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontSize: 22, height: 1.9),
                ),
                const SizedBox(height: 8),
                if (v.bangla != null)
                  Text(v.bangla!, style: const TextStyle(fontSize: 14, height: 1.5))
                else
                  const Text('বাংলা অনুবাদ ডাউনলোড করতে "কুরআন" ট্যাবের যেকোনো সূরা খুলুন',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Divider(height: 28),
              ],
            );
          },
        ),
      ),
    );
  }
}
