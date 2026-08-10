import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class ThemeSwitchScreen extends StatelessWidget {
  const ThemeSwitchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'থিম সেটিং',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          16,
          AppSpacing.md,
          24,
        ),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            'আপনার পছন্দের থিম বাছাই করুন',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.secondaryTextColor,
            ),
          ),

          const SizedBox(height: 14),

          // ==========================================================
          // SYSTEM
          // ==========================================================
          _buildThemeTile(
            context: context,
            title: 'সিস্টেম ডিফল্ট',
            subtitle: 'ফোনের সিস্টেম সেটিং অনুযায়ী Light বা Dark Mode',
            icon: Icons.brightness_auto_rounded,
            isSelected:
                settings.themeMode == ThemeMode.system &&
                !settings.isAmoledMode,
            onTap: () {
              settings.setThemeMode(ThemeMode.system);
              settings.toggleAmoledMode(false);
            },
          ),

          // ==========================================================
          // LIGHT
          // ==========================================================
          _buildThemeTile(
            context: context,
            title: 'লাইট মোড',
            subtitle: 'পরিষ্কার Sea Shore Blue ও White interface',
            icon: Icons.wb_sunny_outlined,
            isSelected:
                settings.themeMode == ThemeMode.light && !settings.isAmoledMode,
            onTap: () {
              settings.setThemeMode(ThemeMode.light);
              settings.toggleAmoledMode(false);
            },
          ),

          // ==========================================================
          // DARK
          // ==========================================================
          _buildThemeTile(
            context: context,
            title: 'ডার্ক মোড',
            subtitle: 'রাতের ব্যবহারের জন্য আরামদায়ক Dark interface',
            icon: Icons.nightlight_round,
            isSelected:
                settings.themeMode == ThemeMode.dark && !settings.isAmoledMode,
            onTap: () {
              settings.setThemeMode(ThemeMode.dark);
              settings.toggleAmoledMode(false);
            },
          ),

          // ==========================================================
          // AMOLED
          // ==========================================================
          _buildThemeTile(
            context: context,
            title: 'AMOLED ডার্ক',
            subtitle: 'সম্পূর্ণ Pure Black theme — OLED/AMOLED display-এর জন্য',
            icon: Icons.phone_android_rounded,
            isSelected: settings.isAmoledMode,
            onTap: () {
              settings.setThemeMode(ThemeMode.dark);
              settings.toggleAmoledMode(true);
            },
          ),

          const SizedBox(height: 12),

          // ==========================================================
          // INFO
          // ==========================================================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.seaBlue.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.seaBlue.withValues(alpha: .10),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.seaBlue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AMOLED মোড চালু করলে অ্যাপের Dark Mode সম্পূর্ণ কালো '
                    'হবে। OLED/AMOLED ডিসপ্লেতে এটি কিছুটা ব্যাটারি সাশ্রয় '
                    'করতে পারে।',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.secondaryTextColor,
                      height: 1.45,
                    ),
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
  // THEME TILE
  // ========================================================================

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? primary : primary.withValues(alpha: .06),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isSelected ? .07 : .03),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                // ------------------------------------------------------
                // ICON
                // ------------------------------------------------------
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color:
                        isSelected ? primary : primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : primary,
                    size: 23,
                  ),
                ),

                const SizedBox(width: 13),

                // ------------------------------------------------------
                // TITLE + SUBTITLE
                // ------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? primary : null,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.secondaryTextColor,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ------------------------------------------------------
                // SELECTED INDICATOR
                // ------------------------------------------------------
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child:
                      isSelected
                          ? Icon(
                            Icons.check_circle_rounded,
                            key: const ValueKey('selected'),
                            color: primary,
                            size: 24,
                          )
                          : Icon(
                            Icons.radio_button_unchecked_rounded,
                            key: const ValueKey('unselected'),
                            color: context.secondaryTextColor.withValues(
                              alpha: .45,
                            ),
                            size: 24,
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
