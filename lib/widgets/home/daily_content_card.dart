import 'package:flutter/material.dart';

import '../../models/daily_content_model.dart';

class DailyContentCard extends StatelessWidget {
  final DailyContentModel content;
  final String languageCode;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const DailyContentCard({
    super.key,
    required this.content,
    required this.languageCode,
    required this.icon,
    required this.iconColor,
    this.onBookmark,
    this.onShare,
  });

  String get _title {
    if (languageCode == 'en') {
      switch (content.type) {
        case DailyContentType.ayah:
          return 'Today’s Ayah';
        case DailyContentType.hadith:
          return 'Today’s Hadith';
        case DailyContentType.dua:
          return 'Today’s Dua';
      }
    }
    return content.title;
  }

  String get _body => languageCode == 'en' ? content.english : content.bangla;

  String get _reference =>
      languageCode == 'en' ? content.englishReference : content.reference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassCard = theme.cardColor.withValues(alpha: isDark ? .58 : .70);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: glassCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .10)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: .18)
                : Colors.black.withValues(alpha: .035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 19),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onBookmark != null)
                IconButton(
                  onPressed: onBookmark,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  icon: const Icon(Icons.bookmark_border_rounded, size: 19),
                ),
              if (onShare != null)
                IconButton(
                  onPressed: onShare,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  icon: const Icon(Icons.share_outlined, size: 19),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            content.arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 19,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            _body,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15.5,
              height: 1.48,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _reference,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
