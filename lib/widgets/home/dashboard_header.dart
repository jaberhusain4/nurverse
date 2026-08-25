import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';

class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String location;
  final String hijriBangla;
  final String englishDate;
  final String currentTime;

  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.location,
    required this.hijriBangla,
    required this.englishDate,
    required this.currentTime,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    const seaBlue = Color(0xFF0288D1);

    final cardColor = theme.cardColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: seaBlue.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: seaBlue.withValues(alpha: .08),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: seaBlue.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: seaBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.tr('ইসলামিক জীবনধারা', 'Islamic Lifestyle'),
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNotificationTap,
                icon: const Icon(Icons.notifications_outlined),
              ),
              IconButton(
                onPressed: onProfileTap,
                icon: const Icon(Icons.person_outline),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Text(
            l10n.tr('আসসালামু আলাইকুম', 'Assalamu Alaikum'),
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),

          const SizedBox(height: 4),

          Text(
            greeting,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: seaBlue),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.calendar_today_outlined,
                  title: l10n.tr('হিজরি', 'Hijri'),
                  value: hijriBangla,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.date_range_outlined,
                  title: l10n.tr('তারিখ', 'Date'),
                  value: englishDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: seaBlue.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: seaBlue),
                const SizedBox(width: 10),
                Text(
                  currentTime,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    const seaBlue = Color(0xFF0288D1);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: seaBlue.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: seaBlue, size: 20),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
