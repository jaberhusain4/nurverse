import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'islamic_book_reader_screen.dart';

class IslamicBooksScreen extends StatelessWidget {
  const IslamicBooksScreen({super.key});

  static const _books = <_BookResource>[
    _BookResource(
      title: 'কুরআন মাজীদ — আরবি ও বাংলা',
      description: 'বাংলাদেশ সরকারের Al Quran: Digital-এর সরাসরি Arabic-Bangla PDF ই-বুক।',
      source: 'Al Quran: Digital — ধর্ম বিষয়ক মন্ত্রণালয়',
      icon: Icons.menu_book_rounded,
      url: 'https://www.quran.gov.bd/quran/pdf/ab/fab.pdf',
      isPdf: true,
    ),
    _BookResource(
      title: 'কুরআন মাজীদ — আরবি, বাংলা ও ইংরেজি',
      description: 'সরাসরি Arabic-Bangla-English PDF ই-বুক।',
      source: 'Al Quran: Digital — ধর্ম বিষয়ক মন্ত্রণালয়',
      icon: Icons.auto_stories_rounded,
      url: 'https://www.quran.gov.bd/quran/pdf/abe/fabe.pdf',
      isPdf: true,
    ),
    _BookResource(
      title: 'কুরআন ও বাংলা তাফসীর',
      description: 'বাংলা অনুবাদ ও তাফসীরের অনলাইন ইসলামিক রিসোর্স।',
      source: 'Waqfeya',
      icon: Icons.menu_book_outlined,
      url: 'https://waqfeya.net/',
    ),
    _BookResource(
      title: 'বাংলা ইসলামিক বই',
      description: 'বাংলা ভাষার ইসলামিক বই ও স্ক্যানকৃত রিসোর্সের সংগ্রহ।',
      source: 'Wikimedia Commons',
      icon: Icons.library_books_rounded,
      url: 'https://commons.wikimedia.org/wiki/Category:Bengali-language_books_about_Islam',
    ),
    _BookResource(
      title: 'Internet Archive — Islamic Books',
      description: 'বিভিন্ন ভাষার ইসলামিক বই খুঁজে পড়া ও ডাউনলোডের সংগ্রহ।',
      source: 'Internet Archive',
      icon: Icons.cloud_download_rounded,
      url: 'https://archive.org/search?query=subject%3A%22Islam%22%20AND%20mediatype%3Atexts',
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
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        itemCount: _books.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) return const _BooksIntroCard();
          final book = _books[index - 1];
          return _BookCard(book: book, onTap: () => _openReader(context, book));
        },
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
            Text('বইয়ের উৎস', style: TextStyle(color: context.primaryTextColor, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'NurVerse বিশ্বস্ত অনলাইন লাইব্রেরি ও ডিজিটাল আর্কাইভের রিসোর্স ব্যবহার করে। যেসব বই সরাসরি PDF হিসেবে পাওয়া যায়, সেগুলো NurVerse-এর ভেতরেই পড়া যায়।',
              style: TextStyle(color: context.secondaryTextColor, fontSize: 13, height: 1.55),
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
              child: const Icon(Icons.auto_stories_rounded, color: AppColors.seaBlue, size: 25),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('জ্ঞানভাণ্ডার', style: TextStyle(color: context.primaryTextColor, fontSize: 17, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('নির্বাচিত ইসলামিক বই ও ডিজিটাল রিসোর্স এক জায়গায়।', style: TextStyle(color: context.secondaryTextColor, fontSize: 12, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final _BookResource book;
  final VoidCallback onTap;

  const _BookCard({required this.book, required this.onTap});

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
                  color: context.isDark ? AppColors.seaBlue.withValues(alpha: 0.14) : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(book.icon, color: AppColors.seaBlueDark, size: 25),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.primaryTextColor, fontSize: 14.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(book.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 11.5, height: 1.45)),
                    const SizedBox(height: 7),
                    Text(book.source, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.secondaryTextColor, fontSize: 10.5)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(book.isPdf ? Icons.menu_book_rounded : Icons.open_in_new_rounded, color: context.secondaryTextColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
