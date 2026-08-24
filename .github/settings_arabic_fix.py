from pathlib import Path
import re

p = Path('lib/screens/settings_hub_screen_v4.dart')
s = p.read_text(encoding='utf-8')

# Keep existing UI structure. Add a single 3-language renderer and only change
# user-visible language branches/fallback helpers.
anchor = "class SettingsHubScreenV4 extends StatelessWidget {\n  const SettingsHubScreenV4({super.key});\n"
helper = r'''class SettingsHubScreenV4 extends StatelessWidget {
  const SettingsHubScreenV4({super.key});

  static const Map<String, String> _ar = {
    'Settings': 'الإعدادات',
    'Personalization': 'التخصيص',
    'Home Screen': 'الشاشة الرئيسية',
    'Choose Simple or Informative Home': 'اختر الصفحة الرئيسية البسيطة أو التفصيلية',
    'Appearance': 'المظهر',
    'Theme': 'السمة',
    'Language': 'اللغة',
    'English': 'الإنجليزية',
    'Bangla': 'البنغالية',
    'Arabic': 'العربية',
    'App Text Size': 'حجم نص التطبيق',
    'Show seconds': 'إظهار الثواني',
    'Show seconds where supported': 'إظهار الثواني حيثما كانت مدعومة',
    'Vibration': 'الاهتزاز',
    'Allow supported haptic feedback': 'السماح بالتغذية اللمسية المدعومة',
    'Prayer & Adhan': 'الصلاة والأذان',
    'Prayer Calculation': 'حساب أوقات الصلاة',
    'Madhhab': 'المذهب',
    'Adhan Notifications': 'إشعارات الأذان',
    'Enable prayer-time notifications': 'تفعيل إشعارات أوقات الصلاة',
    'Prayer Adjustments': 'تعديلات أوقات الصلاة',
    'Jamaat Times': 'أوقات الجماعة',
    'Set local Jamaat times': 'تعيين أوقات الجماعة المحلية',
    'Quran': 'القرآن',
    'Quran Reading': 'قراءة القرآن',
    'Translation': 'الترجمة',
    'Arabic Font': 'الخط العربي',
    'Auto-play next': 'التشغيل التلقائي التالي',
    'Continue with the next supported audio item': 'المتابعة مع العنصر الصوتي التالي المدعوم',
    'Wi-Fi only downloads': 'التنزيل عبر Wi-Fi فقط',
    'Prefer Wi-Fi for downloadable Quran resources': 'تفضيل Wi-Fi لموارد القرآن القابلة للتنزيل',
    'Worship & Dates': 'العبادة والتواريخ',
    'Daily Content': 'المحتوى اليومي',
    'Ayah, Hadith and Dua visibility': 'إظهار الآية والحديث والدعاء',
    'Date Preferences': 'تفضيلات التاريخ',
    'Data & App': 'البيانات والتطبيق',
    'Reset Settings': 'إعادة ضبط الإعدادات',
    'Restore configurable preferences': 'إعادة التفضيلات القابلة للتكوين إلى الوضع الافتراضي',
    'About NurVerse': 'حول نورفيرس',
    'Open Source Licenses': 'تراخيص المصادر المفتوحة',
    'Libraries used by NurVerse': 'المكتبات المستخدمة في نورفيرس',
    'NurVerse': 'نورفيرس',
    'NurVerse Premium': 'نورفيرس بريميوم',
    'ACTIVE': 'نشط',
    'Your premium experience is active': 'تجربة بريميوم الخاصة بك مفعلة',
    'Unlock a richer, calmer NurVerse': 'اكتشف تجربة نورفيرس أكثر ثراءً وهدوءًا',
    'AMOLED': 'AMOLED',
    'Premium Themes': 'سمات بريميوم',
    'Recitations': 'تلاوات',
    'Cloud Sync': 'مزامنة سحابية',
    'Manage Premium': 'إدارة بريميوم',
    'Explore Premium': 'استكشاف بريميوم',
    'NurVerse User': 'مستخدم نورفيرس',
    'Logout': 'تسجيل الخروج',
    'Premium is active.': 'بريميوم مفعّل.',
    'Done': 'تم',
    'Light Mode': 'الوضع الفاتح',
    'Dark Mode': 'الوضع الداكن',
    'System Default': 'افتراضي النظام',
    'AMOLED Black': 'أسود AMOLED',
    'Small': 'صغير',
    'Normal': 'عادي',
    'Large': 'كبير',
    'Very Large': 'كبير جدًا',
    'No adjustments': 'لا توجد تعديلات',
    'min': 'د',
    'Hijri only': 'هجري فقط',
    'Gregorian only': 'ميلادي فقط',
    'Both dates': 'كلا التاريخين',
    'system': 'افتراضي النظام',
    'light': 'الوضع الفاتح',
    'dark': 'الوضع الداكن',
    'amoled': 'أسود AMOLED',
    'Default': 'افتراضي',
    'hijri': 'هجري',
    'gregorian': 'ميلادي',
    'both': 'كلاهما',
    'Karachi': 'كراتشي',
    'Muslim World League': 'رابطة العالم الإسلامي',
    'Egyptian': 'المصري',
    'Umm Al Qura': 'أم القرى',
    'Dubai': 'دبي',
    'Qatar': 'قطر',
    'Kuwait': 'الكويت',
    'Singapore': 'سنغافورة',
    'North America': 'أمريكا الشمالية',
    'Moonsighting Committee': 'لجنة رؤية الهلال',
    'Hanafi': 'حنفي',
    'Shafi': 'شافعي',
    'Fajr': 'الفجر',
    'Dhuhr': 'الظهر',
    'Asr': 'العصر',
    'Maghrib': 'المغرب',
    'Isha': 'العشاء',
    'Cancel': 'إلغاء',
    'Save': 'حفظ',
    'Reset': 'إعادة ضبط',
    'Premium': 'بريميوم',
    'Daily Ayah': 'آية اليوم',
    'Daily Hadith': 'حديث اليوم',
    'Daily Dua': 'دعاء اليوم',
    'Quran Arabic': 'عربي القرآن',
}

  String _t(String languageCode, String bn, String en, [String? ar]) {
    if (languageCode == 'ar') return ar ?? _ar[en] ?? en;
    if (languageCode == 'en') return en;
    return bn;
  }
'''
if 'static const Map<String, String> _ar' not in s:
    s = s.replace(anchor, helper, 1)

