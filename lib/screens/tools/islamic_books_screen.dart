import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_theme.dart';
import 'islamic_book_reader_screen.dart';

class IslamicBooksScreen extends StatefulWidget {
  const IslamicBooksScreen({super.key});

  @override
  State<IslamicBooksScreen> createState() => _IslamicBooksScreenState();
}

class _IslamicBooksScreenState extends State<IslamicBooksScreen> {
  static const _readBooks = <_BookResource>[
    _BookResource(title: 'উলূমুল কুরআন ও উলূমুল হাদীস', description: 'বাংলাদেশ ওপেন ইউনিভার্সিটির বাংলা ইসলামিক পাঠ্যবই।', source: 'Wikimedia Commons • CC BY 4.0', icon: Icons.auto_stories_rounded, url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/উলূমুল_কুরআন_ও_উলূমুল_হাদীস.pdf', isPdf: true),
    _BookResource(title: 'ইসলাম-কাহিনী', description: 'কাজী আকরম হোসেনের বাংলা ইসলামিক গ্রন্থ।', source: 'Wikimedia Commons • Public Domain', icon: Icons.menu_book_rounded, url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/ইসলাম-কাহিনী_–_কাজী_আকরম_হোসেন_(১৯৪৬).pdf', isPdf: true),
    _BookResource(title: 'কোরআনের গল্প', description: 'বন্দে আলি মিয়ার বাংলা ইসলামিক গ্রন্থ।', source: 'Wikimedia Commons • Bengali PDF', icon: Icons.auto_stories_rounded, url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/কোরাণের_গল্প_-_বন্দে_আলি_মিয়া.pdf', isPdf: true),
    _BookResource(title: 'কোরআন শরীফ — প্রথম খণ্ড', description: 'মোহাম্মদ আকরম খাঁর বাংলা অনুবাদগ্রন্থের প্রথম খণ্ড।', source: 'Wikimedia Commons • Bengali PDF', icon: Icons.library_books_rounded, url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/কোরআন_শরীফ_(প্রথম_খণ্ড)_-_মোহাম্মদ_আকরম_খাঁ.pdf', isPdf: true),
    _BookResource(title: 'কোরআন শরীফ — দ্বিতীয় খণ্ড', description: 'মোহাম্মদ আকরম খাঁর বাংলা অনুবাদগ্রন্থের দ্বিতীয় খণ্ড।', source: 'Wikimedia Commons • Bengali PDF', icon: Icons.library_books_rounded, url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/কোরআন_শরীফ_(দ্বিতীয়_খণ্ড)_-_মোহাম্মদ_আকরম_খাঁ.pdf', isPdf: true),
    _BookResource(title: 'ইসলামি অর্থব্যবস্থা', description: 'বাংলা ইসলামিক পাঠ্যবই — সরাসরি reader-এ পড়া যাবে।', source: 'Wikimedia Commons • CC BY 4.0', icon: Icons.account_balance_rounded, url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/ইসলামি_অর্থব্যবস্থা.pdf', isPdf: true),
    _BookResource(title: 'এক নজরে ইসলাম', description: 'বাংলা ইসলাম বিষয়ক গ্রন্থ — সরাসরি reader-এ পড়া যাবে।', source: 'Wikimedia Commons • CC BY-SA 4.0', icon: Icons.menu_book_rounded, url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/এক_নজরে_ইসলাম.pdf', isPdf: true),
  ];

  static const _downloadBooks = <_BookResource>[
    _BookResource(title: 'মিশকাতুল মাসাবীহ — বাংলা অনুবাদসহ', description: 'কওমি ধারায় বহুল পঠিত হাদিসগ্রন্থ। source page-এ একাধিক PDF খণ্ডের Download option রয়েছে।', source: 'তাওহীদের ডাক • PDF download source', icon: Icons.download_for_offline_rounded, url: 'https://www.tauhiderdak.com/mishkatul-masabih-bangla', isDownloadPage: true),
  ];

  final Map<String, double> _downloadProgress = {};
  final Map<String, String> _downloadedPaths = {};

  @override
  void initState() {
    super.initState();
    _loadDownloadedBooks();
  }

  Future<void> _loadDownloadedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = <String, String>{};
    for (final book in _downloadBooks) {
      final path = prefs.getString(_storageKey(book));
      if (path != null && await File(path).exists()) paths[book.title] = path;
    }
    if (mounted) setState(() => _downloadedPaths.addAll(paths));
  }

  String _storageKey(_BookResource book) => 'nurverse_islamic_book_${book.title.hashCode}';

  Future<void> _openBook(_BookResource book) async {
    final localPath = _downloadedPaths[book.title];
    if (localPath != null && await File(localPath).exists()) {
      _pushReader(book, localFilePath: localPath);
      return;
    }
    _pushReader(book);
  }

  void _pushReader(_BookResource book, {String? localFilePath}) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => IslamicBookReaderScreen(title: book.title, url: book.url, isPdf: book.isPdf, localFilePath: localFilePath)));
  }

  Future<void> _downloadBook(_BookResource book) async {
    if (_downloadProgress.containsKey(book.title)) return;

    // Mishkatul Masabih is currently a multi-volume download source page,
    // not a single PDF URL. Open it inside NurVerse so the user can choose
    // the required volume without leaving the app.
    if (book.isDownloadPage) {
      _pushReader(book);
      return;
    }

    setState(() => _downloadProgress[book.title] = 0);
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      final baseDirectory = downloadsDirectory ?? await getApplicationDocumentsDirectory();
      final booksDirectory = Directory(p.join(baseDirectory.path, 'NurVerse', 'Islamic Books'));
      await booksDirectory.create(recursive: true);

      final safeFileName = _safeFileName(book.title);
      final file = File(p.join(booksDirectory.path, '$safeFileName.pdf'));
      final request = http.Request('GET', Uri.parse(book.url));
      request.headers['User-Agent'] = 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 Chrome/151 Mobile Safari/537.36';
      final response = await request.send();
      if (response.statusCode < 200 || response.statusCode >= 300) throw HttpException('HTTP ${response.statusCode}');

      final total = response.contentLength;
      var received = 0;
      final sink = file.openWrite();
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (mounted && total != null && total > 0) setState(() => _downloadProgress[book.title] = received / total);
        }
      } finally {
        await sink.close();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey(book), file.path);
      if (!mounted) return;
      setState(() {
        _downloadedPaths[book.title] = file.path;
        _downloadProgress.remove(book.title);
      });
      _showMessage('“${book.title}” Download complete — NurVerse/Islamic Books-এ সংরক্ষিত হয়েছে।');
    } catch (_) {
      if (!mounted) return;
      setState(() => _downloadProgress.remove(book.title));
      _showMessage('বইটি ডাউনলোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করুন।');
    }
  }

