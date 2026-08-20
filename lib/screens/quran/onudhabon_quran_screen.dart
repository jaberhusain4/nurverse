import 'package:flutter/material.dart';

import 'premium_onudhabon_reader_v2.dart';

class OnudhabonQuranScreen extends StatelessWidget {
  final bool openLastRead;

  const OnudhabonQuranScreen({super.key, this.openLastRead = false});

  @override
  Widget build(BuildContext context) {
    return PremiumOnudhabonReaderV2(openLastRead: openLastRead);
  }
}
