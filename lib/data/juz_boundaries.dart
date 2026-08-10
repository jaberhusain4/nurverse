/// Standard 30-Juz (Para) boundaries of the Quran.
/// Each entry is (juzNumber, startSurah, startAyah).
/// This is fixed structural data (the same in every printed Mushaf),
/// not translated/interpreted content.
class JuzBoundary {
  final int juz;
  final int surah;
  final int ayah;
  const JuzBoundary(this.juz, this.surah, this.ayah);
}

const List<JuzBoundary> kJuzBoundaries = [
  JuzBoundary(1, 1, 1),
  JuzBoundary(2, 2, 142),
  JuzBoundary(3, 2, 253),
  JuzBoundary(4, 3, 93),
  JuzBoundary(5, 4, 24),
  JuzBoundary(6, 4, 148),
  JuzBoundary(7, 5, 82),
  JuzBoundary(8, 6, 111),
  JuzBoundary(9, 7, 88),
  JuzBoundary(10, 8, 41),
  JuzBoundary(11, 9, 93),
  JuzBoundary(12, 11, 6),
  JuzBoundary(13, 12, 53),
  JuzBoundary(14, 15, 1),
  JuzBoundary(15, 17, 1),
  JuzBoundary(16, 18, 75),
  JuzBoundary(17, 21, 1),
  JuzBoundary(18, 23, 1),
  JuzBoundary(19, 25, 21),
  JuzBoundary(20, 27, 56),
  JuzBoundary(21, 29, 46),
  JuzBoundary(22, 33, 31),
  JuzBoundary(23, 36, 28),
  JuzBoundary(24, 39, 32),
  JuzBoundary(25, 41, 47),
  JuzBoundary(26, 46, 1),
  JuzBoundary(27, 51, 31),
  JuzBoundary(28, 58, 1),
  JuzBoundary(29, 67, 1),
  JuzBoundary(30, 78, 1),
];
