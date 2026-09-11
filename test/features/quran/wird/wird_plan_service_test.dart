import 'package:al_mubeen/features/quran/wird/domain/services/wird_plan_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WirdPlanService', () {
    test(
      'generates inclusive daily page ranges and never exceeds the Quran limit',
      () {
        final ranges = WirdPlanService.generateDailyRanges(
          startPage: 1,
          endPage: 604,
          pagesPerDay: 3,
        );

        expect(ranges.first.startPage, 1);
        expect(ranges.first.endPage, 3);
        expect(ranges.first.pageCount, 3);

        final lastRange = ranges.last;
        expect(lastRange.startPage, 604);
        expect(lastRange.endPage, 604);
        expect(lastRange.pageCount, 1);
        expect(ranges.length, 202);
      },
    );

    test('calculates the exact range for a specific day index', () {
      final range = WirdPlanService.resolveRangeForDay(
        startPage: 1,
        endPage: 604,
        pagesPerDay: 3,
        dayIndex: 4,
      );

      expect(range.startPage, 13);
      expect(range.endPage, 15);
      expect(range.pageCount, 3);
    });

    test('validates invalid range input', () {
      expect(
        () => WirdPlanService.validateRange(
          startPage: 0,
          endPage: 604,
          pagesPerDay: 3,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => WirdPlanService.validateRange(
          startPage: 10,
          endPage: 5,
          pagesPerDay: 3,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
