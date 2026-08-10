import 'package:flutter/material.dart';

import '../models/surah_model.dart';
import '../models/bookmark_model.dart';
import '../services/quran_service.dart';
import '../services/bookmark_service.dart';
import '../services/last_read_service.dart';

class SurahDetailsScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailsScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahDetailsScreen> createState() => _SurahDetailsScreenState();
}

class _SurahDetailsScreenState extends State<SurahDetailsScreen> {
  final QuranService _service = QuranService();
  final BookmarkService _bookmarkService = BookmarkService();

  late Future<SurahModel> _surah;
  Set<int> bookmarkedAyahs = {};

  final Color seaBlue = const Color(0xFF0288D1);

  @override
  void initState() {
    super.initState();
    _surah = _service.getSurah(widget.surahNumber);
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    final bookmarks = await _bookmarkService.getBookmarks();
    if (!mounted) return;

    setState(() {
      bookmarkedAyahs =
          bookmarks
              .where((item) => item.surahNumber == widget.surahNumber)
              .map((item) => item.ayahNumber)
              .toSet();
    });
  }

  Future<void> toggleBookmark(int ayahNumber, String ayahText) async {
    if (bookmarkedAyahs.contains(ayahNumber)) {
      await _bookmarkService.removeBookmark(widget.surahNumber, ayahNumber);
    } else {
      await _bookmarkService.addBookmark(
        BookmarkModel(
          surahNumber: widget.surahNumber,
          surahName: widget.surahName,
          ayahNumber: ayahNumber,
          ayahText: ayahText,
        ),
      );
    }
    await loadBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF0A2540) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.surahName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<SurahModel>(
        future: _surah,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: seaBlue));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No Data Found"));
          }

          final surah = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              // সূরার হেডার কার্ড (সলিড কালার - নো গ্রেডিয়েন্ট/বর্ডার)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      surah.englishName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      surah.name,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: seaBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "${surah.revelationType} • ${surah.numberOfAyahs} Ayahs",
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // আয়াতের তালিকা
              ...surah.ayahs.map((ayah) {
                return GestureDetector(
                  onTap: () async {
                    await LastReadService.saveLastRead(
                      surahName: widget.surahName,
                      paraNo: 1,
                      pageNo: 1,
                      progress:
                          (ayah.numberInSurah / surah.numberOfAyahs)
                              .clamp(0.0, 1.0)
                              .toDouble(),
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Saved Ayah ${ayah.numberInSurah} as your last read',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Ayah ${ayah.numberInSurah}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                toggleBookmark(ayah.numberInSurah, ayah.text);
                              },
                              icon: Icon(
                                bookmarkedAyahs.contains(ayah.numberInSurah)
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: seaBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ayah.text,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 26,
                            height: 2.2,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color:
                                  seaBlue, // সবুজ রঙ পরিবর্তন করে সি ব্লু করা হয়েছে
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                ayah.numberInSurah.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
