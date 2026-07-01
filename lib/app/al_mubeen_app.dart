import 'package:al_mubeen/app/routing/app_router.dart';
import 'package:al_mubeen/app/theme/app_theme.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlMubeenApp extends ConsumerWidget {
  const AlMubeenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(appUserPreferencesProvider);
    final themeMode = preferences.maybeWhen(
      data: (preferences) => preferences.resolvedThemeMode,
      orElse: () => ThemeMode.system,
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
        final fontScale = preferences
            .maybeWhen(
              data: (settings) => settings.fontScale,
              orElse: () => 1.0,
            )
            .clamp(0.9, 1.25)
            .toDouble();
        final combinedTextScale = mediaQuery.textScaler.scale(1.0) * fontScale;

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
