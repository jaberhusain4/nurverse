import '../models/daily_content_model.dart';

const List<DailyContentModel> dailyHadiths = [
  DailyContentModel(
    type: DailyContentType.hadith,
    title: "আজকের হাদীস",
    arabic: "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
    bangla:
        "তোমাদের মধ্যে সেই ব্যক্তি উত্তম, যে কুরআন শিক্ষা করে এবং অন্যকে শিক্ষা দেয়।",
    reference: "সহীহ বুখারী ৫০২৭",
  ),

  DailyContentModel(
    type: DailyContentType.hadith,
    title: "আজকের হাদীস",
    arabic: "الدِّينُ النَّصِيحَةُ",
    bangla: "দ্বীন হচ্ছে আন্তরিক কল্যাণকামিতা।",
    reference: "সহীহ মুসলিম ৫৫",
  ),
];
