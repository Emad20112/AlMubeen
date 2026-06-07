import 'package:al_mubeen/app/theme/app_theme.dart';
import 'package:al_mubeen/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page renders primary Quran card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const HomePage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('قراءة القرآن الكريم', skipOffstage: false),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('أسماء سور القرآن', skipOffstage: false), findsNothing);
  });
}