# Establish explicit language code while preserving existing isEnglish/isArabic uses.
s = s.replace("    final isEnglish = settings.isEnglish;\n    final isArabic = settings.isArabic;", "    final languageCode = settings.languageCode;\n    final isEnglish = languageCode == 'en';\n    final isArabic = languageCode == 'ar';", 1)

# Transform direct two-way UI ternaries to 3-way renderer using an English->Arabic dictionary.
def repl_two(m):
    en, bn = m.group(1), m.group(2)
    return f"_t(languageCode, '{bn}', '{en}')"

# The source uses simple single-quoted strings for these UI ternaries.
s = re.sub(r"isEnglish\s*\?\s*'([^'\n]*)'\s*:\s*'([^'\n]*)'", repl_two, s)

# Restore the already-correct Language choice tri-branches where the generic regex touched them.
s = s.replace("_t(languageCode, 'ভাষা', 'Language')", "_t(languageCode, 'ভাষা', 'Language', 'اللغة')")
s = s.replace("_t(languageCode, 'বাংলা', 'English')", "_t(languageCode, 'বাংলা', 'English', 'العربية')")
s = s.replace("isEnglish ? 'Language' : isArabic ? 'اللغة' : 'ভাষা'", "_t(languageCode, 'ভাষা', 'Language', 'اللغة')")
s = s.replace("isEnglish ? 'English' : isArabic ? 'العربية' : 'বাংলা'", "_t(languageCode, 'বাংলা', 'English', 'العربية')")

# Helper call signatures: carry Arabic state where these helpers need it.
s = s.replace("_textSizeLabel(textScale.level, isEnglish)", "_textSizeLabel(textScale.level, languageCode)")
s = s.replace("_adjustmentLabel(settings, isEnglish)", "_adjustmentLabel(settings, languageCode)")
s = s.replace("_dateLabel(settings, isEnglish)", "_dateLabel(settings, languageCode)")

s = s.replace("String _textSizeLabel(int level, bool isEnglish)", "String _textSizeLabel(int level, String languageCode)")
s = re.sub(r"return isEnglish \? 'Small' : '([^']*)';", r"return _t(languageCode, '\1', 'Small');", s)
s = re.sub(r"return isEnglish \? 'Large' : '([^']*)';", r"return _t(languageCode, '\1', 'Large');", s)
s = re.sub(r"return isEnglish \? 'Very Large' : '([^']*)';", r"return _t(languageCode, '\1', 'Very Large');", s)
s = re.sub(r"return isEnglish \? 'Normal' : '([^']*)';", r"return _t(languageCode, '\1', 'Normal');", s)

s = s.replace("String _adjustmentLabel(SettingsProvider settings, bool isEnglish)", "String _adjustmentLabel(SettingsProvider settings, String languageCode)")
s = s.replace("if (active.isEmpty) return isEnglish ? 'No adjustments' : 'কোনো সমন্বয় নেই';", "if (active.isEmpty) return _t(languageCode, 'কোনো সমন্বয় নেই', 'No adjustments');")
s = s.replace("final prayer = _prayerLabel(entry.key, isEnglish);", "final prayer = _prayerLabel(entry.key, languageCode);")
s = s.replace("${isEnglish ? 'min' : 'মিনিট'}", "${_t(languageCode, 'মিনিট', 'min')}")

