from pathlib import Path
import re

p = Path('lib/screens/canonical_settings_screen.dart')
s = p.read_text(encoding='utf-8')

# Keep the large Premium hero at the top of Settings.
s = s.replace('          _premium(context, s, premium),\n', '', 1)
premium_anchor = "        children: [\n          _section(\n            context,\n            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),"
if premium_anchor not in s:
    raise SystemExit('Personalization section not found')
s = s.replace(premium_anchor, "        children: [\n          _premium(context, s, premium),\n          const SizedBox(height: 18),\n          _section(\n            context,\n            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),", 1)

# Restore the historical large Premium presentation.
s = s.replace('padding: const EdgeInsets.all(20),\n          decoration: BoxDecoration(', 'padding: const EdgeInsets.all(22),\n          decoration: BoxDecoration(', 1)
s = s.replace('borderRadius: BorderRadius.circular(28),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),', 'borderRadius: BorderRadius.circular(30),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),', 1)
s = s.replace('width: 54,\n                    height: 54,', 'width: 60,\n                    height: 60,', 1)
s = s.replace('size: 30,\n                    ),', 'size: 32,\n                    ),', 1)
s = s.replace('fontSize: 18,\n                                  fontWeight: FontWeight.w900,', 'fontSize: 20,\n                                  fontWeight: FontWeight.w900,', 1)
s = s.replace('padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),', 'padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),', 1)

# Use the shared auth service for the Premium account control.
if "import '../services/auth_service.dart';" not in s:
    s = s.replace("import '../providers/text_scale_provider.dart';\n", "import '../providers/text_scale_provider.dart';\nimport '../services/auth_service.dart';\n", 1)

# Replace whatever account control is currently in the Premium hero.
account_start = "              const SizedBox(width: 10),\n"
account_end = "              const SizedBox(height: 18),\n              Wrap("
start = s.find(account_start, s.find('Widget _premium('))
end = s.find(account_end, start)
if start == -1 or end == -1:
    raise SystemExit('Premium account control boundaries not found')
s = s[:start] + account_start + "              _premiumAccountButton(context),\n" + s[end:]

if 'Widget _premiumAccountButton(BuildContext context)' not in s:
    marker = '  Widget _premiumChip(IconData icon, String title) => Container(\n'
    if marker not in s:
        raise SystemExit('Premium chip marker not found')
    helper = r'''  Widget _premiumAccountButton(BuildContext context) {
    final theme = Theme.of(context);
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final photoUrl = user?.photoURL?.trim();
        final hasPhoto = user != null && photoUrl != null && photoUrl.isNotEmpty;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleProfileTap(context, user),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.seaBlue.withValues(alpha: .12)),
              ),
              child: hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.network(
                        photoUrl!,
                        width: 42,
                        height: 42,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 22),
                      ),
                    )
                  : Icon(
                      user != null ? Icons.person_rounded : Icons.login_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleProfileTap(BuildContext context, User? user) async {
    if (user == null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const GoogleLoginScreen()),
      );
      return;
    }
    await _openAccount(context, user);
  }

  Future<void> _openAccount(BuildContext context, User user) async {
    final theme = Theme.of(context);
    final photoUrl = user.photoURL?.trim();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final languageCode = context.read<SettingsProvider>().languageCode;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: .10),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null || photoUrl.isEmpty ? Icon(Icons.account_circle_rounded, size: 48, color: theme.colorScheme.primary) : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName?.trim().isNotEmpty == true ? user.displayName! : 'NurVerse User',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                if (user.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(user.email!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .70)), textAlign: TextAlign.center),
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
                    label: Text(languageCode == 'en' ? 'Logout' : 'লগআউট'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

'''
    s = s.replace(marker, helper + marker, 1)

# Restore Premium button behavior: inactive -> activate, active -> show status/manage.
old_button = '''                  onPressed: () => premium.activatePremium(),
'''
new_button = '''                  onPressed: () {
                    if (premium.isPremium) {
                      _showPremiumStatus(context, premium, languageCode == 'en');
                    } else {
                      premium.activatePremium();
                    }
                  },
'''
if old_button in s:
    s = s.replace(old_button, new_button, 1)

if 'Future<void> _showPremiumStatus(' not in s:
    marker = '  Widget _premiumChip(IconData icon, String title) => Container(\n'
    helper = r'''  Future<void> _showPremiumStatus(BuildContext context, PremiumProvider premium, bool isEnglish) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('NurVerse Premium'),
        content: Text(
          premium.purchaseDate == null
              ? (isEnglish ? 'Premium is active.' : 'Premium সক্রিয় আছে।')
              : (isEnglish ? 'Premium is active on this device.' : 'এই ডিভাইসে Premium সক্রিয় আছে।'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(isEnglish ? 'Close' : 'বন্ধ করুন'),
          ),
        ],
      ),
    );
  }

'''
    if marker not in s:
        raise SystemExit('Premium chip marker not found for status helper')
    s = s.replace(marker, helper + marker, 1)

# Force the 12/24 selector to use NurVerse SeaBlue.
old_segment = """      showSelectedIcon: false,
    ),
  );

  Widget _choice("""
new_segment = """      showSelectedIcon: false,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? Colors.white : AppColors.seaBlue;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? AppColors.seaBlue : Colors.transparent;
        }),
        side: WidgetStateProperty.all(
          BorderSide(color: AppColors.seaBlue.withValues(alpha: .30)),
        ),
      ),
    ),
  );

  Widget _choice("""
if old_segment not in s:
    raise SystemExit('Time format segmented control marker not found')
s = s.replace(old_segment, new_segment, 1)

p.write_text(s, encoding='utf-8')
