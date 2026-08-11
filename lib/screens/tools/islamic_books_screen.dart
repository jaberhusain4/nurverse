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
    _BookResource(
      title: 'উলূমুল কুরআন ও উলূমুল হাদীস',
      description: 'বাংলাদেশ ওপেন ইউনিভার্সিটির বাংলা ইসলামিক পাঠ্যবই।',
      source: 'Wikimedia Commons • CC BY 4.0',
      icon: Icons.auto_stories_rounded,
      url: 'https://commons.wikimedia.org/wiki/File:উলূমুল_কুরআন_ও_উলূমুল_হাদীস.pdf',
    ),
    _BookResource(
      title: 'ইসলাম-কাহিনী',
      description: 'কাজী আকরম হোসেনের বাংলা ইসলামিক গ্রন্থ।',
      source: 'Wikimedia Commons • Public Domain',
      icon: Icons.menu_book_rounded,
      url: 'https://commons.wikimedia.org/wiki/File:ইসলাম-কাহিনী_–_কাজী_আকরম_হোসেন_(১৯৪৬).pdf',
    ),
  ];

  static const _downloadBooks = <_BookResource>[
    _BookResource(
      title: 'ইসলামি অর্থব্যবস্থা',
      description: 'বাংলা ইসলামিক পাঠ্যবই — CC BY 4.0 PDF।',
      source: 'Wikimedia Commons • CC BY 4.0',
      icon: Icons.download_for_offline_rounded,
      url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/ইসলামি_অর্থব্যবস্থা.pdf',
      isPdf: true,
    ),
    _BookResource(
      title: 'এক নজরে ইসলাম',
      description: 'বাংলা ইসলাম বিষয়ক গ্রন্থ — CC BY-SA 4.0 PDF।',
      source: 'Wikimedia Commons • CC BY-SA 4.0',
      icon: Icons.download_for_offline_rounded,
      url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/এক_নজরে_ইসলাম.pdf',
      isPdf: true,
    ),
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
    final keys = _downloadBooks.map(_storageKey);
    final paths = <String, String>{};
    for (final key in keys) {
      final path = prefs.getString(key);
      if (path != null && await File(path).exists()) {
        paths[_titleFromKey(key)] = path;
      }
    }
    if (mounted) setState(() => _downloadedPaths.addAll(paths));
  }

  String _storageKey(_BookResource book) =>
      'nurverse_islamic_book_${book.title.hashCode}';

  String _titleFromKey(String key) {
    for (final book in _downloadBooks) {
      if (_storageKey(book) == key) return book.title;
    }
    return key;
  }

  Future<void> _openBook(_BookResource book) async {
    final localPath = _downloadedPaths[book.title];
    if (localPath != null && await File(localPath).exists()) {
      _pushReader(book, localFilePath: localPath);
      return;
    }
    if (book.isPdf) {
      await _downloadBook(book, openAfterDownload: true);
    } else {
      _pushReader(book);
    }
  }

  void _pushReader(_BookResource book, {String? localFilePath}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IslamicBookReaderScreen(
          title: book.title,
          url: book.url,
          isPdf: book.isPdf,
          localFilePath: localFilePath,
        ),
      ),
    );
  }

  Future<void> _downloadBook(
    _BookResource book, {
    bool openAfterDownload = false,
  }) async {
    if (_downloadProgress.containsKey(book.title)) return;

    setState(() => _downloadProgress[book.title] = 0);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final booksDirectory = Directory(p.join(directory.path, 'islamic_books'));
      await booksDirectory.create(recursive: true);

      final file = File(p.join(booksDirectory.path, '${book.title}.pdf'));
      final request = http.Request('GET', Uri.parse(book.url));
      request.headers['User-Agent'] =
          'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 Chrome/151 Mobile Safari/537.36';
      final response = await request.send();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('HTTP ${response.statusCode}');
      }

      final total = response.contentLength;
      var received = 0;
      final sink = file.openWrite();
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (mounted && total != null && total > 0) {
            setState(() => _downloadProgress[book.title] = received / total);
          }
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

      _showMessage('“${book.title}” ডাউনলোড সম্পন্ন হয়েছে।');
      if (openAfterDownload) {
        _pushReader(book, localFilePath: file.path);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _downloadProgress.remove(book.title));
      _showMessage('বইটি ডাউনলোড করা যায়নি। ইন্টারনেট সংযোগ পরীক্ষা করুন।');
    }
  }

  Future<void> _deleteBook(_BookResource book) async {
    final localPath = _downloadedPaths[book.title];
    if (localPath == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('বই মুছে ফেলবেন?'),
        content: Text('“${book.title}” ফোনের offline storage থেকে মুছে যাবে।'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('না'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('মুছে ফেলুন'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await File(localPath).delete().catchError((_) {});
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey(book));
    if (mounted) {
      setState(() => _downloadedPaths.remove(book.title));
      _showMessage('বইটি offline storage থেকে মুছে ফেলা হয়েছে।');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final downloaded = _downloadBooks
        .where((book) => _downloadedPaths.containsKey(book.title))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ইসলামিক বই'),
        actions: [
          IconButton(
            tooltip: 'বইয়ের উৎস',
            onPressed: () => _showSourceInfo(context),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          const _BooksIntroCard(),
          const SizedBox(height: 22),
          const _SectionHeader(
            title: 'Read E-Book',
            subtitle: 'অনলাইনে পড়ার জন্য নির্বাচিত বাংলা বই',
            icon: Icons.menu_book_rounded,
          ),
          const SizedBox(height: 10),
          ..._readBooks.map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BookCard(
                book: book,
                actionLabel: 'পড়ুন',
                onTap: () => _openBook(book),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _SectionHeader(
            title: 'Download E-Book',
            subtitle: 'ডাউনলোড করে offline-এ পড়ুন',
            icon: Icons.download_rounded,
          ),
          const SizedBox(height: 10),
          ..._downloadBooks.map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BookCard(
                book: book,
                actionLabel: _downloadProgress.containsKey(book.title)
                    ? 'ডাউনলোড হচ্ছে'
                    : _downloadedPaths.containsKey(book.title)
                        ? 'Offline-এ পড়ুন'
                        : 'ডাউনলোড',
                progress: _downloadProgress[book.title],
                onTap: () => _openBook(book),
                onDownload: _downloadedPaths.containsKey(book.title)
                    ? () => _deleteBook(book)
                    : () => _downloadBook(book),
                downloaded: _downloadedPaths.containsKey(book.title),
              ),
            ),
          ),
          if (downloaded.isNotEmpty) ...[
            const SizedBox(height: 10),
            const _SectionHeader(
              title: 'Offline Books',
              subtitle: 'ইন্টারনেট ছাড়াই পড়ার জন্য সংরক্ষিত বই',
              icon: Icons.offline_pin_rounded,
            ),
            const SizedBox(height: 10),
            ...downloaded.map(
              (book) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BookCard(
                  book: book,
                  actionLabel: 'পড়ুন',
                  onTap: () => _openBook(book),
                  downloaded: true,
                  onDownload: () => _deleteBook(book),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showSourceInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'বইয়ের উৎস',
              style: TextStyle(
                color: context.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'NurVerse আপাতত শুধু বাংলা ভাষার নির্বাচিত ইসলামিক বই রাখছে। Download E-Book অংশে উন্মুক্ত লাইসেন্সের PDF রাখা হয়েছে, যাতে ডাউনলোড করে offline-এ পড়া যায়।',
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookResource {
  final String title;
  final String description;
  final String source;
  final IconData icon;
  final String url;
  final bool isPdf;

  const _BookResource({
    required this.title,
    required this.description,
    required this.source,
    required this.icon,
    required this.url,
    this.isPdf = false,
  });
}

class _BooksIntroCard extends StatelessWidget {
  const _BooksIntroCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: AppColors.seaBlue,
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'জ্ঞানভাণ্ডার',
                    style: TextStyle(
                      color: context.primaryTextColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'শুধু বাংলা ভাষার নির্বাচিত ইসলামিক বই — পড়ুন ও প্রয়োজনমতো ডাউনলোড করুন।',
                    style: TextStyle(
                      color: context.secondaryTextColor,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.seaBlue.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.seaBlueDark, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.primaryTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: context.secondaryTextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final _BookResource book;
  final String actionLabel;
  final VoidCallback onTap;
  final VoidCallback? onDownload;
  final double? progress;
  final bool downloaded;

  const _BookCard({
    required this.book,
    required this.actionLabel,
    required this.onTap,
    this.onDownload,
    this.progress,
    this.downloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 58,
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.seaBlue.withValues(alpha: 0.14)
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(book.icon, color: AppColors.seaBlueDark, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.primaryTextColor,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      book.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.secondaryTextColor,
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      downloaded ? 'Offline সংরক্ষিত' : book.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.secondaryTextColor,
                        fontSize: 10.5,
                      ),
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 9),
                      LinearProgressIndicator(value: progress),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (onDownload != null)
                IconButton(
                  tooltip: downloaded ? 'Offline বই মুছুন' : 'ডাউনলোড',
                  onPressed: progress != null ? null : onDownload,
                  icon: Icon(
                    downloaded
                        ? Icons.delete_outline_rounded
                        : Icons.download_rounded,
                  ),
                ),
              const SizedBox(width: 2),
              Flexible(
                child: FilledButton(
                  onPressed: progress != null ? null : onTap,
                  child: Text(
                    actionLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
