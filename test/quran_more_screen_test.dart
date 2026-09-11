import 'package:al_mubeen/features/quran/presentation/pages/quran_more_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'tapping the daily wird action triggers the reader action after the more screen closes',
    (tester) async {
      var actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QuranMoreScreen(
                            readerActions: QuranReaderMoreActions(
                              currentPage: 1,
                              onSearch: () {},
                              onSurahPicker: () {},
                              onBookmarks: () {},
                              onSettings: () {},
                              onWird: () => actionCalled = true,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open more'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open more'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ورد القرآن'));
      await tester.pump();

      expect(actionCalled, isTrue);
    },
  );
}
