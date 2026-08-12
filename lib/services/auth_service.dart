import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'settings_sync_service.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const String _serverClientId =
      '220451879730-t11scoc7f9018t41vdhlblnompmuuin1.apps.googleusercontent.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<void> initializeGoogleSignIn() async {
    await _googleSignIn.initialize(
      serverClientId: _serverClientId,
    );
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithGoogle() async {
    if (!_googleSignIn.supportsAuthenticate()) {
      throw StateError('Google Sign-In is not supported on this platform.');
    }

    try {
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google did not return an ID token. Check the Android Google OAuth configuration.',
        );
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential credentialResult =
          await _auth.signInWithCredential(credential);

      final User? user = credentialResult.user;
      if (user != null) {
        final String? photoUrl = googleUser.photoUrl;
        final String? displayName = googleUser.displayName;

        if (photoUrl != null && photoUrl.isNotEmpty && user.photoURL != photoUrl ||
            displayName != null && displayName.isNotEmpty && user.displayName != displayName) {
          await user.updateProfile(
            displayName: displayName ?? user.displayName,
            photoURL: photoUrl ?? user.photoURL,
          );
          await user.reload();
        }
      }

      // Restore the account's saved NurVerse settings, or create the first
      // cloud backup from the device's current settings.
      await SettingsSyncService.instance.syncCurrentUser();

      return credentialResult;
    } on FirebaseAuthException {
      rethrow;
    } on GoogleSignInException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
