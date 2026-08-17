import 'package:flutter/material.dart';

import '../../data/dua_data.dart';
import '../../localization/app_localizations.dart';
import '../../services/r2_dua_upload_service.dart';

/// Temporary creator tool used to publish the locally recorded master Dua files.
/// It is intentionally separate from the normal listener UI and never exposes
/// R2 credentials to the public app bundle.
class DuaR2UploadScreen extends StatefulWidget {
  const DuaR2UploadScreen({super.key});

  @override
  State<DuaR2UploadScreen> createState() => _DuaR2UploadScreenState();
}

class _DuaR2UploadScreenState extends State<DuaR2UploadScreen> {
  final _accessKeyController = TextEditingController();
  final _secretController = TextEditingController();
  bool _busy = false;
  int _completed = 0;
  int _total = 0;
  int _uploaded = 0;
  int _failed = 0;
  String _status = '';

  @override
  void dispose() {
    _accessKeyController.dispose();
    _secretController.dispose();
    R2DuaUploadService.clearCredentials();
    super.dispose();
  }

  List<DuaItem> get _allDuas =>
      duaCategories.expand((category) => category.items).toList(growable: false);

  Future<void> _uploadAll() async {
    if (_busy) return;

    final accessKey = _accessKeyController.text.trim();
    final secret = _secretController.text.trim();
    final l10n = AppLocalizations.of(context);

    if (accessKey.isEmpty || secret.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.isBangla
                ? 'R2 Access Key ID এবং Secret Access Key দিন।'
                : 'Enter the R2 Access Key ID and Secret Access Key.',
          ),
        ),
      );
      return;
    }

    R2DuaUploadService.configure(
      accessKeyId: accessKey,
      secretAccessKey: secret,
    );

    setState(() {
      _busy = true;
      _completed = 0;
      _total = 0;
      _uploaded = 0;
      _failed = 0;
      _status = l10n.isBangla ? 'রেকর্ডিং খোঁজা হচ্ছে...' : 'Finding recordings...';
    });

    final summary = await R2DuaUploadService.uploadAll(
      _allDuas,
      onItem: (completed, total, item, success) {
        if (!mounted) return;
        setState(() {
          _completed = completed;
          _total = total;
          if (success) {
            _uploaded++;
          } else {
            _failed++;
          }
          _status = l10n.isBangla
              ? '$completed / $total — ${success ? 'আপলোড হয়েছে' : 'ব্যর্থ'}'
              : '$completed / $total — ${success ? 'Uploaded' : 'Failed'}';
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      _completed = summary.total;
      _total = summary.total;
      _uploaded = summary.uploaded;
      _failed = summary.failed;
      _status = l10n.isBangla
          ? 'সম্পন্ন: ${summary.uploaded}টি আপলোড, ${summary.failed}টি ব্যর্থ।'
          : 'Done: ${summary.uploaded} uploaded, ${summary.failed} failed.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = _total == 0 ? 0.0 : _completed / _total;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tr('Dua অডিও আপলোড', 'Dua Audio Upload')),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('Creator Upload', 'Creator Upload'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr(
                      'এই স্ক্রিনটি শুধু আপনার নিজের রেকর্ড করা master Dua অডিও R2-তে প্রকাশ করার জন্য। Credential এই ডিভাইসে সংরক্ষণ করা হবে না।',
                      'This screen is only for publishing your own master Dua recordings to R2. Credentials are never saved on this device.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _accessKeyController,
                    enabled: !_busy,
                    decoration: InputDecoration(
                      labelText: l10n.tr('R2 Access Key ID', 'R2 Access Key ID'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _secretController,
                    enabled: !_busy,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.tr('R2 Secret Access Key', 'R2 Secret Access Key'),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _uploadAll,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_upload_rounded),
                      label: Text(
                        _busy
                            ? l10n.tr('আপলোড চলছে...', 'Uploading...')
                            : l10n.tr('সব রেকর্ডিং আপলোড করুন', 'Upload All Recordings'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_status.isNotEmpty) ...[
            const SizedBox(height: 18),
            LinearProgressIndicator(value: _busy ? progress : (_total == 0 ? 0 : 1)),
            const SizedBox(height: 10),
            Text(_status, textAlign: TextAlign.center),
            if (_total > 0) ...[
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(label: l10n.tr('মোট', 'Total'), value: '$_total'),
                  _Stat(label: l10n.tr('আপলোড', 'Uploaded'), value: '$_uploaded'),
                  _Stat(label: l10n.tr('ব্যর্থ', 'Failed'), value: '$_failed'),
                ],
              ),
            ],
          ],
          const SizedBox(height: 18),
          Text(
            l10n.tr(
              'R2 token তৈরি করার সময় শুধু nurverse-audio bucket-এর প্রয়োজনীয় object write permission দিন। কোনো token এখানে বা GitHub-এ শেয়ার করবেন না।',
              'When creating the R2 token, grant only the object-write permission needed for the nurverse-audio bucket. Never share the token here or commit it to GitHub.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label),
      ],
    );
  }
}
