import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../services/hafezi_quran_service.dart';
import 'hafezi_page_screen.dart';

class HafeziQuranScreen extends StatefulWidget {
  const HafeziQuranScreen({super.key});

  @override
  State<HafeziQuranScreen> createState() => _HafeziQuranScreenState();
}

class _HafeziQuranScreenState extends State<HafeziQuranScreen>
    with SingleTickerProviderStateMixin {
  final HafeziQuranService _service = HafeziQuranService.instance;

  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  bool _loading = true;
  int _lastPdfPage = 1;
  Set<int> _bookmarks = <int>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _service.init();
    final last = await _service.getLastReadPdfPage();
    final bookmarks = await _service.getBookmarks();

    if (!mounted) return;
    setState(() {
      _lastPdfPage = last;
      _bookmarks = bookmarks;
      _loading = false;
    });
  }

  Future<void> _openPdfPage(int pdfPage) async {
    final safePage = _service.normalizePdfPage(pdfPage);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => HafeziPageScreen(initialPdfPage: safePage),
      ),
    );

    if (mounted) {
      await _load();
    }
  }

  Future<void> _openLastRead() async {
    await _openPdfPage(_lastPdfPage);
  }

  Future<void> _showParaPageSearch() async {
    var selectedJuz = _service.locationForPdfPage(_lastPdfPage).juzNumber;
    var selectedPage = _service.locationForPdfPage(_lastPdfPage).pageInJuz;
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final juz = _service.getJuz(selectedJuz);
            final maxPage = juz.pageCount;
            if (selectedPage > maxPage) selectedPage = maxPage;

            return AlertDialog(
              title: Text(l10n.isArabic ? 'ابحث عن الجزء والصفحة' : l10n.tr('পারা ও পৃষ্ঠা খুঁজুন', 'Find Juz & Page')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedJuz,
                    decoration: InputDecoration(
                      labelText: l10n.isArabic ? 'الجزء' : l10n.tr('পারা', 'Juz'),
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      30,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(l10n.isArabic ? 'الجزء ${index + 1}' : l10n.tr('পারা ${index + 1}', 'Juz ${index + 1}')),
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedJuz = value;
                        final newCount = _service.getJuz(value).pageCount;
                        if (selectedPage > newCount) {
                          selectedPage = newCount;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedPage,
                    decoration: InputDecoration(
                      labelText: l10n.isArabic ? 'الصفحة' : l10n.tr('পৃষ্ঠা', 'Page'),
                      hintText: l10n.tr('English digit: 1, 2, 3 ...', 'English digits: 1, 2, 3 ...'),
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      maxPage,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    onChanged: (value) {
                      if (value == null) return;
                      setDialogState(() {
                        selectedPage = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.tr('বাতিল', 'Cancel')),
                ),
                FilledButton(
                  onPressed: () {
                    final pdfPage = _service.pdfPageForJuzPage(
                      selectedJuz,
                      selectedPage,
                    );
                    Navigator.pop(dialogContext);
                    _openPdfPage(pdfPage);
                  },
                  child: Text(l10n.tr('খুলুন', 'Open')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showGlobalPdfSearchCompatibility() async {
    // Kept only for compatibility with older UI actions. Users are not asked
    // to search the PDF's physical/printed page number anymore.
    await _showParaPageSearch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final lastLocation = _service.locationForPdfPage(_lastPdfPage);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final card = theme.colorScheme.surface;
    final secondary = theme.colorScheme.onSurface.withValues(alpha: .62);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.isArabic ? 'القرآن الحفظي' : l10n.tr('হিফজি কুরআন', 'Hafezi Quran'),
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: l10n.tr('পারা ও পৃষ্ঠা খুঁজুন', 'Find Juz & Page'),
            onPressed: _showGlobalPdfSearchCompatibility,
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.menu_book_rounded,
                    title: l10n.tr('শেষবার পড়া', 'Last Read'),
                    subtitle: l10n.isArabic ? 'الجزء ${lastLocation.juzNumber} • الصفحة ${lastLocation.pageInJuz}' : l10n.tr('পারা ${lastLocation.juzNumber} • পৃষ্ঠা ${lastLocation.pageInJuz}', 'Juz ${lastLocation.juzNumber} • Page ${lastLocation.pageInJuz}'),
                    onTap: _openLastRead,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.search_rounded,
                    title: l10n.tr('খুঁজুন', 'Search'),
                    subtitle: l10n.isArabic ? 'الجزء + الصفحة' : l10n.tr('পারা + পৃষ্ঠা', 'Juz + Page'),
                    onTap: _showParaPageSearch,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: primary,
            unselectedLabelColor: secondary,
            indicatorColor: primary,
            tabs: [
              Tab(text: l10n.isArabic ? 'السور' : l10n.tr('সূরা', 'Surah')),
              Tab(text: l10n.isArabic ? 'الأجزاء' : l10n.tr('পারা', 'Juz')),
              Tab(text: l10n.isArabic ? 'العلامات المرجعية' : l10n.tr('বুকমার্ক', 'Bookmarks')),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SurahList(
                  service: _service,
                  onOpen: _openPdfPage,
                  cardColor: card,
                  secondaryColor: secondary,
                  primaryColor: primary,
                ),
                _ParaList(
                  service: _service,
                  onOpen: _openPdfPage,
                  cardColor: card,
                  secondaryColor: secondary,
                  primaryColor: primary,
                ),
                _BookmarkList(
                  service: _service,
                  bookmarks: _bookmarks,
                  onOpen: _openPdfPage,
                  cardColor: card,
                  secondaryColor: secondary,
                  primaryColor: primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 26),
              const SizedBox(height: 7),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withValues(alpha: .62),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParaList extends StatelessWidget {
  final HafeziQuranService service;
  final ValueChanged<int> onOpen;
  final Color cardColor;
  final Color secondaryColor;
  final Color primaryColor;

  const _ParaList({
    required this.service,
    required this.onOpen,
    required this.cardColor,
    required this.secondaryColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 30,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final juz = service.getJuz(index + 1);
        return Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onOpen(juz.startPdfPage),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryColor.withValues(alpha: .10),
                    foregroundColor: primaryColor,
                    child: Text(
                      '${juz.juz}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.isArabic ? 'الجزء ${juz.juz}' : l10n.tr(l10n.isArabic ? 'الجزء ${juz.juz}' : l10n.tr('পারা ${juz.juz}', 'Juz ${juz.juz}'), 'Juz ${juz.juz}'),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          juz.name,
                          style: TextStyle(color: secondaryColor),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.isArabic ? '${juz.pageCount} صفحة' : l10n.tr(l10n.isArabic ? '${juz.pageCount} صفحة' : l10n.tr('${juz.pageCount} পৃষ্ঠা', '${juz.pageCount} pages'), '${juz.pageCount} pages'),
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    juz.arabicName,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SurahList extends StatelessWidget {
  final HafeziQuranService service;
  final ValueChanged<int> onOpen;
  final Color cardColor;
  final Color secondaryColor;
  final Color primaryColor;

  const _SurahList({
    required this.service,
    required this.onOpen,
    required this.cardColor,
    required this.secondaryColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (service.surahs.isEmpty) {
      return Center(child: Text(l10n.tr('সূরা তথ্য পাওয়া যাচ্ছে না', 'Surah information is unavailable')));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: service.surahs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final surah = service.surahs[index];
        return Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onOpen(surah.startPdfPage),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor.withValues(alpha: .10),
                foregroundColor: primaryColor,
                child: Text('${surah.number}'),
              ),
              title: Text(
                l10n.isArabic ? surah.arabicName : surah.englishName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                l10n.isArabic ? '${surah.revelationType == 'meccan' ? 'مكية' : 'مدنية'} · ${surah.verses} آيات' : l10n.tr(l10n.isArabic ? '${surah.revelationType == 'meccan' ? 'مكية' : 'مدنية'} · ${surah.verses} آيات' : l10n.tr('${surah.revelationType == 'meccan' ? 'মাক্কী' : 'মাদানী'} · ${surah.verses} আয়াত', '${surah.revelationType == 'meccan' ? 'Meccan' : 'Medinan'} · ${surah.verses} verses'), '${surah.revelationType == 'meccan' ? 'Meccan' : 'Medinan'} · ${surah.verses} verses'),
                style: TextStyle(color: secondaryColor),
              ),
              trailing: Text(
                surah.arabicName,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BookmarkList extends StatelessWidget {
  final HafeziQuranService service;
  final Set<int> bookmarks;
  final ValueChanged<int> onOpen;
  final Color cardColor;
  final Color secondaryColor;
  final Color primaryColor;

  const _BookmarkList({
    required this.service,
    required this.bookmarks,
    required this.onOpen,
    required this.cardColor,
    required this.secondaryColor,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (bookmarks.isEmpty) {
      return Center(child: Text(l10n.tr('এখনও কোনো বুকমার্ক নেই', 'No bookmarks yet')));
    }

    final pages = bookmarks.toList()..sort();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: pages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final pdfPage = pages[index];
        final location = service.locationForPdfPage(pdfPage);

        return Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => onOpen(pdfPage),
            child: ListTile(
              leading: Icon(Icons.bookmark_rounded, color: primaryColor),
              title: Text(
                l10n.isArabic ? 'الجزء ${location.juzNumber} • الصفحة ${location.pageInJuz}' : l10n.tr(l10n.isArabic ? 'الجزء ${location.juzNumber} • الصفحة ${location.pageInJuz}' : l10n.tr('পারা ${location.juzNumber} • পৃষ্ঠা ${location.pageInJuz}', 'Juz ${location.juzNumber} • Page ${location.pageInJuz}'), 'Juz ${location.juzNumber} • Page ${location.pageInJuz}'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                l10n.isArabic ? 'صفحة PDF ${location.pdfPage}' : l10n.tr(l10n.isArabic ? 'صفحة PDF ${location.pdfPage}' : l10n.tr('PDF page ${location.pdfPage}', 'PDF page ${location.pdfPage}'), l10n.isArabic ? 'صفحة PDF ${location.pdfPage}' : l10n.tr('PDF page ${location.pdfPage}', 'PDF page ${location.pdfPage}')),
                style: TextStyle(color: secondaryColor, fontSize: 11),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
        );
      },
    );
  }
}
