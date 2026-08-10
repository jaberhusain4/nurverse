import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class IslamicBookReaderScreen extends StatefulWidget {
  final String title;
  final String url;

  const IslamicBookReaderScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<IslamicBookReaderScreen> createState() => _IslamicBookReaderScreenState();
}

class _IslamicBookReaderScreenState extends State<IslamicBookReaderScreen> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = 'বইটি এখন লোড করা যাচ্ছে না।';

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
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
            if (!mounted) return;
            setState(() => _progress = progress);
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
    await _controller.reload();
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  Future<void> _closeReader() async {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldClose = await _handleBack();
        if (shouldClose) await _closeReader();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'ফিরে যান',
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () async {
              final shouldClose = await _handleBack();
              if (shouldClose) await _closeReader();
            },
          ),
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
          bottom: _loading && _progress < 100
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(
                    value: _progress == 0 ? null : _progress / 100,
                  ),
                )
              : null,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_hasError)
              _ReaderError(message: _errorMessage, onRetry: _reload),
          ],
        ),
      ),
    );
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
                const Text(
                  'বইটি খোলা যাচ্ছে না',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
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
