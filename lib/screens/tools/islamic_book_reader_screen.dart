import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../localization/app_localizations.dart';

class IslamicBookReaderScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool isPdf;
  final String? localFilePath;

  const IslamicBookReaderScreen({
    super.key,
    required this.title,
    required this.url,
    this.isPdf = false,
    this.localFilePath,
  });

  @override
  State<IslamicBookReaderScreen> createState() => _IslamicBookReaderScreenState();
}

class _IslamicBookReaderScreenState extends State<IslamicBookReaderScreen> {
  WebViewController? _webController;
  PdfControllerPinch? _pdfController;
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = '';
  int _progress = 0;

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    if (widget.localFilePath != null) {
      _loadLocalPdf();
    } else if (widget.isPdf) {
      _loadPdf();
    } else {
      _loadWebPage();
    }
  }

  Future<void> _loadLocalPdf() async {
    try {
      final file = File(widget.localFilePath!);
      if (!await file.exists()) throw Exception('File not found');
      final controller = PdfControllerPinch(document: PdfDocument.openFile(file.path));
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _pdfController = controller;
        _loading = false;
        _hasError = false;
        _progress = 100;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = l10n.tr('ডাউনলোড করা বইটি খোলা যাচ্ছে না।', 'The downloaded book could not be opened.');
      });
    }
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url), headers: {'User-Agent': _userAgent});
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }
      final bytes = Uint8List.fromList(response.bodyBytes);
      final controller = PdfControllerPinch(document: PdfDocument.openData(bytes));
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _pdfController = controller;
        _loading = false;
        _hasError = false;
        _progress = 100;
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = l10n.tr('বইটির PDF পাওয়া যাচ্ছে না। ইন্টারনেট সংযোগ পরীক্ষা করুন।', 'The book PDF could not be found. Please check your internet connection.');
      });
    }
  }

  void _loadWebPage() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(_userAgent)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _hasError = false;
              _progress = 0;
            });
          },
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _loading = false;
              _progress = 100;
            });
          },
          onWebResourceError: (error) {
            if (!(error.isForMainFrame ?? true) || !mounted) return;
            setState(() {
              _loading = false;
              _hasError = true;
              _errorMessage = _friendlyError(error.errorCode);
            });
          },
          onHttpError: (error) {
            final status = error.response?.statusCode;
            if (status == null || status < 400 || !mounted) return;
            final l10n = AppLocalizations.of(context);
            setState(() {
              _loading = false;
              _hasError = true;
              _errorMessage = l10n.tr('অনলাইন উৎস থেকে বইটি পাওয়া যাচ্ছে না ($status)।', 'The book is unavailable from the online source ($status).');
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    _webController = controller;
  }

  String _friendlyError(int code) {
    final l10n = AppLocalizations.of(context);
    if (code == -2) return l10n.tr('ইন্টারনেট সংযোগ বা ওয়েবসাইটে পৌঁছাতে সমস্যা হচ্ছে।', 'There is a problem connecting to the internet or website.');
    if (code == -6) return l10n.tr('এই অনলাইন বইটি বর্তমানে পাওয়া যাচ্ছে না।', 'This online book is currently unavailable.');
    return l10n.tr('বইটি এখন লোড করা যাচ্ছে না। আবার চেষ্টা করুন।', 'The book cannot be loaded right now. Please try again.');
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _hasError = false;
      _progress = 0;
    });
    if (widget.localFilePath != null) {
      _pdfController?.dispose();
      _pdfController = null;
      await _loadLocalPdf();
    } else if (widget.isPdf) {
      _pdfController?.dispose();
      _pdfController = null;
      await _loadPdf();
    } else {
      await _webController?.reload();
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.tr('ফিরে যান', 'Back'),
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: l10n.tr('রিফ্রেশ', 'Refresh'),
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: _loading && _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress == 0 ? null : _progress / 100),
              )
            : null,
      ),
      body: _hasError ? _ReaderError(message: _errorMessage, onRetry: _reload) : _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context);
    if ((widget.isPdf || widget.localFilePath != null) && _pdfController != null) {
      return Stack(
        children: [
          PdfViewPinch(
            controller: _pdfController!,
            scrollDirection: Axis.vertical,
            minScale: 1.0,
            maxScale: 4.0,
            padding: 8,
            builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
              options: const DefaultBuilderOptions(),
              documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
              pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
              errorBuilder: (_, __) => _ReaderError(
                message: l10n.tr('PDF পড়া যাচ্ছে না। আবার চেষ্টা করুন।', 'The PDF cannot be read. Please try again.'),
                onRetry: _reload,
              ),
            ),
          ),
          Positioned(
            right: 14,
            bottom: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: PdfPageNumber(
                  controller: _pdfController!,
                  builder: (_, loadingState, page, pagesCount) => Text(
                    loadingState == PdfLoadingState.success
                        ? '$page / ${pagesCount ?? 0}'
                        : l10n.tr('লোড হচ্ছে…', 'Loading…'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    if (_webController != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _webController!),
          if (_loading && _progress == 0) const Center(child: CircularProgressIndicator()),
        ],
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}

class _ReaderError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ReaderError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_rounded, size: 44),
                const SizedBox(height: 14),
                Text(l10n.tr('বইটি খোলা যাচ্ছে না', 'Unable to open book'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.tr('আবার চেষ্টা করুন', 'Try again')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
