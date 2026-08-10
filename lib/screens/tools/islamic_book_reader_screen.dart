import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IslamicBookReaderScreen extends StatefulWidget {
  final String title;
  final String url;
  final bool isPdf;

  const IslamicBookReaderScreen({
    super.key,
    required this.title,
    required this.url,
    this.isPdf = false,
  });

  @override
  State<IslamicBookReaderScreen> createState() => _IslamicBookReaderScreenState();
}

class _IslamicBookReaderScreenState extends State<IslamicBookReaderScreen> {
  WebViewController? _webController;
  PdfControllerPinch? _pdfController;
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = 'বইটি এখন লোড করা যাচ্ছে না।';
  int _progress = 0;

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    widget.isPdf ? _loadPdf() : _loadWebPage();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(
        Uri.parse(widget.url),
        headers: {'User-Agent': _userAgent},
      );
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
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = 'বইটির PDF ডাউনলোড করা যাচ্ছে না। ইন্টারনেট সংযোগ পরীক্ষা করুন।';
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
            setState(() {
              _loading = false;
              _hasError = true;
              _errorMessage = 'অনলাইন উৎস থেকে বইটি পাওয়া যাচ্ছে না ($status)।';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
    _webController = controller;
  }

  String _friendlyError(int code) {
    if (code == -2) return 'ইন্টারনেট সংযোগ বা ওয়েবসাইটে পৌঁছাতে সমস্যা হচ্ছে।';
    if (code == -6) return 'এই অনলাইন বইটি বর্তমানে পাওয়া যাচ্ছে না।';
    return 'বইটি এখন লোড করা যাচ্ছে না। আবার চেষ্টা করুন।';
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _hasError = false;
      _progress = 0;
    });
    if (widget.isPdf) {
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'ফিরে যান',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'রিফ্রেশ',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: _loading && _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress / 100,
                ),
              )
            : null,
      ),
      body: _hasError ? _ReaderError(message: _errorMessage, onRetry: _reload) : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.isPdf && _pdfController != null) {
      return PdfViewPinch(
        controller: _pdfController!,
        scrollDirection: Axis.vertical,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) => const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, __) => _ReaderError(
            message: 'PDF পড়া যাচ্ছে না। আবার চেষ্টা করুন।',
            onRetry: _reload,
          ),
        ),
      );
    }
    if (_webController != null) {
      return Stack(
        children: [
          WebViewWidget(controller: _webController!),
          if (_loading && _progress == 0)
            const Center(child: CircularProgressIndicator()),
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
                const Text('বইটি খোলা যাচ্ছে না', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('আবার চেষ্টা করুন'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
