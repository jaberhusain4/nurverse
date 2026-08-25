import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'hadith_chapter_localization.dart';
import 'hadith_service.dart';

/// Loads the complete chapter index directly from the bundled metadata.
/// This deliberately bypasses the older HadithService chapter parser so a
/// valid title such as "Chapter 21 - Actions while Praying" can never be
/// mistaken for a generic chapter number.
class HadithChapterIndexService {
  HadithChapterIndexService._();

  static final HadithChapterIndexService instance = HadithChapterIndexService._();

  final Map<String, Map<String, Map<int, String>>> _cache = {};

  Future<List<HadithChapter>> getChapters(String bookKey, {required String languageCode}) async {
    final language = _normalizeLanguage(languageCode);
    final maps = await _loadBook(bookKey);
    final ids = <int>{
      ...maps['ara']!.keys,
      ...maps['eng']!.keys,
      ...maps['ben']!.keys,
    }..removeWhere((id) => id == 0);

    final result = <HadithChapter>[];
    for (final id in (ids.toList()..sort())) {
      final ar = (maps['ara']![id] ?? '').trim();
      final en = (maps['eng']![id] ?? '').trim();
      final bnSource = (maps['ben']![id] ?? '').trim();

      final title = switch (language) {
        'ar' => _requireTitle(ar, bookKey, id, 'Arabic'),
        'en' => _requireTitle(en, bookKey, id, 'English'),
        _ => _banglaTitle(bnSource: bnSource, english: en, arabic: ar, chapterIndex: id),
      };

      result.add(HadithChapter(
        id: id,
        // The bundled chapter ids are the book/section numbers used by the
        // existing hadith reader. Keeping them here preserves navigation into
        // the existing HadithService without altering its content loader.
        bookNumber: id,
        nameAr: ar,
        nameBn: language == 'bn' ? title : bnSource,
        nameEn: en,
      ));
    }

    if (result.isEmpty) {
      throw StateError('No chapter metadata found for $bookKey.');
    }
    return result;
  }

  Future<Map<String, Map<int, String>>> _loadBook(String bookKey) async {
    final cached = _cache[bookKey];
    if (cached != null) return cached;

    final result = <String, Map<int, String>>{};
    for (final language in const ['ara', 'eng', 'ben']) {
      result[language] = await _loadSections(bookKey, language);
    }
    _cache[bookKey] = result;
    return result;
  }

  Future<Map<int, String>> _loadSections(String bookKey, String language) async {
    final path = 'assets/hadith/$language-$bookKey.json';
    final raw = await rootBundle.loadString(path);
    final decoded = jsonDecode(raw);
    final sections = <int, String>{};

    void add(dynamic value) {
      if (value is! Map) return;
      for (final entry in value.entries) {
        final id = int.tryParse(entry.key.toString());
        final name = entry.value?.toString().trim() ?? '';
        if (id == null || id == 0 || name.isEmpty || _isBareGeneric(name)) continue;
        sections[id] = name;
      }
    }

    if (decoded is Map) {
      add(decoded['sections']);
      final metadata = decoded['metadata'];
      if (metadata is Map) add(metadata['sections']);
    }

    return sections;
  }

  String _banglaTitle({
    required String bnSource,
    required String english,
    required String arabic,
    required int chapterIndex,
  }) {
    if (_isUsableBangla(bnSource)) return _stripPrefix(bnSource);

    final localized = HadithChapterLocalization.localize(
      bengali: bnSource,
      english: english,
      arabic: arabic,
      chapterIndex: chapterIndex,
    ).trim();
    final cleaned = _stripPrefix(localized);
    if (_isUsableBangla(cleaned)) return cleaned;

    // The bundled Bengali files currently contain English chapter metadata for
    // some collections. Do not expose English or a generic placeholder in
    // Bangla mode. Convert any remaining specialised/proper-name wording into
    // Bengali script as a deterministic last-resort label.
    final fallback = _transliterateEnglish(english);
    if (fallback.isNotEmpty) return fallback;

    throw StateError('Missing Bengali chapter title: chapter $chapterIndex');
  }

  String _requireTitle(String value, String bookKey, int id, String language) {
    if (value.isEmpty || _isBareGeneric(value)) {
      throw StateError('Missing $language chapter title: $bookKey/$id');
    }
    return _stripLanguagePrefix(value, language);
  }

