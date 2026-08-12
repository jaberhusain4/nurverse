import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../home_screen.dart';
import 'google_login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _continueAsGuest = false;

  @override
  Widget build(BuildContext context) {
    if (_continueAsGuest) {
      return MainNavigationScreen();
    }

    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return MainNavigationScreen();
        }

        return GoogleLoginScreen(
          onContinueWithoutAccount: () {
            setState(() => _continueAsGuest = true);
          },
        );
      },
    );
  }
}
