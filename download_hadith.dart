import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String baseUrl = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';

const String editionsUrl = '$baseUrl/editions.json';

const List<String> books = [
  'bukhari',
  'muslim',
  'abudawud',
  'tirmidhi',
  'nasai',
  'ibnmajah',
  'malik',
  'ahmad',
  'darimi',
  'riyadussalihin',
  'adab',
  'shamail',
  'mishkat',
  'bulugh',
];

const List<String> languages = ['ara', 'ben', 'eng'];

Future<void> main() async {
  final directory = Directory('assets/hadith');

  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  stdout.writeln();
  stdout.writeln('==============================================');
  stdout.writeln(' NurVerse Hadith Library Downloader');
  stdout.writeln('==============================================');
  stdout.writeln();

  stdout.writeln('Loading edition catalog...');

  Map<String, dynamic> catalog;

  try {
    final response = await http
        .get(
          Uri.parse(editionsUrl),
          headers: const {
            'User-Agent': 'NurVerse-Hadith-Downloader/1.0',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      stderr.writeln(
        'ERROR: Unable to load edition catalog '
        '(${response.statusCode}).',
      );
      exitCode = 1;
      return;
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));

    if (decoded is! Map) {
      stderr.writeln('ERROR: Invalid editions.json format.');
      exitCode = 1;
      return;
    }

    catalog = Map<String, dynamic>.from(decoded);
  } catch (error) {
    stderr.writeln('ERROR: Failed to load edition catalog.');
    stderr.writeln(error);
    exitCode = 1;
    return;
  }

  stdout.writeln('Edition catalog loaded.');
  stdout.writeln();

  var success = 0;
  var skipped = 0;
  var failed = 0;

  final downloads = <EditionDownload>[];

  stdout.writeln('==============================================');
  stdout.writeln(' Checking available editions');
  stdout.writeln('==============================================');
  stdout.writeln();

  for (final book in books) {
    final rawBook = catalog[book];

    if (rawBook is! Map) {
      stdout.writeln('Collection not found: $book');
      stdout.writeln();
      continue;
    }

    final bookData = Map<String, dynamic>.from(rawBook);
    final collection = bookData['collection'];

    if (collection is! List) {
      stdout.writeln('No editions found: $book');
      stdout.writeln();
      continue;
    }

    stdout.writeln('Checking: $book');

    for (final language in languages) {
      Map<String, dynamic>? selected;

      for (final rawEdition in collection) {
        if (rawEdition is! Map) {
          continue;
        }

        final edition = Map<String, dynamic>.from(rawEdition);

        final name = edition['name']?.toString().trim() ?? '';

        if (_languageCodeFromEditionName(name) != language) {
          continue;
        }

        final link = edition['link']?.toString().trim() ?? '';

        if (link.isEmpty) {
          continue;
        }

        selected = edition;
        break;
      }

      if (selected == null) {
        stdout.writeln('  ${_languageName(language)}: NOT AVAILABLE');
        skipped++;
        continue;
      }

      final name = selected['name']?.toString().trim() ?? '';
      final link = selected['link']?.toString().trim() ?? '';

      final fileName = '$language-$book.json';

      downloads.add(
        EditionDownload(
          book: book,
          language: language,
          editionName: name,
          url: link,
          fileName: fileName,
        ),
      );

      stdout.writeln('  ${_languageName(language)}: $name');
    }

    stdout.writeln();
  }

  stdout.writeln('==============================================');
  stdout.writeln(' Starting downloads');
  stdout.writeln('==============================================');
  stdout.writeln();

  for (final item in downloads) {
    final file = File('${directory.path}/${item.fileName}');

    stdout.write('Downloading ${item.fileName} ... ');

    try {
      final response = await http
          .get(
            Uri.parse(item.url),
            headers: const {
              'User-Agent': 'NurVerse-Hadith-Downloader/1.0',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(minutes: 3));

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        stdout.writeln('FAILED (${response.statusCode})');
        failed++;
        continue;
      }

      try {
        jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        stdout.writeln('FAILED (invalid JSON)');
        failed++;
        continue;
      }

      await file.writeAsBytes(response.bodyBytes, flush: true);

      final sizeKb = response.bodyBytes.length / 1024;

      stdout.writeln('OK (${sizeKb.toStringAsFixed(1)} KB)');

      success++;
    } catch (error) {
      stdout.writeln('FAILED');
      stdout.writeln('  $error');
      failed++;
    }
  }

  stdout.writeln();
  stdout.writeln('==============================================');
  stdout.writeln(' Download completed');
  stdout.writeln('==============================================');
  stdout.writeln('Successful : $success');
  stdout.writeln('Skipped    : $skipped');
  stdout.writeln('Failed     : $failed');
  stdout.writeln();
  stdout.writeln('Files saved to: ${directory.path}/');
  stdout.writeln();

  stdout.writeln('Available files:');

  for (final item in downloads) {
    final file = File('${directory.path}/${item.fileName}');

    if (file.existsSync()) {
      stdout.writeln('  ✓ ${item.fileName}');
    }
  }

  stdout.writeln();
  stdout.writeln('==============================================');
  stdout.writeln(' Done');
  stdout.writeln('==============================================');

  if (failed > 0) {
    exitCode = 1;
  }
}

String? _languageCodeFromEditionName(String editionName) {
  final value = editionName.toLowerCase().trim();

  if (value.startsWith('ara-')) {
    return 'ara';
  }

  if (value.startsWith('ben-')) {
    return 'ben';
  }

  if (value.startsWith('eng-')) {
    return 'eng';
  }

  return null;
}

String _languageName(String language) {
  switch (language) {
    case 'ara':
      return 'Arabic';

    case 'ben':
      return 'Bengali';

    case 'eng':
      return 'English';

    default:
      return language;
  }
}

class EditionDownload {
  final String book;
  final String language;
  final String editionName;
  final String url;
  final String fileName;

  const EditionDownload({
    required this.book,
    required this.language,
    required this.editionName,
    required this.url,
    required this.fileName,
  });
}
