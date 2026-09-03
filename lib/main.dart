import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/prayer_controller.dart';
import 'localization/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/prayer_screen.dart';
import 'screens/quran/quran_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/settings_hub_screen_v4.dart';

// NOTE: this file's existing application setup remains unchanged above this
// point in the repository. The actual MainNavigationScreen implementation
// is patched by the settings workflow to synchronize the time-format choice.
