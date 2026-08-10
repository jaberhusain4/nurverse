import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AsmaUlHusnaScreen extends StatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  State<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends State<AsmaUlHusnaScreen> {
  String _searchQuery = '';

  final List<Map<String, String>> _names = const [
    {
      'id': '১',
      'arabic': 'ٱلرَّحْمَٰنُ',
      'bangla': 'আর-রহমান',
      'meaning': 'পরম দয়ালু',
    },
    {
      'id': '২',
      'arabic': 'ٱلرَّحِيمُ',
      'bangla': 'আর-রাহীম',
      'meaning': 'অতি দাতা ও পরম দয়ালু',
    },
    {
      'id': '৩',
      'arabic': 'ٱلْمَلِكُ',
      'bangla': 'আল-মালিক',
      'meaning': 'সর্বভৌম ক্ষমতার অধিকারী',
    },
    {
      'id': '৪',
      'arabic': 'ٱلْقُدُّوسُ',
      'bangla': 'আল-কুদ্দুস',
      'meaning': 'নিষ্পাপ ও অতি পবিত্র',
    },
    {
      'id': '৫',
      'arabic': 'ٱلسَّلَٰمُ',
      'bangla': 'আস-সালাম',
      'meaning': 'শান্তিদাতা ও নিরাপত্তা দানকারী',
    },
    {
      'id': '৬',
      'arabic': 'ٱلْمُؤْمِنُ',
      'bangla': 'আল-মু\'মিন',
      'meaning': 'ইমান ও নিরাপত্তা দানকারী',
    },
    {
      'id': '৭',
      'arabic': 'ٱلْمُهَيْمِنُ',
      'bangla': 'আল-মুহাইমিন',
      'meaning': 'রক্ষণাবেক্ষণকারী ও অভিভাবক',
    },
    {
      'id': '৮',
      'arabic': 'ٱلْعَزِيزُ',
      'bangla': 'আল-আযীয',
      'meaning': 'মহাপরাক্রমশালী ও বিজয়ী',
    },
    {
      'id': '৯',
      'arabic': 'ٱلْجَبَّارُ',
      'bangla': 'আল-জাব্বার',
      'meaning': 'দুর্নিবার ও সর্বশক্তিমান',
    },
    {
      'id': '১০',
      'arabic': 'ٱلْمُتَكَبِّرُ',
      'bangla': 'আল-মু তাকাব্বির',
      'meaning': 'অসীম গৌরবের অধিকারী',
    },
    {
      'id': '১১',
      'arabic': 'ٱلْخَٰلِقُ',
      'bangla': 'আল-খালিক',
      'meaning': 'সৃষ্টিকর্তা',
    },
    {
      'id': '১২',
      'arabic': 'ٱلْبَارِئُ',
      'bangla': 'আল-বারী',
      'meaning': 'সঠিক আকৃতিদাতা',
    },
    {
      'id': '১৩',
      'arabic': 'ٱلْمُصَوِّرُ',
      'bangla': 'আল-মুসাব্বির',
      'meaning': 'রূপদানকারী',
    },
    {
      'id': '১৪',
      'arabic': 'ٱلْغَفَّارُ',
      'bangla': 'আল-গাফফার',
      'meaning': 'পরম ক্ষমাশীল',
    },
    {
      'id': '১৫',
      'arabic': 'ٱلْقَهَّارُ',
      'bangla': 'আল-কাহ্হার',
      'meaning': 'কঠোর নিয়ন্ত্রণকারী',
    },
    {
      'id': '১৬',
      'arabic': 'ٱلْوَهَّابُ',
      'bangla': 'আল-ওয়াহ্হাব',
      'meaning': 'সবকিছু দানকারী',
    },
    {
      'id': '১৭',
      'arabic': 'ٱلرَّزَّاقُ',
      'bangla': 'আর-রাজ্জাক',
      'meaning': 'রিজিকদাতা',
    },
    {
      'id': '১৮',
      'arabic': 'ٱلْفَتَّاحُ',
      'bangla': 'আল-ফাত্তাহ',
      'meaning': 'উন্মোচনকারী ও বিজয়দাতা',
    },
    {
      'id': '১৯',
      'arabic': 'ٱلْعَلِيمُ',
      'bangla': 'আল-আলীম',
      'meaning': 'সর্বজ্ঞানী',
    },
    {
      'id': '২০',
      'arabic': 'ٱلْقَابِضُ',
      'bangla': 'আল-কাবিদ্ব',
      'meaning': 'সংকুচিতকারী',
    },
    {
      'id': '২১',
      'arabic': 'ٱلْبَاسِطُ',
      'bangla': 'আল-বাসিত',
      'meaning': 'সম্প্রসারণকারী',
    },
    {
      'id': '২২',
      'arabic': 'ٱلْخَافِضُ',
      'bangla': 'আল-খাফিদ',
      'meaning': 'অবনমিতকারী',
    },
    {
      'id': '২৩',
      'arabic': 'ٱلرَّافِعُ',
      'bangla': 'আর-রাফি',
      'meaning': 'উন্নতকারী',
    },
    {
      'id': '২৪',
      'arabic': 'ٱلْمُعِزُّ',
      'bangla': 'আল-মুইজ্জ',
      'meaning': 'সম্মানদাতা',
    },
    {
      'id': '২৫',
      'arabic': 'ٱلْمُذِلُّ',
      'bangla': 'আল-মুজিল',
      'meaning': 'অপমানকারী',
    },
    {
      'id': '২৬',
      'arabic': 'ٱلسَّمِيعُ',
      'bangla': 'আস-সামী',
      'meaning': 'সর্বশ্রোতা',
    },
    {
      'id': '২৭',
      'arabic': 'ٱلْبَصِيرُ',
      'bangla': 'আল-বাশীর',
      'meaning': 'সর্বদ্রষ্টা',
    },
    {
      'id': '২৮',
      'arabic': 'ٱلْحَكَمُ',
      'bangla': 'আল-হাকাম',
      'meaning': 'বিচারক',
    },
    {
      'id': '২৯',
      'arabic': 'ٱلْعَدْلُ',
      'bangla': 'আল-আদল',
      'meaning': 'ন্যায়পরায়ণ',
    },
    {
      'id': '৩০',
      'arabic': 'ٱللَّطِيفُ',
      'bangla': 'আল-লাতীফ',
      'meaning': 'সূক্ষ্মদর্শী ও দয়ালু',
    },
    {
      'id': '৩১',
      'arabic': 'ٱلْخَبِيرُ',
      'bangla': 'আল-খাবীর',
      'meaning': 'সর্বজ্ঞ',
    },
    {
      'id': '৩২',
      'arabic': 'ٱلْحَلِيمُ',
      'bangla': 'আল-হালীম',
      'meaning': 'ধৈর্যশীল',
    },
    {
      'id': '৩৩',
      'arabic': 'ٱلْعَظِيمُ',
      'bangla': 'আল-আযীম',
      'meaning': 'মহামহিম',
    },
    {
      'id': '৩৪',
      'arabic': 'ٱلْغَفُورُ',
      'bangla': 'আল-গফুর',
      'meaning': 'ক্ষমাশীল',
    },
    {
      'id': '৩৫',
      'arabic': 'ٱلشَّكُورُ',
      'bangla': 'আশ-শাকুর',
      'meaning': 'গুণগ্রাহী',
    },
    {
      'id': '৩৬',
      'arabic': 'ٱلْعَلِيُّ',
      'bangla': 'আল-আলী',
      'meaning': 'সর্বোচ্চ',
    },
    {
      'id': '৩৭',
      'arabic': 'ٱلْكَبِيرُ',
      'bangla': 'আল-কাবীর',
      'meaning': 'মহান',
    },
    {
      'id': '৩৮',
      'arabic': 'ٱلْحَفِيظُ',
      'bangla': 'আল-হাফীজ',
      'meaning': 'হেফাজতকারী',
    },
    {
      'id': '৩৯',
      'arabic': 'ٱلْمُقِيتُ',
      'bangla': 'আল-মুকীত',
      'meaning': 'জীবনোপকরণ দাতা',
    },
    {
      'id': '৪০',
      'arabic': 'ٱلْحَسِيبُ',
      'bangla': 'আল-হাসীব',
      'meaning': 'হিসাব গ্রহণকারী',
    },
    {
      'id': '৪১',
      'arabic': 'ٱلْجَلِيلُ',
      'bangla': 'আল-জালীল',
      'meaning': 'মহামহিম',
    },
    {
      'id': '৪২',
      'arabic': 'ٱلْكَرِيمُ',
      'bangla': 'আল-কারীম',
      'meaning': 'মহানুভব',
    },
    {
      'id': '৪৩',
      'arabic': 'ٱلرَّقِيبُ',
      'bangla': 'আর-রাকীব',
      'meaning': 'তত্ত্বাবধায়ক',
    },
    {
      'id': '৪৪',
      'arabic': 'ٱلْمُجِيبُ',
      'bangla': 'আল-মুজীব',
      'meaning': 'সাড়া দানকারী',
    },
    {
      'id': '৪৫',
      'arabic': 'ٱلْوَٰسِعُ',
      'bangla': 'আল-ওয়াসি',
      'meaning': 'সর্বব্যাপী',
    },
    {
      'id': '৪৬',
      'arabic': 'ٱلْحَكِيمُ',
      'bangla': 'আল-হাকীম',
      'meaning': 'প্রজ্ঞাময়',
    },
    {
      'id': '৪৭',
      'arabic': 'ٱلْوَدُودُ',
      'bangla': 'আল-ওয়াদুদ',
      'meaning': 'স্নেহময়',
    },
    {
      'id': '৪৮',
      'arabic': 'ٱلْمَجِيدُ',
      'bangla': 'আল-মাজীদ',
      'meaning': 'মহামহিম',
    },
    {
      'id': '৪৯',
      'arabic': 'ٱلْبَاعِثُ',
      'bangla': 'আল-বাইছ',
      'meaning': 'পুনরুত্থানকারী',
    },
    {
      'id': '৫০',
      'arabic': 'ٱلشَّهِيدُ',
      'bangla': 'আশ-শাহীদ',
      'meaning': 'উপস্থিত ও পর্যবেক্ষণকারী',
    },
    {'id': '৫১', 'arabic': 'ٱلْحَقُّ', 'bangla': 'আল-হাক্ক', 'meaning': 'সত্য'},
    {
      'id': '৫২',
      'arabic': 'ٱلْوَكِيلُ',
      'bangla': 'আল-ওয়াকীল',
      'meaning': 'তত্ত্বাবধায়ক',
    },
    {
      'id': '৫৩',
      'arabic': 'ٱلْقَوِيُّ',
      'bangla': 'আল-কাউই',
      'meaning': 'শক্তিমান',
    },
    {
      'id': '৫৪',
      'arabic': 'ٱلْمَتِينُ',
      'bangla': 'আল-মাতীন',
      'meaning': 'সুদৃঢ়',
    },
    {
      'id': '৫৫',
      'arabic': 'ٱلْوَلِيُّ',
      'bangla': 'আল-ওয়ালী',
      'meaning': 'অভিভাবক',
    },
    {
      'id': '৫৬',
      'arabic': 'ٱلْحَمِيدُ',
      'bangla': 'আল-হামীদ',
      'meaning': 'প্রশংসিত',
    },
    {
      'id': '৫৭',
      'arabic': 'ٱلْمُحْصِي',
      'bangla': 'আল-মুহসী',
      'meaning': 'গণনাকারী',
    },
    {
      'id': '৫৮',
      'arabic': 'ٱلْمُبْدِئُ',
      'bangla': 'আল-মুবদি',
      'meaning': 'সূচনাকারী',
    },
    {
      'id': '৫৯',
      'arabic': 'ٱلْمُعِيدُ',
      'bangla': 'আল-মুঈদ',
      'meaning': 'পুনরায় সৃষ্টিকর্তা',
    },
    {
      'id': '৬০',
      'arabic': 'ٱلْمُحْيِي',
      'bangla': 'আল-মুহয়ী',
      'meaning': 'জীবনদানকারী',
    },
    {
      'id': '৬১',
      'arabic': 'ٱلْمُمِيتُ',
      'bangla': 'আল-মুমিৎ',
      'meaning': 'মৃত্যুদানকারী',
    },
    {
      'id': '৬২',
      'arabic': 'ٱلْحَيُّ',
      'bangla': 'আল-হাইয়্যু',
      'meaning': 'চিরঞ্জীব',
    },
    {
      'id': '৬৩',
      'arabic': 'ٱلْقَيُّومُ',
      'bangla': 'আল-কায়্যুম',
      'meaning': 'চিরস্থায়ী',
    },
    {
      'id': '৬৪',
      'arabic': 'ٱلْوَٰجِدُ',
      'bangla': 'আল-ওয়াজিদ',
      'meaning': 'প্রাপক',
    },
    {
      'id': '৬৫',
      'arabic': 'ٱلْمَٰجِدُ',
      'bangla': 'আল-মাজিদ',
      'meaning': 'শ্রেষ্ঠ',
    },
    {
      'id': '৬৬',
      'arabic': 'ٱلْوَٰحِدُ',
      'bangla': 'আল-ওয়াহিদ',
      'meaning': 'এক',
    },
    {'id': '৬৭', 'arabic': 'ٱلْأَحَدُ', 'bangla': 'আল-আহাদ', 'meaning': 'একক'},
    {
      'id': '৬৮',
      'arabic': 'ٱلصَّمَدُ',
      'bangla': 'আস-সামাদ',
      'meaning': 'অমুখাপেক্ষী',
    },
    {
      'id': '৬৯',
      'arabic': 'ٱلْقَٰدِرُ',
      'bangla': 'আল-কাদির',
      'meaning': 'সর্বশক্তিমান',
    },
    {
      'id': '৭০',
      'arabic': 'ٱلْمُقْتَدِرُ',
      'bangla': 'আল-মুকতাদির',
      'meaning': 'প্রভাবশালী',
    },
    {
      'id': '৭১',
      'arabic': 'ٱلْمُقَدِّمُ',
      'bangla': 'আল-মুকাদ্দিম',
      'meaning': 'অগ্রসরকারী',
    },
    {
      'id': '৭২',
      'arabic': 'ٱلْمُؤَخِّرُ',
      'bangla': 'আল-মুআখখির',
      'meaning': 'পশ্চাতে আনয়নকারী',
    },
    {
      'id': '৭৩',
      'arabic': 'ٱلْأَوَّلُ',
      'bangla': 'আল-আউয়াল',
      'meaning': 'অনাদি',
    },
    {'id': '৭৪', 'arabic': 'ٱلْآخِرُ', 'bangla': 'আল-আখির', 'meaning': 'অনন্ত'},
    {
      'id': '৭৫',
      'arabic': 'ٱلظَّٰهِرُ',
      'bangla': 'আজ-জাহির',
      'meaning': 'প্রকাশ্য',
    },
    {
      'id': '৭৬',
      'arabic': 'ٱلْبَاطِنُ',
      'bangla': 'আল-বাতিন',
      'meaning': 'গুপ্ত',
    },
    {
      'id': '৭৭',
      'arabic': 'ٱلْوَالِي',
      'bangla': 'আল-ওয়ালী',
      'meaning': 'পরিচালক',
    },
    {
      'id': '৭৮',
      'arabic': 'ٱلْمُتَعَالِي',
      'bangla': 'আল-মুতাআলী',
      'meaning': 'সর্বোচ্চ',
    },
    {'id': '৭৯', 'arabic': 'ٱلْبَرُّ', 'bangla': 'আল-বার্র', 'meaning': 'সদয়'},
    {
      'id': '৮০',
      'arabic': 'ٱلتَّوَّابُ',
      'bangla': 'আত-তাওয়াব',
      'meaning': 'তওবা কবুলকারী',
    },
    {
      'id': '৮১',
      'arabic': 'ٱلْمُنْتَقِمُ',
      'bangla': 'আল-মুনতাকীম',
      'meaning': 'প্রতিশোধ গ্রহণকারী',
    },
    {
      'id': '৮২',
      'arabic': 'ٱلْعَفُوُّ',
      'bangla': 'আল-আফুঊ',
      'meaning': 'ক্ষমাশীল',
    },
    {
      'id': '৮৩',
      'arabic': 'ٱلرَّءُوفُ',
      'bangla': 'আর-রউফ',
      'meaning': 'স্নেহশীল',
    },
    {
      'id': '৮৪',
      'arabic': 'مَٰلِكُ ٱلْمُلْكِ',
      'bangla': 'মালিকুল মুলক',
      'meaning': 'সাম্রাজ্যের মালিক',
    },
    {
      'id': '৮৫',
      'arabic': 'ذُو ٱلْجَلَٰلِ وَٱلْإِكْرَامِ',
      'bangla': 'জুল জালালি ওয়াল ইকরাম',
      'meaning': 'মহিমাময় ও মহানুভব',
    },
    {
      'id': '৮৬',
      'arabic': 'ٱلْمُقْسِطُ',
      'bangla': 'আল-মুকসিত',
      'meaning': 'সুবিচারক',
    },
    {
      'id': '৮৭',
      'arabic': 'ٱلْجَامِعُ',
      'bangla': 'আল-জামি',
      'meaning': 'একত্রকারী',
    },
    {
      'id': '৮৮',
      'arabic': 'ٱلْغَنِيُّ',
      'bangla': 'আল-গানী',
      'meaning': 'অভাবমুক্ত',
    },
    {
      'id': '৮৯',
      'arabic': 'ٱلْمُغْنِي',
      'bangla': 'আল-মুগনী',
      'meaning': 'ধনীকারী',
    },
    {
      'id': '৯০',
      'arabic': 'ٱلْمَانِعُ',
      'bangla': 'আল-মানি',
      'meaning': 'নিবারণকারী',
    },
    {
      'id': '৯১',
      'arabic': 'ٱلضَّارُّ',
      'bangla': 'অ্যাদ্-দার্র',
      'meaning': 'ক্ষতিসাধনকারী',
    },
    {
      'id': '৯২',
      'arabic': 'ٱلنَّافِعُ',
      'bangla': 'আন-নাফি',
      'meaning': 'উপকারী',
    },
    {'id': '৯৩', 'arabic': 'ٱلنُّورُ', 'bangla': 'আন-নুর', 'meaning': 'জ্যোতি'},
    {
      'id': '৯৪',
      'arabic': 'ٱلْهَادِي',
      'bangla': 'আল-হাদী',
      'meaning': 'পথপ্রদর্শক',
    },
    {
      'id': '৯৫',
      'arabic': 'ٱلْبَدِيعُ',
      'bangla': 'আল-বাদী',
      'meaning': 'অনুপম সৃষ্টিকর্তা',
    },
    {
      'id': '৯৬',
      'arabic': 'ٱلْبَاقِي',
      'bangla': 'আল-বাকী',
      'meaning': 'চিরস্থায়ী',
    },
    {
      'id': '৯৭',
      'arabic': 'ٱلْوَٰرِثُ',
      'bangla': 'আল-ওয়ারিশ',
      'meaning': 'উত্তরাধিকারী',
    },
    {
      'id': '৯৮',
      'arabic': 'ٱلرَّشِيدُ',
      'bangla': 'আর-রশীদ',
      'meaning': 'সঠিক পথপ্রদর্শক',
    },
    {
      'id': '৯৯',
      'arabic': 'ٱلصَّبُورُ',
      'bangla': 'আস-সবুর',
      'meaning': 'ধৈর্যশীল',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNames =
        _names.where((item) {
          final query = _searchQuery.toLowerCase();
          return item['bangla']!.toLowerCase().contains(query) ||
              item['meaning']!.toLowerCase().contains(query) ||
              item['id']!.contains(query);
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'আল্লাহর ৯৯ নাম',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'নাম বা অর্থ দিয়ে খুঁজুন...',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.seaBlue,
                  ),
                  filled: true,
                  fillColor: context.cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    borderSide: const BorderSide(color: AppColors.seaBlue),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                itemCount: filteredNames.length,
                itemBuilder: (context, index) {
                  final item = filteredNames[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.seaBlue.withValues(alpha: 0.15),
                        child: Text(
                          item['id']!,
                          style: const TextStyle(
                            color: AppColors.seaBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['bangla']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow:
                                  TextOverflow
                                      .ellipsis, // বড় নাম হলে স্ক্রিন ওভারফ্লো করবে না
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['arabic']!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.seaBlue,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          item['meaning']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
