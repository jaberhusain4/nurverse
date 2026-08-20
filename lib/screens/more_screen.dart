// lib/screens/more_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'auth/google_login_screen.dart';

import '../providers/premium_provider.dart';
import '../services/auth_service.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common/brand_logo.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final premium = context.watch<PremiumProvider>();
    final isEnglish = settings.languageCode == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEnglish ? 'Settings' : 'সেটিংস',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 8, AppSpacing.md, 32),
        children: [
          // ============================================================
          // PREMIUM HERO
          // ============================================================
          _buildPremiumHero(context, settings, premium),

          const SizedBox(height: 24),

          // ============================================================
          // APPEARANCE
          // ============================================================
          _buildSectionTitle(
            context,
            isEnglish ? 'Appearance' : 'অ্যাপের চেহারা',
            Icons.palette_outlined,
          ),

          _buildSettingsGroup(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.palette_outlined,
                title: isEnglish ? 'Theme' : 'থিম',
                subtitle: _themeLabel(settings),
                onTap: () {
                  _showThemeSheet(context, settings, premium);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.language_rounded,
                title: isEnglish ? 'Language' : 'ভাষা',
                subtitle: _languageLabel(settings),
                onTap: () {
                  _showLanguageSheet(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.text_fields_rounded,
                title: isEnglish ? 'Reading & Font' : 'পাঠ ও ফন্ট',
                subtitle:
                    isEnglish
                        ? 'Quran and translation appearance'
                        : 'কুরআন ও অনুবাদের লেখার আকার',
                trailing: Icons.arrow_forward_ios_rounded,
                onTap: () {
                  _showReadingSettings(context, settings);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================================
          // PRAYER & ADHAN
          // ============================================================
          _buildSectionTitle(
            context,
            isEnglish ? 'Prayer & Adhan' : 'সালাত ও আজান',
            Icons.mosque_outlined,
          ),

          _buildSettingsGroup(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.calculate_outlined,
                title:
                    isEnglish ? 'Prayer Calculation' : 'সালাতের হিসাব পদ্ধতি',
                subtitle: settings.calculationMethod,
                onTap: () {
                  _showCalculationMethodSheet(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.mosque_outlined,
                title: isEnglish ? 'Madhhab' : 'মাযহাব',
                subtitle: settings.madhhab,
                onTap: () {
                  _showMadhhabSheet(context, settings);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                context,
                icon: Icons.notifications_active_outlined,
                title: isEnglish ? 'Adhan Notifications' : 'আজান নোটিফিকেশন',
                subtitle:
                    isEnglish
                        ? 'Receive prayer-time reminders'
                        : 'সালাতের সময় মনে করিয়ে দিন',
                value: settings.isAdhanNotificationEnabled,
                onChanged: (value) {
                  settings.toggleAdhanNotification(value);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.volume_up_outlined,
                title:
                    isEnglish ? 'Adhan & Reminder Sounds' : 'আজান ও রিমাইন্ডার',
                subtitle: isEnglish ? 'Sound preferences' : 'শব্দের পছন্দ',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title: isEnglish ? 'Advanced Adhan' : 'Advanced Adhan',
                    description:
                        isEnglish
                            ? 'Advanced Adhan sounds, reminder controls and personalized prayer alerts are planned for NurVerse Premium.'
                            : 'Advanced Adhan sound, reminder control এবং personalized prayer alert NurVerse Premium-এর জন্য পরিকল্পনা করা হয়েছে।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.tune_rounded,
                title:
                    isEnglish ? 'Prayer Adjustments' : 'সালাতের সময় সমন্বয়',
                subtitle: _prayerAdjustmentSubtitle(settings, isEnglish),
                trailing: Icons.arrow_forward_ios_rounded,
                onTap: () {
                  _showPrayerAdjustmentsDialog(context, settings);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================================
          // QURAN
          // ============================================================
          _buildSectionTitle(
            context,
            isEnglish ? 'Quran' : 'কুরআন',
            Icons.menu_book_outlined,
          ),

          _buildSettingsGroup(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.format_size_rounded,
                title: isEnglish ? 'Quran Reading' : 'কুরআন পড়ার সেটিংস',
                subtitle:
                    isEnglish
                        ? 'Arabic and translation font size'
                        : 'আরবি ও অনুবাদের ফন্ট সাইজ',
                onTap: () {
                  _showReadingSettings(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.translate_rounded,
                title: isEnglish ? 'Translation' : 'অনুবাদ',
                subtitle:
                    isEnglish ? 'Translation preferences' : 'অনুবাদের পছন্দ',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title:
                        isEnglish
                            ? 'More Quran Translations'
                            : 'আরও কুরআন অনুবাদ',
                    description:
                        isEnglish
                            ? 'Additional translations and advanced reading preferences can be added to NurVerse Premium.'
                            : 'অতিরিক্ত অনুবাদ এবং advanced reading preference NurVerse Premium-এ যুক্ত করা যাবে।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.headphones_outlined,
                title: isEnglish ? 'Recitation' : 'তেলাওয়াত',
                subtitle:
                    isEnglish
                        ? 'Reciter and audio preferences'
                        : 'কারীর ও অডিও পছন্দ',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title:
                        isEnglish ? 'Premium Recitations' : 'Premium তেলাওয়াত',
                    description:
                        isEnglish
                            ? 'Premium reciters, audio controls and advanced Quran listening features are planned here.'
                            : 'Premium reciter, audio control এবং advanced Quran listening feature এখানে যুক্ত করা হবে।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.auto_stories_outlined,
                title: isEnglish ? 'Reading Goals' : 'কুরআন পড়ার লক্ষ্য',
                subtitle:
                    isEnglish
                        ? 'Build a consistent reading habit'
                        : 'নিয়মিত কুরআন পড়ার অভ্যাস তৈরি করুন',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title:
                        isEnglish
                            ? 'Quran Reading Goals'
                            : 'কুরআন পড়ার লক্ষ্য',
                    description:
                        isEnglish
                            ? 'Khatam plans, reading goals and progress insights are planned as premium tools.'
                            : 'খতম পরিকল্পনা, reading goal এবং progress insight Premium tool হিসেবে যুক্ত করা হবে।',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================================
          // WORSHIP & REMINDERS
          // ============================================================
          _buildSectionTitle(
            context,
            isEnglish ? 'Worship & Reminders' : 'ইবাদত ও রিমাইন্ডার',
            Icons.favorite_border_rounded,
          ),

          _buildSettingsGroup(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.today_outlined,
                title: isEnglish ? 'Daily Content' : 'দৈনিক কনটেন্ট',
                subtitle:
                    isEnglish
                        ? 'Ayah, Hadith and Dua preferences'
                        : 'আয়াত, হাদিস ও দোয়ার পছন্দ',
                onTap: () {
                  _showDailyContentSheet(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.wb_twilight_outlined,
                title:
                    isEnglish
                        ? 'Morning & Evening Adhkar'
                        : 'সকাল-সন্ধ্যার যিকির',
                subtitle:
                    isEnglish
                        ? 'Dhikr reminders and routines'
                        : 'যিকির রিমাইন্ডার ও রুটিন',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title: isEnglish ? 'Adhkar Reminders' : 'যিকির রিমাইন্ডার',
                    description:
                        isEnglish
                            ? 'Personalized morning and evening adhkar reminders are planned for a future NurVerse release.'
                            : 'ব্যক্তিগত সকাল-সন্ধ্যার যিকির রিমাইন্ডার NurVerse-এর future release-এ যুক্ত করা হবে।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.repeat_rounded,
                title: isEnglish ? 'Worship Goals' : 'ইবাদতের লক্ষ্য',
                subtitle:
                    isEnglish
                        ? 'Track your daily worship'
                        : 'দৈনিক ইবাদত ট্র্যাক করুন',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title: isEnglish ? 'Worship Goals' : 'ইবাদতের লক্ষ্য',
                    description:
                        isEnglish
                            ? 'Personal worship goals, streaks and progress tracking are planned as premium features.'
                            : 'ব্যক্তিগত ইবাদতের লক্ষ্য, streak এবং progress tracking Premium feature হিসেবে পরিকল্পিত।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.calendar_month_outlined,
                title: isEnglish ? 'Islamic Calendar' : 'ইসলামিক ক্যালেন্ডার',
                subtitle:
                    isEnglish
                        ? 'Hijri, Bangla and Gregorian dates'
                        : 'হিজরি, বাংলা ও ইংরেজি তারিখ',
                onTap: () {
                  _showCalendarPreferencesSheet(context, settings);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================================
          // PERSONALIZATION
          // ============================================================
          _buildSectionTitle(
            context,
            isEnglish ? 'Personalization' : 'ব্যক্তিগতকরণ',
            Icons.tune_rounded,
          ),

          _buildSettingsGroup(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.dashboard_customize_outlined,
                title: isEnglish ? 'Home Screen' : 'হোম স্ক্রিন',
                subtitle:
                    isEnglish
                        ? 'Customize your dashboard'
                        : 'ড্যাশবোর্ড নিজের মতো সাজান',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title:
                        isEnglish
                            ? 'Home Screen Personalization'
                            : 'হোম স্ক্রিন ব্যক্তিগতকরণ',
                    description:
                        isEnglish
                            ? 'Premium users will be able to customize dashboard cards and shortcuts.'
                            : 'Premium userরা dashboard card এবং shortcut নিজের মতো সাজাতে পারবেন।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.widgets_outlined,
                title: isEnglish ? 'Quick Actions' : 'Quick Actions',
                subtitle:
                    isEnglish
                        ? 'Choose your favorite shortcuts'
                        : 'পছন্দের shortcut নির্বাচন করুন',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title: isEnglish ? 'Quick Actions' : 'Quick Actions',
                    description:
                        isEnglish
                            ? 'Customize the shortcuts shown on your NurVerse dashboard.'
                            : 'NurVerse dashboard-এ কোন shortcut থাকবে তা নিজের মতো সাজাতে পারবেন।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.date_range_outlined,
                title: isEnglish ? 'Date Preferences' : 'তারিখের পছন্দ',
                subtitle:
                    isEnglish
                        ? 'Hijri and Gregorian display'
                        : 'হিজরি ও ইংরেজি তারিখ প্রদর্শন',
                onTap: () {
                  _showDatePreferencesSheet(context, settings);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================================
          // DATA & PRIVACY
          // ============================================================
          _buildSectionTitle(
            context,
            isEnglish ? 'Data & Privacy' : 'ডেটা ও গোপনীয়তা',
            Icons.security_outlined,
          ),

          _buildSettingsGroup(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.cloud_outlined,
                title: isEnglish ? 'Cloud Sync' : 'ক্লাউড সিঙ্ক',
                subtitle:
                    isEnglish
                        ? 'Sync your NurVerse preferences'
                        : 'NurVerse-এর পছন্দগুলো সিঙ্ক করুন',
                trailing: Icons.lock_outline_rounded,
                premium: true,
                onTap: () {
                  _showPremiumFeature(
                    context,
                    settings,
                    title: isEnglish ? 'Cloud Sync' : 'ক্লাউড সিঙ্ক',
                    description:
                        isEnglish
                            ? 'Cloud backup and cross-device synchronization are planned for NurVerse Premium.'
                            : 'Cloud backup এবং একাধিক ডিভাইসে synchronization NurVerse Premium-এর জন্য পরিকল্পিত।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.download_outlined,
                title: isEnglish ? 'Offline Content' : 'অফলাইন কনটেন্ট',
                subtitle:
                    isEnglish
                        ? 'Manage downloaded resources'
                        : 'ডাউনলোড করা কনটেন্ট পরিচালনা করুন',
                onTap: () {
                  _showOfflineContentSheet(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.cleaning_services_outlined,
                title: isEnglish ? 'Clear Cache' : 'ক্যাশ পরিষ্কার',
                subtitle:
                    isEnglish
                        ? 'Remove temporary app data'
                        : 'অস্থায়ী অ্যাপ ডেটা মুছে দিন',
                onTap: () {
                  _showClearCacheDialog(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.restart_alt_rounded,
                title: isEnglish ? 'Reset Settings' : 'সেটিংস রিসেট',
                subtitle:
                    isEnglish
                        ? 'Restore default preferences'
                        : 'ডিফল্ট সেটিংসে ফিরে যান',
                onTap: () {
                  _showResetDialog(context, settings);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================================
          // SUPPORT
          // ============================================================
          _buildSectionTitle(
            context,
            isEnglish ? 'Support & Feedback' : 'সহায়তা ও মতামত',
            Icons.support_agent_outlined,
          ),

          _buildSettingsGroup(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.help_outline_rounded,
                title: isEnglish ? 'Help Center' : 'সহায়তা কেন্দ্র',
                subtitle:
                    isEnglish
                        ? 'Get help using NurVerse'
                        : 'NurVerse ব্যবহারে সাহায্য নিন',
                onTap: () {
                  _showSupportSheet(
                    context,
                    settings,
                    title: isEnglish ? 'Help Center' : 'সহায়তা কেন্দ্র',
                    body:
                        isEnglish
                            ? 'Need help with prayer times, location, or reading settings? Start with the main sections in Settings and use the available controls to adjust your experience.'
                            : 'সালাতের সময়, লোকেশন বা পড়ার সেটিংস নিয়ে সাহায্যের প্রয়োজন হলে সেটিংসের প্রধান বিভাগগুলো ব্যবহার করে আপনার পছন্দগুলি সহজে সামঞ্জস্য করুন।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.feedback_outlined,
                title: isEnglish ? 'Report a Problem' : 'সমস্যা জানান',
                subtitle:
                    isEnglish
                        ? 'Help us improve NurVerse'
                        : 'NurVerse আরও ভালো করতে সাহায্য করুন',
                onTap: () {
                  _showSupportSheet(
                    context,
                    settings,
                    title: isEnglish ? 'Report a Problem' : 'সমস্যা জানান',
                    body:
                        isEnglish
                            ? 'Please describe the issue you ran into and any steps to reproduce it. This version now captures your preference changes directly, so you can review and adjust the settings that affect your experience.'
                            : 'আপনি কোন সমস্যা faced করেছেন এবং কীভাবে reproduce করতে হয় তা বর্ণনা করুন। এই ভার্সনটি এখন আপনার সেটিংস পরিবর্তনগুলো সরাসরি সংরক্ষণ করে, তাই আপনি আপনার অভিজ্ঞতাকে প্রভাবিত করে এমন সেটিংস পর্যালোচনা করতে পারবেন।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.lightbulb_outline_rounded,
                title: isEnglish ? 'Request a Feature' : 'নতুন ফিচার প্রস্তাব',
                subtitle:
                    isEnglish
                        ? 'Tell us what you want next'
                        : 'পরবর্তী কোন ফিচার চান জানান',
                onTap: () {
                  _showSupportSheet(
                    context,
                    settings,
                    title: isEnglish ? 'Request a Feature' : 'নতুন ফিচার প্রস্তাব',
                    body:
                        isEnglish
                            ? 'Feature ideas are now collected through your settings preferences and the in-app experience, so the next update can focus on the options you use most.'
                            : 'ফিচার-এর ধারণাগুলো এখন আপনার সেটিংস পছন্দ এবং ইন-অ্যাপ অভিজ্ঞতা থেকে সংগ্রহ করা হবে, যাতে পরবর্তী আপডেট আপনার সবচেয়ে বেশি ব্যবহৃত অপশনগুলোর উপর ফোকাস করতে পারে।',
                  );
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.share_outlined,
                title: isEnglish ? 'Share NurVerse' : 'NurVerse শেয়ার করুন',
                subtitle:
                    isEnglish
                        ? 'Share the app with others'
                        : 'অন্যদের সাথে অ্যাপটি শেয়ার করুন',
                onTap: () {
                  _showShareSheet(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.star_outline_rounded,
                title: isEnglish ? 'Rate NurVerse' : 'NurVerse রেটিং দিন',
                subtitle:
                    isEnglish
                        ? 'Support the project'
                        : 'প্রজেক্টটিকে সমর্থন করুন',
                onTap: () {
                  _showRatingSheet(context, settings);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ============================================================
          // ABOUT
          // ============================================================
          _buildSectionTitle(
            context,
            isEnglish ? 'About' : 'সম্পর্কে',
            Icons.info_outline_rounded,
          ),

          _buildSettingsGroup(
            context,
            children: [
              _buildSettingTile(
                context,
                icon: Icons.info_outline_rounded,
                leadingWidget: const BrandLogo(size: 42),
                title: isEnglish ? 'About NurVerse' : 'NurVerse সম্পর্কে',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  _showAboutDialog(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.privacy_tip_outlined,
                title: isEnglish ? 'Privacy Policy' : 'Privacy Policy',
                subtitle:
                    isEnglish
                        ? 'How NurVerse handles your data'
                        : 'NurVerse কীভাবে আপনার ডেটা পরিচালনা করে',
                onTap: () {
                  _showPolicySheet(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.description_outlined,
                title: isEnglish ? 'Terms of Use' : 'ব্যবহারের শর্তাবলি',
                subtitle:
                    isEnglish
                        ? 'NurVerse terms and conditions'
                        : 'NurVerse-এর ব্যবহারের শর্তাবলি',
                onTap: () {
                  _showTermsSheet(context, settings);
                },
              ),
              _buildDivider(),
              _buildSettingTile(
                context,
                icon: Icons.code_rounded,
                title:
                    isEnglish ? 'Open Source Licenses' : 'Open Source Licenses',
                subtitle:
                    isEnglish
                        ? 'Libraries used by NurVerse'
                        : 'NurVerse-এ ব্যবহৃত লাইব্রেরি',
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'NurVerse',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ============================================================
          // FOOTER
          // ============================================================
          Center(
            child: Column(
              children: [
                const BrandLogo(size: 28),
                const SizedBox(height: 8),
                Text(
                  'NurVerse',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withValues(alpha: .70),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isEnglish
                      ? 'A peaceful companion for everyday worship'
                      : 'প্রতিদিনের ইবাদতের শান্ত সঙ্গী',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: .50),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 9,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: .40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // PREMIUM HERO
  // ========================================================================

  Future<void> _openAccount(BuildContext context, User user) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: context.cardColor,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final photoUrl = user.photoURL;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.10),
                  backgroundImage:
                      photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                  child:
                      photoUrl == null || photoUrl.isEmpty
                          ? Icon(
                              Icons.account_circle_rounded,
                              size: 48,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName?.trim().isNotEmpty == true
                      ? user.displayName!
                      : 'NurVerse User',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (user.email?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.email!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.secondaryTextColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.of(sheetContext).pop();
                      await AuthService.instance.signOut();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleProfileTap(BuildContext context, User? user) async {
    if (user == null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GoogleLoginScreen(),
        ),
      );
      return;
    }

    await _openAccount(context, user);
  }

  Widget _premiumAccountButton(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      initialData: AuthService.instance.currentUser,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final photoUrl = user?.photoURL?.trim();
        final hasPhoto = user != null && photoUrl != null && photoUrl.isNotEmpty;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleProfileTap(context, user),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.seaBlue.withValues(alpha: .12),
                ),
              ),
              child:
                  hasPhoto
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.network(
                            photoUrl,
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                            errorBuilder:
                                (_, __, ___) => Icon(
                                  Icons.person_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 22,
                                ),
                          ),
                        )
                      : Icon(
                          user != null
                              ? Icons.person_rounded
                              : Icons.person_outline_rounded,
                          color: theme.colorScheme.primary,
                          size: 22,
                        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumHero(
    BuildContext context,
    SettingsProvider settings,
    PremiumProvider premium,
  ) {
    final isEnglish = settings.languageCode == 'en';
    final isActive = premium.isPremium;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.seaBlue.withValues(alpha: .20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.seaBlue.withValues(alpha: .07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  isActive
                      ? Icons.verified_rounded
                      : Icons.workspace_premium_rounded,
                  color: AppColors.seaBlue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'NurVerse Premium',
                            style: const TextStyle(
                              color: AppColors.seaBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.seaBlue.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isEnglish ? 'ACTIVE' : 'সক্রিয়',
                              style: const TextStyle(
                                color: AppColors.seaBlue,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive
                          ? (isEnglish
                              ? 'Your premium experience is active'
                              : 'আপনার Premium অভিজ্ঞতা সক্রিয়')
                          : (isEnglish
                              ? 'Unlock a richer, calmer NurVerse'
                              : 'আরও সমৃদ্ধ ও সুন্দর NurVerse উপভোগ করুন'),
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: .70),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _premiumAccountButton(context),
            ],
          ),

          const SizedBox(height: 18),

          // Premium benefits
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _premiumChip(
                Icons.contrast_rounded,
                isEnglish ? 'AMOLED' : 'AMOLED',
              ),
              _premiumChip(
                Icons.palette_outlined,
                isEnglish ? 'Premium Themes' : 'Premium থিম',
              ),
              _premiumChip(
                Icons.headphones_outlined,
                isEnglish ? 'Recitations' : 'তেলাওয়াত',
              ),
              _premiumChip(
                Icons.cloud_outlined,
                isEnglish ? 'Cloud Sync' : 'ক্লাউড সিঙ্ক',
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                _showPremiumSheet(context, settings, premium);
              },
              icon: Icon(
                isActive ? Icons.settings_rounded : Icons.auto_awesome_rounded,
                size: 18,
              ),
              label: Text(
                isActive
                    ? (isEnglish ? 'Manage Premium' : 'Premium পরিচালনা করুন')
                    : (isEnglish ? 'Explore Premium' : 'Premium দেখুন'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumChip(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.seaBlue),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.seaBlue,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // SECTION TITLE
  // ========================================================================

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.seaBlue),
          const SizedBox(width: 7),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withValues(alpha: .72),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================================
  // SETTINGS GROUP
  // ========================================================================

  Widget _buildSettingsGroup(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  // ========================================================================
  // SETTING TILE
  // ========================================================================

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    IconData? trailing,
    Widget? leadingWidget,
    bool premium = false,
  }) {
    final iconColor = AppColors.seaBlue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
          child: Row(
            children: [
              leadingWidget ?? _iconContainer(icon, iconColor),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (premium) ...[
                          const SizedBox(width: 7),
                          _premiumBadge(context),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.35,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                trailing ?? Icons.arrow_forward_ios_rounded,
                size: trailing == null ? 14 : 17,
                color: Theme.of(
                  context,
                ).iconTheme.color?.withValues(alpha: .38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // SWITCH TILE
  // ========================================================================

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
      child: Row(
        children: [
          _iconContainer(icon, AppColors.seaBlue),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.35,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: .62),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ========================================================================
  // ICON
  // ========================================================================

  Widget _iconContainer(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 21, color: color),
    );
  }

  Widget _premiumBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.seaBlue.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 10,
            color: AppColors.seaBlue,
          ),
          SizedBox(width: 3),
          Text(
            'PREMIUM',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              color: AppColors.seaBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 70, endIndent: 0);
  }

  // ========================================================================
  // THEME SHEET
  // ========================================================================

  void _showThemeSheet(
    BuildContext context,
    SettingsProvider settings,
    PremiumProvider premium,
  ) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(context),
              const SizedBox(height: 18),
              Text(
                isEnglish
                    ? 'Choose your appearance'
                    : 'আপনার পছন্দের থিম নির্বাচন করুন',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                isEnglish
                    ? 'Your choice is saved automatically.'
                    : 'আপনার পছন্দ স্বয়ংক্রিয়ভাবে সংরক্ষিত হবে।',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),

              _themeOption(
                context,
                settings,
                title: isEnglish ? 'System Default' : 'সিস্টেম অনুযায়ী',
                subtitle:
                    isEnglish
                        ? 'Follow your phone settings'
                        : 'ফোনের বর্তমান থিম অনুসরণ করবে',
                icon: Icons.brightness_auto_rounded,
                selected:
                    !settings.isAmoledMode &&
                    settings.themeMode == ThemeMode.system,
                onTap: () async {
                  await settings.setSystemTheme();
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),

              const SizedBox(height: 9),

              _themeOption(
                context,
                settings,
                title: isEnglish ? 'Light' : 'লাইট',
                subtitle: isEnglish ? 'Clean and bright' : 'উজ্জ্বল ও পরিষ্কার',
                icon: Icons.light_mode_rounded,
                selected:
                    !settings.isAmoledMode &&
                    settings.themeMode == ThemeMode.light,
                onTap: () async {
                  await settings.setLightTheme();
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),

              const SizedBox(height: 9),

              _themeOption(
                context,
                settings,
                title: isEnglish ? 'Dark' : 'ডার্ক',
                subtitle:
                    isEnglish
                        ? 'Comfortable at night'
                        : 'রাতে চোখের জন্য আরামদায়ক',
                icon: Icons.dark_mode_rounded,
                selected:
                    !settings.isAmoledMode &&
                    settings.themeMode == ThemeMode.dark,
                onTap: () async {
                  await settings.setDarkTheme();
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),

              const SizedBox(height: 9),

              _themeOption(
                context,
                settings,
                title: 'AMOLED Black',
                subtitle:
                    isEnglish
                        ? 'Pure black for OLED displays'
                        : 'OLED ডিসপ্লের জন্য পিওর ব্ল্যাক',
                icon: Icons.contrast_rounded,
                selected: settings.isAmoledMode,
                premium: true,
                locked: !premium.isPremium,
                onTap: () async {
                  if (!premium.isPremium) {
                    Navigator.pop(sheetContext);
                    _showPremiumSheet(context, settings, premium);
                    return;
                  }

                  await settings.setAmoledTheme();

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOption(
    BuildContext context,
    SettingsProvider settings, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    bool premium = false,
    bool locked = false,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color:
                selected
                    ? primary.withValues(alpha: .09)
                    : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  selected
                      ? primary.withValues(alpha: .30)
                      : primary.withValues(alpha: .07),
              width: selected ? 1.3 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (premium) ...[
                          const SizedBox(width: 6),
                          _premiumBadge(context),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: .62),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                locked
                    ? Icons.lock_outline_rounded
                    : selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color:
                    locked
                        ? primary.withValues(alpha: .55)
                        : selected
                        ? primary
                        : Theme.of(
                          context,
                        ).iconTheme.color?.withValues(alpha: .35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // LANGUAGE SHEET
  // ========================================================================

  void _showLanguageSheet(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandle(context),
              const SizedBox(height: 18),
              Text(
                isEnglish ? 'Choose language' : 'ভাষা নির্বাচন করুন',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 5),
              Text(
                isEnglish
                    ? 'NurVerse currently supports Bangla and English.'
                    : 'NurVerse বর্তমানে বাংলা ও ইংরেজি সমর্থন করে।',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              _languageOption(
                context,
                settings,
                code: 'bn',
                nativeName: 'বাংলা',
                englishName: 'Bangla',
                icon: Icons.translate_rounded,
                onTap: () async {
                  await settings.setBangla();
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
              const SizedBox(height: 9),
              _languageOption(
                context,
                settings,
                code: 'en',
                nativeName: 'English',
                englishName: 'English',
                icon: Icons.language_rounded,
                onTap: () async {
                  await settings.setEnglish();
                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _languageOption(
    BuildContext context,
    SettingsProvider settings, {
    required String code,
    required String nativeName,
    required String englishName,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    final selected = settings.languageCode == code;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                selected
                    ? primary.withValues(alpha: .09)
                    : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  selected
                      ? primary.withValues(alpha: .30)
                      : primary.withValues(alpha: .07),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nativeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      englishName,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: .60),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_off_rounded,
                color:
                    selected
                        ? primary
                        : Theme.of(
                          context,
                        ).iconTheme.color?.withValues(alpha: .35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // READING SETTINGS
  // ========================================================================

  void _showReadingSettings(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return _sheetContainer(
              context,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHandle(context),
                  const SizedBox(height: 18),
                  Text(
                    isEnglish ? 'Reading & Font' : 'পাঠ ও ফন্ট',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEnglish
                        ? 'Adjust Quran reading sizes.'
                        : 'কুরআন পড়ার লেখার আকার পরিবর্তন করুন।',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 22),

                  _fontSizeRow(
                    context,
                    title: isEnglish ? 'Quran Arabic' : 'কুরআন আরবি',
                    value: settings.quranFontSize,
                    min: 14,
                    max: 50,
                    onChanged: (value) async {
                      setState(() {});
                      await settings.updateQuranFontSize(value);
                    },
                  ),

                  const SizedBox(height: 18),

                  _fontSizeRow(
                    context,
                    title: isEnglish ? 'Translation' : 'অনুবাদ',
                    value: settings.translationFontSize,
                    min: 10,
                    max: 30,
                    onChanged: (value) async {
                      setState(() {});
                      await settings.updateTranslationFontSize(value);
                    },
                  ),

                  const SizedBox(height: 18),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEnglish ? 'Preview' : 'প্রিভিউ',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ٱلْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: settings.quranFontSize,
                            height: 1.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isEnglish
                              ? 'All praise is for Allah, Lord of the worlds.'
                              : 'সমস্ত প্রশংসা আল্লাহর জন্য, যিনি সকল জগতের প্রতিপালক।',
                          style: TextStyle(
                            fontSize: settings.translationFontSize,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _fontSizeRow(
    BuildContext context, {
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.seaBlue.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${value.round()}',
                style: const TextStyle(
                  color: AppColors.seaBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: (max - min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ========================================================================
  // CALCULATION METHOD
  // ========================================================================

  void _showCalculationMethodSheet(
    BuildContext context,
    SettingsProvider settings,
  ) {
    _showSelectionSheet(
      context,
      title:
          settings.languageCode == 'en'
              ? 'Prayer Calculation Method'
              : 'সালাতের হিসাব পদ্ধতি',
      current: settings.calculationMethod,
      options: SettingsProvider.calculationMethods,
      onSelected: (value) {
        settings.setCalculationMethod(value);
      },
    );
  }

  // ========================================================================
  // MADHHAB
  // ========================================================================

  void _showMadhhabSheet(BuildContext context, SettingsProvider settings) {
    _showSelectionSheet(
      context,
      title: settings.languageCode == 'en' ? 'Madhhab' : 'মাযহাব',
      current: settings.madhhab,
      options: SettingsProvider.madhabs,
      onSelected: (value) {
        settings.setMadhhab(value);
      },
    );
  }

  // ========================================================================
  // GENERIC SELECTION SHEET
  // ========================================================================

  void _showSelectionSheet(
    BuildContext context, {
    required String title,
    required String current,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(context),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 14),
              ...options.map((option) {
                final selected = option == current;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    title: Text(
                      option,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    trailing: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected ? AppColors.seaBlue : null,
                    ),
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(sheetContext);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ========================================================================
  // PRAYER ADJUSTMENTS
  // ========================================================================

  String _prayerAdjustmentSubtitle(SettingsProvider settings, bool isEnglish) {
    final activeAdjustments = settings.prayerAdjustments.entries
        .where((entry) => entry.value != 0)
        .toList();

    if (activeAdjustments.isEmpty) {
      return isEnglish
          ? 'Fine-tune calculated prayer times'
          : 'সালাতের সময় সূক্ষ্মভাবে সমন্বয় করুন';
    }

    final entry = activeAdjustments.first;
    final label = _prayerAdjustmentLabel(entry.key, isEnglish);
    final valueLabel = entry.value > 0 ? '+${entry.value}' : '${entry.value}';

    return isEnglish
        ? '$valueLabel min for $label'
        : '$valueLabel মিনিট ($label)';
  }

  String _prayerAdjustmentLabel(String prayerName, bool isEnglish) {
    switch (prayerName) {
      case 'Fajr':
        return isEnglish ? 'Fajr' : 'ফজর';
      case 'Dhuhr':
        return isEnglish ? 'Dhuhr' : 'যোহর';
      case 'Asr':
        return isEnglish ? 'Asr' : 'আসর';
      case 'Maghrib':
        return isEnglish ? 'Maghrib' : 'মাগরিব';
      case 'Isha':
        return isEnglish ? 'Isha' : 'ইশা';
      default:
        return prayerName;
    }
  }

  String _formatPrayerAdjustmentValue(int value, bool isEnglish) {
    final sign = value > 0 ? '+' : '';
    return isEnglish ? '$sign$value min' : '$sign$value মিনিট';
  }

  void _showPrayerAdjustmentsDialog(
    BuildContext context,
    SettingsProvider settings,
  ) {
    final isEnglish = settings.languageCode == 'en';
    final prayerKeys = <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
          contentPadding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
          title: Text(
            isEnglish ? 'Prayer Adjustments' : 'সালাতের সময় সমন্বয়',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: StatefulBuilder(
              builder: (context, setLocalState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEnglish
                            ? 'Set a custom minute offset for each prayer time.'
                            : 'প্রতিটি ওয়াক্তের জন্য কাস্টম মিনিট অফসেট নির্ধারণ করুন।',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      ...prayerKeys.map((prayerKey) {
                        final int value = settings.prayerAdjustments[prayerKey] ?? 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _prayerAdjustmentLabel(prayerKey, isEnglish),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isEnglish
                                          ? 'Adjust the calculated time'
                                          : 'গণনা করা সময় সমন্বয় করুন',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.color
                                            ?.withValues(alpha: .65),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await settings.setPrayerAdjustment(
                                    prayerKey,
                                    value - 1,
                                  );
                                  setLocalState(() {});
                                },
                                icon: const Icon(Icons.remove_circle_outline_rounded),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.seaBlue.withValues(alpha: .10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _formatPrayerAdjustmentValue(value, isEnglish),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.seaBlue,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await settings.setPrayerAdjustment(
                                    prayerKey,
                                    value + 1,
                                  );
                                  setLocalState(() {});
                                },
                                icon: const Icon(Icons.add_circle_outline_rounded),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () async {
                          await settings.resetPrayerAdjustments();
                          setLocalState(() {});
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(
                          isEnglish ? 'Reset to default' : 'ডিফল্টে ফিরিয়ে দিন',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(isEnglish ? 'Done' : 'সম্পন্ন'),
            ),
          ],
        );
      },
    );
  }

  // ========================================================================
  // PREMIUM SHEET
  // ========================================================================

  void _showPremiumSheet(
    BuildContext context,
    SettingsProvider settings,
    PremiumProvider premium,
  ) {
    final isEnglish = settings.languageCode == 'en';
    final isActive = premium.isPremium;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.seaBlue.withValues(alpha: .20),
                      AppColors.seaBlue.withValues(alpha: .07),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  isActive
                      ? Icons.verified_rounded
                      : Icons.workspace_premium_rounded,
                  size: 36,
                  color: AppColors.seaBlue,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'NurVerse Premium',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.seaBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isActive
                    ? (isEnglish
                        ? 'Premium is active on this device.'
                        : 'এই ডিভাইসে NurVerse Premium সক্রিয়।')
                    : (isEnglish
                        ? 'A richer and more personalized NurVerse experience.'
                        : 'আরও সমৃদ্ধ ও ব্যক্তিগত NurVerse অভিজ্ঞতা।'),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 22),

              _premiumFeatureRow(
                context,
                Icons.contrast_rounded,
                isEnglish ? 'AMOLED Black' : 'AMOLED Black',
              ),
              _premiumFeatureRow(
                context,
                Icons.palette_outlined,
                isEnglish ? 'Premium themes' : 'Premium থিম',
              ),
              _premiumFeatureRow(
                context,
                Icons.headphones_outlined,
                isEnglish ? 'Premium recitations' : 'Premium তেলাওয়াত',
              ),
              _premiumFeatureRow(
                context,
                Icons.cloud_outlined,
                isEnglish ? 'Cloud sync' : 'ক্লাউড সিঙ্ক',
              ),
              _premiumFeatureRow(
                context,
                Icons.dashboard_customize_outlined,
                isEnglish ? 'Home personalization' : 'হোম ব্যক্তিগতকরণ',
              ),
              _premiumFeatureRow(
                context,
                Icons.auto_stories_outlined,
                isEnglish ? 'Quran reading goals' : 'কুরআন পড়ার লক্ষ্য',
              ),

              const SizedBox(height: 22),

              if (!isActive)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await premium.activatePremium();

                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEnglish
                                  ? 'Premium activated for testing.'
                                  : 'Testing-এর জন্য Premium সক্রিয় হয়েছে।',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: Text(
                      isEnglish ? 'Activate Premium' : 'Premium সক্রিয় করুন',
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(
                      isEnglish ? 'Premium Active' : 'Premium সক্রিয়',
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              Text(
                isEnglish
                    ? 'Billing and subscription management can be connected later.'
                    : 'পরবর্তীতে Google Play Billing ও subscription management যুক্ত করা যাবে।',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _premiumFeatureRow(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppColors.seaBlue),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.check_rounded, size: 18, color: AppColors.seaBlue),
        ],
      ),
    );
  }

  // ========================================================================
  // PREMIUM FEATURE DIALOG
  // ========================================================================

  void _showPremiumFeature(
    BuildContext context,
    SettingsProvider settings, {
    required String title,
    required String description,
  }) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.seaBlue.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 30,
                  color: AppColors.seaBlue,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  _premiumBadge(context),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showPremiumSheet(
                      context,
                      settings,
                      context.read<PremiumProvider>(),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: Text(isEnglish ? 'Explore Premium' : 'Premium দেখুন'),
                ),
              ),
              const SizedBox(height: 7),
              TextButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                },
                child: Text(isEnglish ? 'Maybe later' : 'পরে দেখব'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ========================================================================
  // RESET SETTINGS
  // ========================================================================

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEnglish ? 'Reset settings?' : 'সেটিংস রিসেট করবেন?',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            isEnglish
                ? 'All NurVerse preferences such as theme, language, prayer calculation and reading sizes will return to their defaults.'
                : 'থিম, ভাষা, সালাতের হিসাব পদ্ধতি এবং পড়ার ফন্টসহ NurVerse-এর পছন্দগুলো ডিফল্ট অবস্থায় ফিরে যাবে।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(isEnglish ? 'Cancel' : 'বাতিল'),
            ),
            FilledButton(
              onPressed: () async {
                await settings.resetSettings();

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isEnglish
                            ? 'Settings have been reset.'
                            : 'সেটিংস রিসেট হয়েছে।',
                      ),
                    ),
                  );
                }
              },
              child: Text(isEnglish ? 'Reset' : 'রিসেট'),
            ),
          ],
        );
      },
    );
  }

  // ========================================================================
  // CLEAR CACHE
  // ========================================================================

  void _showClearCacheDialog(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isEnglish ? 'Clear cache' : 'ক্যাশ পরিষ্কার করুন',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            isEnglish
                ? 'Cache management will be available when NurVerse starts storing downloadable content.'
                : 'NurVerse-এ downloadable content সংরক্ষণ শুরু হলে এখানে cache management যুক্ত করা হবে।',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(isEnglish ? 'Close' : 'বন্ধ করুন'),
            ),
          ],
        );
      },
    );
  }

  // ========================================================================
  // ABOUT
  // ========================================================================

  void _showAboutDialog(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showAboutDialog(
      context: context,
      applicationName: 'NurVerse',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.seaBlue.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const BrandLogo(size: 52),
      ),
      children: [
        Text(
          isEnglish
              ? 'A peaceful Islamic companion for everyday worship.'
              : 'প্রতিদিনের ইবাদতের জন্য একটি সুন্দর ও শান্ত ইসলামিক companion।',
        ),
        const SizedBox(height: 10),
        Text(
          isEnglish
              ? 'Built with the goal of making everyday Islamic practice simpler, calmer and more meaningful.'
              : 'প্রতিদিনের ইসলামিক জীবনকে আরও সহজ, সুন্দর ও অর্থবহ করার লক্ষ্যেই NurVerse তৈরি করা হয়েছে।',
        ),
      ],
    );
  }

  // ========================================================================
  // ACTIVE SETTINGS SHEETS
  // ========================================================================

  void _showDailyContentSheet(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          child: Consumer<SettingsProvider>(
            builder: (consumerContext, currentSettings, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHandle(context),
                  const SizedBox(height: 12),
                  Text(
                    isEnglish ? 'Daily content' : 'দৈনিক কনটেন্ট',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEnglish
                        ? 'Choose which daily reminders you want to see in your routine.'
                        : 'আপনার রুটিনে কোন দৈনিক কনটেন্ট দেখতে চান তা নির্বাচন করুন।',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceSwitch(
                    context,
                    title: isEnglish ? 'Daily Ayah' : 'দৈনিক আয়াত',
                    subtitle:
                        isEnglish
                            ? 'Show a short ayah reminder each day'
                            : 'প্রতি দিনে একটি সংক্ষিপ্ত আয়াতের রিমাইন্ডার দেখুন',
                    value: currentSettings.showDailyAyah,
                    onChanged: (value) {
                      currentSettings.setDailyContentPreferences(ayah: value);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildPreferenceSwitch(
                    context,
                    title: isEnglish ? 'Daily Hadith' : 'দৈনিক হাদিস',
                    subtitle:
                        isEnglish
                            ? 'Show a hadith for reflection'
                            : 'চিন্তা-অনুশোচনার জন্য একটি হাদিস দেখুন',
                    value: currentSettings.showDailyHadith,
                    onChanged: (value) {
                      currentSettings.setDailyContentPreferences(hadith: value);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildPreferenceSwitch(
                    context,
                    title: isEnglish ? 'Daily Dua' : 'দৈনিক দোয়া',
                    subtitle:
                        isEnglish
                            ? 'Show a recommended dua for the day'
                            : 'দিনের জন্য একটি প্রস্তাবিত দোয়া দেখুন',
                    value: currentSettings.showDailyDua,
                    onChanged: (value) {
                      currentSettings.setDailyContentPreferences(dua: value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: Text(isEnglish ? 'Done' : 'সম্পন্ন'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showCalendarPreferencesSheet(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          child: Consumer<SettingsProvider>(
            builder: (consumerContext, currentSettings, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHandle(context),
                  const SizedBox(height: 12),
                  Text(
                    isEnglish ? 'Calendar preferences' : 'ক্যালেন্ডার পছন্দ',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEnglish
                        ? 'Choose how your Islamic dates are shown.'
                        : 'আপনার ইসলামিক তারিখ কীভাবে দেখাতে চান তা নির্বাচন করুন।',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceOption(
                    context,
                    title: isEnglish ? 'Hijri only' : 'শুধু হিজরি',
                    selected: currentSettings.dateDisplayPreference == 'hijri',
                    onTap: () {
                      currentSettings.setDateDisplayPreference('hijri');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildPreferenceOption(
                    context,
                    title: isEnglish ? 'Gregorian only' : 'শুধু ইংরেজি',
                    selected: currentSettings.dateDisplayPreference == 'gregorian',
                    onTap: () {
                      currentSettings.setDateDisplayPreference('gregorian');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildPreferenceOption(
                    context,
                    title: isEnglish ? 'Both dates' : 'উভয় তারিখ',
                    selected: currentSettings.dateDisplayPreference == 'both',
                    onTap: () {
                      currentSettings.setDateDisplayPreference('both');
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: Text(isEnglish ? 'Done' : 'সম্পন্ন'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showDatePreferencesSheet(BuildContext context, SettingsProvider settings) {
    _showCalendarPreferencesSheet(context, settings);
  }

  void _showOfflineContentSheet(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          child: Consumer<SettingsProvider>(
            builder: (consumerContext, currentSettings, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sheetHandle(context),
                  const SizedBox(height: 12),
                  Text(
                    isEnglish ? 'Offline content' : 'অফলাইন কনটেন্ট',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isEnglish
                        ? 'Choose when downloaded content should be preferred.'
                        : 'ডাউনলোড করা কনটেন্ট কখন অগ্রাধিকার পাবে তা নির্বাচন করুন।',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      isEnglish ? 'Only on Wi-Fi' : 'শুধু Wi-Fi-তে',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      isEnglish
                          ? 'Use downloaded content only when you are on Wi-Fi.'
                          : 'শুধু Wi-Fi-এ থাকা অবস্থায় ডাউনলোড করা কনটেন্ট ব্যবহার করুন।',
                    ),
                    value: currentSettings.downloadWifiOnly,
                    onChanged: (value) {
                      currentSettings.toggleDownloadWifiOnly(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      child: Text(isEnglish ? 'Done' : 'সম্পন্ন'),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showSupportSheet(
    BuildContext context,
    SettingsProvider settings, {
    required String title,
    required String body,
  }) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(context),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  },
                  child: Text(isEnglish ? 'Close' : 'বন্ধ করুন'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showShareSheet(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(context),
              const SizedBox(height: 14),
              Text(
                isEnglish ? 'Share NurVerse' : 'NurVerse শেয়ার করুন',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isEnglish
                    ? 'Share a calm note with friends and family so they can explore NurVerse too.'
                    : 'আপনার বন্ধু-বান্ধব ও পরিবারকে NurVerse-এর সাথে পরিচয় করিয়ে দিন।',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () async {
                    await SharePlus.instance.share(
                      ShareParams(
                        text:
                            isEnglish
                                ? 'Try NurVerse for peaceful daily worship and prayer guidance.'
                                : 'প্রতিদিনের ইবাদত ও সালাতের নির্দেশনার জন্য NurVerse ব্যবহার করুন।',
                      ),
                    );

                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  },
                  icon: const Icon(Icons.share_rounded),
                  label: Text(isEnglish ? 'Share app' : 'অ্যাপ শেয়ার করুন'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRatingSheet(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _sheetContainer(
          context,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHandle(context),
              const SizedBox(height: 14),
              Text(
                isEnglish ? 'Rate NurVerse' : 'NurVerse রেটিং দিন',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isEnglish
                    ? 'Thank you for supporting NurVerse. Your feedback helps make the app more useful for daily worship.'
                    : 'NurVerse-কে সমর্থন করার জন্য ধন্যবাদ। আপনার মতামত অ্যাপটিকে আরও উপযোগী করে তুলতে সাহায্য করবে।',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (sheetContext.mounted) {
                      Navigator.pop(sheetContext);
                    }
                  },
                  child: Text(isEnglish ? 'Thanks' : 'ধন্যবাদ'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPolicySheet(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    _showSupportSheet(
      context,
      settings,
      title: isEnglish ? 'Privacy Policy' : 'Privacy Policy',
      body:
          isEnglish
              ? 'NurVerse stores your app preferences locally on your device so the app can remember your choices. No personal worship data is shared with third parties by default.'
              : 'NurVerse আপনার পছন্দগুলো আপনার ডিভাইসেই স্থানীয়ভাবে সংরক্ষণ করে যাতে অ্যাপ সেগুলো মনে রাখতে পারে। কোনো ব্যক্তিগত ইবাদতের ডেটা ডিফল্টভাবে তৃতীয় পক্ষের সাথে শেয়ার করা হয় না।',
    );
  }

  void _showTermsSheet(BuildContext context, SettingsProvider settings) {
    final isEnglish = settings.languageCode == 'en';

    _showSupportSheet(
      context,
      settings,
      title: isEnglish ? 'Terms of Use' : 'ব্যবহারের শর্তাবলি',
      body:
          isEnglish
              ? 'NurVerse is designed to help you maintain a calm and consistent worship routine. Use the app respectfully and keep your device settings secure.'
              : 'NurVerse আপনাকে শান্ত ও নিয়মিত ইবাদতের রুটিন বজায় রাখতে সাহায্য করার জন্য ডিজাইন করা হয়েছে। অ্যাপটি সম্মানের সাথে ব্যবহার করুন এবং আপনার ডিভাইসের সেটিংস নিরাপদ রাখুন।',
    );
  }

  Widget _buildPreferenceSwitch(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildPreferenceOption(
    BuildContext context, {
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color:
              selected
                  ? AppColors.seaBlue.withValues(alpha: .10)
                  : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                selected
                    ? AppColors.seaBlue.withValues(alpha: .35)
                    : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.seaBlue),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // SHEET HELPERS
  // ========================================================================

  Widget _sheetContainer(
    BuildContext context, {
    required Widget child,
    EdgeInsets padding = const EdgeInsets.fromLTRB(18, 12, 18, 22),
  }) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: child,
      ),
    );
  }

  Widget _sheetHandle(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: Theme.of(context).dividerColor,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ========================================================================
  // LABELS
  // ========================================================================

  String _themeLabel(SettingsProvider settings) {
    if (settings.isAmoledMode) {
      return 'AMOLED Black';
    }

    switch (settings.themeMode) {
      case ThemeMode.light:
        return settings.languageCode == 'en' ? 'Light Mode' : 'লাইট মোড';

      case ThemeMode.dark:
        return settings.languageCode == 'en' ? 'Dark Mode' : 'ডার্ক মোড';

      case ThemeMode.system:
        return settings.languageCode == 'en'
            ? 'System Default'
            : 'সিস্টেম অনুযায়ী';
    }
  }

  String _languageLabel(SettingsProvider settings) {
    return settings.languageCode == 'en' ? 'English' : 'বাংলা';
  }
}
