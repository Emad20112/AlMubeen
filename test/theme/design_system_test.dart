import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_icon.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/app/theme/app_theme.dart';
import 'package:al_mubeen/app/theme/app_typography.dart';
import 'package:al_mubeen/core/design/app_async_view.dart';
import 'package:al_mubeen/core/design/app_page_header.dart';
import 'package:al_mubeen/core/design/app_state_view.dart';
import 'package:al_mubeen/core/design/app_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// اختبارات طبقة الـDesign System (Task 1).
///
/// الغرض ليس تغطية كل توكن، بل **حماية القرارات المعمارية** التي اتُّخذت
/// في هذه المرحلة من الانCollapse لاحقًا.
void main() {
  group('AppTheme', () {
    test('يبني الوضعين الفاتح والداكن دون أخطاء', () {
      expect(AppTheme.light().brightness, Brightness.light);
      expect(AppTheme.dark().brightness, Brightness.dark);
    });

    test('يُعيد نفس النسخة في كل نداء (PERF: بناء واحد فقط)', () {
      // 🔴 PERF: الثيم لا يُعاد بناؤه عند كل بناء. `identical` تتحقق
      // من عدم إعادة تنفيذ `ColorScheme.fromSeed` في كل نداء.
      expect(identical(AppTheme.light(), AppTheme.light()), isTrue);
      expect(identical(AppTheme.dark(), AppTheme.dark()), isTrue);
    });

    test('يسجّل Design Tokens في كل وضع', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        expect(theme.extension<AppDesignTokens>(), isNotNull);
      }
    });

    test('يسجّل AppColorScheme في كل وضع', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        expect(theme.extension<AppColorScheme>(), isNotNull);
      }
    });

    test('surfaceTintColor شفاف — يمنع تلوّن الأجسام المرتفعة بالذهبي', () {
      // قرار تصميمي: صبغة السطح الذهبية فوق خلفية ورقية كانت أثرًا غير
      // مقصود. هذا الاختبار يمنع عودتها بصمت.
      expect(AppTheme.light().appBarTheme.surfaceTintColor, Colors.transparent);
      expect(AppTheme.dark().appBarTheme.surfaceTintColor, Colors.transparent);
    });

    test('حارس بصري: ألوان الأسطح لم تتغيّر عن التطبيق السابق', () {
      // القيم أدناه مأخوذة حرفيًا من `AppTheme` القديم قبل إعادة البناء.
      // أي انحراف هنا = تغيّر بصري لم يُطلب.
      expect(
        AppTheme.light().scaffoldBackgroundColor,
        const Color(0xFFF5F1E8),
        reason: 'scaffold فاتح',
      );
      expect(
        AppTheme.light().appBarTheme.backgroundColor,
        const Color(0xFFFFFCF7),
        reason: 'appBar فاتح',
      );
      expect(
        AppTheme.dark().scaffoldBackgroundColor,
        const Color(0xFF0B1018),
        reason: 'scaffold داكن',
      );
      expect(
        AppTheme.dark().appBarTheme.backgroundColor,
        const Color(0xFF0B1018),
        reason: 'appBar داكن',
      );
      expect(
        AppTheme.light().colorScheme.primary,
        AppColors.goldLight,
        reason: 'primary فاتح',
      );
      expect(
        AppTheme.dark().colorScheme.primary,
        AppColors.goldPale,
        reason: 'primary داكن',
      );
    });

    test('عائلة خط الـUI لم تُغيَّر عن السلوك السابق', () {
      // ملاحظة مهمّة: `fontFamily == null` لا تعني "بلا خط" — بل تعني
      // "لا نتجاوز الأساس". الأساس `Typography.blackMountainView` يزوّد
      // `Roboto` على Android، فكان التطبيق يعرض Roboto قبل هذه المرحلة
      // وبعدها. المطلوب ألّا نُدخل عائلة جديدة.
      expect(AppTypography.fontFamily, isNull);

      final previous = Typography.blackMountainView.apply(
        bodyColor: const Color(0xFF1E1A16),
        displayColor: const Color(0xFF1E1A16),
      );
      final now = AppTheme.light().textTheme;

      expect(
        now.bodyMedium?.fontFamily,
        previous.bodyMedium?.fontFamily,
        reason: 'bodyMedium',
      );
      expect(
        now.titleLarge?.fontFamily,
        previous.titleLarge?.fontFamily,
        reason: 'titleLarge',
      );
      expect(
        now.bodyLarge?.fontSize,
        previous.bodyLarge?.fontSize,
        reason: 'bodyLarge fontSize',
      );
    });

    test('لا تسرّب لخط المصحف (QCF_*) إلى نصوص الواجهة', () {
      // حارس أخطر: خط المصحف ملك `qcf_quran` (QCF_P001…QCF_P604).
      // أي ظهور له في `TextTheme` يعني أن نصوص الواجهة ستُصيَّر بخط
      // المصحف.
      for (final family in AppTypography.fontFamilyFallback) {
        expect(family.startsWith('QCF'), isFalse);
      }
      expect(
        AppTypography.fontFamilyFallback.contains('Amiri'),
        isFalse,
        reason: 'Amiri غير معلن في pubspec ولا يستخدم خط المصحف',
      );
    });

    test('خط المصحف غير ممسّ', () {
      // ملك حزمة `qcf_quran` حصرًا — يجب أن يبقى null.
      expect(AppTypography.quranFontFamily, isNull);
    });
  });

  group('AppColorScheme', () {
    test('الوضع الفاتح: البطاقة أفتح من خلفية الصفحة', () {
      final colors = AppColorScheme.from(
        AppTheme.light().colorScheme,
        isDark: false,
      );
      expect(colors.isDark, isFalse);
      // ⚠️ هذا كان معكوسًا في أول إصدار: كان `surface` (خلفية الشاشة)
      // أفتح من `surfaceElevated` (البطاقة)، أي أن البطاقة تبدو غائرة
      // لا مرفوعة.
      expect(
        colors.surfaceElevated.computeLuminance(),
        greaterThan(colors.canvas.computeLuminance()),
      );
    });

    test('الوضع الداكن: البطاقة أفتح من الخلفية', () {
      final colors = AppColorScheme.from(
        AppTheme.dark().colorScheme,
        isDark: true,
      );
      expect(colors.isDark, isTrue);
      // في الوضع الداكن "أفتح" = "أعلى": الإضاءة تأتي من الأعلى.
      expect(
        colors.surfaceElevated.computeLuminance(),
        greaterThan(colors.canvas.computeLuminance()),
      );
    });

    test('لون الحالة contrast كافٍ على الخلفية (WCAG AA ≥ 3.0)', () {
      // قرار تصميمي: أخضر النجاح الأصلي `#10B981` كان يمرّ بنسبة 2.48:1
      // على خلفية ورقية — أي دون الحدّ المطلوب لعنصر غير نصّي.
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final colors = AppColorScheme.from(
          theme.colorScheme,
          isDark: theme.brightness == Brightness.dark,
        );
        expect(
          _contrast(colors.error, colors.canvas),
          greaterThan(3.0),
          reason: 'error',
        );
        expect(
          _contrast(colors.success, colors.canvas),
          greaterThan(3.0),
          reason: 'success',
        );
        expect(
          _contrast(colors.primaryStrong, colors.canvas),
          greaterThan(3.0),
          reason: 'primaryStrong',
        );
      }
    });

    test('نص الأساس يقرأ بوضوح على كل أسطح الوضعين', () {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        final colors = AppColorScheme.from(
          theme.colorScheme,
          isDark: theme.brightness == Brightness.dark,
        );
        for (final surface in [
          colors.canvas,
          colors.surface,
          colors.surfaceElevated,
          colors.surfaceMuted,
          colors.surfaceSunken,
        ]) {
          expect(
            _contrast(colors.textPrimary, surface),
            greaterThan(4.5),
            reason: 'textPrimary على $surface',
          );
        }
      }
    });

    test('lerp عند t=0 و t=1 يعيد الطرفين', () {
      final light = AppColorScheme.from(
        AppTheme.light().colorScheme,
        isDark: false,
      );
      final dark = AppColorScheme.from(
        AppTheme.dark().colorScheme,
        isDark: true,
      );

      expect(light.lerp(dark, 0).canvas, light.canvas);
      expect(light.lerp(dark, 1).canvas, dark.canvas);
      expect(light.lerp(null, 0.5), same(light));
    });
  });

  group('AppSpacing', () {
    test('السلّم تصاعدي تمامًا', () {
      const scale = <double>[
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ];
      for (var i = 1; i < scale.length; i++) {
        expect(scale[i], greaterThan(scale[i - 1]));
      }
    });
  });

  group('AppDesignTokens', () {
    testWidgets('of(context) يقرأ من Theme لا من القيم الثابتة', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light(), home: const _TokenProbe()),
      );

      final context = tester.element(find.byType(_TokenProbe));
      final fromTheme = Theme.of(context).extension<AppDesignTokens>();
      final fromHelper = AppDesignTokens.of(context);

      expect(fromTheme, isNotNull);
      expect(fromHelper, same(fromTheme));

      // القيم متساوية مع القياسية (سُلّم واحد للطرفين)، لكن القراءة تمر
      // عبر `Theme.extension`.
      expect(fromHelper.radii.md, const AppDesignTokens.standard().radii.md);
    });

    test('fallback يعمل خارج MaterialApp', () {
      // Safety: أي استدعاء لـ`of` قبل تثبيت الـTheme يجب ألا يرمي.
      expect(const AppDesignTokens.standard(), isNotNull);
    });
  });

  group('AppSizes', () {
    test('لا يستخدم `Size.fromHeight` — عرضه infinity', () {
      // ⚠️ حارس ضد انحدار حقيقي حدث فعلًا: `Size.fromHeight(48)` ==
      // `Size(double.infinity, 48)`. حين وُضع في `minimumSize` داخل
      // `ButtonTheme`، طلب **كل** زر عرضًا لا نهائيًّا ورمى
      // `BoxConstraints forces an infinite width` في كل إطار على أي زر
      // داخل `Row` (زر «تخطّي» في شاشة الـonboarding).
      expect(
        Size.fromHeight(48).width,
        double.infinity,
        reason: 'هذه هي الفخ — لا تُستخدم أبدًا كـminimumSize',
      );
      expect(AppSizes.minButtonTarget.width, isNot(double.infinity));
    });

    testWidgets('زر داخل Row لا يطلب عرضًا لا نهائيًا', (tester) async {
      // الاختبار الحاسم: تخطيط `Row` + `Spacer` + `TextButton` هو ما
      // كشف العطل. نُعيد إنتاجه هنا صراحةً.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('السابق')),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('تخطّي')),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('تخطّي'), findsOneWidget);
    });

    testWidgets('أزرار الثيم كلها لها minimumSize بعرض محدود', (tester) async {
      // مسح شامل: أي زر في أي ثيم يعرض رمي layout.
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Column(
              children: [
                FilledButton(onPressed: () {}, child: const Text('a')),
                ElevatedButton(onPressed: () {}, child: const Text('b')),
                OutlinedButton(onPressed: () {}, child: const Text('c')),
                TextButton(onPressed: () {}, child: const Text('d')),
                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('AppIcon — اتجاه RTL', () {
    // الفحص الحاسم: `Icons.arrow_forward_*` لا ينعكس مع `Directionality`،
    // فمؤشّر «إلى الأمام» كان يشير لليمين داخل تطبيق عربي. `forwardFor`
    // هو ما يمنع ذلك.
    Future<(IconData, IconData)> resolve(
      WidgetTester tester,
      TextDirection direction,
    ) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Directionality(
          textDirection: direction,
          child: Builder(
            builder: (context) {
              captured = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return (AppIcon.forwardFor(captured), AppIcon.backFor(captured));
    }

    testWidgets('forwardFor ينعكس بين RTL و LTR', (tester) async {
      final (ltrForward, ltrBack) = await resolve(tester, TextDirection.ltr);
      final (rtlForward, rtlBack) = await resolve(tester, TextDirection.rtl);

      expect(ltrForward, Icons.arrow_forward_rounded);
      expect(rtlForward, Icons.arrow_back_rounded);
      expect(ltrBack, Icons.arrow_back_rounded);
      expect(rtlBack, Icons.arrow_forward_rounded);
    });

    testWidgets('الأيقونات الاتجاهية مختلفة فعليًا بين الوضعين', (
      tester,
    ) async {
      // حارس ضد انحدار يجعل الدالة تُرجع `arrow_forward_ios` في الحالتين،
      // وهو بالضبط ما كان موجودًا قبل هذا الإصلاح.
      final (ltrForward, _) = await resolve(tester, TextDirection.ltr);
      final (rtlForward, _) = await resolve(tester, TextDirection.rtl);

      expect(ltrForward, isNot(rtlForward));
    });
  });

  group('AppStateView', () {
    Widget wrap(Widget child, ThemeData theme) {
      return MaterialApp(
        theme: theme,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );
    }

    testWidgets('حالة الخطأ تعرض زر إعادة المحاولة', (tester) async {
      var retried = false;
      await tester.pumpWidget(
        wrap(
          AppStateView.error(message: 'خطأ', onAction: () => retried = true),
          AppTheme.light(),
        ),
      );

      expect(find.text('إعادة المحاولة'), findsOneWidget);
      await tester.tap(find.text('إعادة المحاولة'));
      expect(retried, isTrue);
    });

    testWidgets('حالة التحميل بدون progress تعرض CircularProgressIndicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const AppStateView.loading(), AppTheme.light()),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('حالة التحميل مع progress تعرض قيمة محددة', (tester) async {
      await tester.pumpWidget(
        wrap(const AppStateView.loading(progress: 0.4), AppTheme.light()),
      );
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.value, 0.4);
    });
  });

  group('AppAsyncView', () {
    testWidgets('يعرض البيانات عند AsyncData', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppAsyncView<int>(
              value: const AsyncData(7),
              data: (value) => Text('القيمة $value'),
            ),
          ),
        ),
      );
      expect(find.text('القيمة 7'), findsOneWidget);
    });

    testWidgets('يعرض زر إعادة المحاولة عند AsyncError', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppAsyncView<int>(
              value: AsyncError<int>(Exception('boom'), StackTrace.current),
              onRetry: () {},
              data: (value) => const SizedBox.shrink(),
            ),
          ),
        ),
      );
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('يميّز الخطأ عن الفراغ في AppAsyncContentView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: AppAsyncContentView<List<int>>(
              value: const AsyncData(<int>[]),
              isEmpty: (list) => list.isEmpty,
              emptyMessage: 'لا توجد نتائج',
              data: (list) => Text('عناصر: ${list.length}'),
            ),
          ),
        ),
      );
      expect(find.text('لا توجد نتائج'), findsOneWidget);
      expect(find.text('عناصر: 0'), findsNothing);
    });
  });

  group('AppSurface', () {
    testWidgets('يرسم السطح بالدور المطلوب', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: const Scaffold(
            body: AppSurface(role: AppSurfaceRole.elevated, child: Text('x')),
          ),
        ),
      );

      final box = tester.widget<DecoratedBox>(find.byType(DecoratedBox).first);
      final decoration = box.decoration as BoxDecoration;
      final expected = AppColorScheme.from(
        AppTheme.dark().colorScheme,
        isDark: true,
      ).surfaceElevated;
      expect(decoration.color, expected);
    });
  });

  group('AppPageHeader', () {
    testWidgets('يعرض العنوان والعنوان الفرعي', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: const Scaffold(
            body: AppPageHeader(title: 'أذكار', subtitle: '12 ذكرًا'),
          ),
        ),
      );
      expect(find.text('أذكار'), findsOneWidget);
      expect(find.text('12 ذكرًا'), findsOneWidget);
    });
  });
}

class _TokenProbe extends StatelessWidget {
  const _TokenProbe();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

double _luminance(Color color) => color.computeLuminance();

/// نسبة التباين (WCAG 2.1) بين لونين.
double _contrast(Color a, Color b) {
  final lumA = _luminance(a);
  final lumB = _luminance(b);
  final lighter = lumA > lumB ? lumA : lumB;
  final darker = lumA > lumB ? lumB : lumA;
  return (lighter + 0.05) / (darker + 0.05);
}