  String _stripPrefix(String value) => value
      .replaceFirst(RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*[-—:]\s*'), '')
      .replaceFirst(RegExp(r'^অধ্যায়\s*[০-৯0-9]+\s*[-—:]\s*'), '')
      .trim();

  String _stripLanguagePrefix(String value, String language) {
    if (language == 'English') {
      return value.replaceFirst(RegExp(r'^chapter\s*\d+\s*[-—:]\s*', caseSensitive: false), '').trim();
    }
    return value.replaceFirst(RegExp(r'^الفصل\s*[٠-٩0-9]+\s*[-—:]\s*'), '').trim();
  }

  bool _isUsableBangla(String value) =>
      value.isNotEmpty && !_containsLatin(value) && !_isBanglaGeneric(value);

  bool _isBanglaGeneric(String value) {
    final text = value.trim();
    if (text.isEmpty) return true;
    return RegExp(r'^(অধ্যায়|অধ্যায়)\s*[০-৯0-9]+$').hasMatch(text) ||
        text.contains('অন্যান্য বিষয়') ||
        text.contains('অন্যান্য বিষয়');
  }

  bool _isBareGeneric(String value) {
    final text = value.trim();
    if (text.isEmpty) return true;
    return RegExp(r'^(chapter\s*\d+|অধ্যায়\s*[০-৯0-9]+|অধ্যায়\s*[০-৯0-9]+|الفصل\s*[٠-٩0-9]+)$', caseSensitive: false).hasMatch(text) ||
        text.toLowerCase().contains('other topics') ||
        text.toLowerCase().contains('other subjects') ||
        text.toLowerCase().contains('other matters') ||
        text.toLowerCase().contains('miscellaneous') ||
        text.contains('অন্যান্য বিষয়') ||
        text.contains('অন্যান্য বিষয়');
  }

  bool _containsLatin(String value) => RegExp(r'[A-Za-z]').hasMatch(value);

  String _normalizeLanguage(String code) {
    final value = code.trim().toLowerCase();
    if (value.startsWith('ar')) return 'ar';
    if (value.startsWith('en')) return 'en';
    return 'bn';
  }

  String _transliterateEnglish(String value) {
    var text = value.trim().toLowerCase();
    if (text.isEmpty) return '';

    const wordMap = <String, String>{
      'revelation': 'ওহী',
      'belief': 'ঈমান',
      'faith': 'ঈমান',
      'knowledge': 'ইলম',
      'prayer': 'সালাত',
      'prayers': 'সালাত',
      'praying': 'সালাত',
      'ablution': 'উযূ',
      'ablutions': 'উযূ',
      'bathing': 'গোসল',
      'menstrual': 'হায়েয',
      'tayammum': 'তায়াম্মুম',
      'fasting': 'সিয়াম ও রোযা',
      'zakat': 'যাকাত',
      'hajj': 'হজ্জ',
      'umrah': 'উমরাহ',
      'marriage': 'বিবাহ',
      'divorce': 'তালাক',
      'food': 'খাদ্য',
      'drink': 'পানীয়',
      'drinks': 'পানীয়',
      'medicine': 'চিকিৎসা',
      'dreams': 'স্বপ্ন',
      'funerals': 'জানাযা',
      'inheritance': 'উত্তরাধিকার',
      'witnesses': 'সাক্ষ্য',
      'gifts': 'উপহার',
      'oaths': 'শপথ',
      'vows': 'মানত',
      'jihad': 'জিহাদ',
      'sacrifice': 'কুরবানী',
      'hunting': 'শিকার',
      'mosque': 'মসজিদ',
      'companions': 'সাহাবায়ে কেরাম',
      'prophets': 'নবীগণ',
      'prophet': 'নবী',
      'creation': 'সৃষ্টি',
      'judgments': 'বিচার ও ফয়সালা',
      'punishments': 'শাস্তি',
      'leadership': 'নেতৃত্ব',
      'justice': 'ন্যায়বিচার',
      'allah': 'আল্লাহ',
      'messenger': 'রাসূল',
    };

    for (final entry in wordMap.entries) {
      text = text.replaceAll(RegExp(r'\b' + RegExp.escape(entry.key) + r'\b', caseSensitive: false), entry.value);
    }

    text = text.replaceAllMapped(RegExp(r"[a-z][a-z'-]*", caseSensitive: false), (m) {
      final word = m.group(0)!;
      final chars = word.split('').map((c) {
        const map = <String, String>{
          'a': 'আ', 'b': 'ব', 'c': 'ক', 'd': 'দ', 'e': 'এ', 'f': 'ফ', 'g': 'গ',
          'h': 'হ', 'i': 'ই', 'j': 'জ', 'k': 'ক', 'l': 'ল', 'm': 'ম', 'n': 'ন',
          'o': 'ও', 'p': 'প', 'q': 'ক', 'r': 'র', 's': 'স', 't': 'ত', 'u': 'উ',
          'v': 'ভ', 'w': 'ও', 'x': 'ক্স', 'y': 'ইয়', 'z': 'জ',
        };
        return map[c] ?? c;
      }).join();
      return chars;
    });

    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\u0980-\u09FF\s()\-:,]'), '')
        .trim();
  }

  void clearCache() => _cache.clear();
}
