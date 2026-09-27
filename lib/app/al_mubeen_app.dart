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
    final themeMode = ref.watch(
      appUserPreferencesProvider.select(
        (preferences) => preferences.maybeWhen(
          data: (value) => value.resolvedThemeMode,
          orElse: () => ThemeMode.system,
        ),
      ),
    );
    final fontScale = ref.watch(
      appUserPreferencesProvider.select(
        (preferences) => preferences.maybeWhen(
          data: (value) => value.fontScale,
          orElse: () => const AppUserPreferences.initial().fontScale,
        ),
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
        final safeFontScale = fontScale.clamp(0.55, 1.25).toDouble();
        final systemTextScale = mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.3);
        final combinedTextScale = (systemTextScale * safeFontScale).clamp(
          0.8,
          1.45,
        );

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
}
