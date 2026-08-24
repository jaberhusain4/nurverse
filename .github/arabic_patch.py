from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

ARABIC = {
    'Home':'الرئيسية','Prayer':'الصلاة','Quran':'القرآن','Hadith':'الحديث','Tools':'الأدوات','More':'المزيد',
    'Refresh':'تحديث','Refresh prayer times':'تحديث أوقات الصلاة','Try Again':'حاول مرة أخرى','Cancel':'إلغاء',
    'Save':'حفظ','Close':'إغلاق','Done':'تم','Search':'بحث','Settings':'الإعدادات','Current Prayer':'الصلاة الحالية',
    'Next Prayer':'الصلاة التالية','Prayer Time':'وقت الصلاة','Today':'اليوم','Sunrise':'الشروق','Sunset':'الغروب',
    'Current Location':'الموقع الحالي','Today’s Prayer':'صلاة اليوم','Complete prayer schedule':'جدول الصلاة الكامل',
    'Prayer Times':'أوقات الصلاة','Previous Prayer':'الصلاة السابقة','Current':'الحالي','Next':'التالي','Completed':'تمت',
    'No prayer window':'لا يوجد وقت للصلاة','Start':'البداية','End':'النهاية','Jama’ah':'الجماعة','Friday':'الجمعة',
    'Important Times Today':'الأوقات المهمة اليوم','Solar Noon':'الزوال','Makruh Time':'وقت الكراهة','Prohibited Time':'الوقت المنهي عنه',
    'Nafl & Other Prayers':'النوافل والصلوات الأخرى','Important times for optional worship':'أوقات مهمة للعبادات النافلة',
    'Ishraq':'الإشراق','Duha':'الضحى','Awwabin':'الأوابين','Tahajjud':'التهجد','Prayer Tracker':'متابعة الصلوات',
    'Mark the prayers you have performed':'حدد الصلوات التي أديتها','Could not load prayer information':'تعذر تحميل معلومات الصلاة',
    'Prayer times may vary depending on location, date, and calculation method.':'قد تختلف أوقات الصلاة حسب الموقع والتاريخ وطريقة الحساب.',
    'Fajr':'الفجر','Dhuhr':'الظهر','Asr':'العصر','Maghrib':'المغرب','Isha':'العشاء','Jumu’ah':'الجمعة',
    'Qibla':'القبلة','Tasbih':'التسبيح','Asma ul Husna':'أسماء الله الحسنى','Ruqyah':'الرقية','Zakat Calculator':'حاسبة الزكاة',
    'Islamic Calendar':'التقويم الإسلامي','Nearby Mosque':'المسجد القريب','Islamic Books':'الكتب الإسلامية',
    'Ayah of the Day':'آية اليوم','Hadith of the Day':'حديث اليوم','Dua of the Day':'دعاء اليوم','Continue Reading':'متابعة القراءة',
    'Last Read':'آخر قراءة','See All':'عرض الكل','Language':'اللغة','Theme':'المظهر','Light':'فاتح','Dark':'داكن',
    'System':'النظام','Bangla':'البنغالية','English':'الإنجليزية','Arabic':'العربية','Location unavailable':'الموقع غير متاح',
    'No data available':'لا توجد بيانات','Something went wrong':'حدث خطأ ما','Loading...':'جارٍ التحميل...',
    'Islamic Tools':'الأدوات الإسلامية','Worship & Practice':'العبادة والعمل','Dua':'الدعاء','Dua and supplication':'الدعاء والمناجاة',
    'Dhikr counting and practice':'عدّ الذكر والعبادة','Quran and authentic duas':'القرآن والأدعية الصحيحة','99 Names of Allah':'أسماء الله الحسنى',
    'Quran & Hadith':'القرآن والحديث','Reading, audio and saved knowledge':'القراءة والاستماع والمعرفة المحفوظة',
    'Audio Quran':'القرآن الصوتي','Listen to Quran recitation':'استمع إلى تلاوة القرآن','Saved Hadith':'الأحاديث المحفوظة',
    'Your favorite hadith':'أحاديثك المفضلة','Islamic knowledge library':'مكتبة المعرفة الإسلامية','Time & Direction':'الوقت والاتجاه',
    'Islamic time, date and Qibla':'الوقت والتاريخ والقبلة','Find the direction of the Kaaba':'تحديد اتجاه الكعبة',
    'Calendar':'التقويم','Hijri and Islamic dates':'التواريخ الهجرية والإسلامية','Islamic Calculations':'الحسابات الإسلامية',
    'Calculate your Zakat':'احسب زكاتك','Your Islamic Tools':'أدواتك الإسلامية','Al-Quran':'القرآن الكريم',
    'Hifzi Quran':'القرآن الحفظي','15-line offline Hifzi Quran':'قرآن حفظي من 15 سطرًا بدون إنترنت',
    'Onudhabon Quran':'قرآن التدبر','Translation • Tafsir':'الترجمة • التفسير','Translation':'الترجمة',
    'Audio Quran':'القرآن الصوتي','Offline cache':'التخزين المؤقت دون اتصال',
}


def write_arabic_strings():
    body = 'import \'dart:collection\';\n\nconst Map<String, String> kArabicStrings = UnmodifiableMapView<String, String>({\n'
    for k, v in ARABIC.items():
        body += f"  {k!r}: {v!r},\n"
    body += '});\n'
    path = ROOT / 'lib/localization/arabic_strings.dart'
    path.write_text(body, encoding='utf-8')