s = s.replace("String _dateLabel(SettingsProvider settings, bool isEnglish)", "String _dateLabel(SettingsProvider settings, String languageCode)")
s = s.replace("return isEnglish ? 'Hijri only' : 'শুধু হিজরি';", "return _t(languageCode, 'শুধু হিজরি', 'Hijri only');")
s = s.replace("return isEnglish ? 'Gregorian only' : 'শুধু গ্রেগরিয়ান';", "return _t(languageCode, 'শুধু গ্রেগরিয়ান', 'Gregorian only');")
s = s.replace("return isEnglish ? 'Both dates' : 'উভয় তারিখ';", "return _t(languageCode, 'উভয় তারিখ', 'Both dates');")

# Choice/prayer labels now accept language code, avoiding Arabic falling through to Bangla.
s = s.replace("String _choiceLabel(String option, bool isEnglish)", "String _choiceLabel(String option, String languageCode)")
old = """    if (isEnglish) {
      if (option == 'bn') return 'Bangla';
      if (option == 'en') return 'English';
      if (option == 'ar') return 'Arabic';
      return option;
    }
"""
new = """    if (languageCode == 'en') {
      if (option == 'bn') return 'Bangla';
      if (option == 'en') return 'English';
      if (option == 'ar') return 'Arabic';
      return option;
    }
    if (languageCode == 'ar') {
      return _ar[option] ?? option;
    }
"""
s = s.replace(old, new, 1)
s = s.replace("String _prayerLabel(String prayer, bool isEnglish)", "String _prayerLabel(String prayer, String languageCode)")
s = s.replace("    if (isEnglish) return prayer;\n", "    if (languageCode == 'en') return prayer;\n    if (languageCode == 'ar') return _ar[prayer] ?? prayer;\n", 1)
s = s.replace("String _calculationLabel(String method, bool isEnglish) => _choiceLabel(method, isEnglish);", "String _calculationLabel(String method, String languageCode) => _choiceLabel(method, languageCode);")
s = s.replace("String _madhabLabel(String madhab, bool isEnglish) => _choiceLabel(madhab, isEnglish);", "String _madhabLabel(String madhab, String languageCode) => _choiceLabel(madhab, languageCode);")
s = s.replace("String _quranTranslationLabel(String translation, bool isEnglish) => _choiceLabel(translation, isEnglish);", "String _quranTranslationLabel(String translation, String languageCode) => _choiceLabel(translation, languageCode);")

s = s.replace("_calculationLabel(settings.calculationMethod, isEnglish)", "_calculationLabel(settings.calculationMethod, languageCode)")
s = s.replace("_madhabLabel(settings.madhab, isEnglish)", "_madhabLabel(settings.madhab, languageCode)")
s = s.replace("_quranTranslationLabel(settings.quranTranslation, isEnglish)", "_quranTranslationLabel(settings.quranTranslation, languageCode)")
s = s.replace("_prayerLabel(prayer, settings.isEnglish)", "_prayerLabel(prayer, settings.languageCode)")

# Choice sheet uses the active locale for all option labels.
s = s.replace("...options.map(\n              (option) => ListTile(\n                title: Text(\n                  options.length == 3 && options.contains('bn') && options.contains('en') && options.contains('ar')", "...options.map(\n              (option) => ListTile(\n                title: Text(\n                  options.length == 3 && options.contains('bn') && options.contains('en') && options.contains('ar')", 1)
s = s.replace(": _choiceLabel(option, isEnglish),", ": _choiceLabel(option, languageCode),")

# Text-size sheet should use the current locale, not a bool.
s = s.replace("Future<void> _showTextSizeSheet(BuildContext context, TextScaleProvider provider, bool isEnglish)", "Future<void> _showTextSizeSheet(BuildContext context, TextScaleProvider provider, bool isEnglish)")
# Add Arabic handling without changing its external call shape.
s = s.replace("final labels = isEnglish ? const ['Small', 'Normal', 'Large', 'Very Large'] : const ['ছোট', 'স্বাভাবিক', 'বড়', 'খুব বড়'];", "final languageCode = Localizations.localeOf(context).languageCode;\n    final labels = languageCode == 'en' ? const ['Small', 'Normal', 'Large', 'Very Large'] : languageCode == 'ar' ? const ['صغير', 'عادي', 'كبير', 'كبير جدًا'] : const ['ছোট', 'স্বাভাবিক', 'বড়', 'খুব বড়'];")
s = s.replace("Text(isEnglish ? 'App Text Size' : 'অ্যাপের লেখা'", "Text(_t(languageCode, 'অ্যাপের লেখা', 'App Text Size', 'حجم نص التطبيق')")

