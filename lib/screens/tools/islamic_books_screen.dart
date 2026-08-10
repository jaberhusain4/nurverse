import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

class IslamicBooksScreen extends StatelessWidget {
  const IslamicBooksScreen({super.key});

  static const _books = <_BookResource>[
    _BookResource(
      title: 'কুরআন মাজীদ — বাংলা',
      description: 'বাংলা অনুবাদসহ কুরআনের অনলাইন সংস্করণ।',
      source: 'Open Library / Internet Archive',
      icon: Icons.menu_book_rounded,
      url: 'https://openlibrary.org/works/OL16816466W/Holy_Quran_in_Bengali',
    ),
    _BookResource(
      title: 'কুরআন ও বাংলা তাফসীর',
      description: 'বাংলা অনুবাদ ও সংক্ষিপ্ত তাফসীরের ডিজিটাল সংস্করণ।',
      source: 'Waqfeya',
      icon: Icons.auto_stories_rounded,
      url: 'https://waqfeya.net/books/%D8%A7%D9%84%D9%82%D8%B1%D8%A2%D9%86-%D8%A7%D9%84%D9%83%D8%B1%D9%8A%D9%85-%D9%88%D8%AA%D8%B1%D8%AC%D9%85%D8%A9-%D9%85%D8%B9%D8%A7%D9%86%D9%8A%D9%87-%D9%88%D8%AA%D9%81%D8%B3%D9%8A%D8%B1%D9%87-%D8%A5%D9%84%D9%89-%D8%A7%D9%84%D9%84%D8%BA%D8%A9-%D8%A7%D9%84%D8%A8%D9%86%D8%BA%D8%A7%D9%84%D9%8A%D8%A9-Bengali/3ab87ac29e094d07bd0ab00b0ac09e4d',
    ),
    _BookResource(
      title: 'বাংলা ইসলামিক বই — Commons',
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

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('বইয়ের লিংকটি খোলা যায়নি।')),
      );
    }
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
          return _BookCard(
            book: book,
            onTap: () => _open(context, book.url),
          );
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
              'NurVerse আপাতত বিশ্বস্ত অনলাইন লাইব্রেরি ও ডিজিটাল আর্কাইভে থাকা রিসোর্সে নিয়ে যাবে। ভবিষ্যতে অনুমতি/লাইসেন্স যাচাই করে নির্বাচিত বই offline download ও reader-এ আনা যাবে।',
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

  const _BookResource({
    required this.title,
    required this.description,
    required this.source,
    required this.icon,
    required this.url,
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
                    'নির্বাচিত ইসলামিক বই ও ডিজিটাল রিসোর্স এক জায়গায়।',
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
                    Text(
                      book.source,
                      style: const TextStyle(
                        color: AppColors.seaBlueDark,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.open_in_new_rounded, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}
