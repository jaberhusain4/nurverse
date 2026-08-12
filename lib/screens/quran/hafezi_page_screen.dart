import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

import '../../services/hafezi_quran_service.dart';

class HafeziPageScreen extends StatefulWidget {
  final int? initialPdfPage;
  final int? initialPage;

  const HafeziPageScreen({super.key, this.initialPdfPage, this.initialPage});

  @override
  State<HafeziPageScreen> createState() => _HafeziPageScreenState();
}

class _HafeziPageScreenState extends State<HafeziPageScreen> {
  final HafeziQuranService _service = HafeziQuranService.instance;

  PdfController? _pdfController;
  Timer? _hideTimer;

  int _currentPdfPage = 1;
  int _pageCount = HafeziQuranService.fallbackPdfPageCount;

  bool _isBookmarked = false;
  bool _loading = true;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _service.init();
      final document = await PdfDocument.openAsset(HafeziQuranService.pdfAsset);
      final count = document.pagesCount;
      _service.setActualPageCount(count);

      final explicitPage = widget.initialPdfPage ?? widget.initialPage;
      final requestedPage = explicitPage ?? await _service.getLastReadPdfPage();
      final safePage = requestedPage.clamp(1, count).toInt();
      final bookmarked = await _service.isBookmarked(safePage);

      if (!mounted) {
        await document.close();
        return;
      }

      final controller = PdfController(
        document: Future.value(document),
        initialPage: safePage,
      );

      setState(() {
        _pdfController = controller;
        _pageCount = count;
        _currentPdfPage = safePage;
        _isBookmarked = bookmarked;
        _loading = false;
      });

      _keepControlsVisible();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hafezi Quran খুলতে সমস্যা হয়েছে:\n$e')),
      );
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _onPageChanged(int page) async {
    if (page < 1) return;
    final safePage = _service.normalizePdfPage(page);
    if (mounted) setState(() => _currentPdfPage = safePage);
    await _service.saveLastReadPdfPage(safePage);
    final bookmarked = await _service.isBookmarked(safePage);
    if (!mounted) return;
    setState(() => _isBookmarked = bookmarked);
  }

  void _nextPage() {
    if (_currentPdfPage >= _pageCount) return;
    _pdfController?.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
    _keepControlsVisible();
  }

  void _previousPage() {
    if (_currentPdfPage <= 1) return;
    _pdfController?.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
    _keepControlsVisible();
  }

  Future<void> _toggleBookmark() async {
    await _service.toggleBookmark(_currentPdfPage);
    final bookmarked = await _service.isBookmarked(_currentPdfPage);
    if (!mounted) return;
    setState(() => _isBookmarked = bookmarked);
  }

  void _showPageSelector() {
    final location = _service.locationForPdfPage(_currentPdfPage);
    var selectedJuz = location.juzNumber;
    var selectedPage = location.pageInJuz;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final juz = _service.getJuz(selectedJuz);
          final maxPage = juz.pageCount;
          if (selectedPage > maxPage) selectedPage = maxPage;

          return AlertDialog(
            title: const Text('পারা ও পৃষ্ঠা নির্বাচন'),
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
                      if (selectedPage > newCount) selectedPage = newCount;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedPage,
                  decoration: const InputDecoration(
                    labelText: 'পৃষ্ঠা',
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
                    setDialogState(() => selectedPage = value);
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
                  _pdfController?.jumpToPage(pdfPage);
                  _keepControlsVisible();
                },
                child: const Text('খুলুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showParaSelector() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .78,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 14),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'পারা নির্বাচন করুন',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: 30,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final juz = _service.getJuz(index + 1);
                    final current = _service.locationForPdfPage(_currentPdfPage);
                    final selected = current.juzNumber == juz.juz;

                    return Material(
                      color: selected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: .10)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _pdfController?.jumpToPage(juz.startPdfPage);
                          _keepControlsVisible();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .10),
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                child: Text('${juz.juz}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('পারা ${juz.juz}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                    const SizedBox(height: 2),
                                    Text(juz.name, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .65))),
                                    const SizedBox(height: 3),
                                    Text('${juz.pageCount} পৃষ্ঠা', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
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
      ),
    );
  }

  void _keepControlsVisible() {
    _hideTimer?.cancel();
    if (!mounted) return;
    if (!_showControls) setState(() => _showControls = true);
  }

  void _toggleControls() => _keepControlsVisible();

  @override
  Widget build(BuildContext context) {
    if (_loading || _pdfController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final location = _service.locationForPdfPage(_currentPdfPage);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: PdfView(
              controller: _pdfController!,
              scrollDirection: Axis.horizontal,
              reverse: true,
              pageSnapping: true,
              onPageChanged: _onPageChanged,
              onDocumentLoaded: (document) {
                final count = document.pagesCount;
                _service.setActualPageCount(count);
                if (!mounted) return;
                if (_pageCount != count) setState(() => _pageCount = count);
              },
              builders: PdfViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(
                  loaderSwitchDuration: Duration(milliseconds: 150),
                ),
                documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                errorBuilder: (_, error) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Quran page দেখানো যাচ্ছে না.\n\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 70,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _toggleControls,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            top: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: _buildTopBar(context, location),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            bottom: _showControls ? 0 : -110,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, HafeziPageLocation location) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 6, 8, 0),
        height: 62,
        decoration: BoxDecoration(color: const Color(0xEA1B1B1B), borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            _TopButton(icon: Icons.arrow_back_rounded, onTap: () => Navigator.pop(context)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'পারা ${location.juzNumber} • পৃষ্ঠা ${location.pageInJuz}/${location.juzPageCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text('Hafezi Quran', style: TextStyle(color: Colors.white.withValues(alpha: .62), fontSize: 10)),
                ],
              ),
            ),
            _TopButton(
              icon: _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              onTap: _toggleBookmark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        height: 74,
        decoration: BoxDecoration(color: const Color(0xEA1B1B1B), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Expanded(child: _BottomAction(icon: Icons.keyboard_arrow_left_rounded, label: 'পরের পৃষ্ঠা', enabled: _currentPdfPage < _pageCount, onTap: _nextPage)),
            Expanded(child: _BottomAction(icon: Icons.menu_book_rounded, label: 'পারা', enabled: true, onTap: _showParaSelector)),
            Expanded(child: _BottomAction(icon: Icons.grid_view_rounded, label: 'পৃষ্ঠা', enabled: true, onTap: _showPageSelector)),
            Expanded(child: _BottomAction(icon: Icons.keyboard_arrow_right_rounded, label: 'আগের পৃষ্ঠা', enabled: _currentPdfPage > 1, onTap: _previousPage)),
          ],
        ),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(width: 54, height: 54, child: Icon(icon, color: Colors.white, size: 24)),
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _BottomAction({required this.icon, required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: enabled ? 1 : .28,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 25),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
