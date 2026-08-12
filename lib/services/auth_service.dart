import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

      return await _auth.signInWithCredential(credential);
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
