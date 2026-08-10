import 'package:flutter/material.dart';
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
  int _progress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.isPdf) {
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openData(Uri.parse(widget.url).toString().codeUnits),
      );
    } else {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (progress) {
              if (mounted) setState(() => _progress = progress);
            },
            onWebResourceError: (error) {
              if (error.isForMainFrame ?? true) {
                if (mounted) setState(() => _hasError = true);
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  Future<void> _reload() async {
    if (!mounted) return;
    setState(() => _hasError = false);
    if (widget.isPdf) {
      _pdfController?.loadDocument(PdfDocument.openData(Uri.parse(widget.url).toString().codeUnits));
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
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'রিফ্রেশ',
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: !widget.isPdf && _progress < 100
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress / 100),
              )
            : null,
      ),
      body: _hasError ? _ErrorView(onRetry: _reload) : _buildReader(),
    );
  }

  Widget _buildReader() {
    if (widget.isPdf && _pdfController != null) {
      return PdfViewPinch(
        controller: _pdfController!,
        scrollDirection: Axis.vertical,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
          pageLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (_, error) => _ErrorView(onRetry: _reload),
        ),
      );
    }

    return Stack(
      children: [
        if (_webController != null) WebViewWidget(controller: _webController!),
        if (_progress == 0)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book_rounded, size: 42),
              const SizedBox(height: 12),
              const Text(
                'বইটি এখন খোলা যাচ্ছে না',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 7),
              const Text(
                'ইন্টারনেট সংযোগ পরীক্ষা করে আবার চেষ্টা করুন।',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('আবার চেষ্টা করুন'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
