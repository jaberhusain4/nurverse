import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../services/settings_sync_service.dart';
import '../../theme/app_theme.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key, this.onContinueWithoutAccount});

  final VoidCallback? onContinueWithoutAccount;

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.instance.signInWithGoogle();

      if (!mounted) return;

      await SettingsSyncService.instance.applyToProvider(
        context.read<SettingsProvider>(),
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } on Exception catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object error) {
    final String message = error.toString();

    if (message.contains('canceled') || message.contains('cancelled')) {
      return 'Google sign-in বাতিল করা হয়েছে।';
    }
    if (message.contains('operation-not-allowed')) {
      return 'Firebase Console-এ Google Sign-In চালু করা নেই।';
    }
    if (message.contains('ApiException: 10') ||
        message.contains('DEVELOPER_ERROR')) {
      return 'Google Sign-In configuration ঠিক নেই। Firebase-এ Android SHA-1/SHA-256 যাচাই করুন।';
    }
    return 'Google Sign-In সম্পন্ন হয়নি। আবার চেষ্টা করুন।';
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinueAsGuest = widget.onContinueWithoutAccount != null;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // NurVerse brand mark: keep the same mosque identity used
                  // by the Home header throughout the app.
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: AppColors.seaBlue.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Icon(
                      Icons.mosque_rounded,
                      size: 50,
                      color: AppColors.seaBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NurVerse',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'আপনার ইবাদতের সঙ্গী',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'অ্যাকাউন্টে সাইন ইন করুন',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'আপনার NurVerse account ও ভবিষ্যতের personal features নিরাপদে sync করতে Google ব্যবহার করুন।',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _loading ? null : _signIn,
                              icon: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.account_circle_outlined),
                              label: Text(
                                _loading ? 'Signing in...' : 'Continue with Google',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (canContinueAsGuest) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Google account ছাড়াও NurVerse ব্যবহার করা যাবে।',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onContinueWithoutAccount,
                      child: const Text('Continue without account'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
