import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'islamic_book_reader_screen.dart';

class IslamicBooksScreen extends StatelessWidget {
  const IslamicBooksScreen({super.key});

  static const _readBooks = <_BookResource>[
    _BookResource(
      title: 'উলূমুল কুরআন ও উলূমুল হাদীস',
      description: 'বাংলাদেশ ওপেন ইউনিভার্সিটির বাংলা ইসলামিক পাঠ্যবই।',
      source: 'Wikimedia Commons • CC BY 4.0',
      icon: Icons.auto_stories_rounded,
      url: 'https://commons.wikimedia.org/wiki/File:উলূমুল_কুরআন_ও_উলূমুল_হাদীস.pdf',
      isPdf: false,
    ),
    _BookResource(
      title: 'ইসলাম-কাহিনী',
      description: 'কাজী আকরম হোসেনের বাংলা ইসলামিক গ্রন্থ।',
      source: 'Wikimedia Commons • Public Domain',
      icon: Icons.menu_book_rounded,
      url: 'https://commons.wikimedia.org/wiki/File:ইসলাম-কাহিনী_–_কাজী_আকরম_হোসেন_(১৯৪৬).pdf',
      isPdf: false,
    ),
  ];

  static const _downloadBooks = <_BookResource>[
    _BookResource(
      title: 'ইসলামি অর্থব্যবস্থা',
      description: 'বাংলা ইসলামিক পাঠ্যবই — সরাসরি PDF ই-বুক।',
      source: 'Wikimedia Commons • CC BY 4.0',
      icon: Icons.download_for_offline_rounded,
      url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/ইসলামি_অর্থব্যবস্থা.pdf',
      isPdf: true,
    ),
    _BookResource(
      title: 'এক নজরে ইসলাম',
      description: 'বাংলা ভাষার ইসলাম বিষয়ক গ্রন্থ — সরাসরি PDF ই-বুক।',
      source: 'Wikimedia Commons • CC BY-SA 4.0',
      icon: Icons.download_for_offline_rounded,
      url: 'https://commons.wikimedia.org/wiki/Special:Redirect/file/এক_নজরে_ইসলাম.pdf',
      isPdf: true,
    ),
  ];

  void _openReader(BuildContext context, _BookResource book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => IslamicBookReaderScreen(
          title: book.title,
          url: book.url,
          isPdf: book.isPdf,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                onTap: () => _openReader(context, book),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _SectionHeader(
            title: 'Download E-Book',
            subtitle: 'ডাউনলোডযোগ্য বাংলা PDF ই-বুক',
            icon: Icons.download_rounded,
          ),
          const SizedBox(height: 10),
          ..._downloadBooks.map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BookCard(
                book: book,
                actionLabel: 'খুলুন',
                onTap: () => _openReader(context, book),
              ),
            ),
          ),
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
              'NurVerse আপাতত শুধু বাংলা ভাষার নির্বাচিত ইসলামিক বই রাখছে। বইগুলো বিশ্বস্ত অনলাইন আর্কাইভ ও উন্মুক্ত লাইসেন্সের উৎস থেকে নেওয়া হচ্ছে।',
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

  const _BookCard({
    required this.book,
    required this.actionLabel,
    required this.onTap,
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
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.secondaryTextColor,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          actionLabel,
                          style: const TextStyle(
                            color: AppColors.seaBlueDark,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                book.isPdf
                    ? Icons.picture_as_pdf_rounded
                    : Icons.menu_book_rounded,
                color: context.secondaryTextColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
