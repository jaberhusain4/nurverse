// lib/widgets/home/asma_ul_husna_preview_card.dart

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../services/asma_ul_husna_service.dart';
import '../../theme/app_theme.dart';
import '../common_widgets.dart';

class AsmaUlHusnaPreviewCard extends StatelessWidget {
  final AsmaUlHusnaModel name;
  final VoidCallback? onTap;

  const AsmaUlHusnaPreviewCard({super.key, required this.name, this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.star_rounded, color: AppColors.seaBlue),
            const SizedBox(width: 8),
            Text(l10n.tr('আল্লাহর নাম', 'Name of Allah'), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.primaryTextColor)),
            const Spacer(),
            AppBadge(text: '#${name.id}', color: AppColors.seaBlue),
          ]),
          const SizedBox(height: 22),
          Center(child: Text(name.arabic, textAlign: TextAlign.center, style: const TextStyle(fontSize: 38, height: 1.8, fontFamily: 'Amiri'))),
          const SizedBox(height: 16),
          Center(child: Text(name.transliteration, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: context.primaryTextColor))),
          const SizedBox(height: 8),
          Center(child: Text(name.meaning, textAlign: TextAlign.center, style: TextStyle(color: context.secondaryTextColor, fontSize: 15))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: onTap, icon: const Icon(Icons.arrow_forward), label: Text(l10n.tr('৯৯টি নাম দেখুন', 'View All 99 Names')))),
        ],
      ),
    );
  }
}
