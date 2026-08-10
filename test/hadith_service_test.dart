import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurverse/services/hadith_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('today hadith loads from bundled assets', () async {
    expect(await rootBundle.loadString('assets/hadith/ben-bukhari.json'), isNotEmpty);

    final chapters = await HadithService.instance.getChapters('bukhari');
    expect(chapters, isNotEmpty);

    final hadiths = await HadithService.instance.getHadiths('bukhari', chapters.first.id);
    expect(hadiths, isNotEmpty);

    final hadith = await HadithService.instance.getTodayHadith();

    expect(hadith.hadithNo, isNotEmpty);
    expect(
      hadith.arabic.isNotEmpty || hadith.bangla.isNotEmpty || hadith.english.isNotEmpty,
      isTrue,
    );
  });
}