def replace_once(path, old, new):
    text = path.read_text(encoding='utf-8')
    if old not in text:
        raise RuntimeError(f'Pattern not found in {path}: {old[:120]!r}')
    path.write_text(text.replace(old, new, 1), encoding='utf-8')


def patch_localization():
    path = ROOT / 'lib/localization/app_localizations.dart'
    replace_once(path, "import 'package:flutter/material.dart';\n", "import 'package:flutter/material.dart';\nimport 'arabic_strings.dart';\n")
    replace_once(path, "static const supportedLocales = [Locale('bn'), Locale('en')];", "static const supportedLocales = [Locale('bn'), Locale('en'), Locale('ar')];")
    replace_once(path, "bool get isBangla => locale.languageCode == 'bn';\n  String _text(String bn, String en) => isBangla ? bn : en;", "bool get isBangla => locale.languageCode == 'bn';\n  bool get isArabic => locale.languageCode == 'ar';\n  String _text(String bn, String en) => isArabic ? (kArabicStrings[en] ?? en) : (isBangla ? bn : en);")
    replace_once(path, "String get english => _text('ইংরেজি', 'English');", "String get english => _text('ইংরেজি', 'English');\n  String get arabic => isArabic ? 'العربية' : (isBangla ? 'আরবি' : 'Arabic');")
    replace_once(path, "isSupported(Locale locale) => ['bn', 'en'].contains(locale.languageCode);", "isSupported(Locale locale) => ['bn', 'en', 'ar'].contains(locale.languageCode);")


def patch_settings_provider():
    path = ROOT / 'lib/providers/settings_provider.dart'
    replace_once(path, "bool get isEnglish => _languageCode == 'en';", "bool get isEnglish => _languageCode == 'en';\n\n  bool get isArabic => _languageCode == 'ar';")
    replace_once(path, "} else {\n        _languageCode = 'bn';\n      }", "} else if (savedLanguage == 'ar') {\n        _languageCode = 'ar';\n      } else {\n        _languageCode = 'bn';\n      }")
    replace_once(path, "if (normalizedCode != 'bn' && normalizedCode != 'en') {", "if (normalizedCode != 'bn' && normalizedCode != 'en' && normalizedCode != 'ar') {")
    replace_once(path, "Future<void> setEnglish() async {\n    await setLanguage('en');\n  }", "Future<void> setEnglish() async {\n    await setLanguage('en');\n  }\n\n  Future<void> setArabic() async {\n    await setLanguage('ar');\n  }")


def patch_language_controller():
    path = ROOT / 'lib/controllers/language_controller.dart'
    replace_once(path, "bool get isEnglish => _locale.languageCode == 'en';", "bool get isEnglish => _locale.languageCode == 'en';\n\n  bool get isArabic => _locale.languageCode == 'ar';")
    replace_once(path, "if (savedLanguage == 'en') {\n        _locale = const Locale('en');\n      } else {", "if (savedLanguage == 'en') {\n        _locale = const Locale('en');\n      } else if (savedLanguage == 'ar') {\n        _locale = const Locale('ar');\n      } else {")
    replace_once(path, "if (normalizedCode != 'bn' && normalizedCode != 'en') {", "if (normalizedCode != 'bn' && normalizedCode != 'en' && normalizedCode != 'ar') {")
    replace_once(path, "Future<void> setEnglish() async {\n    await setLanguage('en');\n  }", "Future<void> setEnglish() async {\n    await setLanguage('en');\n  }\n\n  Future<void> setArabic() async {\n    await setLanguage('ar');\n  }")


def patch_main():
    path = ROOT / 'lib/main.dart'
    replace_once(path, "await initializeDateFormatting('bn');", "await initializeDateFormatting('bn');\n  await initializeDateFormatting('ar');")


def patch_settings_hub():
    path = ROOT / 'lib/screens/settings_hub_screen_v4.dart'
    replace_once(path, "final isEnglish = settings.isEnglish;", "final isEnglish = settings.isEnglish;\n    final isArabic = settings.isArabic;")
    replace_once(path, "appBar: AppBar(title: Text(isEnglish ? 'Settings' : 'সেটিংস'))", "appBar: AppBar(title: Text(isEnglish ? 'Settings' : isArabic ? 'الإعدادات' : 'সেটিংস'))")
    replace_once(path, "isEnglish ? 'Language' : 'ভাষা',\n              isEnglish ? 'English' : 'বাংলা',", "isEnglish ? 'Language' : isArabic ? 'اللغة' : 'ভাষা',\n              isEnglish ? 'English' : isArabic ? 'العربية' : 'বাংলা',")
    replace_once(path, "const ['bn', 'en'],", "const ['bn', 'en', 'ar'],")
    replace_once(path, "'en': 'ইংরেজি',\n      'Bangla': 'বাংলা',", "'en': 'ইংরেজি',\n      'ar': 'العربية',\n      'Bangla': 'বাংলা',")
    replace_once(path, "if (option == 'en') return 'English';\n      return option;", "if (option == 'en') return 'English';\n      if (option == 'ar') return 'Arabic';\n      return option;")
    replace_once(path, "'en': 'ইংরেজি',\n      'Bangla': 'বাংলা',", "'en': 'ইংরেজি',\n      'ar': 'العربية',\n      'Bangla': 'বাংলা',")


write_arabic_strings()
patch_localization()
patch_settings_provider()
patch_language_controller()
patch_main()
patch_settings_hub()
print('Arabic patch applied successfully')
