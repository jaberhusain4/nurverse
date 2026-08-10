import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'dua/dua_screen.dart';
import 'quran/audio_quran_screen.dart';
import 'qibla/qibla_screen.dart';
import 'tools/asma_ul_husna.dart';
import 'tools/calendar_screen.dart';
import 'tools/ruqyah_screen.dart';
import 'tools/tasbih_screen.dart';
import 'tools/zakat_calculator_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static const List<Map<String, dynamic>> tools = [
    {'icon': Icons.favorite_outline, 'title': "দু'আ"},
    {'icon': Icons.explore_outlined, 'title': 'কিবলা'},
    {'icon': Icons.fingerprint, 'title': 'তাসবিহ'},
    {'icon': Icons.star_outline, 'title': 'আল্লাহর ৯৯ নাম'},
    {'icon': Icons.shield_outlined, 'title': 'রুকইয়াহ'},
    {'icon': Icons.headphones, 'title': 'অডিও কুরআন'},
    {'icon': Icons.calculate_outlined, 'title': 'যাকাত ক্যালকুলেটর'},
    {'icon': Icons.near_me_outlined, 'title': 'নিকটস্থ মসজিদ'},
    {'icon': Icons.calendar_month_outlined, 'title': 'ক্যালেন্ডার'},
    {'icon': Icons.menu_book_outlined, 'title': 'ইসলামিক বই'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ইসলামিক টুলস',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tools.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final tool = tools[index];

              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  onTap: () => _openTool(context, tool['title'] as String),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.seaBlue.withValues(alpha: 0.15),
                          child: Icon(
                            tool['icon'] as IconData,
                            color: AppColors.seaBlue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tool['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            'আসন্ন টুলস (Future)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.account_tree_outlined,
                color: AppColors.seaBlue,
              ),
              title: const Text('ফারায়েজ (উত্তরাধিকার) ক্যালকুলেটর'),
              subtitle: const Text('v2.0 ভার্সনে যুক্ত হবে'),
            ),
          ),
        ],
      ),
    );
  }

  void _openTool(BuildContext context, String title) {
    switch (title) {
      case "দু'আ":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DuaScreen()),
        );
        break;
      case 'কিবলা':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QiblaScreen()),
        );
        break;
      case 'তাসবিহ':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TasbihScreen()),
        );
        break;
      case 'আল্লাহর ৯৯ নাম':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AsmaUlHusnaScreen()),
        );
        break;
      case 'অডিও কুরআন':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AudioQuranScreen()),
        );
        break;
      case 'রুকইয়াহ':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RuqyahScreen()),
        );
        break;
      case 'যাকাত ক্যালকুলেটর':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen()),
        );
        break;
      case 'ক্যালেন্ডার':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CalendarScreen()),
        );
        break;
      case 'নিকটস্থ মসজিদ':
      case 'ইসলামিক বই':
        _showComingSoon(context, title);
        break;
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ফিচারটি শীঘ্রই যুক্ত করা হবে ইনশাআল্লাহ।'),
      ),
    );
  }
}
