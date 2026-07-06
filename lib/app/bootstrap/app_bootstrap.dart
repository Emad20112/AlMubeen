import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/home/presentation/home_page.dart';
import 'package:al_mubeen/features/onboarding/presentation/onboarding_screen.dart';
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
      loading: () => const _InitialLoading(),
      error: (error, stackTrace) {
        debugPrint(
          'AppBootstrap: preferences failed to load: $error\n$stackTrace',
        );
        return const HomePage();
      },
      data: (preferences) {
        if (!preferences.hasCompletedWelcome) {
          return const OnboardingScreen();
        }
        return const _AnimatedHome();
      },
    );
  }
}

class _InitialLoading extends StatelessWidget {
  const _InitialLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkScaffold : AppColors.parchment,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              color: AppColors.maroon800,
              size: 52,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.maroon800),
          ],
        ),
      ),
    );
  }
}

class _AnimatedHome extends StatefulWidget {
  const _AnimatedHome();

  @override
  State<_AnimatedHome> createState() => _AnimatedHomeState();
}

class _AnimatedHomeState extends State<_AnimatedHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: const HomePage(),
    );
  }
}
