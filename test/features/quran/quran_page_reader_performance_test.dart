import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_page_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePreferencesStore extends AppUserPreferencesStore {
  _FakePreferencesStore() : super();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget({int initialPage = 1, AyahRef? initialHighlight}) {
    return ProviderScope(
      overrides: [
        appUserPreferencesStoreProvider.overrideWithValue(
          _FakePreferencesStore(),
        ),
      ],
      child: MaterialApp(
        home: QuranPageReader(
          initialPage: initialPage,
          initialHighlight: initialHighlight,
        ),
      ),
    );
  }

  group('QuranPageReader Widget Performance & Overlay Tests', () {
    testWidgets(
      'Renders page reader and toggles overlay without animation leaks',
      (tester) async {
        await tester.pumpWidget(createTestWidget(initialPage: 1));
        await tester.pumpAndSettle();

        // Verify widget rendered
        expect(find.byType(QuranPageReader), findsOneWidget);

        // Repeatedly tap to trigger _toggleOverlay forward & reverse 10 times
        for (int i = 0; i < 10; i++) {
          await tester.tap(
            find.byType(GestureDetector).first,
            warnIfMissed: false,
          );
          await tester.pump(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 200));
          await tester.pumpAndSettle();
        }

        // No memory leaks, exceptions, or unhandled tickers
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Disposes cleanly during active animation without throwing exception',
      (tester) async {
        await tester.pumpWidget(createTestWidget(initialPage: 1));
        await tester.pumpAndSettle();

        // Trigger animation start
        await tester.tap(
          find.byType(GestureDetector).first,
          warnIfMissed: false,
        );
        await tester.pump(const Duration(milliseconds: 50)); // Mid-flight!

        // Immediately replace widget tree to trigger dispose() while animating
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: Text('Done'))),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      },
    );
  });
}
