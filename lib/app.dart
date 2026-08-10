import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

class NurVerseApp extends StatelessWidget {
  const NurVerseApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NurVerse",
      theme: Theme.of(context),
      home: const SplashScreen(),
    );
  }
}
