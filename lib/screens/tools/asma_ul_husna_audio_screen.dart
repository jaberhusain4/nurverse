import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../theme/app_theme.dart';
import '../../services/asma_ul_husna_audio_cache_service.dart';

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

  static const List<Map<String, String>> _names = [
    {'id':'1','arabic':'الرَّحْمَنُ','name':'আর-রহমান','meaning':'পরম দয়ালু'},{'id':'2','arabic':'الرَّحِيمُ','name':'আর-রহীম','meaning':'অতি দয়ালু'},{'id':'3','arabic':'الْمَلِكُ','name':'আল-মালিক','meaning':'সর্বময় অধিপতি'},{'id':'4','arabic':'الْقُدُّوسُ','name':'আল-কুদ্দুস','meaning':'অতি পবিত্র'},{'id':'5','arabic':'السَّلَامُ','name':'আস-সালাম','meaning':'শান্তিদাতা'},{'id':'6','arabic':'الْمُؤْمِنُ','name':'আল-মু’মিন','meaning':'নিরাপত্তাদাতা'},{'id':'7','arabic':'الْمُهَيْمِنُ','name':'আল-মুহাইমিন','meaning':'রক্ষক'},{'id':'8','arabic':'الْعَزِيزُ','name':'আল-আযীয','meaning':'মহাপরাক্রমশালী'},{'id':'9','arabic':'الْجَبَّارُ','name':'আল-জাব্বার','meaning':'পরাক্রমশালী'},{'id':'10','arabic':'الْمُتَكَبِّرُ','name':'আল-মুতাকাব্বির','meaning':'মহিমান্বিত'},
    {'id':'11','arabic':'الْخَالِقُ','name':'আল-খালিক','meaning':'সৃষ্টিকর্তা'},{'id':'12','arabic':'الْبَارِئُ','name':'আল-বারী','meaning':'সৃষ্টির উদ্ভাবক'},{'id':'13','arabic':'الْمُصَوِّرُ','name':'আল-মুসাওয়ির','meaning':'আকৃতিদাতা'},{'id':'14','arabic':'الْغَفَّارُ','name':'আল-গাফ্ফার','meaning':'পরম ক্ষমাশীল'},{'id':'15','arabic':'الْقَهَّارُ','name':'আল-কাহ্হার','meaning':'প্রবল পরাক্রমশালী'},{'id':'16','arabic':'الْوَهَّابُ','name':'আল-ওয়াহ্হাব','meaning':'পরম দানশীল'},{'id':'17','arabic':'الرَّزَّاقُ','name':'আর-রাজ্জাক','meaning':'রিজিকদাতা'},{'id':'18','arabic':'الْفَتَّاحُ','name':'আল-ফাত্তাহ','meaning':'বিজয়দাতা'},{'id':'19','arabic':'الْعَلِيمُ','name':'আল-আলীম','meaning':'সর্বজ্ঞ'},{'id':'20','arabic':'الْقَابِضُ','name':'আল-কাবিদ','meaning':'সংকোচনকারী'},
    {'id':'21','arabic':'الْبَاسِطُ','name':'আল-বাসিত','meaning':'প্রশস্তকারী'},{'id':'22','arabic':'الْخَافِضُ','name':'আল-খাফিদ','meaning':'অবনমিতকারী'},{'id':'23','arabic':'الرَّافِعُ','name':'আর-রাফি','meaning':'উন্নতকারী'},{'id':'24','arabic':'الْمُعِزُّ','name':'আল-মু’ইয্য','meaning':'সম্মানদাতা'},{'id':'25','arabic':'الْمُذِلُّ','name':'আল-মুযিল','meaning':'অপমানকারী'},{'id':'26','arabic':'السَّمِيعُ','name':'আস-সামী','meaning':'সর্বশ্রোতা'},{'id':'27','arabic':'الْبَصِيرُ','name':'আল-বাছীর','meaning':'সর্বদ্রষ্টা'},{'id':'28','arabic':'الْحَكَمُ','name':'আল-হাকাম','meaning':'বিচারক'},{'id':'29','arabic':'الْعَدْلُ','name':'আল-আদল','meaning':'ন্যায়পরায়ণ'},{'id':'30','arabic':'اللَّطِيفُ','name':'আল-লাতীফ','meaning':'অতি কোমল ও সূক্ষ্মদর্শী'},
    {'id':'31','arabic':'الْخَبِيرُ','name':'আল-খাবীর','meaning':'সর্বজ্ঞাত'},{'id':'32','arabic':'الْحَلِيمُ','name':'আল-হালীম','meaning':'পরম সহনশীল'},{'id':'33','arabic':'الْعَظِيمُ','name':'আল-আযীম','meaning':'মহামহিম'},{'id':'34','arabic':'الْغَفُورُ','name':'আল-গফুর','meaning':'অতি ক্ষমাশীল'},{'id':'35','arabic':'الشَّكُورُ','name':'আশ-শাকুর','meaning':'গুণগ্রাহী'},{'id':'36','arabic':'الْعَلِيُّ','name':'আল-আলী','meaning':'সর্বোচ্চ'},{'id':'37','arabic':'الْكَبِيرُ','name':'আল-কাবীর','meaning':'সুমহান'},{'id':'38','arabic':'الْحَفِيظُ','name':'আল-হাফীয','meaning':'সংরক্ষণকারী'},{'id':'39','arabic':'الْمُقِيتُ','name':'আল-মুকীত','meaning':'জীবনোপকরণদাতা'},{'id':'40','arabic':'الْحَسِيبُ','name':'আল-হাসীব','meaning':'হিসাবগ্রহণকারী'},
    {'id':'41','arabic':'الْجَلِيلُ','name':'আল-জালীল','meaning':'মহিমান্বিত'},{'id':'42','arabic':'الْكَرِيمُ','name':'আল-কারীম','meaning':'মহানুভব'},{'id':'43','arabic':'الرَّقِيبُ','name':'আর-রকীব','meaning':'পর্যবেক্ষক'},{'id':'44','arabic':'الْمُجِيبُ','name':'আল-মুজীব','meaning':'সাড়াদানকারী'},{'id':'45','arabic':'الْوَاسِعُ','name':'আল-ওয়াসি','meaning':'সর্বব্যাপী'},{'id':'46','arabic':'الْحَكِيمُ','name':'আল-হাকীম','meaning':'প্রজ্ঞাময়'},{'id':'47','arabic':'الْوَدُودُ','name':'আল-ওয়াদূদ','meaning':'পরম স্নেহশীল'},{'id':'48','arabic':'الْمَجِيدُ','name':'আল-মাজীদ','meaning':'মহিমান্বিত'},{'id':'49','arabic':'الْبَاعِثُ','name':'আল-বা’ইস','meaning':'পুনরুত্থানকারী'},{'id':'50','arabic':'الشَّهِيدُ','name':'আশ-শাহীদ','meaning':'সাক্ষী'},
    {'id':'51','arabic':'الْحَقُّ','name':'আল-হাক্ক','meaning':'পরম সত্য'},{'id':'52','arabic':'الْوَكِيلُ','name':'আল-ওয়াকীল','meaning':'অভিভাবক'},{'id':'53','arabic':'الْقَوِيُّ','name':'আল-কাওয়ী','meaning':'পরম শক্তিশালী'},{'id':'54','arabic':'الْمَتِينُ','name':'আল-মাতীন','meaning':'সুদৃঢ়'},{'id':'55','arabic':'الْوَلِيُّ','name':'আল-ওয়ালিয়্য','meaning':'অভিভাবক ও সাহায্যকারী'},{'id':'56','arabic':'الْحَمِيدُ','name':'আল-হামীদ','meaning':'সকল প্রশংসার যোগ্য'},{'id':'57','arabic':'الْمُحْصِي','name':'আল-মুহসী','meaning':'গণনাকারী'},{'id':'58','arabic':'الْمُبْدِئُ','name':'আল-মুবদি','meaning':'প্রথম সৃষ্টিকারী'},{'id':'59','arabic':'الْمُعِيدُ','name':'আল-মুঈদ','meaning':'পুনঃসৃষ্টিকারী'},{'id':'60','arabic':'الْمُحْيِي','name':'আল-মুহয়ী','meaning':'জীবনদানকারী'},
    {'id':'61','arabic':'الْمُمِيتُ','name':'আল-মুমীত','meaning':'মৃত্যুদানকারী'},{'id':'62','arabic':'الْحَيُّ','name':'আল-হাইয়্য','meaning':'চিরঞ্জীব'},{'id':'63','arabic':'الْقَيُّومُ','name':'আল-কাইয়্যুম','meaning':'স্বয়ংসম্পূর্ণ'},{'id':'64','arabic':'الْوَاجِدُ','name':'আল-ওয়াজিদ','meaning':'প্রাপ্তকারী'},{'id':'65','arabic':'الْمَاجِدُ','name':'আল-মাজিদ','meaning':'মহিমান্বিত'},{'id':'66','arabic':'الْوَاحِدُ','name':'আল-ওয়াহিদ','meaning':'একক'},{'id':'67','arabic':'الْأَحَدُ','name':'আল-আহাদ','meaning':'অদ্বিতীয়'},{'id':'68','arabic':'الصَّمَدُ','name':'আস-সামাদ','meaning':'অমুখাপেক্ষী'},{'id':'69','arabic':'الْقَادِرُ','name':'আল-কাদির','meaning':'সর্বশক্তিমান'},{'id':'70','arabic':'الْمُقْتَدِرُ','name':'আল-মুকতাদির','meaning':'সর্বময় ক্ষমতার অধিকারী'},
    {'id':'71','arabic':'الْمُقَدِّمُ','name':'আল-মুকাদ্দিম','meaning':'অগ্রসরকারী'},{'id':'72','arabic':'الْمُؤَخِّرُ','name':'আল-মুয়াখখির','meaning':'পিছিয়ে দানকারী'},{'id':'73','arabic':'الْأَوَّلُ','name':'আল-আউয়াল','meaning':'প্রথম'},{'id':'74','arabic':'الْآخِرُ','name':'আল-আখির','meaning':'শেষ'},{'id':'75','arabic':'الظَّاهِرُ','name':'আয-যাহির','meaning':'প্রকাশ্য'},{'id':'76','arabic':'الْبَاطِنُ','name':'আল-বাতিন','meaning':'অপ্রকাশ্য'},{'id':'77','arabic':'الْوَالِي','name':'আল-ওয়ালী','meaning':'শাসনকর্তা'},{'id':'78','arabic':'الْمُتَعَالِي','name':'আল-মুতা’আলী','meaning':'সর্বোচ্চ মর্যাদার অধিকারী'},{'id':'79','arabic':'الْبَرُّ','name':'আল-বার্','meaning':'পরম কল্যাণময়'},{'id':'80','arabic':'التَّوَابُ','name':'আত-তাওয়াব','meaning':'তওবা কবুলকারী'},
    {'id':'81','arabic':'الْمُنْتَقِمُ','name':'আল-মুনতাকিম','meaning':'প্রতিফলদাতা'},{'id':'82','arabic':'الْعَفُوُّ','name':'আল-আফুউ','meaning':'পরম ক্ষমাকারী'},{'id':'83','arabic':'الرَّؤُوفُ','name':'আর-রউফ','meaning':'অতি স্নেহশীল'},{'id':'84','arabic':'مَالِكُ الْمُلْكِ','name':'মালিকুল মুলক','meaning':'সার্বভৌমত্বের মালিক'},{'id':'85','arabic':'ذُو الْجَلَالِ وَالْإِكْرَامِ','name':'যুল-জালালি ওয়াল-ইকরাম','meaning':'মহিমা ও সম্মানের অধিকারী'},{'id':'86','arabic':'الْمُقْسِطُ','name':'আল-মুকসিত','meaning':'ন্যায়বিচারকারী'},{'id':'87','arabic':'الْجَامِعُ','name':'আল-জামি','meaning':'একত্রকারী'},{'id':'88','arabic':'الْغَنِيُّ','name':'আল-গানী','meaning':'অমুখাপেক্ষী'},{'id':'89','arabic':'الْمُغْنِي','name':'আল-মুগনী','meaning':'অভাবমোচনকারী'},{'id':'90','arabic':'الْمَانِعُ','name':'আল-মানি','meaning':'নিবারণকারী'},
    {'id':'91','arabic':'الضَّارُّ','name':'আদ-দার্','meaning':'ক্ষতি সাধনে সক্ষম'},{'id':'92','arabic':'النَّافِعُ','name':'আন-নাফি','meaning':'উপকারকারী'},{'id':'93','arabic':'النُّورُ','name':'আন-নূর','meaning':'জ্যোতি'},{'id':'94','arabic':'الْهَادِي','name':'আল-হাদী','meaning':'পথপ্রদর্শক'},{'id':'95','arabic':'الْبَدِيعُ','name':'আল-বাদী','meaning':'অনুপম সৃষ্টিকর্তা'},{'id':'96','arabic':'الْبَاقِي','name':'আল-বাকী','meaning':'চিরস্থায়ী'},{'id':'97','arabic':'الْوَارِثُ','name':'আল-ওয়ারিস','meaning':'উত্তরাধিকারী'},{'id':'98','arabic':'الرَّشِيدُ','name':'আর-রশীদ','meaning':'সঠিক পথপ্রদর্শক'},{'id':'99','arabic':'الصَّبُورُ','name':'আস-সবূর','meaning':'পরম ধৈর্যশীল'},
  ];

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
              '${_downloadedCount}/${_audioFiles.length}টি অডিও অফলাইনে প্রস্তুত। ${failed.length}টি আবার চেষ্টা করতে হবে।',
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
              '${_downloadedCount}/${_audioFiles.length}টি অডিও অফলাইনে প্রস্তুত। বাকি অডিওর জন্য আবার Download চাপুন।',
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
