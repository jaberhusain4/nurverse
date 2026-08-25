import csv
import json
import os
import re
import urllib.request
from pathlib import Path

BOOKS = ['bukhari', 'muslim', 'abudawud', 'tirmidhi', 'nasai', 'ibnmajah', 'malik']
SOURCE_BASE = os.environ.get(
    'SOURCE_BASE',
    'https://raw.githubusercontent.com/HsnSaboor/hadith-api-toon/main/editions',
)


def fetch_book(book: str) -> dict[str, dict[str, str]]:
    url = f'{SOURCE_BASE}/{book}/info.toon'
    with urllib.request.urlopen(url, timeout=60) as response:
        text = response.read().decode('utf-8')

    match = re.search(r'sections\[(\d+)\]\{([^}]+)\}:\s*\n(.*)', text, re.DOTALL)
    if not match:
        raise RuntimeError(f'No sections table found for {book}')

    columns = [x.strip() for x in match.group(2).split(',')]
    rows = []
    for line in match.group(3).splitlines():
        if not line.strip().startswith('"'):
            if rows:
                break
            continue
        parsed = next(csv.reader([line]))
        parsed += [''] * max(0, len(columns) - len(parsed))
        rows.append(dict(zip(columns, parsed)))

    catalog = {}
    for row in rows:
        section_id = row.get('id', '').strip()
        if not section_id.isdigit():
            continue
        title = {
            'ar': row.get('name_ar', '').strip(),
            'bn': row.get('name_bn', '').strip(),
            'en': row.get('name_en', '').strip(),
        }
        if not all(title.values()):
            raise RuntimeError(f'Missing multilingual title: {book} section {section_id}: {title}')
        catalog[section_id] = title

    if not catalog:
        raise RuntimeError(f'No chapter titles extracted for {book}')
    return catalog


def write_generated(catalogs: dict[str, dict[str, dict[str, str]]]) -> None:
    parts = [
        '// GENERATED FILE. DO NOT EDIT BY HAND.',
        '// Source: HsnSaboor/hadith-api-toon multilingual section metadata.',
        '',
        'class GeneratedHadithChapterMetadata {',
        '  const GeneratedHadithChapterMetadata._();',
        '',
        '  static const Map<String, Map<int, GeneratedHadithChapterTitle>> books = {',
    ]
    for book in BOOKS:
        parts.append(f"    '{book}': {{")
        for section_id, title in catalogs[book].items():
            parts.append(
                f"      {int(section_id)}: GeneratedHadithChapterTitle("
                f"ar: {json.dumps(title['ar'], ensure_ascii=False)}, "
                f"bn: {json.dumps(title['bn'], ensure_ascii=False)}, "
                f"en: {json.dumps(title['en'], ensure_ascii=False)}),"
            )
        parts.append('    },')
    parts += [
        '  };',
        '}',
        '',
        'class GeneratedHadithChapterTitle {',
        '  final String ar;',
        '  final String bn;',
        '  final String en;',
        '',
        '  const GeneratedHadithChapterTitle({',
        '    required this.ar,',
        '    required this.bn,',
        '    required this.en,',
        '  });',
        '}',
        '',
    ]
    Path('lib/services/generated_hadith_chapter_metadata.dart').write_text('\n'.join(parts), encoding='utf-8')


def wire_service() -> None:
    path = Path('lib/services/hadith_service.dart')
    text = path.read_text(encoding='utf-8')

    import_line = "import 'generated_hadith_chapter_metadata.dart';\n"
    if import_line not in text:
        text = text.replace(
            "import 'package:flutter/services.dart' show rootBundle;\n",
            "import 'package:flutter/services.dart' show rootBundle;\n\n" + import_line,
            1,
        )

    old = """    final chapters = _extractChapters(\n      arabic: arabic,\n      requested: requested,\n      english: english,\n      languageCode: language,\n    );\n\n    _chapterCache[cacheKey] = chapters;\n    return chapters;\n"""
    new = """    final extractedChapters = _extractChapters(\n      arabic: arabic,\n      requested: requested,\n      english: english,\n      languageCode: language,\n    );\n    final chapters = _applyCanonicalChapterMetadata(bookKey, extractedChapters);\n\n    _chapterCache[cacheKey] = chapters;\n    return chapters;\n"""
    if old in text:
        text = text.replace(old, new, 1)

    method = '''  List<HadithChapter> _applyCanonicalChapterMetadata(\n    String bookKey,\n    List<HadithChapter> chapters,\n  ) {\n    final catalog = GeneratedHadithChapterMetadata.books[bookKey];\n    if (catalog == null || catalog.isEmpty) return chapters;\n\n    final merged = <int, HadithChapter>{\n      for (final chapter in chapters) chapter.id: chapter,\n    };\n\n    for (final entry in catalog.entries) {\n      final existing = merged[entry.key];\n      final title = entry.value;\n      merged[entry.key] = HadithChapter(\n        id: entry.key,\n        bookNumber: existing?.bookNumber ?? 0,\n        nameAr: title.ar,\n        nameBn: title.bn,\n        nameEn: title.en,\n      );\n    }\n\n    final result = merged.values.toList();\n    result.sort((a, b) {\n      final byBook = a.bookNumber.compareTo(b.bookNumber);\n      if (byBook != 0) return byBook;\n      return a.id.compareTo(b.id);\n    });\n    return result;\n  }\n\n'''
    if '_applyCanonicalChapterMetadata(' not in text:
        marker = '  void _setName(_ChapterBuilder builder, String language, String name) {\n'
        text = text.replace(marker, method + marker, 1)

    path.write_text(text, encoding='utf-8')


if __name__ == '__main__':
    catalogs = {book: fetch_book(book) for book in BOOKS}
    write_generated(catalogs)
    wire_service()
    print('Generated chapter counts:', {book: len(catalogs[book]) for book in BOOKS})
