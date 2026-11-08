import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../theme/app_theme.dart';
import '../../services/asma_ul_husna_audio_cache_service.dart';
import '../../services/asma_ul_husna_service.dart';

class AsmaUlHusnaAudioScreen extends StatefulWidget {
  const AsmaUlHusnaAudioScreen({super.key});

  @override
  State<AsmaUlHusnaAudioScreen> createState() => _AsmaUlHusnaAudioScreenState();
}

class _AsmaUlHusnaAudioScreenState extends State<AsmaUlHusnaAudioScreen> {
  final AudioPlayer _player = AudioPlayer();
  final AsmaUlHusnaAudioCacheService _audioCache =
      AsmaUlHusnaAudioCacheService.instance;

  String? _playingId;
  bool _loadingAudio = false;
  bool _downloadingAll = false;
  int _downloadedCount = 0;
  int _downloadProgress = 0;
  String _query = '';

  static const List<String> _audioFiles = [
    '01-ar-rahman.ogg','02-ar-rahim.ogg','03-al-malik.ogg','04-al-quddus.ogg','05-as-salam.ogg','06-al-mumin.ogg','07-al-muhaymin.ogg','08-al-aziz.ogg','09-al-jabbar.ogg','10-al-mutakabbir.ogg','11-al-khaliq.ogg','12-al-bari.ogg','13-al-musawwir.ogg','14-al-ghaffar.ogg','15-al-qahhar.ogg','16-al-wahhab.ogg','17-ar-razzaq.ogg','18-al-fattah.ogg','19-al-alim.ogg','20-al-qabid.ogg','21-al-basit.ogg','22-al-khafid.ogg','23-ar-rafi.ogg','24-al-muizz.ogg','25-al-mudhill.ogg','26-as-sami.ogg','27-al-basir.ogg','28-al-hakam.ogg','29-al-adl.ogg','30-al-latif.ogg','31-al-khabir.ogg','32-al-halim.ogg','33-al-azim.ogg','34-al-ghafur.ogg','35-ash-shakur.ogg','36-al-ali.ogg','37 al-kabir.ogg','38-al-hafiz.ogg','39-al-muqit.ogg','40-al-hasib.ogg','41-al-jalil.ogg','42 al-karim.ogg','43-ar-raqib.ogg','44-al-mujib.ogg','45-al-wasi.ogg','46-al-hakim.ogg','47-al-wadud.ogg','48-al-majid.ogg','49 al-baith.ogg','50-ash-shahid.ogg','51-al-haqq.ogg','52-al-wakil.ogg','53-al-qawi.ogg','54-al-matin.ogg','55-al-wali.ogg','56-al-hamid.ogg','57-al-muhsi.ogg','58-al-mubdi.ogg','59-al-muid.ogg','60-al-muhyi.ogg','61-al-mumit.ogg','62-al-hayy.ogg','63-al-qayyum.ogg','64-al-wajid.ogg','65-al-majid.ogg','66-al-wahid.ogg','67-al-ahad.ogg','68-as-samad.ogg','69-al-qadir.ogg','70-al-muqtadir.ogg','71-al-muqaddim.ogg','72-al-muakhkhir.ogg','73-al-awwal.ogg','74-al-akhir.ogg','75-az-zahir.ogg','76-al-batin.ogg','77-al-wali.ogg','78-al-mutaali.ogg','79-al-barr.ogg','80-at-tawwab.ogg','81-al-muntaqim.ogg','82-al-afuw.ogg','83-ar-rauf.ogg','84-malik-ul-mulk.ogg','85-dhul-jalaal-wal-ikraam.ogg','86-al-muqsit.ogg','87-al-jame.ogg','88-al-ghani.ogg','89-al-mughni.ogg','90-al-mani.ogg','91-ad-darr.ogg','92-an-nafi.ogg','93-an-nur.ogg','94-al-hadi.ogg','95-al-badi.ogg','96-al-baqi.ogg','97-al-warith.ogg','98-ar-rashid.ogg','99-as-sabur.ogg',
  ];

