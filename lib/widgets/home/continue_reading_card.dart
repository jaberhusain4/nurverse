import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ContinueReadingCard extends StatelessWidget {
  final String surahName;
  final int paraNo;
  final int pageNo;
  final double progress;
  final VoidCallback? onTap;

  const ContinueReadingCard({
    super.key,
    required this.surahName,
    required this.paraNo,
    required this.pageNo,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primary = theme.colorScheme.primary;

    final cardColor = context.cardColor;

    final textColor =
        theme.textTheme.bodyLarge?.color ?? theme.colorScheme.onSurface;

    final secondaryColor = context.secondaryTextColor;

    final safeProgress = progress.clamp(0.0, 1.0);

    final percentage = (safeProgress * 100).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: primary.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ====================================================
              // HEADER
              // ====================================================
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: primary,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue Reading',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'কুরআন তিলাওয়াত চালিয়ে যান',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryColor,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 15,
                    color: secondaryColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ====================================================
              // SURAH
              // ====================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surahName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'পারা $paraNo  •  পৃষ্ঠা $pageNo',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondaryColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ==================================================
                  // PERCENTAGE
                  // ==================================================
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$percentage%',
                      style: TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ====================================================
              // PROGRESS BAR
              // ====================================================
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 6,
                  child: LinearProgressIndicator(
                    value: safeProgress,
                    backgroundColor: primary.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(primary),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ====================================================
              // FOOTER
              // ====================================================
              Row(
                children: [
                  Icon(Icons.play_arrow_rounded, size: 16, color: primary),
                  const SizedBox(width: 5),
                  Text(
                    'আবার শুরু করুন',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$percentage% সম্পন্ন',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: secondaryColor,
                      fontSize: 10,
                    ),
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
