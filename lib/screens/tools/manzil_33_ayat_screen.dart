import 'package:flutter/material.dart';

import '../../services/quran_data_service.dart';
import '../../theme/app_theme.dart';

/// A commonly circulated Manzil / 33-Ayat compilation.
///
/// This is presented as a compiled devotional collection, not as a claim
/// that this exact set or repetition count is a specifically prescribed
/// Sunnah formula.
class Manzil33AyatScreen extends StatefulWidget {
  const Manzil33AyatScreen({super.key});

  @override
  State<Manzil33AyatScreen> createState() => _Manzil33AyatScreenState();
}

class _Manzil33AyatScreenState extends State<Manzil33AyatScreen> {
  final _quran = QuranDataService.instance;
  bool _loading = true;
  List<_ManzilGroup> _groups = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _quran.init();

    const references = <_ManzilGroup>[
      _ManzilGroup(1, 'সূরা আল-ফাতিহা', 1, 7),
      _ManzilGroup(2, 'সূরা আল-বাকারা', 1, 5),
      _ManzilGroup(2, 'সূরা আল-বাকারা', 163, 163),
      _ManzilGroup(2, 'সূরা আল-বাকারা', 255, 257),
      _ManzilGroup(2, 'সূরা আল-বাকারা', 284, 286),
      _ManzilGroup(3, 'সূরা আলে ইমরান', 18, 18),
      _ManzilGroup(3, 'সূরা আলে ইমরান', 26, 27),
      _ManzilGroup(7, 'সূরা আল-আ‘রাফ', 54, 56),
      _ManzilGroup(17, 'সূরা আল-ইসরা', 110, 111),
      _ManzilGroup(23, 'সূরা আল-মু’মিনূন', 115, 118),
      _ManzilGroup(37, 'সূরা আস-সাফফাত', 1, 11),
      _ManzilGroup(55, 'সূরা আর-রহমান', 33, 40),
      _ManzilGroup(59, 'সূরা আল-হাশর', 21, 24),
      _ManzilGroup(72, 'সূরা আল-জিন', 1, 4),
      _ManzilGroup(109, 'সূরা আল-কাফিরূন', 1, 6),
      _ManzilGroup(112, 'সূরা আল-ইখলাস', 1, 4),
      _ManzilGroup(113, 'সূরা আল-ফালাক', 1, 5),
      _ManzilGroup(114, 'সূরা আন-নাস', 1, 6),
    ];

    if (!mounted) return;
    setState(() {
      _groups = references;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'মনজিল — ৩৩ আয়াত',
          style: TextStyle(
            fontSize: 17,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 30),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: .11),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        color: primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'মনজিল — প্রচলিত ৩৩ আয়াতের সংকলন',
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  'কুরআনের বিভিন্ন সূরার নির্বাচিত আয়াতের একটি প্রচলিত সংকলন। NurVerse এটিকে নির্দিষ্ট Sunnah-নির্ধারিত পাঠ বা বাধ্যতামূলক repetition হিসেবে উপস্থাপন করছে না।',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._groups.map((group) => _buildGroup(context, group)),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, _ManzilGroup group) {
    final primary = Theme.of(context).colorScheme.primary;
    final surah = _quran.getSurah(group.surahNumber);
    final verses = surah.verses
        .where(
          (verse) =>
              verse.number >= group.from && verse.number <= group.to,
        )
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${group.surahNumber}:${group.from}${group.from == group.to ? '' : '-${group.to}'}',
                  style: TextStyle(
                    color: primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.title,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ...verses.map(
            (verse) => Padding(
              padding: const EdgeInsets.only(bottom: 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: verse.arabic.trim(),
                            style: const TextStyle(
                              fontSize: 19,
                              height: 1.55,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '  ۝ ${verse.number}',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                              color: primary.withValues(alpha: .72),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (verse.bangla != null && verse.bangla!.trim().isNotEmpty)
                    Text(
                      verse.bangla!.trim(),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: context.primaryTextColor,
                      ),
                    )
                  else
                    Text(
                      'বাংলা অনুবাদ এখনো অফলাইনে প্রস্তুত হয়নি। কুরআন অনুবাদ একবার সিঙ্ক করলে এখানে দেখাবে।',
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        color: context.secondaryTextColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManzilGroup {
  final int surahNumber;
  final String title;
  final int from;
  final int to;

  const _ManzilGroup(this.surahNumber, this.title, this.from, this.to);
}