  static final List<Map<String, String>> _names = const AsmaUlHusnaService()
      .getAll()
      .map((item) => <String, String>{
        'id': item.id.toString(),
        'arabic': item.arabic,
        'name': item.transliteration,
        'meaning': item.meaning,
      })
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _refreshDownloadedCount();
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _playingId = null;
          _loadingAudio = false;
        });
      } else if (state.processingState == ProcessingState.ready &&
          _loadingAudio) {
        setState(() => _loadingAudio = false);
      }
    });
  }

  Future<void> _refreshDownloadedCount() async {
    final count = await _audioCache.downloadedCount(_audioFiles);
    if (mounted) setState(() => _downloadedCount = count);
  }

  Future<void> _downloadAllAudio() async {
    if (_downloadingAll || _downloadedCount == _audioFiles.length) return;

    setState(() {
      _downloadingAll = true;
      _downloadProgress = 0;
    });

    try {
      final failed = await _audioCache.downloadAll(
        _audioFiles,
        onProgress: (completed, total) {
          if (!mounted) return;
          setState(() => _downloadProgress = completed);
        },
      );
      await _refreshDownloadedCount();

      if (!mounted) return;

      if (_downloadedCount == _audioFiles.length && failed.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('আল্লাহর ৯৯ নামের সব অডিও অফলাইনের জন্য সংরক্ষিত হয়েছে।'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_downloadedCount/${_audioFiles.length}টি অডিও অফলাইনে প্রস্তুত। ${failed.length}টি আবার চেষ্টা করতে হবে।',
            ),
          ),
        );
      }
    } catch (_) {
      await _refreshDownloadedCount();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$_downloadedCount/${_audioFiles.length}টি অডিও অফলাইনে প্রস্তুত। বাকি অডিওর জন্য আবার Download চাপুন।',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingAll = false);
    }
  }

  Future<void> _playName(Map<String, String> item) async {
    final id = item['id']!;
    if (_playingId == id && _player.playing) {
      await _player.stop();
      if (mounted) {
        setState(() {
          _playingId = null;
          _loadingAudio = false;
        });
      }
      return;
    }

    await _player.stop();
    if (mounted) {
      setState(() {
        _playingId = id;
        _loadingAudio = true;
      });
    }

    try {
      final fileName = _audioFiles[int.parse(id) - 1];
      final file = await _audioCache.getCachedFile(fileName);
      if (file == null) {
        throw StateError('Audio is not downloaded for offline playback.');
      }

      await _player.setFilePath(file.path);
      await _player.play();
    } catch (_) {
      if (mounted) {
        setState(() {
          _playingId = null;
          _loadingAudio = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('এই অডিওটি অফলাইনে প্রস্তুত নয়। উপরের Download চাপুন।'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _names.where((item) {
      final q = _query.trim().toLowerCase();
      return q.isEmpty ||
          item['name']!.toLowerCase().contains(q) ||
          item['meaning']!.toLowerCase().contains(q) ||
          item['id'] == q;
    }).toList();
    final secondary = context.secondaryTextColor;
    final allDownloaded = _downloadedCount == _audioFiles.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'আল্লাহর ৯৯ নাম',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.download_for_offline_rounded,
                              color: AppColors.seaBlue),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  allDownloaded
                                      ? 'অফলাইন অডিও প্রস্তুত'
                                      : '৯৯টি নামের অডিও অফলাইনে রাখুন',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _downloadingAll
                                      ? 'ডাউনলোড হচ্ছে $_downloadProgress/${_audioFiles.length}...'
                                      : allDownloaded
                                          ? '৯৯/৯৯টি অডিও সংরক্ষিত। এখন ইন্টারনেট ছাড়াই শুনতে পারবেন।'
                                          : '$_downloadedCount/${_audioFiles.length}টি প্রস্তুত। একবার Download চাপুন।',
                                  style: TextStyle(fontSize: 11, color: secondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton.icon(
                            onPressed: (_downloadingAll || allDownloaded)
                                ? null
                                : _downloadAllAudio,
                            icon: _downloadingAll
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(allDownloaded
                                    ? Icons.check_rounded
                                    : Icons.download_rounded),
                            label: Text(allDownloaded ? 'সম্পন্ন' : 'ডাউনলোড'),
                          ),
                        ],
                      ),
                      if (_downloadingAll) ...[
                        const SizedBox(height: 9),
                        LinearProgressIndicator(
                          value: _downloadProgress / _audioFiles.length,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'নাম বা অর্থ দিয়ে খুঁজুন...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.seaBlue),
                  filled: true,
                  fillColor: context.cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    borderSide: const BorderSide(color: AppColors.seaBlue),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
              child: Row(
                children: [
                  const Icon(Icons.volume_up_rounded,
                      size: 18, color: AppColors.seaBlue),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      _loadingAudio
                          ? 'অডিও চালু হচ্ছে...'
                          : allDownloaded
                              ? 'অফলাইন মোড: যেকোনো নাম চাপুন'
                              : 'আগে উপরের Download চাপুন, তারপর যেকোনো নাম শুনুন',
                      style: TextStyle(fontSize: 12, color: secondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  final active = _playingId == item['id'];
                  return Card(
                    child: ListTile(
                      onTap: () => _playName(item),
                      leading: CircleAvatar(
                        backgroundColor:
                            AppColors.seaBlue.withValues(alpha: .10),
                        child: Text(
                          item['id']!,
                          style: const TextStyle(
                            color: AppColors.seaBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        item['arabic']!,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${item['name']} — ${item['meaning']}'),
                      ),
                      trailing: active
                          ? (_loadingAudio
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(
                                  Icons.stop_circle_rounded,
                                  color: AppColors.seaBlue,
                                ))
                          : const Icon(
                              Icons.play_circle_fill_rounded,
                              color: AppColors.seaBlue,
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
