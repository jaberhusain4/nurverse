// lib/widgets/home/top_header.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../screens/auth/google_login_screen.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../common/brand_logo.dart';

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

    if (language == 'bn') {
      if (normalized == 'শুভ সকাল' || normalized == 'Good Morning' || normalized == 'صباح الخير') return 'শুভ সকাল';
      if (normalized == 'শুভ দুপুর' || normalized == 'Good Afternoon') return 'শুভ দুপুর';
      if (normalized == 'শুভ বিকেল') return 'শুভ বিকেল';
      if (normalized == 'শুভ সন্ধ্যা' || normalized == 'Good Evening' || normalized == 'مساء الخير') return 'শুভ সন্ধ্যা';
      return normalized;
    }

    if (language == 'ar') {
      if (normalized == 'শুভ সকাল' || normalized == 'Good Morning' || normalized == 'صباح الخير') return 'صباح الخير';
      if (normalized == 'শুভ দুপুর' || normalized == 'শুভ বিকেল' || normalized == 'Good Afternoon' || normalized == 'Good Evening' || normalized == 'مساء الخير') return 'مساء الخير';
      if (normalized == 'শুভ সন্ধ্যা') return 'مساء الخير';
      return normalized;
    }

    if (normalized == 'শুভ সকাল' || normalized == 'صباح الخير') return 'Good Morning';
    if (normalized == 'শুভ দুপুর' || normalized == 'শুভ বিকেল') return 'Good Afternoon';
    if (normalized == 'শুভ সন্ধ্যা' || normalized == 'مساء الخير') return 'Good Evening';
    return normalized;
  }

  String _notificationTooltip(String language) {
    switch (language) {
      case 'bn': return 'নোটিফিকেশন';
      case 'ar': return 'الإشعارات';
      case 'en':
      default: return 'Notifications';
    }
  }

  String _profileTooltip(String language, bool signedIn) {
    if (signedIn) {
      switch (language) {
        case 'bn': return 'অ্যাকাউন্ট';
        case 'ar': return 'الحساب';
        case 'en':
        default: return 'Account';
      }
    }

    switch (language) {
      case 'bn': return 'লগইন';
      case 'ar': return 'تسجيل الدخول';
      case 'en':
      default: return 'Login';
    }
  }

  Future<void> _openAccount(BuildContext context, User user) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.cardColor,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final photoUrl = user.photoURL;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.10),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Icon(Icons.account_circle_rounded, size: 48, color: theme.colorScheme.primary)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName?.trim().isNotEmpty == true ? user.displayName! : 'NurVerse User',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                if (user.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(user.email!, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor), textAlign: TextAlign.center),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await AuthService.instance.signOut();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleProfileTap(BuildContext context, User? user) async {
    if (user == null) {
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GoogleLoginScreen()));
      return;
    }
    await _openAccount(context, user);
  }

  Widget _profileFallback(BuildContext context, User? user) {
    final theme = Theme.of(context);
    final signedIn = user != null;

    return Icon(
      signedIn ? Icons.person_rounded : Icons.person_outline_rounded,
      size: 24,
      color: theme.colorScheme.primary,
    );
  }

  Widget _profileButton(BuildContext context, String language, User? user) {
    final theme = Theme.of(context);
    final signedIn = user != null;
    final photoUrl = user?.photoURL?.trim();
    final hasPhoto = signedIn && photoUrl != null && photoUrl.isNotEmpty;

    return Tooltip(
      message: _profileTooltip(language, signedIn),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _handleProfileTap(context, user),
            customBorder: const CircleBorder(),
            child: hasPhoto
                ? ClipOval(
                    child: Image.network(
                      photoUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => Center(
                        child: _profileFallback(context, user),
                      ),
                    ),
                  )
                : Center(child: _profileFallback(context, user)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();
    final language = settings.languageCode;
    final subtitle = _subtitle(language);
    final assalamuAlaikum = _assalamuAlaikum(language);
    final localizedGreeting = _localizedGreeting(language);

    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const BrandLogo(size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text('NurVerse', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'نُورٌ عَلَىٰ نُورٍ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontFamily: 'Amiri', fontSize: 12, color: theme.colorScheme.primary.withValues(alpha: 0.80), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: context.secondaryTextColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onNotificationTap,
                    tooltip: _notificationTooltip(language),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
                const SizedBox(width: 2),
                _profileButton(context, language, user),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(assalamuAlaikum, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 3),
                      Text(localizedGreeting, style: theme.textTheme.bodyMedium?.copyWith(color: context.secondaryTextColor)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(14)),
                  child: Text(currentTime, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
