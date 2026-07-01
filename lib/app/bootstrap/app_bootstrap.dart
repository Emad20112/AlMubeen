import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/core/widgets/app_loading_view.dart';
import 'package:al_mubeen/features/home/presentation/home_page.dart';
import 'package:al_mubeen/features/onboarding/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  @override
  Widget build(BuildContext context) {
    final preferencesAsync = ref.watch(appUserPreferencesProvider);

    return preferencesAsync.when(
      loading: () => const AppLoadingView(
        title: 'نُجهّز صفحتك',
        message: 'نحمّل التفضيلات ونعدّ الموارد الأساسية بهدوء.',
        progress: 0.6,
      ),
      error: (error, stackTrace) {
        debugPrint(
          'AppBootstrap: preferences failed to load: $error\n$stackTrace',
        );
        return const HomePage();
      },
      data: (preferences) {
        if (!preferences.hasCompletedWelcome) {
          return const WelcomeScreen();
        }

        return const HomePage();
      },
    );
  }
}
