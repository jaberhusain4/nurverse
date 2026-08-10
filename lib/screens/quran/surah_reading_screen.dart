import 'package:flutter/material.dart';

import '../../services/audio_quran_service.dart';
import '../../services/quran_data_service.dart';
import '../../theme/app_theme.dart';

class SurahReadingScreen extends StatefulWidget {
  final int surahNumber;
  const SurahReadingScreen({super.key, required this.surahNumber});

  @override
  State<SurahReadingScreen> createState() => _SurahReadingScreenState();
}

class _SurahReadingScreenState extends State<SurahReadingScreen> {
  bool _playing = false;
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    final service = QuranDataService.instance;
    final surah = service.getSurah(widget.surahNumber);

    return Scaffold(
      appBar: AppBar(
        title: Text('সূরা ${surah.transliteration}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_playing ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
            onPressed: () async {
              if (_playing) {
                await AudioQuranService.instance.pause();
                setState(() => _playing = false);
              } else {
                await AudioQuranService.instance.play(kReciters.first, widget.surahNumber);
                setState(() => _playing = true);
              }
            },
          ),
          IconButton(
            icon: _downloading
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.download_for_offline_outlined),
            onPressed: _downloading
                ? null
                : () async {
                    setState(() => _downloading = true);
                    final ok = await AudioQuranService.instance.download(kReciters.first, widget.surahNumber);
                    setState(() => _downloading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok ? 'অফলাইনে ডাউনলোড সম্পন্ন হয়েছে' : 'ডাউনলোড ব্যর্থ হয়েছে, ইন্টারনেট চেক করুন'),
                      ));
                    }
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surah.verses.length,
          itemBuilder: (context, index) {
            final v = surah.verses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  else if (service.downloading)
                    const Text('বাংলা অনুবাদ ডাউনলোড হচ্ছে…',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                  else
                    TextButton(
                      onPressed: () => service.downloadTranslation().then((_) => setState(() {})),
                      child: const Text('বাংলা অনুবাদ ডাউনলোড করুন'),
                    ),
                  const Divider(height: 28),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
