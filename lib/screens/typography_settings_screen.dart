import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bold_text_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/text_scale_provider.dart';
import '../theme/app_theme.dart';

/// Global NurVerse text accessibility settings.
///
/// Quran-specific Arabic/translation font sizes remain in SettingsProvider
/// and are intentionally kept separate from this app-wide accessibility scale.
class TypographySettingsScreen extends StatelessWidget {
  const TypographySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final textScale = context.watch<TextScaleProvider>();
    final boldText = context.watch<BoldTextProvider>();
    final isEnglish = settings.languageCode == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Text & Display' : 'টেক্সট ও প্রদর্শন'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(
            isEnglish ? 'Text Size' : 'টেক্সট সাইজ',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isEnglish
                ? 'Choose the text size that feels most comfortable.'
                : 'আপনার জন্য যেটি সবচেয়ে আরামদায়ক সেই টেক্সট সাইজ বেছে নিন।',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          _scaleSelector(context, textScale, isEnglish),
          const SizedBox(height: 18),
          _previewCard(context, textScale, boldText, isEnglish),
          const SizedBox(height: 18),
          Card(
            margin: EdgeInsets.zero,
            child: SwitchListTile.adaptive(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              secondary: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.format_bold_rounded,
                  color: AppColors.seaBlue,
                ),
              ),
              title: Text(
                isEnglish ? 'Bold Text' : 'বোল্ড টেক্সট',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                isEnglish
                    ? 'Make app text easier to see.'
                    : 'অ্যাপের লেখাগুলো আরও স্পষ্টভাবে দেখতে সাহায্য করবে।',
              ),
              value: boldText.isBold,
              onChanged: boldText.setBold,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isEnglish
                ? 'Bold Text works independently with every text size.'
                : 'বোল্ড টেক্সট প্রতিটি টেক্সট সাইজের সঙ্গে স্বাধীনভাবে কাজ করবে।',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _scaleSelector(
    BuildContext context,
    TextScaleProvider textScale,
    bool isEnglish,
  ) {
    const labelsBn = <String>['ছোট', 'স্বাভাবিক', 'বড়', 'Extra Large'];
    const labelsEn = <String>['Small', 'Normal', 'Large', 'Extra Large'];
    const previewSizes = <double>[14, 16, 18, 20];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: Row(
          children: List<Widget>.generate(4, (index) {
            final selected = textScale.level == index;
            final label = isEnglish ? labelsEn[index] : labelsBn[index];

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => textScale.setLevel(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(minHeight: 82),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.seaBlue.withValues(alpha: .10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppColors.seaBlue.withValues(alpha: .35)
                            : Theme.of(context).dividerColor,
                        width: selected ? 1.4 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'A',
                          style: TextStyle(
                            fontSize: previewSizes[index],
                            fontWeight: FontWeight.w800,
                            color: selected
                                ? AppColors.seaBlue
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          selected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          size: 15,
                          color: selected
                              ? AppColors.seaBlue
                              : Theme.of(context)
                                  .iconTheme
                                  .color
                                  ?.withValues(alpha: .35),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _previewCard(
    BuildContext context,
    TextScaleProvider textScale,
    BoldTextProvider boldText,
    bool isEnglish,
  ) {
    final normalSize = 16.0 * textScale.scale;
    final headlineSize = normalSize * 1.12;
    final weight = boldText.isBold ? FontWeight.bold : FontWeight.w500;
    final headlineWeight = boldText.isBold ? FontWeight.bold : FontWeight.w700;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish ? 'Preview' : 'প্রিভিউ',
              style: TextStyle(
                fontSize: 12 * textScale.scale,
                fontWeight: headlineWeight,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isEnglish ? 'Prayer time' : 'আওয়াল ওয়াক্ত চলছে',
              style: TextStyle(
                fontSize: headlineSize,
                fontWeight: headlineWeight,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              isEnglish
                  ? 'Your next prayer is coming soon.'
                  : 'আপনার পরবর্তী ওয়াক্তের সময় শীঘ্রই আসছে।',
              style: TextStyle(
                fontSize: normalSize,
                fontWeight: weight,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              isEnglish ? 'Location • Date • Prayer time' : 'লোকেশন • তারিখ • সালাতের সময়',
              style: TextStyle(
                fontSize: normalSize,
                fontWeight: weight,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
