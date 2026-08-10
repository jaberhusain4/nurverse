import 'package:flutter/material.dart';

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

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final juz = _service.getJuz(selectedJuz);
            final maxPage = juz.pageCount;
            if (selectedPage > maxPage) selectedPage = maxPage;

            return AlertDialog(
              title: const Text('পারা ও পৃষ্ঠা খুঁজুন'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedJuz,
                    decoration: const InputDecoration(
                      labelText: 'পারা',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      30,
                      (index) => DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text('পারা ${index + 1}'),
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
                    decoration: const InputDecoration(
                      labelText: 'পৃষ্ঠা',
                      hintText: 'English digit: 1, 2, 3 ...',
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
                  child: const Text('বাতিল'),
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
                  child: const Text('খুলুন'),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hafezi Quran',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'পারা ও পৃষ্ঠা খুঁজুন',
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
                    title: 'Last Read',
                    subtitle:
                        'পারা ${lastLocation.juzNumber} • পৃষ্ঠা ${lastLocation.pageInJuz}',
                    onTap: _openLastRead,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.search_rounded,
                    title: 'Search',
                    subtitle: 'পারা + পৃষ্ঠা',
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
            tabs: const [
              Tab(text: 'সূরা'),
              Tab(text: 'পারা'),
              Tab(text: 'বুকমার্ক'),
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
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: 30,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
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
                          'পারা ${juz.juz}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          juz.name,
                          style: TextStyle(color: secondaryColor),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${juz.pageCount} পৃষ্ঠা',
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
    if (service.surahs.isEmpty) {
      return const Center(child: Text('সূরা তথ্য পাওয়া যাচ্ছে না'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: service.surahs.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
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
                surah.englishName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '${surah.revelationType == 'meccan' ? 'মাক্কী' : 'মাদানী'} · ${surah.verses} আয়াত',
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
    if (bookmarks.isEmpty) {
      return const Center(child: Text('এখনও কোনো বুকমার্ক নেই'));
    }

    final pages = bookmarks.toList()..sort();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: pages.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
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
                'পারা ${location.juzNumber} • পৃষ্ঠা ${location.pageInJuz}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'PDF page ${location.pdfPage}',
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
