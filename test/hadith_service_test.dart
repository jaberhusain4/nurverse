import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurverse/services/hadith_service.dart';

void main() {
  test('HadithService parses bundled-style assets', () async {
    final service = HadithService(assetBundle: _FixtureAssetBundle());

    final chapters = await service.getChapters(
      'fixture',
      languageCode: 'bn',
    );
    expect(chapters, isNotEmpty);

    final chapter = chapters.firstWhere((item) => item.id == 1);
    expect(chapter.nameBn, 'Sample Chapter');

    final hadiths = await service.getHadiths(
      'fixture',
      1,
      bookNumber: 1,
      languageCode: 'bn',
    );
    expect(hadiths, isNotEmpty);

    final hadith = hadiths.first;
    expect(hadith.hadithNo, '1');
    expect(hadith.arabic, isNotEmpty);
    expect(hadith.bangla, isNotEmpty);
    expect(hadith.english, isNotEmpty);
  });
}

class _FixtureAssetBundle extends AssetBundle {
  static const String _fixture = '''{
  "metadata": {
    "sections": {
      "1": "Sample Chapter"
    },
    "section_details": {
      "1": {
        "hadithnumber_first": 1,
        "hadithnumber_last": 1
      }
    }
  },
  "data": [
    {
      "hadithnumber": "1",
      "chapterId": 1,
      "bookNumber": 1,
      "chapterName": "Sample Chapter",
      "text": "Sample hadith text",
      "reference": "Bukhari 1",
      "grade": "Sahih"
    }
  ]
}''';

  @override
  Future<ByteData> load(String key) async {
    return ByteData.sublistView(
      Uint8List.fromList(utf8.encode(_fixture)),
    );
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _fixture;
  }
}
