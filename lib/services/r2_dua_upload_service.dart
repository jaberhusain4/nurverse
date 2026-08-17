import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../data/dua_data.dart';
import 'dua_audio_service.dart';

/// Owner-only uploader for publishing locally recorded Dua audio to Cloudflare R2.
/// Credentials are kept in memory only and are never persisted in the app.
class R2DuaUploadService {
  R2DuaUploadService._();

  static const String accountId = '577d1293667bdfb2d46cdf84ebae4297';
  static const String bucket = 'nurverse-audio';
  static const String region = 'auto';
  static const String service = 's3';
  static const String host = '$accountId.r2.cloudflarestorage.com';

  static String? _accessKeyId;
  static String? _secretAccessKey;

  static bool get configured =>
      _accessKeyId != null && _secretAccessKey != null;

  static void configure({
    required String accessKeyId,
    required String secretAccessKey,
  }) {
    _accessKeyId = accessKeyId.trim();
    _secretAccessKey = secretAccessKey.trim();
  }

  static void clearCredentials() {
    _accessKeyId = null;
    _secretAccessKey = null;
  }

  static Future<bool> uploadOne(DuaItem item) async {
    if (!configured) return false;
    await DuaAudioService.initialize();

    final localPath = DuaAudioService.recordedPath(item);
    if (localPath == null || localPath.isEmpty) return false;
    final file = File(localPath);
    if (!await file.exists()) return false;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return false;

    final key = 'dua_audio/${DuaAudioService.keyFor(item)}.m4a';
    final uri = Uri.https(host, '/$bucket/$key');
    final payloadHash = sha256.convert(bytes).toString();
    final now = DateTime.now().toUtc();
    final amzDate = _amzDate(now);
    final dateStamp = _dateStamp(now);
    final credentialScope = '$dateStamp/$region/$service/aws4_request';
    final canonicalHeaders =
        'content-type:audio/mp4\nhost:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';
    const signedHeaders = 'content-type;host;x-amz-content-sha256;x-amz-date';
    final canonicalRequest = [
      'PUT',
      _canonicalPath(uri.path),
      '',
      canonicalHeaders,
      signedHeaders,
      payloadHash,
    ].join('\n');
    final stringToSign = [
      'AWS4-HMAC-SHA256',
      amzDate,
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');
    final signingKey = _signingKey(
      _secretAccessKey!,
      dateStamp,
      region,
      service,
    );
    final signature = _hexHmac(signingKey, stringToSign);
    final authorization =
        'AWS4-HMAC-SHA256 Credential=${_accessKeyId!}/$credentialScope, '
        'SignedHeaders=$signedHeaders, Signature=$signature';

    try {
      final response = await http.put(
        uri,
        headers: {
          'content-type': 'audio/mp4',
          'host': host,
          'x-amz-content-sha256': payloadHash,
          'x-amz-date': amzDate,
          'authorization': authorization,
        },
        body: bytes,
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static Future<UploadSummary> uploadAll(
    List<DuaItem> items, {
    void Function(int completed, int total, DuaItem item, bool success)? onItem,
  }) async {
    if (!configured) {
      return const UploadSummary(total: 0, uploaded: 0, failed: 0);
    }
    await DuaAudioService.initialize();

    final candidates = <DuaItem>[];
    for (final item in items) {
      final path = DuaAudioService.recordedPath(item);
      if (path != null && path.isNotEmpty && await File(path).exists()) {
        candidates.add(item);
      }
    }

    var uploaded = 0;
    var failed = 0;
    for (var i = 0; i < candidates.length; i++) {
      final item = candidates[i];
      final success = await uploadOne(item);
      if (success) {
        uploaded++;
      } else {
        failed++;
      }
      onItem?.call(i + 1, candidates.length, item, success);
    }

    return UploadSummary(
      total: candidates.length,
      uploaded: uploaded,
      failed: failed,
    );
  }

  static String _amzDate(DateTime value) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${value.year.toString().padLeft(4, '0')}${two(value.month)}'
        '${two(value.day)}T${two(value.hour)}${two(value.minute)}${two(value.second)}Z';
  }

  static String _dateStamp(DateTime value) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${value.year.toString().padLeft(4, '0')}${two(value.month)}${two(value.day)}';
  }

  static String _canonicalPath(String path) =>
      path.split('/').map(Uri.encodeComponent).join('/');

  static List<int> _hmac(List<int> key, String value) =>
      Hmac(sha256, key).convert(utf8.encode(value)).bytes;

  static String _hexHmac(List<int> key, String value) =>
      Hmac(sha256, key).convert(utf8.encode(value)).toString();

  static List<int> _signingKey(
    String secret,
    String date,
    String region,
    String service,
  ) {
    final kDate = _hmac(utf8.encode('AWS4$secret'), date);
    final kRegion = _hmac(kDate, region);
    final kService = _hmac(kRegion, service);
    return _hmac(kService, 'aws4_request');
  }
}

class UploadSummary {
  final int total;
  final int uploaded;
  final int failed;

  const UploadSummary({
    required this.total,
    required this.uploaded,
    required this.failed,
  });
}
