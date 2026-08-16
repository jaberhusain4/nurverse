import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ContinueReadingCard extends StatelessWidget {
  final String surahName;
  final int paraNo;
  final int pageNo;
  final double progress;
  final VoidCallback? onTap;
  final String languageCode;

  const ContinueReadingCard({
    super.key,
    required this.surahName,
    required this.paraNo,
    required this.pageNo,
    required this.progress,
    this.onTap,
    this.languageCode = 'bn',
  });

  String _label({required String bn, required String en, required String ar}) {
    switch (languageCode) {
      case 'en':
        return en;
      case 'ar':
        return ar;
      default:
        return bn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final text = theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;
    final secondary = context.secondaryTextColor;
    final safeProgress = progress.clamp(0.0, 1.0);
    final percentage = (safeProgress * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: primary.withValues(alpha: 0.07)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.menu_book_rounded, color: primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _label(
                            bn: 'কুরআন পড়া চালিয়ে যান',
                            en: 'Continue Reading Quran',
                            ar: 'تابع قراءة القرآن',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _label(
                            bn: 'পড়া এখান থেকে চালিয়ে যান',
                            en: 'Continue from here',
                            ar: 'تابع القراءة من هنا',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: secondary),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: text,
                            fontSize: 16,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _label(
                            bn: 'পারা $paraNo  •  পৃষ্ঠা $pageNo',
                            en: 'Juz $paraNo  •  Page $pageNo',
                            ar: 'الجزء $paraNo  •  الصفحة $pageNo',
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        color: primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 5,
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    backgroundColor: primary.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Icon(Icons.play_arrow_rounded, size: 16, color: primary),
                  const SizedBox(width: 4),
                  Text(
                    _label(
                      bn: 'অনুধাবন শুরু করুন',
                      en: 'Start Onudhabon',
                      ar: 'ابدأ قرآن الفهم',
                    ),
                    style: TextStyle(
                      color: primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _label(
                      bn: '$percentage% সম্পন্ন',
                      en: '$percentage% complete',
                      ar: '$percentage٪ مكتمل',
                    ),
                    style: TextStyle(color: secondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
