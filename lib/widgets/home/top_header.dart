// lib/widgets/home/top_header.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class TopHeader extends StatelessWidget {
  final String greeting;
  final String currentTime;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const TopHeader({
    super.key,
    required this.greeting,
    required this.currentTime,
    this.onNotificationTap,
    this.onProfileTap,
  });

  String _subtitle(String language) {
    switch (language) {
      case 'bn':
        return 'আপনার দৈনন্দিন ইসলামিক সঙ্গী';

      case 'ar':
        return 'رفيقك الإسلامي اليومي';

      case 'en':
      default:
        return 'Your Daily Islamic Companion';
    }
  }

  String _assalamuAlaikum(String language) {
    switch (language) {
      case 'bn':
        return 'আসসালামু আলাইকুম';

      case 'ar':
        return 'السلام عليكم';

      case 'en':
      default:
        return 'Assalamu Alaikum';
    }
  }

  String _localizedGreeting(String language) {
    final normalized = greeting.trim();

    // ============================================================
    // BANGLA
    // ============================================================
    if (language == 'bn') {
      if (normalized == 'শুভ সকাল' ||
          normalized == 'Good Morning' ||
          normalized == 'صباح الخير') {
        return 'শুভ সকাল';
      }

      if (normalized == 'শুভ দুপুর' || normalized == 'Good Afternoon') {
        return 'শুভ দুপুর';
      }

      if (normalized == 'শুভ বিকেল') {
        return 'শুভ বিকেল';
      }

      if (normalized == 'শুভ সন্ধ্যা' ||
          normalized == 'Good Evening' ||
          normalized == 'مساء الخير') {
        return 'শুভ সন্ধ্যা';
      }

      return normalized;
    }

    // ============================================================
    // ARABIC
    // ============================================================
    if (language == 'ar') {
      if (normalized == 'শুভ সকাল' ||
          normalized == 'Good Morning' ||
          normalized == 'صباح الخير') {
        return 'صباح الخير';
      }

      if (normalized == 'শুভ দুপুর' ||
          normalized == 'শুভ বিকেল' ||
          normalized == 'Good Afternoon' ||
          normalized == 'Good Evening' ||
          normalized == 'مساء الخير') {
        return 'مساء الخير';
      }

      if (normalized == 'শুভ সন্ধ্যা') {
        return 'مساء الخير';
      }

      return normalized;
    }

    // ============================================================
    // ENGLISH
    // ============================================================
    if (normalized == 'শুভ সকাল' || normalized == 'صباح الخير') {
      return 'Good Morning';
    }

    if (normalized == 'শুভ দুপুর') {
      return 'Good Afternoon';
    }

    if (normalized == 'শুভ বিকেল') {
      return 'Good Afternoon';
    }

    if (normalized == 'শুভ সন্ধ্যা' || normalized == 'مساء الخير') {
      return 'Good Evening';
    }

    return normalized;
  }

  String _notificationTooltip(String language) {
    switch (language) {
      case 'bn':
        return 'নোটিফিকেশন';

      case 'ar':
        return 'الإشعارات';

      case 'en':
      default:
        return 'Notifications';
    }
  }

  String _profileTooltip(String language) {
    switch (language) {
      case 'bn':
        return 'প্রোফাইল';

      case 'ar':
        return 'الملف الشخصي';

      case 'en':
      default:
        return 'Profile';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final settings = context.watch<SettingsProvider>();
    final language = settings.languageCode;

    final subtitle = _subtitle(language);
    final assalamuAlaikum = _assalamuAlaikum(language);
    final localizedGreeting = _localizedGreeting(language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ============================================================
        // LOGO + APP NAME + SUBTITLE + ACTIONS
        // ============================================================
        Row(
          children: [
            // --------------------------------------------------------
            // Logo
            // --------------------------------------------------------
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.mosque_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),

            const SizedBox(width: 12),

            // --------------------------------------------------------
            // NurVerse + Arabic + Subtitle
            // --------------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'NurVerse',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        'نُورٌ عَلَىٰ نُورٍ',
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 12,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.80,
                          ),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 2),

                  // App subtitle
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------
            // Notification
            // --------------------------------------------------------
            IconButton(
              onPressed: onNotificationTap,
              tooltip: _notificationTooltip(language),
              icon: const Icon(Icons.notifications_none_rounded),
            ),

            // --------------------------------------------------------
            // Profile
            // --------------------------------------------------------
            IconButton(
              onPressed: onProfileTap,
              tooltip: _profileTooltip(language),
              icon: const Icon(Icons.account_circle_outlined),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ============================================================
        // GREETING + CURRENT TIME
        // ============================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Islamic greeting
                  Text(
                    assalamuAlaikum,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Time-of-day greeting
                  Text(
                    localizedGreeting,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // --------------------------------------------------------
            // Current Time
            // --------------------------------------------------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                currentTime,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