  String _safeFileName(String value) => value.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').replaceAll(RegExp(r'\s+'), ' ').trim();

  Future<void> _deleteBook(_BookResource book) async {
    final localPath = _downloadedPaths[book.title];
    if (localPath == null) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('বই মুছে ফেলবেন?'), content: Text('“${book.title}” NurVerse-এর download storage থেকে মুছে যাবে।'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('মুছে ফেলুন'))]));
    if (confirmed != true) return;
    try { await File(localPath).delete(); } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(book));
    if (mounted) {
      setState(() => _downloadedPaths.remove(book.title));
      _showMessage('বইটি offline storage থেকে মুছে ফেলা হয়েছে।');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final downloaded = _downloadBooks.where((book) => _downloadedPaths.containsKey(book.title)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('ইসলামিক বই'), actions: [IconButton(tooltip: 'বইয়ের উৎস', onPressed: () => _showSourceInfo(context), icon: const Icon(Icons.info_outline_rounded))]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          const _BooksIntroCard(),
          const SizedBox(height: 22),
          const _SectionHeader(title: 'Read E-Book', subtitle: 'নির্বাচিত বাংলা ইসলামিক ও কওমি ধারার বই — সরাসরি পড়ুন', icon: Icons.menu_book_rounded),
          const SizedBox(height: 10),
          ..._readBooks.map((book) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _BookCard(book: book, actionLabel: 'পড়ুন', onTap: () => _openBook(book)))),
          const SizedBox(height: 10),
          const _SectionHeader(title: 'Download E-Book', subtitle: 'যেসব বই Download source থেকে সংগ্রহ করতে হয়', icon: Icons.download_rounded),
          const SizedBox(height: 10),
          ..._downloadBooks.map((book) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _BookCard(book: book, actionLabel: 'Download source', progress: _downloadProgress[book.title], onTap: () => _openBook(book), onDownload: _downloadedPaths.containsKey(book.title) ? () => _deleteBook(book) : () => _downloadBook(book), downloaded: _downloadedPaths.containsKey(book.title)))),
          if (downloaded.isNotEmpty) ...[
            const SizedBox(height: 10),
            const _SectionHeader(title: 'Offline Books', subtitle: 'ডিভাইসে সংরক্ষিত বই — ইন্টারনেট ছাড়াই পড়ুন', icon: Icons.offline_pin_rounded),
            const SizedBox(height: 10),
            ...downloaded.map((book) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _BookCard(book: book, actionLabel: 'পড়ুন', onTap: () => _openBook(book), downloaded: true, onDownload: () => _deleteBook(book)))),
          ],
        ],
      ),
    );
  }

  void _showSourceInfo(BuildContext context) {
    showModalBottomSheet<void>(context: context, showDragHandle: true, builder: (context) => Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('বইয়ের উৎস', style: TextStyle(color: context.primaryTextColor, fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 8), Text('NurVerse আপাতত বাংলা ভাষার নির্বাচিত ইসলামিক বই রাখছে। সরাসরি পড়ার বইগুলো PDF reader-এ খোলা হয়। মিশকাতুল মাসাবীহ-এর মতো multi-volume Download source বইগুলো NurVerse-এর ভেতরের reader-এ source page হিসেবে খোলা হয়, যাতে ব্যবহারকারী প্রয়োজনীয় খণ্ড নির্বাচন করতে পারেন।', style: TextStyle(color: context.secondaryTextColor, fontSize: 13, height: 1.55))]));
  }
}

