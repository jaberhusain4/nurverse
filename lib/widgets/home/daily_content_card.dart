import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../localization/app_localizations_locale_text_x.dart';
import '../../models/daily_content_model.dart';

class DailyContentCard extends StatelessWidget {
  final DailyContentModel content;
  final String languageCode;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onBookmark;
  final VoidCallback? onShare;

  const DailyContentCard({super.key, required this.content, required this.languageCode, required this.icon, required this.iconColor, this.onBookmark, this.onShare});

  String _title(AppLocalizations l10n) {
    switch (content.type) {
      case DailyContentType.ayah:
        return l10n.localeText(values: const {'bn': 'আজকের আয়াত', 'en': 'Today’s Ayah', 'ar': 'آية اليوم'});
      case DailyContentType.hadith:
        return l10n.localeText(values: const {'bn': 'আজকের হাদিস', 'en': 'Today’s Hadith', 'ar': 'حديث اليوم'});
      case DailyContentType.dua:
        return l10n.localeText(values: const {'bn': 'আজকের দোয়া', 'en': 'Today’s Dua', 'ar': 'دعاء اليوم'});
    }
  }

  String _body(AppLocalizations l10n) => l10n.isArabic ? content.arabic : (l10n.isBangla ? content.bangla : content.english);
  String _reference(AppLocalizations l10n) => l10n.isBangla ? content.reference : content.englishReference;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassCard = theme.cardColor.withValues(alpha: isDark ? .58 : .70);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(color: glassCard, borderRadius: BorderRadius.circular(18), border: Border.all(color: primary.withValues(alpha: .10)), boxShadow: [BoxShadow(color: isDark ? Colors.black.withValues(alpha: .18) : Colors.black.withValues(alpha: .035), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Icon(icon, color: iconColor, size: 19), const SizedBox(width: 7), Expanded(child: Text(_title(l10n), maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall?.copyWith(fontSize: 16, fontWeight: FontWeight.bold))), if (onBookmark != null) IconButton(onPressed: onBookmark, visualDensity: VisualDensity.compact, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30), icon: const Icon(Icons.bookmark_border_rounded, size: 19)), if (onShare != null) IconButton(onPressed: onShare, visualDensity: VisualDensity.compact, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 30, minHeight: 30), icon: const Icon(Icons.share_outlined, size: 19))]),
        const SizedBox(height: 6),
        SelectableText(content.arabic, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Amiri', fontSize: 19, height: 1.65)),
        const SizedBox(height: 7),
        Text(_body(l10n), textAlign: l10n.isArabic ? TextAlign.right : TextAlign.start, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.5, height: 1.48)),
        const SizedBox(height: 6),
        Text(_reference(l10n), textAlign: l10n.isArabic ? TextAlign.right : TextAlign.start, style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}