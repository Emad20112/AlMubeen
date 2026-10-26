import 'package:al_mubeen/app/routing/app_router.dart';
import 'package:al_mubeen/app/theme/app_theme.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlMubeenApp extends ConsumerWidget {
  const AlMubeenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🛡️ PERF: نراقب فقط الحقول التي يحتاجها MaterialApp (themeMode + fontScale).
    // سابقاً كان `ref.watch(appUserPreferencesProvider)` يعيد بناء الشجرة
    // بالكامل عند أي تغيير في أي تفضيل (مثل حفظ آخر صفحة قرآن كل 900ms).
    // ⚙️ Dart 3: نستخدم switch expressions بدلاً من maybeWhen (غير متوفر بدون Freezed).
    final themeMode = ref.watch(
      appUserPreferencesProvider.select(
        (preferences) => switch (preferences) {
          AsyncData(:final value) => value.resolvedThemeMode,
          _ => ThemeMode.system,
        },
      ),
    );
    final fontScale = ref.watch(
      appUserPreferencesProvider.select(
        (preferences) => switch (preferences) {
          AsyncData(:final value) => value.fontScale,
          _ => const AppUserPreferences.initial().fontScale,
        },
      ),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Al-Mubeen',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);

        // 🔎 البند 1.1.3 من خطة إعادة الهيكلة: **لا نلتهم مقياس خط النظام**.
        //
        // كان الكود يقصّ مقياس النظام إلى `0.8–1.3` ثم يضربه في تفضيل
        // التطبيق ويقصّ الناتج إلى `0.8–1.45`. يعني أن مستخدمًا ضبط خط
        // الجهاز على 200% (حدّ accessibility) كان يرى 145% فقط — أي أن
        // ميزة تكبير الخط كانت **معطّلة عمليًا** في أكثر الحالات حرجًا.
        //
        // السلوك الحالي:
        //   1. مقياس النظام يُمرَّر كما هو (بلا قص أقصى).
        //   2. تفضيل «حجم خط التطبيق» مُضاعِف إضافي فوقه، محصور في `0.55–1.25`
        //      حتى لا ينتج عن مستخدم يكبّر الجهاز *ويكبّر التطبيق* أيضًا نص
        //      يفوق ثلاث أضعاف الحجم الأساسي فينكسر التخطيط.
        //   3. حدّ أعلى دفاعي `maxEffectiveTextScale` يرفع سنام التخطيط من
        //      الانفجار، وليس من ميزة تكبير الخط.
        //
        // أدوات القياس في شاشات المصحف (أحجام الخط داخل المصحف) تبقى مستقلة
        // تمامًا عن هذا المقياس لأنها تُدار يدويًا في `AutoScrollText`.
        final appScale = fontScale.clamp(0.55, 1.25).toDouble();
        final systemScaler = mediaQuery.textScaler;
        final combinedTextScale = (systemScaler.scale(1.0) * appScale)
            .clamp(0.55, maxEffectiveTextScale)
            .toDouble();

        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(combinedTextScale),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  /// الحدّ الأعلى الفعّال لمقياس النص (مقياس النظام × مقياس التطبيق).
  ///
  /// `2.0` = ضعف الحجم الأساسي، وهو السقف الذي تختبره إرشادات Android
  /// للوصول (وضع «كبير جدًا» يُنتج قرابة 1.3–1.5، و200% يُنتج 2.0).
  /// القصّ هنا **دفاعي فقط** ضد تركيبة «نظام 2.0 × تطبيق 1.25».
  static const double maxEffectiveTextScale = 2.0;
}
