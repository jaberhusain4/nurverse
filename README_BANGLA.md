# NurVerse — ধাপ ১: প্রজেক্ট ফাউন্ডেশন

এই zip-এ যা আছে:

```
nurverse/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── theme/app_theme.dart
    ├── widgets/main_shell.dart
    ├── widgets/common_widgets.dart
    └── screens/
        ├── home_screen.dart
        ├── prayer_screen.dart
        ├── quran_screen.dart
        ├── hadith_screen.dart
        ├── tools_screen.dart
        └── more_screen.dart
```

## এখন পর্যন্ত কী তৈরি হয়েছে

- ৬টি ট্যাবের Bottom Navigation (Home, Prayer, Quran, Hadith, Tools, More)
- "Sea Shore" থিম (Light + Dark মোড, Material 3, রাউন্ডেড কার্ড)
- **Home**: হেডার, বাংলা/হিজরি/ইংরেজি তারিখ, লোকেশন, নামাজ সামারি কার্ড, ৮টি কুইক অ্যাকশন, আজকের আয়াত/হাদিস/দোয়া, সর্বশেষ পঠিত
- **Prayer**: ৬ ওয়াক্তের সময়সূচী, বাড়তি তথ্য (সূর্যাস্ত, মাকরূহ সময় ইত্যাদি), নামাজ ট্র্যাকার, অ্যালার্ম সেটিংস
- **Quran**: হিফজ ও অধ্যয়ন — দুটি ট্যাব, সূরা লিস্ট
- **Hadith**: আজকের হাদিস, ৮টি হাদিস সংকলনের গ্রিড
- **Tools**: ১০টি ইসলামিক টুল + ৫টি "শীঘ্রই আসছে" টুল
- **More**: অ্যাকাউন্ট, প্রিমিয়াম ব্যানার, সেটিংস (থিম বদলানো এখনই কাজ করে), সাপোর্ট, অ্যাবাউট

⚠️ এখন সব ডেটা **mock/placeholder** — আসল প্রেয়ার টাইম ক্যালকুলেশন, কুরআন API, হাদিস ডাটাবেজ এখনো যুক্ত হয়নি। এটা শুধু কাঠামো (structure) ও ডিজাইন।

## কীভাবে বসাবেন

1. এই zip থেকে `lib/` ফোল্ডার আর `pubspec.yaml` আপনার existing Flutter প্রজেক্টে কপি করে replace করুন।
2. `pubspec.yaml`-এ যদি আগে থেকেই অন্য dependency থাকে, সেগুলো এই ফাইলের `dependencies:` অংশে যোগ করে নিন (google_fonts, intl নতুন যোগ হয়েছে)।
3. টার্মিনালে প্রজেক্ট ফোল্ডারে গিয়ে:
   ```
   flutter pub get
   flutter run
   ```

## পরের ধাপে কী করব

আপনি বলুন কোনটা আগে চান:
1. **Prayer times** আসল হিসাব (location + calculation method দিয়ে বাস্তব সময়)
2. **Quran** পূর্ণাঙ্গ ডেটা (আরবি + বাংলা অনুবাদ + অডিও)
3. **Hadith** পূর্ণাঙ্গ ডেটা
4. **Tools** গুলো (Tasbih, Qibla Compass, Dua লিস্ট, Zakat Calculator ইত্যাদি) এক এক করে ফাংশনাল করা

জানালে পরের zip সেই অনুযায়ী বানিয়ে দেব।
