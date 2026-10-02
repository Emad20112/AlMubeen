import 'package:al_mubeen/core/design/app_design_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// اختبارات شبكة أمان الإنتاج.
///
/// `kReleaseMode == false` أثناء `flutter test`، لذا لا يمكن اختبار
/// `installReleaseErrorWidget` مباشرةً. لذلك نختبر الدالة التي يثبّتها
/// عبرها: [buildReleaseErrorScreen].
void main() {
  group('buildReleaseErrorScreen', () {
    testWidgets('تُبنى بلا استثناء وتعرض رسالة عربية', (tester) async {
      // ⚠️ هذا هو الفحص الحقيقي: البناء خارج `MaterialApp` لا يوجد في
      // التطبيق، فإذا احتاج `Theme`/`Directionality` ضمنًا لرنمت
      // الشاشة فسنكتشفه هنا. هذا ما كان وما سيبقى مع `ErrorWidget` الخام.
      await tester.pumpWidget(
        buildReleaseErrorScreen(
          FlutterErrorDetails(exception: Exception('boom')),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('تعذّر عرض هذا الجزء من الشاشة'), findsOneWidget);
    });

    testWidgets('محتواها RTL', (tester) async {
      await tester.pumpWidget(
        buildReleaseErrorScreen(
          FlutterErrorDetails(exception: Exception('boom')),
        ),
      );

      final directionality = tester.widget<Directionality>(
        find
            .ancestor(
              of: find.byType(AppStateView),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
    });

    testWidgets('لا يعرض زر إعادة محاولة ميتًا', (tester) async {
      // عند فشل `build` لا نعرف أي شجرة تالفة، فأي زر "إعادة المحاولة"
      // سيكون مضللًا. الفحص يمنع عودة زر بلا وظيفة.
      await tester.pumpWidget(
        buildReleaseErrorScreen(
          FlutterErrorDetails(exception: Exception('boom')),
        ),
      );

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('يبني وودجت صالحًا', (tester) async {
      final widget = buildReleaseErrorScreen(
        FlutterErrorDetails(exception: Exception('boom')),
      );
      expect(widget, isA<Widget>());
    });
  });
}
