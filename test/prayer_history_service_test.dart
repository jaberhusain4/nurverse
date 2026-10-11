import 'package:flutter_test/flutter_test.dart';
import 'package:nurverse/services/prayer_history_service.dart';

void main() {
  final fajr = DateTime(2026, 10, 11, 4, 30);
  final sunrise = DateTime(2026, 10, 11, 5, 45);
  final dhuhr = DateTime(2026, 10, 11, 11, 50);
  final asr = DateTime(2026, 10, 11, 15, 15);
  final maghrib = DateTime(2026, 10, 11, 17, 45);
  final isha = DateTime(2026, 10, 11, 19, 5);
  final yesterdayIsha = DateTime(2026, 10, 10, 19, 5);

  PreviousPrayerInfo resolve(DateTime now) =>
      PrayerHistoryService.resolvePreviousPrayer(
        now: now,
        fajr: fajr,
        sunrise: sunrise,
        dhuhr: dhuhr,
        asr: asr,
        maghrib: maghrib,
        isha: isha,
        yesterdayIsha: yesterdayIsha,
      );

  group('Previous prayer history', () {
    test('shows yesterday Isha before Fajr and during Fajr', () {
      for (final now in [
        DateTime(2026, 10, 11, 2),
        DateTime(2026, 10, 11, 5),
      ]) {
        final previous = resolve(now);
        expect(previous.name, 'ইশা');
        expect(previous.time, yesterdayIsha);
        expect(previous.description, 'ইশা শেষ হয়েছে');
      }
    });

    test('switches to Fajr at sunrise', () {
      final previous = resolve(sunrise);
      expect(previous.name, 'ফজর');
      expect(previous.time, fajr);
      expect(previous.description, 'ফজর সম্পন্ন হয়েছে');
    });

    test('keeps Fajr as previous prayer during the Dhuhr interval', () {
      final previous = resolve(DateTime(2026, 10, 11, 13));
      expect(previous.name, 'ফজর');
      expect(previous.time, fajr);
      expect(previous.description, 'ফজর শেষ হয়েছে');
    });

    test('switches to Dhuhr at Asr start', () {
      final previous = resolve(asr);
      expect(previous.name, 'যোহর');
      expect(previous.time, dhuhr);
      expect(previous.description, 'যোহর শেষ হয়েছে');
    });

    test('switches to Asr at Maghrib start', () {
      final previous = resolve(maghrib);
      expect(previous.name, 'আসর');
      expect(previous.time, asr);
      expect(previous.description, 'আসর শেষ হয়েছে');
    });

    test('switches to Maghrib at Isha start', () {
      final previous = resolve(isha);
      expect(previous.name, 'মাগরিব');
      expect(previous.time, maghrib);
      expect(previous.description, 'মাগরিব শেষ হয়েছে');
    });

    test('preserves the previous prayer just before each boundary', () {
      expect(
        resolve(sunrise.subtract(const Duration(seconds: 1))).name,
        'ইশা',
      );
      expect(
        resolve(dhuhr.subtract(const Duration(seconds: 1))).name,
        'ফজর',
      );
      expect(
        resolve(asr.subtract(const Duration(seconds: 1))).name,
        'ফজর',
      );
      expect(
        resolve(maghrib.subtract(const Duration(seconds: 1))).name,
        'যোহর',
      );
      expect(
        resolve(isha.subtract(const Duration(seconds: 1))).name,
        'আসর',
      );
    });
  });
}
