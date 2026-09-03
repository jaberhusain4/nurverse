from pathlib import Path

path = Path('lib/screens/canonical_settings_screen.dart')
text = path.read_text(encoding='utf-8')

# Shared auth service.
if "import '../services/auth_service.dart';" not in text:
    marker = "import '../providers/text_scale_provider.dart';\n"
    if marker not in text:
        raise SystemExit('settings import marker not found')
    text = text.replace(marker, marker + "import '../services/auth_service.dart';\n", 1)

# Premium card must use the shared auth state source.
old_stream = """    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
"""
new_stream = """    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
"""
if old_stream in text:
    text = text.replace(old_stream, new_stream, 1)

# Restore the full account interaction on the Premium card.
old_account = """                        child: user == null
                            ? Icon(
                                Icons.person_outline_rounded,
                                color: theme.colorScheme.primary,
                                size: 22,
                              )
                            : Icon(
                                Icons.person_rounded,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
"""
new_account = """                        child: Builder(
                          builder: (buttonContext) {
                            final photoUrl = user?.photoURL?.trim();
                            final hasPhoto = user != null &&
                                photoUrl != null &&
                                photoUrl.isNotEmpty;
                            return InkWell(
                              onTap: () async {
                                if (user == null) {
                                  await Navigator.of(buttonContext).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const GoogleLoginScreen(),
                                    ),
                                  );
                                  return;
                                }
                                await showModalBottomSheet<void>(
                                  context: buttonContext,
                                  showDragHandle: true,
                                  builder: (sheetContext) => SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        8,
                                        20,
                                        24,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 34,
                                            backgroundColor: AppColors.seaBlue
                                                .withValues(alpha: .10),
                                            backgroundImage: hasPhoto
                                                ? NetworkImage(photoUrl!)
                                                : null,
                                            child: hasPhoto
                                                ? null
                                                : Icon(
                                                    Icons.account_circle_rounded,
                                                    size: 46,
                                                    color: theme.colorScheme.primary,
                                                  ),
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
                                                color: theme.textTheme.bodyMedium?.color
                                                    ?.withValues(alpha: .70),
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
                                                languageCode == 'en'
                                                    ? 'Logout'
                                                    : 'লগআউট',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: SizedBox(
                                width: 42,
                                height: 42,
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
                            );
                          },
                        ),
"""
if old_account in text:
    text = text.replace(old_account, new_account, 1)

# Restore the large Premium card presentation if an older compact variant is present.
text = text.replace(
    'padding: const EdgeInsets.all(20),\n          decoration: BoxDecoration(',
    'padding: const EdgeInsets.all(22),\n          decoration: BoxDecoration(',
    1,
)
text = text.replace(
    'borderRadius: BorderRadius.circular(28),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),',
    'borderRadius: BorderRadius.circular(30),\n            border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),',
    1,
)
text = text.replace('width: 54,\n                    height: 54,', 'width: 60,\n                    height: 60,', 1)
text = text.replace('size: 30,\n                    ),', 'size: 32,\n                    ),', 1)
text = text.replace(
    'fontSize: 18,\n                                  fontWeight: FontWeight.w900,',
    'fontSize: 20,\n                                  fontWeight: FontWeight.w900,',
    1,
)

# NurVerse SeaBlue styling for the 12/24 selector.
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
if old_segment in text:
    text = text.replace(old_segment, new_segment, 1)

path.write_text(text, encoding='utf-8')
print('premium card/account and 12/24 styling restored')
