import 'language_controller.dart';

class AppStrings {
  final LanguageController language;

  AppStrings(this.language);

  bool get bn => language.isBangla;

  // ---------------------------
  // App
  // ---------------------------

  String get appName => bn ? "নূরভার্স" : "NurVerse";

  String get greeting => bn ? "আসসালামু আলাইকুম" : "Assalamu Alaikum";

  // ---------------------------
  // Home
  // ---------------------------

  String get currentPrayer => bn ? "বর্তমান সালাত" : "Current Prayer";

  String get nextPrayer => bn ? "পরবর্তী সালাত" : "Next Prayer";

  String get remaining => bn ? "বাকি" : "Remaining";

  String get prayerTimeline => bn ? "সালাতের সময়সূচী" : "Prayer Timeline";

  String get continueReading => bn ? "পাঠ চালিয়ে যান" : "Continue Reading";

  String get quickActions => bn ? "কুইক অ্যাকশনস" : "Quick Actions";

  // ---------------------------
  // Daily
  // ---------------------------

  String get dailyAyah => bn ? "আজকের আয়াত" : "Daily Ayah";

  String get dailyHadith => bn ? "আজকের হাদিস" : "Daily Hadith";

  String get dailyDua => bn ? "আজকের দোয়া" : "Daily Dua";

  // ---------------------------
  // Bottom Navigation
  // ---------------------------

  String get home => bn ? "হোম" : "Home";

  String get prayer => bn ? "সালাত" : "Prayer";

  String get quran => bn ? "কুরআন" : "Quran";

  String get dua => bn ? "দোয়া" : "Dua";

  String get tools => bn ? "টুলস" : "Tools";

  String get more => bn ? "আরও" : "More";

  // ---------------------------
  // Tools
  // ---------------------------

  String get qibla => bn ? "কিবলা" : "Qibla";

  String get tasbih => bn ? "তাসবীহ" : "Tasbih";

  String get zakat => bn ? "যাকাত" : "Zakat";

  String get ruqyah => bn ? "রুকিয়াহ" : "Ruqyah";

  String get names99 => bn ? "আল্লাহর ৯৯ নাম" : "99 Names of Allah";
}
