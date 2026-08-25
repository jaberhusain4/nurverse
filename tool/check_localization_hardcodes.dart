import 'dart:io';

final _bangla = RegExp(r'[\u0980-\u09FF]');
final _directEnglishBranch = RegExp(r"\b(?:isEnglish|isBangla|isArabic|languageCode|language)\s*==?\s*['\"](?:en|bn|ar)['\"]");
final _ternaryLanguage = RegExp(r'\b(?:isEnglish|isBangla|isArabic)\s*\?');
final _textLiteral = RegExp(r'\b(?:Text|Tooltip|SnackBar|AlertDialog|SimpleDialog|showDialog|showModalBottomSheet)\s*\(');

void main() {
  final root = Directory('lib');
  if (!root.existsSync()) {
    stderr.writeln('lib/ directory not found.');
    exitCode = 2;
    return;
  }

  final findings = <String>[];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final path = entity.path.replaceAll('\\', '/');
    if (path.startsWith('lib/localization/')) continue;
    if (path.startsWith('lib/l10n/')) continue;
    if (path.endsWith('_strings.dart')) continue;
    if (path.contains('/generated/')) continue;

    final lines = entity.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final uiContext = _textLiteral.hasMatch(line) ||
          line.contains("Text(") ||
          line.contains("label:") ||
          line.contains("title:") ||
          line.contains("subtitle:");

      if (uiContext && _bangla.hasMatch(line)) {
        findings.add('$path:${i + 1}: direct Bangla UI literal');
      }
      if (_ternaryLanguage.hasMatch(line) || _directEnglishBranch.hasMatch(line)) {
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
  stderr.writeln('Migrate these UI strings to AppLocalizations/AppLocalizationsX before merging.');
  exitCode = 1;
}
