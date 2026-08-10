// lib/screens/hadith/hadith_chapters_screen.dart

import 'package:flutter/material.dart';

import '../../services/hadith_chapter_stats_service.dart';
import '../../services/hadith_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'hadith_list_screen.dart';

class HadithChaptersScreen extends StatefulWidget {
  final HadithBook book;

  const HadithChaptersScreen({super.key, required this.book});

  @override
  State<HadithChaptersScreen> createState() => _HadithChaptersScreenState();
}

class _HadithChaptersScreenState extends State<HadithChaptersScreen> {
  List<HadithChapter>? _chapters;
  Map<int, HadithChapterStats> _stats = const {};
  String? _error;
  bool _isLoading = true;
  bool _didLoad = false;

  String get _loadingText => 'অধ্যায় লোড হচ্ছে...';
  String get _errorText => 'অধ্যায় লোড করা যায়নি। আবার চেষ্টা করুন।';
  String get _retryText => 'আবার চেষ্টা করুন';
  String get _emptyText => 'এই গ্রন্থের কোনো অধ্যায় পাওয়া যায়নি।';
  String get _chapterLabel => 'অধ্যায়';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoad) {
      _didLoad = true;
      _load();
    }
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final chapters = await HadithService.instance.getChapters(
        widget.book.key,
        languageCode: 'bn',
      );

      final stats = await HadithChapterStatsService.instance.getAllStats(
        widget.book.key,
      );

      if (!mounted) return;

      setState(() {
        _chapters = chapters;
        _stats = stats;
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _chapters = null;
        _stats = const {};
        _error = _errorText;
        _isLoading = false;
      });
    }
  }

  void _openChapter(HadithChapter chapter) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HadithListScreen(book: widget.book, chapter: chapter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.book.nameBn,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
            const SizedBox(height: 14),
            Text(
              _loadingText,
              style: TextStyle(
                fontSize: 13,
                color: context.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) return _buildErrorState();

    final chapters = _chapters ?? const <HadithChapter>[];
    if (chapters.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ChapterCard(
              chapter: chapter,
              index: index,
              title: _chapterTitle(chapter, index),
              fallbackTitle: '$_chapterLabel ${_bnDigits(index + 1)}',
              stats: _stats[chapter.id],
              onTap: () => _openChapter(chapter),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 46,
              color: context.secondaryTextColor,
            ),
            const SizedBox(height: 14),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: context.primaryTextColor,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_retryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.35,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _emptyText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.55,
                    color: context.secondaryTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _chapterTitle(HadithChapter chapter, int index) {
    final bangla = chapter.nameBn.trim();

    if (bangla.isNotEmpty && !_looksEnglish(bangla)) {
      return bangla;
    }

    final translated = _translateChapterTitle(bangla);
    if (translated.isNotEmpty) {
      return translated;
    }

    final english = chapter.nameEn.trim();
    final translatedEnglish = _translateChapterTitle(english);
    if (translatedEnglish.isNotEmpty) {
      return translatedEnglish;
    }

    if (chapter.nameAr.trim().isNotEmpty) {
      return chapter.nameAr.trim();
    }

    // Never expose an English chapter title in the Bangla UI.
    return '$_chapterLabel ${_bnDigits(index + 1)}';
  }

  bool _looksEnglish(String value) {
    if (value.isEmpty) return false;

    final latin = RegExp(r'[A-Za-z]');
    return latin.hasMatch(value);
  }

  String _translateChapterTitle(String value) {
    final key = value.trim().toLowerCase();
    if (key.isEmpty) return '';

    return _chapterTranslations[key] ?? '';
  }

  static const Map<String, String> _chapterTranslations = {
    // Sahih al-Bukhari
    'revelation': 'ওহীর সূচনা',
    'belief': 'ঈমান',
    'knowledge': 'ইলম ও জ্ঞান',
    "ablutions (wudu')": 'উযূ',
    'bathing (ghusl)': 'গোসল',
    'menstrual periods': 'হায়েয',
    'rubbing hands and feet with dust (tayammum)': 'তায়াম্মুম',
    'prayers (salat)': 'সালাত',
    'times of the prayers': 'সালাতের ওয়াক্ত',
    'call to prayers (adhaan)': 'আযান',
    'friday prayer': 'জুমুআর সালাত',
    'fear prayer': 'ভয়ের সময়ের সালাত',
    'the two festivals (eids)': 'দুই ঈদের সালাত',
    'witr prayer': 'বিতর সালাত',
    'invoking allah for rain (istisqaa)': 'বৃষ্টির জন্য দোয়া (ইস্তিসকা)',
    'eclipses': 'সূর্য ও চন্দ্রগ্রহণ',
    "prostration during recital of qur'an": 'কুরআন তিলাওয়াতের সময় সিজদা',
    'shortening the prayers (at-taqseer)': 'সালাত কসর করা',
    'prayer at night (tahajjud)': 'রাতের সালাত (তাহাজ্জুদ)',
    'virtues of prayer at masjid makkah and madinah': 'মক্কা ও মদিনার মসজিদে সালাতের ফযীলত',
    'actions while praying': 'সালাতের সময়ের আমল',
    'forgetfulness in prayer': 'সালাতে ভুল-ত্রুটি',
    'funerals (al-janaa\'iz)': 'জানাযা',
    'obligatory charity tax (zakat)': 'যাকাত',
    'hajj (pilgrimage)': 'হজ্জ',
    '`umrah (minor pilgrimage)': 'উমরাহ',
    'pilgrims prevented from completing the pilgrimage': 'হজ্জ সম্পন্ন করতে বাধাগ্রস্ত হাজীদের বিধান',
    'penalty of hunting while on pilgrimage': 'ইহরাম অবস্থায় শিকার করার কাফফারা',
    'virtues of madinah': 'মদিনার ফযীলত',
    'fasting': 'সিয়াম ও রোযা',
    'praying at night in ramadaan (taraweeh)': 'রমযানে রাতের সালাত (তারাবীহ)',
    'virtues of the night of qadr': 'লাইলাতুল কদরের ফযীলত',
    "retiring to a mosque for remembrance of allah (i'tikaf)": 'আল্লাহর স্মরণের জন্য মসজিদে ইতিকাফ',
    'sales and trade': 'ক্রয়-বিক্রয় ও ব্যবসা',
    'sales in which a price is paid for goods to be delivered later (as-salam)': 'অগ্রিম মূল্য পরিশোধের মাধ্যমে ক্রয়-বিক্রয় (সালাম)',
    "shuf'a": 'শুফআ',
    'hiring': 'ভাড়া ও শ্রমিক নিয়োগ',
    'transferance of a debt from one person to another (al-hawaala)': 'ঋণ এক ব্যক্তি থেকে অন্য ব্যক্তির কাছে হস্তান্তর (হাওয়ালা)',
    'kafalah': 'জামিন ও কাফালাহ',
    'representation, authorization, business by proxy': 'প্রতিনিধিত্ব, অনুমোদন ও代理 ব্যবসা',
    'agriculture': 'কৃষি',
    'distribution of water': 'পানি বণ্টন ও সেচ',
    'loans, payment of loans, freezing of property, bankruptcy': 'ঋণ, ঋণ পরিশোধ, সম্পত্তি জব্দ ও দেউলিয়াত্ব',
    'khusoomaat': 'কলহ-বিবাদ ও বিরোধ নিষ্পত্তি',
    'lost things picked up by someone (luqatah)': 'কুড়িয়ে পাওয়া বস্তু (লুকাতাহ)',
    'oppressions': 'জুলুম ও নির্যাতন',
    'partnership': 'অংশীদারিত্ব',
    'mortgaging': 'বন্ধক রাখা',
    'manumission of slaves': 'দাসমুক্তি',
    'makaatib': 'মুকাতাব',
    'gifts': 'উপহার',
    'witnesses': 'সাক্ষ্য',
    'peacemaking': 'মীমাংসা ও সন্ধি',
    'conditions': 'শর্তাবলি',
    'wills and testaments (wasaayaa)': 'অছিয়ত ও উইল',
    'fighting for the cause of allah (jihaad)': 'আল্লাহর পথে জিহাদ',
    'one-fifth of booty to the cause of allah (khumus)': 'গনীমতের এক-পঞ্চমাংশ',
    "jizyah and mawaada'ah": 'জিযিয়া ও সন্ধিচুক্তি',
    'beginning of creation': 'সৃষ্টির সূচনা',
    'prophets': 'নবীগণ',
    'virtues and merits of the prophet (pbuh) and his companions': 'নবী ﷺ ও সাহাবায়ে কেরামের ফযীলত',
    'companions of the prophet': 'রাসূল ﷺ-এর সাহাবীগণ',
    'merits of the helpers in madinah (ansaar)': 'মদিনার আনসারদের ফযীলত',
    'military expeditions led by the prophet (pbuh) (al-maghaazi)': 'নবী ﷺ-এর নেতৃত্বে সামরিক অভিযান (মাগাযী)',
    'prophetic commentary on the qur\'an (tafseer of the prophet (pbuh))': 'কুরআনের নববী তাফসীর',
    'virtues of the qur\'an': 'কুরআনের ফযীলত',
    'wedlock, marriage (nikaah)': 'বিবাহ ও নিকাহ',
    'divorce': 'তালাক',
    'supporting the family': 'পরিবারের ভরণ-পোষণ',
    'food, meals': 'খাদ্য ও পানাহার',
    'sacrifice on occasion of birth (`aqiqa)': 'জন্ম উপলক্ষে আকীকা',
    'hunting, slaughtering': 'শিকার ও যবেহ',
    'al-adha festival sacrifice (adaahi)': 'কুরবানির বিধান',
    'drinks': 'পানীয়',
    'patients': 'রোগী ও অসুস্থতা',
    'medicine': 'চিকিৎসা',
    'dress': 'পোশাক-পরিচ্ছদ',
    'good manners and form (al-adab)': 'উত্তম আখলাক ও শিষ্টাচার',
    'asking permission': 'অনুমতি গ্রহণ',
    'invocations': 'দোয়া ও যিকির',
    'to make the heart tender (ar-riqaq)': 'হৃদয় কোমলকারী বিষয়সমূহ (রীকাক)',
    'divine will (al-qadar)': 'তাকদীর',
    'oaths and vows': 'শপথ ও মানত',
    'expiation for unfulfilled oaths': 'শপথ ভঙ্গের কাফফারা',
    'laws of inheritance (al-faraa\'id)': 'উত্তরাধিকার আইন (ফারায়েয)',
    'limits and punishments set by allah (hudood)': 'আল্লাহ নির্ধারিত দণ্ডবিধি (হুদূদ)',
    'blood money (ad-diyat)': 'রক্তপণ (দিয়াত)',
    'apostates': 'ধর্মত্যাগী',
    '(statements made under) coercion': 'জবরদস্তির অধীনে প্রদত্ত বক্তব্য',
    'tricks': 'কৌশল ও হিলা',
    'interpretation of dreams': 'স্বপ্নের ব্যাখ্যা',
    'afflictions and the end of the world': 'ফিতনা ও কিয়ামতের আলামত',
    'judgments (ahkaam)': 'বিচার ও বিধান (আহকাম)',
    'wishes': 'আকাঙ্ক্ষা',
    'accepting information given by a truthful person': 'সত্যবাদী ব্যক্তির সংবাদ গ্রহণ',
    'holding fast to the qur\'an and sunnah': 'কুরআন ও সুন্নাহকে দৃঢ়ভাবে ধারণ',
    'oneness, uniqueness of allah (tawheed)': 'আল্লাহর একত্ব ও তাওহীদ',

    // Common chapter names used by the other collections.
    'purification': 'পবিত্রতা',
    'prayer': 'সালাত',
    'charity': 'যাকাত',
    'fasting': 'সিয়াম',
    'pilgrimage': 'হজ্জ',
    'marriage': 'বিবাহ',
    'divorce': 'তালাক',
    'judgements': 'বিচার ও বিধান',
    'judgments': 'বিচার ও বিধান',
    'manners': 'শিষ্টাচার',
    'supplications': 'দোয়া',
    'remembrance': 'যিকির',
    'faith': 'ঈমান',
    'knowledge and virtue': 'ইলম ও ফযীলত',
    'virtues': 'ফযীলত',
    'testimony': 'সাক্ষ্য',
    'oaths': 'শপথ',
    'inheritance': 'উত্তরাধিকার',
    'business': 'ব্যবসা ও লেনদেন',
    'transactions': 'লেনদেন',
    'foods': 'খাদ্য',
    'drinks': 'পানীয়',
    'medicine': 'চিকিৎসা',
    'clothing': 'পোশাক',
    'funerals': 'জানাযা',
    'zakat': 'যাকাত',
    'hajj': 'হজ্জ',
    'umrah': 'উমরাহ',
    'jihad': 'জিহাদ',
    'tafsir': 'তাফসীর',
    'quran': 'কুরআন',
    'tawhid': 'তাওহীদ',
  };

  static String _bnDigits(int value) {
    const western = '0123456789';
    const bengali = '০১২৩৪৫৬৭৮৯';

    return value
        .toString()
        .split('')
        .map((digit) => bengali[western.indexOf(digit)])
        .join();
  }
}

class _ChapterCard extends StatelessWidget {
  final HadithChapter chapter;
  final int index;
  final String title;
  final String fallbackTitle;
  final HadithChapterStats? stats;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.title,
    required this.fallbackTitle,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title.trim().isNotEmpty ? title.trim() : fallbackTitle;

    final statsText = stats == null
        ? 'হাদিসের সংখ্যা পাওয়া যায়নি'
        : 'মোট ${_bnDigits(stats!.count)}টি হাদিস • ${_bnDigits(stats!.firstHadith)} থেকে ${_bnDigits(stats!.lastHadith)}';

    return NvCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.seaBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          alignment: Alignment.center,
          child: Text(
            _bnDigits(index + 1),
            style: const TextStyle(
              color: AppColors.seaBlue,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
        title: Text(
          displayTitle,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            statsText,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: context.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.seaBlue,
        ),
      ),
    );
  }

  static String _bnDigits(int value) {
    const western = '0123456789';
    const bengali = '০১২৩৪৫৬৭৮৯';

    return value
        .toString()
        .split('')
        .map((digit) => bengali[western.indexOf(digit)])
        .join();
  }
}
