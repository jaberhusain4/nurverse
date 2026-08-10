# NurVerse Logo & App Icon Installation Guide

তুমি যে লোগো দিয়েছ সেটা দিয়ে আমি সব প্ল্যাটফর্মের আইকন + ইন-অ্যাপ লোগো তৈরি করে দিয়েছি।

## ১. In-App Logo (assets)

কপি করো:
```
assets/images/logo.png          ← 512px transparent (মূল লোগো)
assets/images/logo_256.png      ← ছোট ভার্সন
```

ফাইলগুলো এখানে পাবে: `nurverse_icons/assets/`

## ২. Android App Icon (Adaptive + Google Themed / Dark Mode)

Android 13+ Themed Icons (Material You / Google themed icons) সাপোর্ট করার জন্য **monochrome** লেয়ার রাখা হয়েছে। Dark mode-এ সিস্টেম অটোমেটিক্যালি থিম কালার অ্যাপ্লাই করবে।

### ফাইল কপি করার জায়গা:

```
android/app/src/main/res/
├── drawable/
│   ├── ic_launcher_foreground.png
│   ├── ic_launcher_monochrome.png
│   ├── ic_nurverse_foreground.xml
│   └── ic_nurverse_monochrome.xml
├── mipmap-anydpi-v26/
│   └── ic_launcher.xml
├── mipmap-mdpi/ic_launcher.png
├── mipmap-hdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
├── mipmap-xxxhdpi/ic_launcher.png
└── values/colors.xml          (nurverse_launcher_background = #0B4D3B)
```

### অপশনাল (Vector ভার্সন — আরও sharp):
যদি PNG-এর বদলে vector চাও, তাহলে:
- `ic_nurverse_foreground_vector.xml` → `ic_nurverse_foreground.xml` হিসেবে rename করে দাও
- `ic_nurverse_monochrome_vector.xml` → `ic_nurverse_monochrome.xml` হিসেবে rename করে দাও

## ৩. iOS App Icon

সব ফাইল কপি করো:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```
(সব `Icon-App-*.png` ফাইল)

## ৪. Web Icons

```
web/icons/Icon-192.png
web/icons/Icon-512.png
web/icons/Icon-maskable-192.png
web/icons/Icon-maskable-512.png
web/favicon.png
```

## ৫. Build করার পর

```bash
flutter clean
flutter pub get
# Android
flutter run
# বা
flutter build apk
```

Android Studio / VS Code-এ থেকে **Uninstall** করে আবার ইনস্টল করলে নতুন আইকন দেখা যাবে (ক্যাশ ক্লিয়ার হয়)।

---

### Dark Mode / Google Themed Icon কীভাবে কাজ করে?

`ic_launcher.xml`-এ `<monochrome>` লেয়ার আছে।  
Android 13+ ডিভাইসে Settings → Wallpaper & style → Themed icons অন থাকলে সিস্টেম এই monochrome মাস্ক ব্যবহার করে অ্যাপের আইকনকে ওয়ালপেপারের সাথে মিলিয়ে রঙ করে (dark mode-এও সুন্দর দেখায়)।

বর্তমান ব্যাকগ্রাউন্ড কালার: **#0B4D3B** (গভীর সবুজ)