class _BookResource {
  final String title;
  final String description;
  final String source;
  final IconData icon;
  final String url;
  final bool isPdf;
  final bool isDownloadPage;

  const _BookResource({required this.title, required this.description, required this.source, required this.icon, required this.url, this.isPdf = false, this.isDownloadPage = false});
}

class _BooksIntroCard extends StatelessWidget {
  const _BooksIntroCard();

  @override
  Widget build(BuildContext context) {
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.auto_stories_rounded, color: AppColors.seaBlue, size: 25)), const SizedBox(width: 14), Expanded(child: Text('নির্বাচিত বাংলা ইসলামিক বই — সরাসরি পড়ুন অথবা Download source থেকে বই সংগ্রহ করুন।', style: TextStyle(color: context.secondaryTextColor, fontSize: 13, height: 1.5)))])));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20, color: AppColors.seaBlue), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: context.primaryTextColor, fontSize: 16, fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 12))]))]);
  }
}

class _BookCard extends StatelessWidget {
  final _BookResource book;
  final String actionLabel;
  final VoidCallback onTap;
  final VoidCallback? onDownload;
  final double? progress;
  final bool downloaded;

  const _BookCard({required this.book, required this.actionLabel, required this.onTap, this.onDownload, this.progress, this.downloaded = false});

  @override
  Widget build(BuildContext context) {
    return Card(child: InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: Padding(padding: const EdgeInsets.fromLTRB(15, 15, 12, 13), child: Row(children: [Container(width: 46, height: 54, decoration: BoxDecoration(color: AppColors.seaBlue.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(13)), child: Icon(book.icon, color: AppColors.seaBlue)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.primaryTextColor, fontSize: 15, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(book.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 12, height: 1.4)), const SizedBox(height: 5), Text(book.source, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 10.5)), if (progress != null) ...[const SizedBox(height: 8), LinearProgressIndicator(value: progress)]])), const SizedBox(width: 8), Column(mainAxisSize: MainAxisSize.min, children: [IconButton(tooltip: actionLabel, onPressed: progress != null ? null : onTap, icon: Icon(downloaded ? Icons.offline_pin_rounded : book.isDownloadPage ? Icons.open_in_new_rounded : Icons.menu_book_rounded)), if (onDownload != null) IconButton(tooltip: downloaded ? 'মুছে ফেলুন' : actionLabel, onPressed: progress != null ? null : onDownload, icon: Icon(downloaded ? Icons.delete_outline_rounded : Icons.download_rounded))])])));
  }
}
