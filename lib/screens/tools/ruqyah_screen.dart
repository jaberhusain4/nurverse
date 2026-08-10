import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class RuqyahScreen extends StatefulWidget {
  const RuqyahScreen({super.key});

  @override
  State<RuqyahScreen> createState() => _RuqyahScreenState();
}

class _RuqyahScreenState extends State<RuqyahScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String _selectedCategory = 'সব';

  final List<String> _categories = const [
    'সব',
    'কুরআনিক রুকইয়াহ',
    'অসুস্থতা ও ব্যথা',
    'সুরক্ষা',
    'সকাল ও সন্ধ্যা',
  ];

  final List<RuqyahItem> _items = const [
    // ==========================================================
    // AL-FATIHAH
    // ==========================================================
    RuqyahItem(
      id: 'fatiha',
      title: 'সূরা আল-ফাতিহা',
      subtitle: 'রুকইয়াহ হিসেবে কুরআনের সূচনা সূরা',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.menu_book_rounded,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৬–৫৭৩৭',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      arabic: '''
بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ

الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ

الرَّحْمَٰنِ الرَّحِيمِ

مَالِكِ يَوْمِ الدِّينِ

إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ

اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ

صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ
غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ
وَلَا الضَّالِّينَ
''',
      transliteration: '''
Bismillahir-Rahmanir-Rahim.

Alhamdu lillahi Rabbil-'alamin.

Ar-Rahmanir-Rahim.

Maliki Yawmid-Din.

Iyyaka na'budu wa iyyaka nasta'in.

Ihdinas-siratal-mustaqim.

Siratal-ladhina an'amta 'alayhim,
ghayril-maghdubi 'alayhim
wa lad-dallin.
''',
      translation:
          'পরম করুণাময়, অতি দয়ালু আল্লাহর নামে। সকল প্রশংসা আল্লাহর, যিনি সকল জগতের প্রতিপালক। তিনি পরম করুণাময়, অতি দয়ালু। প্রতিফল দিবসের মালিক। আমরা শুধু আপনারই ইবাদত করি এবং শুধু আপনারই সাহায্য চাই। আমাদের সরল পথ দেখান—তাদের পথ, যাদের আপনি অনুগ্রহ করেছেন; তাদের পথ নয়, যারা গজবপ্রাপ্ত এবং যারা পথভ্রষ্ট।',
      note:
          'এক সাহাবি সূরা আল-ফাতিহা পড়ে একজন দংশিত ব্যক্তির ওপর রুকইয়াহ করেছিলেন এবং সে সুস্থ হয়। নবী ﷺ এটিকে অনুমোদন করেন।',
      referenceUrl: 'Sahih al-Bukhari 5736',
    ),

    // ==========================================================
    // AL-IKHLAS
    // ==========================================================
    RuqyahItem(
      id: 'ikhlas',
      title: 'সূরা আল-ইখলাস',
      subtitle: 'মু‘আউইযাতের অন্তর্ভুক্ত',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.shield_outlined,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৫',
      repetition: 'সুন্নাহ অনুযায়ী মু‘আউইযাত পাঠ',
      arabic: '''
بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ

قُلْ هُوَ اللَّهُ أَحَدٌ

اللَّهُ الصَّمَدُ

لَمْ يَلِدْ وَلَمْ يُولَدْ

وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ
''',
      transliteration: '''
Bismillahir-Rahmanir-Rahim.

Qul huwallahu ahad.

Allahus-samad.

Lam yalid wa lam yulad.

Wa lam yakun lahu kufuwan ahad.
''',
      translation:
          'বলুন, তিনি আল্লাহ, একক। আল্লাহ অমুখাপেক্ষী। তিনি কাউকে জন্ম দেননি এবং তাঁকেও জন্ম দেওয়া হয়নি। আর তাঁর সমতুল্য কেউ নেই।',
      note:
          'রাসূলুল্লাহ ﷺ অসুস্থতার সময় আল-ইখলাস, আল-ফালাক ও আন-নাস পাঠ করে নিজের ওপর ফুঁ দিতেন।',
      referenceUrl: 'Sahih al-Bukhari 5735',
    ),

    // ==========================================================
    // AL-FALAQ
    // ==========================================================
    RuqyahItem(
      id: 'falaq',
      title: 'সূরা আল-ফালাক',
      subtitle: 'বাহ্যিক অনিষ্ট থেকে আশ্রয়',
      category: 'সুরক্ষা',
      icon: Icons.wb_twilight_rounded,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৫',
      repetition: 'সুন্নাহ অনুযায়ী মু‘আউইযাত পাঠ',
      arabic: '''
بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ

قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ

مِنْ شَرِّ مَا خَلَقَ

وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ

وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ

وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ
''',
      transliteration: '''
Bismillahir-Rahmanir-Rahim.

Qul a'udhu bi Rabbil-falaq.

Min sharri ma khalaq.

Wa min sharri ghasiqin idha waqab.

Wa min sharrin-naffathati fil-'uqad.

Wa min sharri hasidin idha hasad.
''',
      translation:
          'বলুন, আমি আশ্রয় নিচ্ছি ঊষার প্রতিপালকের। তিনি যা সৃষ্টি করেছেন তার অনিষ্ট থেকে; রাতের অন্ধকারের অনিষ্ট থেকে যখন তা গভীর হয়; গ্রন্থিতে ফুঁ দেয় এমনদের অনিষ্ট থেকে; এবং হিংসুকের অনিষ্ট থেকে যখন সে হিংসা করে।',
      note:
          'সূরা আল-ফালাক মু‘আউইযাতের অংশ। রাসূলুল্লাহ ﷺ অসুস্থতার সময় এটি পাঠ করতেন।',
      referenceUrl: 'Sahih al-Bukhari 5735',
    ),

    // ==========================================================
    // AN-NAS
    // ==========================================================
    RuqyahItem(
      id: 'nas',
      title: 'সূরা আন-নাস',
      subtitle: 'ওয়াসওয়াসা ও শয়তানের অনিষ্ট থেকে আশ্রয়',
      category: 'সুরক্ষা',
      icon: Icons.security_rounded,
      type: RuqyahType.quran,
      source: 'সহীহ আল-বুখারী ৫৭৩৫',
      repetition: 'সুন্নাহ অনুযায়ী মু‘আউইযাত পাঠ',
      arabic: '''
بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ

قُلْ أَعُوذُ بِرَبِّ النَّاسِ

مَلِكِ النَّاسِ

إِلَٰهِ النَّاسِ

مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ

الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ

مِنَ الْجِنَّةِ وَالنَّاسِ
''',
      transliteration: '''
Bismillahir-Rahmanir-Rahim.

Qul a'udhu bi Rabbin-nas.

Malikin-nas.

Ilahin-nas.

Min sharril-waswasil-khannas.

Alladhi yuwaswisu fi sudurin-nas.

Minal-jinnati wan-nas.
''',
      translation:
          'বলুন, আমি আশ্রয় নিচ্ছি মানুষের প্রতিপালকের, মানুষের অধিপতির, মানুষের উপাস্যের কাছে—কুমন্ত্রণাদাতার অনিষ্ট থেকে, যে আত্মগোপন করে মানুষের অন্তরে কুমন্ত্রণা দেয়; সে জিনদের মধ্য থেকে হোক অথবা মানুষের মধ্য থেকে।',
      note:
          'মু‘আউইযাতের অন্তর্ভুক্ত। রাসূলুল্লাহ ﷺ অসুস্থতার সময় এটি পাঠ করে নিজের ওপর ফুঁ দিতেন।',
      referenceUrl: 'Sahih al-Bukhari 5735',
    ),

    // ==========================================================
    // PAIN
    // ==========================================================
    RuqyahItem(
      id: 'pain',
      title: 'শরীরের ব্যথার রুকইয়াহ',
      subtitle: 'ব্যথার স্থানে হাত রেখে পড়ার দু‘আ',
      category: 'অসুস্থতা ও ব্যথা',
      icon: Icons.healing_rounded,
      type: RuqyahType.dua,
      source: 'সহীহ মুসলিম ২২০২',
      repetition: 'بِسْمِ اللَّهِ — ৩ বার; এরপর দু‘আ — ৭ বার',
      arabic: '''
بِسْمِ اللَّهِ

أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ
مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ
''',
      transliteration: '''
Bismillah.

A'udhu billahi wa qudratihi
min sharri ma ajidu wa uhadhiru.
''',
      translation:
          'আল্লাহর নামে। আমি যে কষ্ট অনুভব করছি এবং যার আশঙ্কা করছি, তার অনিষ্ট থেকে আল্লাহ ও তাঁর ক্ষমতার আশ্রয় প্রার্থনা করছি।',
      note:
          'রাসূলুল্লাহ ﷺ ব্যথার স্থানে হাত রেখে প্রথমে “বিসমিল্লাহ” তিনবার এবং এরপর এই দু‘আ সাতবার পড়তে বলেছেন।',
      referenceUrl: 'Sahih Muslim 2202',
    ),

    // ==========================================================
    // HEALING
    // ==========================================================
    RuqyahItem(
      id: 'healing',
      title: 'আরোগ্যের দু‘আ',
      subtitle: 'অসুস্থতার জন্য নববী রুকইয়াহ',
      category: 'অসুস্থতা ও ব্যথা',
      icon: Icons.favorite_rounded,
      type: RuqyahType.dua,
      source: 'সহীহ আল-বুখারী ৫৭৪২',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      arabic: '''
اللَّهُمَّ رَبَّ النَّاسِ
مُذْهِبَ الْبَاسِ
اشْفِ أَنْتَ الشَّافِي
لَا شَافِيَ إِلَّا أَنْتَ
شِفَاءً لَا يُغَادِرُ سَقَمًا
''',
      transliteration: '''
Allahumma Rabban-nas,
mudhhibil-ba's,
ishfi antash-Shafi,
la shafiya illa Anta,
shifa'an la yughadiru saqaman.
''',
      translation:
          'হে মানুষের প্রতিপালক! কষ্ট দূরকারী! আপনি আরোগ্য দান করুন; আপনিই আরোগ্যদানকারী। আপনার আরোগ্য ছাড়া কোনো আরোগ্য নেই। এমন আরোগ্য দান করুন যা কোনো রোগ অবশিষ্ট রাখে না।',
      note: 'আনাস (রা.)-কে রাসূলুল্লাহ ﷺ-এর রুকইয়াহ দিয়ে চিকিৎসা করা হয়েছিল।',
      referenceUrl: 'Sahih al-Bukhari 5742',
    ),

    // ==========================================================
    // PROTECTION
    // ==========================================================
    RuqyahItem(
      id: 'protection',
      title: 'সর্বপ্রকার সৃষ্টির অনিষ্ট থেকে আশ্রয়',
      subtitle: 'আল্লাহর পূর্ণাঙ্গ কালিমার মাধ্যমে আশ্রয়',
      category: 'সুরক্ষা',
      icon: Icons.lock_rounded,
      type: RuqyahType.dua,
      source: 'সহীহ মুসলিম ২৭০৮',
      repetition: 'সাধারণভাবে পাঠ করা যায়',
      arabic: '''
أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ
مِنْ شَرِّ مَا خَلَقَ
''',
      transliteration: '''
A'udhu bi kalimatillahit-tammati
min sharri ma khalaq.
''',
      translation:
          'আমি আল্লাহর পরিপূর্ণ কালিমাসমূহের আশ্রয় নিচ্ছি, তিনি যা সৃষ্টি করেছেন তার অনিষ্ট থেকে।',
      note: 'সৃষ্টির অনিষ্ট থেকে আল্লাহর আশ্রয় চাওয়ার সংক্ষিপ্ত মাসনূন দু‘আ।',
      referenceUrl: 'Sahih Muslim 2708',
    ),

    // ==========================================================
    // MORNING / EVENING PROTECTION
    // ==========================================================
    RuqyahItem(
      id: 'morning-evening',
      title: 'সকাল-সন্ধ্যার সুরক্ষার দু‘আ',
      subtitle: 'আল্লাহর নামে সুরক্ষা চাওয়া',
      category: 'সকাল ও সন্ধ্যা',
      icon: Icons.wb_sunny_outlined,
      type: RuqyahType.dua,
      source: 'জামে‘ আত-তিরমিযী ৩৩৮৮',
      repetition: 'সকাল ও সন্ধ্যায় ৩ বার',
      arabic: '''
بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ
مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ
وَلَا فِي السَّمَاءِ
وَهُوَ السَّمِيعُ الْعَلِيمُ
''',
      transliteration: '''
Bismillahil-ladhi la yadurru
ma'a ismihi shay'un fil-ardi
wa la fis-sama',
wa Huwas-Sami'ul-'Alim.
''',
      translation:
          'আল্লাহর নামে, যাঁর নামের সাথে পৃথিবী ও আকাশে কোনো কিছুই ক্ষতি করতে পারে না। তিনি সর্বশ্রোতা, সর্বজ্ঞ।',
      note: 'হাদিসে সকাল ও সন্ধ্যায় এই দু‘আ তিনবার পড়ার কথা এসেছে।',
      referenceUrl: 'Jami at-Tirmidhi 3388',
    ),

    // ==========================================================
    // QURAN HEALING
    // ==========================================================
    RuqyahItem(
      id: 'healing-quran',
      title: 'কুরআন—শিফা ও রহমত',
      subtitle: 'কুরআনের নিরাময় ও রহমতের ঘোষণা',
      category: 'কুরআনিক রুকইয়াহ',
      icon: Icons.auto_stories_rounded,
      type: RuqyahType.quran,
      source: 'সূরা আল-ইসরা ১৭:৮২',
      repetition: 'নির্দিষ্ট সংখ্যা নির্ধারিত নয়',
      arabic: '''
وَنُنَزِّلُ مِنَ الْقُرْآنِ
مَا هُوَ شِفَاءٌ وَرَحْمَةٌ
لِّلْمُؤْمِنِينَ
وَلَا يَزِيدُ الظَّالِمِينَ
إِلَّا خَسَارًا
''',
      transliteration: '''
Wa nunazzilu minal-Qur'ani
ma huwa shifa'un wa rahmatul
lil-mu'minin,
wa la yaziduz-zalimina
illa khasara.
''',
      translation:
          'আমি কুরআনে এমন কিছু নাজিল করি যা মুমিনদের জন্য আরোগ্য ও রহমত; কিন্তু জালিমদের জন্য তা ক্ষতি ছাড়া আর কিছুই বৃদ্ধি করে না।',
      note: 'এই আয়াতে কুরআনকে মুমিনদের জন্য শিফা ও রহমত বলা হয়েছে।',
      referenceUrl: 'Quran 17:82',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RuqyahItem> get _filteredItems {
    final query = _query.trim().toLowerCase();

    return _items.where((item) {
      final matchesCategory =
          _selectedCategory == 'সব' || item.category == _selectedCategory;

      if (!matchesCategory) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return item.title.toLowerCase().contains(query) ||
          item.subtitle.toLowerCase().contains(query) ||
          item.category.toLowerCase().contains(query) ||
          item.translation.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'রুকইয়াহ শরইয়াহ',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'রুকইয়াহ সম্পর্কে',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              _showInfo(context);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroCard(context),

                const SizedBox(height: 16),

                _buildSearchBar(context),

                const SizedBox(height: 12),

                _buildCategorySelector(context),

                const SizedBox(height: 20),

                _buildSectionHeader(context),

                const SizedBox(height: 12),

                if (_filteredItems.isEmpty)
                  _buildEmptyState(context)
                else
                  ..._filteredItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildRuqyahCard(context, item),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: primary.withValues(alpha: .10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(Icons.shield_rounded, color: primary, size: 27),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'রুকইয়াহ শরইয়াহ',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'কুরআন ও সহীহ সুন্নাহভিত্তিক আমল',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: .68,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            'রুকইয়াহ হলো কুরআনের আয়াত ও বৈধ দু‘আ দ্বারা আল্লাহর কাছে শিফা ও সুরক্ষা চাওয়া। শিফা একমাত্র আল্লাহর পক্ষ থেকেই আসে।',
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),

          const SizedBox(height: 13),

          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: .72),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.verified_outlined, color: primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'NurVerse-এ অপ্রমাণিত তাবিজ, মন্ত্র বা নির্দিষ্ট ভিত্তিহীন repetition-কে Sunnah হিসেবে দেখানো হবে না।',
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.45,
                      fontWeight: FontWeight.w600,
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

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _query = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'রুকইয়াহ বা দু‘আ খুঁজুন...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon:
            _query.isEmpty
                ? null
                : IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _query = '';
                    });
                  },
                ),
        filled: true,
        fillColor: theme.cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: primary.withValues(alpha: .08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: primary.withValues(alpha: .08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: primary.withValues(alpha: .35)),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORY SELECTOR
  // ============================================================

  Widget _buildCategorySelector(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 39,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];

          final selected = category == _selectedCategory;

          return Material(
            color: selected ? primary : theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? primary : primary.withValues(alpha: .08),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color:
                        selected
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          _selectedCategory == 'সব' ? 'রুকইয়াহ সংগ্রহ' : _selectedCategory,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Text(
          '${_filteredItems.length}টি',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: .55),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RUQYAH CARD
  // ============================================================

  Widget _buildRuqyahCard(BuildContext context, RuqyahItem item) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => RuqyahDetailScreen(item: item)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: primary.withValues(alpha: .08)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(item.icon, color: primary, size: 23),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: .65,
                        ),
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: .07),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            item.type == RuqyahType.quran ? 'কুরআন' : 'দু‘আ',
                            style: TextStyle(
                              color: primary,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            item.source,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 9.5,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: .5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 7),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 15,
                color: primary.withValues(alpha: .45),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 46,
            color: primary.withValues(alpha: .45),
          ),
          const SizedBox(height: 12),
          const Text(
            'কোনো রুকইয়াহ পাওয়া যায়নি',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            'অন্য শব্দ দিয়ে আবার চেষ্টা করুন।',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: .6),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  void _showInfo(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: .10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.verified_rounded, color: primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'রুকইয়াহ সম্পর্কে',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'রুকইয়াহ শারইয়াহ হলো কুরআনের আয়াত ও বৈধ দু‘আ দ্বারা আল্লাহর কাছে শিফা ও সুরক্ষা চাওয়া।',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                ),
                const SizedBox(height: 12),
                Text(
                  'NurVerse-এ প্রতিটি entry-এর সঙ্গে source/reference রাখা হবে, যাতে ব্যবহারকারী জানতে পারেন এটি কোথা থেকে এসেছে।',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                ),
                const SizedBox(height: 12),
                Text(
                  'রুকইয়াহ চিকিৎসার বিকল্প নয়। গুরুতর বা দীর্ঘস্থায়ী অসুস্থতায় প্রয়োজনীয় চিকিৎসা গ্রহণ করতে হবে।',
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.55,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: .65,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// DETAIL SCREEN
// ============================================================================

class RuqyahDetailScreen extends StatefulWidget {
  final RuqyahItem item;

  const RuqyahDetailScreen({super.key, required this.item});

  @override
  State<RuqyahDetailScreen> createState() => _RuqyahDetailScreenState();
}

class _RuqyahDetailScreenState extends State<RuqyahDetailScreen> {
  bool _showTransliteration = true;
  bool _showTranslation = true;

  Future<void> _copyArabic() async {
    await Clipboard.setData(ClipboardData(text: widget.item.arabic.trim()));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('আরবি লেখা কপি করা হয়েছে।')));
  }

  Future<void> _shareRuqyah() async {
    final item = widget.item;

    final text = '''
${item.title}

${item.arabic.trim()}

অর্থ:
${item.translation}

পাঠ:
${item.repetition}

উৎস:
${item.source}

— NurVerse
''';

    try {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: '${item.title} — NurVerse'),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('শেয়ার করা যায়নি।')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'কপি',
            icon: const Icon(Icons.copy_rounded),
            onPressed: _copyArabic,
          ),
          IconButton(
            tooltip: 'শেয়ার',
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareRuqyah,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .07),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primary.withValues(alpha: .10)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.icon, color: primary, size: 25),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(
                              alpha: .65,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ----------------------------------------------------
            // ARABIC
            // ----------------------------------------------------
            _buildSectionTitle(context, 'আরবি', Icons.language_rounded),

            const SizedBox(height: 9),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: primary.withValues(alpha: .08)),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: SelectableText(
                  item.arabic.trim(),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    height: 2.05,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ----------------------------------------------------
            // REPETITION
            // ----------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: .055),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.repeat_rounded, color: primary, size: 20),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'পাঠের নির্দেশনা',
                          style: TextStyle(
                            color: primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.repetition,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ----------------------------------------------------
            // TRANSLITERATION
            // ----------------------------------------------------
            _buildToggleHeader(
              context: context,
              title: 'উচ্চারণ',
              icon: Icons.record_voice_over_rounded,
              value: _showTransliteration,
              onChanged: (value) {
                setState(() {
                  _showTransliteration = value;
                });
              },
            ),

            if (_showTransliteration) ...[
              const SizedBox(height: 9),
              _buildTextCard(context, item.transliteration, italic: true),
            ],

            const SizedBox(height: 16),

            // ----------------------------------------------------
            // TRANSLATION
            // ----------------------------------------------------
            _buildToggleHeader(
              context: context,
              title: 'বাংলা অর্থ',
              icon: Icons.translate_rounded,
              value: _showTranslation,
              onChanged: (value) {
                setState(() {
                  _showTranslation = value;
                });
              },
            ),

            if (_showTranslation) ...[
              const SizedBox(height: 9),
              _buildTextCard(context, item.translation),
            ],

            const SizedBox(height: 18),

            // ----------------------------------------------------
            // NOTE
            // ----------------------------------------------------
            _buildSectionTitle(
              context,
              'ব্যবহারের প্রেক্ষাপট',
              Icons.lightbulb_outline_rounded,
            ),

            const SizedBox(height: 9),

            _buildTextCard(context, item.note),

            const SizedBox(height: 18),

            // ----------------------------------------------------
            // SOURCE
            // ----------------------------------------------------
            _buildSectionTitle(
              context,
              'উৎস ও রেফারেন্স',
              Icons.menu_book_rounded,
            ),

            const SizedBox(height: 9),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: primary.withValues(alpha: .08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      item.source,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ----------------------------------------------------
            // COPY BUTTON
            // ----------------------------------------------------
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: _copyArabic,
                icon: const Icon(Icons.copy_rounded, size: 19),
                label: const Text(
                  'আরবি কপি করুন',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _shareRuqyah,
                icon: const Icon(Icons.share_outlined, size: 19),
                label: const Text(
                  'শেয়ার করুন',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ----------------------------------------------------
            // DISCLAIMER
            // ----------------------------------------------------
            Text(
              'শিফা একমাত্র আল্লাহর পক্ষ থেকে। রুকইয়াহ আমল করার পাশাপাশি প্রয়োজনীয় চিকিৎসা গ্রহণ করা যেতে পারে এবং গুরুতর অসুস্থতায় চিকিৎসকের পরামর্শ নেওয়া উচিত।',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: .55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(icon, color: primary, size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildToggleHeader({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(icon, color: primary, size: 18),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        Switch.adaptive(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildTextCard(
    BuildContext context,
    String text, {
    bool italic = false,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: .07)),
      ),
      child: SelectableText(
        text.trim(),
        style: TextStyle(
          fontSize: 13,
          height: 1.65,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
    );
  }
}

// ============================================================================
// MODEL
// ============================================================================

enum RuqyahType { quran, dua }

class RuqyahItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final RuqyahType type;
  final String source;
  final String repetition;
  final String arabic;
  final String transliteration;
  final String translation;
  final String note;
  final String referenceUrl;

  const RuqyahItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.type,
    required this.source,
    required this.repetition,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.note,
    required this.referenceUrl,
  });
}
