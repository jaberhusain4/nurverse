from pathlib import Path

p = Path('lib/screens/canonical_settings_screen.dart')
s = p.read_text(encoding='utf-8')

# The canonical settings repair script rebuilds the Premium card. Apply the
# final account behavior here so login/profile/logout remains in one place.
if "import '../services/auth_service.dart';" not in s:
    s = s.replace("import '../providers/text_scale_provider.dart';\n", "import '../providers/text_scale_provider.dart';\nimport '../services/auth_service.dart';\n", 1)

premium_start = s.find('  Widget _premium(')
if premium_start == -1:
    raise SystemExit('Premium widget not found')

# Restore the larger Premium card presentation.
s = s.replace('padding: const EdgeInsets.all(20),', 'padding: const EdgeInsets.all(22),', 1)
s = s.replace('borderRadius: BorderRadius.circular(28),', 'borderRadius: BorderRadius.circular(30),', 1)
s = s.replace('width: 54,\n                    height: 54,', 'width: 60,\n                    height: 60,', 1)
s = s.replace('size: 30,', 'size: 32,', 1)
s = s.replace('fontSize: 18,', 'fontSize: 20,', 1)
s = s.replace('padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),', 'padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),', 1)

# Replace only the old account button inside _premium.
account_start = s.find('              const SizedBox(width: 10),\n', premium_start)
account_end = s.find('              const SizedBox(height: 18),\n              Wrap(', account_start)
if account_start == -1 or account_end == -1:
    raise SystemExit('Premium account control boundaries not found')

account = '''              const SizedBox(width: 10),
              StreamBuilder<User?>(
                stream: AuthService.instance.authStateChanges,
                initialData: AuthService.instance.currentUser,
                builder: (context, authSnapshot) {
                  final user = authSnapshot.data;
                  final photoUrl = user?.photoURL?.trim();
                  final hasPhoto = user != null && photoUrl != null && photoUrl.isNotEmpty;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        if (user == null) {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const GoogleLoginScreen(),
                            ),
                          );
                          return;
                        }
                        await showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          builder: (sheetContext) {
                            final languageCode = settings.languageCode;
                            return SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 34,
                                      backgroundColor: AppColors.seaBlue.withValues(alpha: .10),
                                      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
                                      child: hasPhoto
                                          ? null
                                          : const Icon(Icons.account_circle_rounded, size: 46),
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
                                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: .70),
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
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.seaBlue.withValues(alpha: .10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: hasPhoto
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.network(
                                  photoUrl!,
                                  width: 42,
                                  height: 42,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 22,
                                  ),
                                ),
                              )
                            : Icon(
                                user != null
                                    ? Icons.person_rounded
                                    : Icons.login_rounded,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                      ),
                    ),
                  );
                },
              ),
'''
s = s[:account_start] + account + s[account_end:]

# Keep the existing Premium activation/status button logic intact.
# Ensure the 12/24 selector uses the NurVerse SeaBlue rather than a default
# Material color, without changing its selection behavior.
marker = '''      showSelectedIcon: false,
    ),
  );

  Widget _choice('''
styled = '''      showSelectedIcon: false,
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

  Widget _choice('''
if marker in s:
    s = s.replace(marker, styled, 1)

p.write_text(s, encoding='utf-8')
print('premium account restore applied')
