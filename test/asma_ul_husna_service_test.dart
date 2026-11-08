import 'package:flutter_test/flutter_test.dart';
import 'package:nurverse/services/asma_ul_husna_service.dart';

void main() {
  const service = AsmaUlHusnaService();

  group('Asma ul Husna dataset', () {
    test('contains all 99 sequentially numbered names', () {
      final names = service.getAll();

      expect(names, hasLength(99));
      expect(names.map((name) => name.id).toList(),
          List<int>.generate(99, (index) => index + 1));
      expect(names.every((name) =>
          name.arabic.isNotEmpty &&
          name.transliteration.isNotEmpty &&
          name.meaning.isNotEmpty), isTrue);
    });

    test('looks up names by their stable 1-based ID', () {
      expect(service.byId(1)?.transliteration, 'আর-রহমান');
      expect(service.byId(99)?.transliteration, 'আস-সবূর');
      expect(service.byId(0), isNull);
      expect(service.byId(100), isNull);
    });

    test('searches Bengali transliteration and meaning', () {
      expect(service.search('রহমান').single.id, 1);
      expect(service.search('পরম ধৈর্যশীল').single.id, 99);
      expect(service.search('not-a-name'), isEmpty);
    });

    test('returns a valid daily name', () {
      final daily = service.dailyName;
      expect(daily.id, inInclusiveRange(1, 99));
    });
  });
}
