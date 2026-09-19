import 'dart:io';

final _bangla = RegExp(r'[\u0980-\u09FF]');
final _directEnglishBranch = RegExp(
  r'\b(?:isEnglish|isBangla|isArabic|languageCode|language)\s*==?\s*(?:\x27|\x22)(?:en|bn|ar)(?:\x27|\x22)',
);
final _ternaryLanguage = RegExp(r'\b(?:isEnglish|isBangla|isArabic)\s*\?');
final _textLiteral = RegExp(
  r'\b(?:Text|Tooltip|SnackBar|AlertDialog|SimpleDialog|showDialog|showModalBottomSheet)\s*\(',
);
final _localizationCall = RegExp(r'\b(?:\.tr|\.localeText|localeText)\s*\(');

bool _isUserFacingUiFile(String path) {
  return path.startsWith('lib/screens/') || path.startsWith('lib/widgets/');
}

void main(List<String> args) {
  final root = Directory('lib');
  final changedOnly = args.contains('--changed-lines');

  if (changedOnly) {
    _checkChangedLines();
    return;
  }
  if (!root.existsSync()) {
    stderr.writeln('lib/ directory not found.');
    exitCode = 2;
    return;
  }

  final findings = <String>[];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll('\\', '/');
    if (!_isUserFacingUiFile(path)) continue;
    if (path.startsWith('lib/localization/')) continue;
    if (path.startsWith('lib/l10n/')) continue;
    if (path.endsWith('_strings.dart')) continue;
    if (path.contains('/generated/')) continue;

    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Translation arguments are localization data, not hardcoded UI.
      final isLocalizationSource = _localizationCall.hasMatch(line);
      final uiContext = _textLiteral.hasMatch(line) ||
          line.contains('Text(') ||
          line.contains('label:') ||
          line.contains('title:') ||
          line.contains('subtitle:');

      if (!isLocalizationSource && uiContext && _bangla.hasMatch(line)) {
        findings.add('$path:${i + 1}: direct Bangla UI literal');
      }
      if (!isLocalizationSource &&
          (_ternaryLanguage.hasMatch(line) || _directEnglishBranch.hasMatch(line))) {
        findings.add('$path:${i + 1}: language-specific UI branching');
      }
    }
  }

  if (findings.isEmpty) {
    stdout.writeln('Localization hardcode guard: PASS');
    return;
  }

  stderr.writeln('Localization hardcode guard: FAIL');
  for (final finding in findings) {
    stderr.writeln(finding);
  }
  stderr.writeln(
    'Migrate these user-facing strings to AppLocalizations/AppLocalizationsX before merging.',
  );
  exitCode = 1;
}


void _checkChangedLines() {
  final baseRef = Platform.environment['GITHUB_BASE_REF'];
  if (baseRef == null || baseRef.isEmpty) {
    stdout.writeln(
      'Localization hardcode guard: skipped changed-line mode outside GitHub pull requests.',
    );
    return;
  }

  final result = Process.runSync(
    'git',
    <String>[
      'diff',
      '--unified=0',
      'origin/$baseRef...HEAD',
      '--',
      'lib/screens',
      'lib/widgets',
    ],
  );

  if (result.exitCode != 0) {
    stderr.writeln('Unable to inspect pull-request diff for localization guard.');
    stderr.writeln(result.stderr);
    exitCode = 2;
    return;
  }

  final findings = <String>[];
  String? currentFile;
  var lineNumber = 0;

  for (final rawLine in result.stdout.toString().split('\n')) {
    if (rawLine.startsWith('+++ b/')) {
      currentFile = rawLine.substring(6);
      lineNumber = 0;
      continue;
    }

    if (rawLine.startsWith('@@')) {
      final match = RegExp(r'\+([0-9]+)(?:,([0-9]+))?').firstMatch(rawLine);
      if (match != null) {
        lineNumber = int.parse(match.group(1)!);
      }
      continue;
    }

    if (rawLine.startsWith('+') && !rawLine.startsWith('+++')) {
      final line = rawLine.substring(1);
      final path = currentFile ?? '';
      if (path.isEmpty) continue;

      final isLocalizationSource = _localizationCall.hasMatch(line);
      final uiContext = _textLiteral.hasMatch(line) ||
          line.contains('Text(') ||
          line.contains('label:') ||
          line.contains('title:') ||
          line.contains('subtitle:');

      if (!isLocalizationSource && uiContext && _bangla.hasMatch(line)) {
        findings.add('$path:$lineNumber: direct Bangla UI literal');
      }
      if (!isLocalizationSource &&
          (_ternaryLanguage.hasMatch(line) ||
              _directEnglishBranch.hasMatch(line))) {
        findings.add('$path:$lineNumber: language-specific UI branching');
      }

      lineNumber++;
    } else if (rawLine.startsWith('-') || rawLine.startsWith('---')) {
      continue;
    } else if (rawLine.isNotEmpty) {
      lineNumber++;
    }
  }

  if (findings.isEmpty) {
    stdout.writeln('Localization hardcode guard: PASS (new lines only)');
    return;
  }

  stderr.writeln('Localization hardcode guard: FAIL (new lines only)');
  for (final finding in findings) {
    stderr.writeln(finding);
  }
  stderr.writeln(
    'Migrate newly introduced user-facing strings to AppLocalizations/AppLocalizationsX before merging.',
  );
  exitCode = 1;
}
