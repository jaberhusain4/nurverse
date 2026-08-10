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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x220288D1)),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: .35)
                    : Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  content.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: onBookmark,
                icon: const Icon(Icons.bookmark_border_rounded),
              ),

              IconButton(
                onPressed: onShare,
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SelectableText(
            content.arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              height: 2,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            content.bangla,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
          ),

          const SizedBox(height: 14),

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