# Adjustment/Jamaat/Quran/Reset/Daily-content dialogs use SettingsProvider's real language.
s = s.replace("settings.isEnglish ? 'Prayer Adjustments' : 'সালাতের সময় সমন্বয়'", "_t(settings.languageCode, 'সালাতের সময় সমন্বয়', 'Prayer Adjustments', 'تعديلات أوقات الصلاة')")
s = s.replace("settings.isEnglish ? 'Jamaat Times' : 'জামাতের সময়'", "_t(settings.languageCode, 'জামাতের সময়', 'Jamaat Times', 'أوقات الجماعة')")
s = s.replace("settings.isEnglish ? 'Done' : 'সম্পন্ন'", "_t(settings.languageCode, 'সম্পন্ন', 'Done', 'تم')")
s = s.replace("settings.isEnglish ? 'Cancel' : 'বাতিল'", "_t(settings.languageCode, 'বাতিল', 'Cancel', 'إلغاء')")
s = s.replace("settings.isEnglish ? 'Save' : 'সংরক্ষণ'", "_t(settings.languageCode, 'সংরক্ষণ', 'Save', 'حفظ')")
s = s.replace("settings.isEnglish ? 'Quran Arabic' : 'কুরআন আরবি'", "_t(settings.languageCode, 'কুরআন আরবি', 'Quran Arabic', 'عربي القرآن')")
s = s.replace("settings.isEnglish ? 'Translation' : 'অনুবাদ'", "_t(settings.languageCode, 'অনুবাদ', 'Translation', 'الترجمة')")
s = s.replace("current.isEnglish ? 'Daily Ayah' : 'দৈনিক আয়াত'", "_t(current.languageCode, 'দৈনিক আয়াত', 'Daily Ayah', 'آية اليوم')")
s = s.replace("current.isEnglish ? 'Daily Hadith' : 'দৈনিক হাদিস'", "_t(current.languageCode, 'দৈনিক হাদিস', 'Daily Hadith', 'حديث اليوم')")
s = s.replace("current.isEnglish ? 'Daily Dua' : 'দৈনিক দোয়া'", "_t(current.languageCode, 'দৈনিক দোয়া', 'Daily Dua', 'دعاء اليوم')")
s = s.replace("settings.isEnglish ? 'Reset settings?' : 'সেটিংস রিসেট করবেন?'", "_t(settings.languageCode, 'সেটিংস রিসেট করবেন?', 'Reset settings?', 'هل تريد إعادة ضبط الإعدادات؟')")
s = s.replace("settings.isEnglish ? 'All saved preferences will return to their default values.' : 'সব সংরক্ষিত সেটিংস ডিফল্ট অবস্থায় ফিরে যাবে.'", "_t(settings.languageCode, 'সব সংরক্ষিত সেটিংস ডিফল্ট অবস্থায় ফিরে যাবে।', 'All saved preferences will return to their default values.', 'ستعود جميع التفضيلات المحفوظة إلى إعداداتها الافتراضية.')")
s = s.replace("settings.isEnglish ? 'Reset' : 'রিসেট'", "_t(settings.languageCode, 'রিসেট', 'Reset', 'إعادة ضبط')")

# Premium/account helper booleans gain Arabic through current provider/locale.
s = s.replace("final isEnglish = settings.languageCode == 'en';\n    final isActive = premium.isPremium;", "final languageCode = settings.languageCode;\n    final isEnglish = languageCode == 'en';\n    final isArabic = languageCode == 'ar';\n    final isActive = premium.isPremium;", 1)
s = re.sub(r"isEnglish \? '([^'\n]*)' : '([^'\n]*)'", lambda m: f"_t(languageCode, '{m.group(2)}', '{m.group(1)}')", s)

# Account sheet: use locale directly.
s = s.replace("final isEnglish = Localizations.localeOf(context).languageCode == 'en';", "final languageCode = Localizations.localeOf(context).languageCode;\n    final isEnglish = languageCode == 'en';")
# Premium status dialog: use language code.
s = s.replace("Future<void> _showPremiumStatus(BuildContext context, PremiumProvider premium, bool isEnglish)", "Future<void> _showPremiumStatus(BuildContext context, PremiumProvider premium, bool isEnglish)")

# Final clean-up of any direct English/Bangla choice-label helper calls left behind.
s = s.replace("_choiceLabel(option, isEnglish)", "_choiceLabel(option, languageCode)")
s = s.replace("_prayerLabel(entry.key, isEnglish)", "_prayerLabel(entry.key, languageCode)")

p.write_text(s, encoding='utf-8')
print('Arabic settings localization transformation complete')
