import 'package:flutter/material.dart';
import '../../models/daily_content_model.dart';

class DailyContentCard extends StatelessWidget {
  final DailyContentModel content;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const DailyContentCard({
    super.key,
    required this.content,
    required this.icon,
    required this.iconColor,
    this.onBookmark,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x220288D1)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: .28)
                : Colors.black.withValues(alpha: .045),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  content.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onBookmark != null)
                IconButton(
                  onPressed: onBookmark,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                ),
              if (onShare != null)
                IconButton(
                  onPressed: onShare,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(Icons.share_outlined, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            content.arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 21,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            content.bangla,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 8),
          Text(
            content.reference,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.hintColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
