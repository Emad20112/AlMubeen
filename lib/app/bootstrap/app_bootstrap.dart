import 'dart:async';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/hadith_nawawi/data/hadith_nawawi_providers.dart';
import 'package:al_mubeen/features/names_of_allah/data/names_of_allah_providers.dart';
import 'package:al_mubeen/features/quran/application/quran_download_recovery_service.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_page_reader.dart';
import 'package:al_mubeen/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  bool _startupScheduled = false;

  @override
  Widget build(BuildContext context) {
    final preferencesAsync = ref.watch(appUserPreferencesProvider);

    return preferencesAsync.when(
      loading: () => const _InitialLoading(),
      error: (error, stackTrace) {
        debugPrint(
          'AppBootstrap: preferences failed to load: $error\n$stackTrace',
        );
        return const _QuranLaunchShell(initialPage: 1);
      },
      data: (preferences) {
        _scheduleStartupTasks();
        if (!preferences.hasCompletedWelcome) {
          return const OnboardingScreen();
        }
        final initialPage = preferences.autoContinueFromLastPosition
            ? (preferences.lastQuranPage ?? 1)
            : 1;
        return _QuranLaunchShell(initialPage: initialPage);
      },
    );
  }

  void _scheduleStartupTasks() {
    if (_startupScheduled) return;
    _startupScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runSequentialStartupPipeline();
    });
  }

  Future<void> _runSequentialStartupPipeline() async {
    // Step A: Recover pending downloads (after 2 seconds of stability).
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await QuranDownloadRecoveryService(
        ref,
      ).restorePendingDownloads(resumeDelay: const Duration(seconds: 3));
    } catch (error, stackTrace) {
      debugPrint('Startup pipeline: download recovery failed: $error');
      debugPrint('$stackTrace');
    }

    // Step B: Seed the default tafsir (heaviest operation).
    try {
      if (!mounted) return;
      await ref.read(defaultTafsirSeedServiceProvider).ensureSeeded();
    } catch (error, stackTrace) {
      debugPrint('Startup pipeline: tafsir seed failed: $error');
      debugPrint('$stackTrace');
    }

    // Step C: Warm up Names of Allah.
    try {
      if (!mounted) return;
      await ref.read(namesOfAllahLocalDataSourceProvider).warmUp();
    } catch (error, stackTrace) {
      debugPrint('Startup pipeline: Names of Allah warm-up failed: $error');
      debugPrint('$stackTrace');
    }

    // Step D: Warm up Hadith Nawawi.
    try {
      if (!mounted) return;
      await ref.read(hadithNawawiLocalDataSourceProvider).warmUp();
    } catch (error, stackTrace) {
      debugPrint('Startup pipeline: Hadith Nawawi warm-up failed: $error');
      debugPrint('$stackTrace');
    }
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
            Icon(Icons.menu_book_rounded, color: AppColors.maroon800, size: 52),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: AppColors.maroon800),
          ],
        ),
      ),
    );
  }
}

class _QuranLaunchShell extends StatefulWidget {
  const _QuranLaunchShell({required this.initialPage});

  @override
  State<_QuranLaunchShell> createState() => _QuranLaunchShellState();

  final int initialPage;
}

class _QuranLaunchShellState extends State<_QuranLaunchShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final int _initialPage;
  bool _renderHeavyQuran = false;

  @override
  void initState() {
    super.initState();
    _initialPage = widget.initialPage;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();

    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() => _renderHeavyQuran = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fade,
      child: _renderHeavyQuran
          ? QuranPageReader(initialPage: _initialPage)
          : Scaffold(
              backgroundColor: isDark
                  ? AppColors.darkScaffold
                  : AppColors.parchment,
              body: const Center(
                child: CircularProgressIndicator(color: AppColors.maroon800),
              ),
            ),
    );
  }
}
