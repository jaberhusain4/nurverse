from pathlib import Path
import re

p = Path('lib/screens/canonical_settings_screen.dart')
s = p.read_text(encoding='utf-8')

# Restore the historical layout: the large Premium hero appears first,
# before the Personalization section.
premium_call = "          _premium(context, s, premium),\n"
s = s.replace(premium_call, '', 1)

personalization = """        children: [
          _section(
            context,
            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),"""
if personalization not in s:
    raise SystemExit('Personalization section not found')

replacement = """        children: [
          _premium(context, s, premium),
          const SizedBox(height: 18),
          _section(
            context,
            t(l, 'ব্যক্তিগতকরণ', 'Personalization'),"""
s = s.replace(personalization, replacement, 1)

# Match the historical larger Premium presentation.
s = s.replace(
    'padding: const EdgeInsets.all(20),\n          decoration: BoxDecoration(',
    'padding: const EdgeInsets.all(22),\n          decoration: BoxDecoration(',
    1,
)
s = s.replace(
    'borderRadius: BorderRadius.circular(28),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),',
    'borderRadius: BorderRadius.circular(30),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),',
    1,
)
s = s.replace('width: 54,\n                    height: 54,', 'width: 60,\n                    height: 60,', 1)
s = s.replace('size: 30,\n                    ),', 'size: 32,\n                    ),', 1)
s = s.replace(
    'fontSize: 18,\n                                  fontWeight: FontWeight.w900,',
    'fontSize: 20,\n                                  fontWeight: FontWeight.w900,',
    1,
)
s = s.replace(
    'padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),',
    'padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),',
    1,
)

# Restore the Premium card's Google account login/logout control.
if "import '../services/auth_service.dart';" not in s:
    s = s.replace(
        "import '../providers/text_scale_provider.dart';\n",
        "import '../providers/text_scale_provider.dart';\nimport '../services/auth_service.dart';\n",
        1,
    )

account_pattern = re.compile(
    r"              const SizedBox\(width: 10\),\n"
    r"              Container\(\n"
    r"                width: 42,\n"
    r"                height: 42,\n"
    r"                decoration: BoxDecoration\(\n"
    r".*?"
    r"                child: user == null\n"
    r".*?"
    r"              \),\n"
    r"            \],\n"
    r"          \),\n"
    r"          const SizedBox\(height: 18\),",
    re.DOTALL,
)
if '_premiumAccountButton(context)' not in s:
    match = account_pattern.search(s)
    if not match:
        raise SystemExit('Premium account control block not found')
    replacement_account = """              const SizedBox(width: 10),
              _premiumAccountButton(context),
            ],
          ),
          const SizedBox(height: 18),"""
    s = account_pattern.sub(replacement_account, s, count=1)

if '_premiumAccountButton(BuildContext context)' not in s:
    marker = "  Widget _premiumChip(IconData icon, String title) => Container(\n"
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
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
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
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null || photoUrl.isEmpty
                      ? Icon(
                          Icons.account_circle_rounded,
                          size: 48,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName?.trim().isNotEmpty == true
                      ? user.displayName!
                      : 'NurVerse User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (user.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.email!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                    label: Text(
                      languageCode == 'en' ? 'Logout' : 'লগআউট',
                    ),
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

# Ensure the 12/24 segmented control uses NurVerse's SeaBlue instead of the
# default Material secondary-container colors.
old_segment = """      showSelectedIcon: false,
    ),
  );

  Widget _choice("""
new_segment = """      showSelectedIcon: false,
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.seaBlue;
        }),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.seaBlue
              : Colors.transparent;
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
