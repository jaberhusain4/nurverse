class QuranSurahMetadata {
  final int rukuCount;
  final int sajdaCount;

  const QuranSurahMetadata({
    required this.rukuCount,
    required this.sajdaCount,
  });
}

class QuranMetadataService {
  const QuranMetadataService._();

  static const _ruku = <int>[
    7, 7, 20, 24, 16, 20, 24, 10, 16, 11, 10, 12, 6, 7, 6, 16,
    8, 7, 6, 8, 7, 10, 6, 9, 6, 8, 9, 7, 6, 6, 3, 3, 6, 6, 5, 5,
    5, 5, 5, 4, 5, 3, 4, 4, 4, 4, 3, 4, 3, 2, 2, 3, 2, 3, 3, 3,
    3, 4, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  ];

  static const _sajda = <int, int>{
    7: 1,
    13: 1,
    16: 1,
    17: 1,
    19: 1,
    22: 2,
    25: 1,
    27: 1,
    32: 1,
    38: 1,
    41: 1,
    53: 1,
    84: 1,
    96: 1,
  };

  static QuranSurahMetadata forSurah(int number) {
    final index = number.clamp(1, 114).toInt() - 1;
    return QuranSurahMetadata(
      rukuCount: _ruku[index],
      sajdaCount: _sajda[number] ?? 0,
    );
  }
}
