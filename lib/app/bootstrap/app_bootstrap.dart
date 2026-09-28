import 'dart:async';

import 'package:al_mubeen/app/bootstrap/qcf_font_bootstrap.dart';
import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/hadith_nawawi/data/hadith_nawawi_providers.dart';
import 'package:al_mubeen/features/names_of_allah/data/names_of_allah_providers.dart';
import 'package:al_mubeen/features/onboarding/presentation/onboarding_screen.dart';
import 'package:al_mubeen/features/quran/application/quran_download_recovery_service.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_page_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qcf_quran/qcf_quran.dart';

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  bool _initialStartupScheduled = false;
  bool _startupScheduled = false;
  bool _deferredWarmUpsScheduled = false;
  bool _qcfWarmUpStarted = false;

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
        // 🛡️ FIX: حماية ضد إعادة الاستدعاء المكرر عند إعادة البناء (Rebuild)
        _scheduleInitialStartup(preferences);

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

  void _scheduleInitialStartup(AppUserPreferences preferences) {
    if (_initialStartupScheduled) return;
    _initialStartupScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ensureQcfWarmUpStarted();
      _scheduleStartupTasks();
    });
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
    // Step A: Recover pending downloads after UI stability
    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await QuranDownloadRecoveryService(
        ref,
      ).restorePendingDownloads(resumeDelay: const Duration(seconds: 3));
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint(
        'Startup pipeline: download recovery failed: $error\n$stackTrace',
      );
    }

    // Step B: Seed the default tafsir
    try {
      if (!mounted) return;
      await ref.read(defaultTafsirSeedServiceProvider).ensureSeeded();
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('Startup pipeline: tafsir seed failed: $error\n$stackTrace');
    }

    // Step C/D: Defer to idle time
    if (!mounted) return;
    _scheduleDeferredWarmUps();
  }

  void _ensureQcfWarmUpStarted() {
    if (_qcfWarmUpStarted) return;
    _qcfWarmUpStarted = true;

    unawaited(
      ref.read(qcfFontBootstrapProvider.notifier).start().catchError((
        error,
        stackTrace,
      ) {
        debugPrint('Startup pipeline: QCF warm-up failed: $error\n$stackTrace');
      }),
    );
  }

  void _scheduleDeferredWarmUps() {
    if (_deferredWarmUpsScheduled) return;
    _deferredWarmUpsScheduled = true;

    unawaited(
      SchedulerBinding.instance.scheduleTask<void>(
        () async {
          if (!mounted) return;
          await _warmUpReciters();
          if (!mounted) return;
          await _warmUpNamesOfAllah();
          if (!mounted) return;
          await _warmUpHadithNawawi();
        },
        Priority.idle,
        debugLabel: 'Deferred startup warm-ups',
      ),
    );
  }

  Future<void> _warmUpReciters() async {
    try {
      if (!mounted) return;
      await ref.read(quranRecitationsProvider.future);
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('Deferred warm-up: Reciters failed: $error\n$stackTrace');
    }
  }

  Future<void> _warmUpNamesOfAllah() async {
    try {
      if (!mounted) return;
      await ref.read(namesOfAllahLocalDataSourceProvider).warmUp();
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint(
        'Deferred warm-up: Names of Allah failed: $error\n$stackTrace',
      );
    }
  }

  Future<void> _warmUpHadithNawawi() async {
    try {
      if (!mounted) return;
      await ref.read(hadithNawawiLocalDataSourceProvider).warmUp();
    } catch (error, stackTrace) {
      if (!mounted) return;
      debugPrint('Deferred warm-up: Hadith Nawawi failed: $error\n$stackTrace');
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
            const Gap(24),
            const CircularProgressIndicator(color: AppColors.maroon800),
          ],
        ),
      ),
    );
  }
}

class _QuranLaunchShell extends ConsumerStatefulWidget {
  const _QuranLaunchShell({required this.initialPage});

  final int initialPage;

  @override
  ConsumerState<_QuranLaunchShell> createState() => _QuranLaunchShellState();
}

class _QuranLaunchShellState extends ConsumerState<_QuranLaunchShell>
    with SingleTickerProviderStateMixin {
  static const Duration _qcfGraceDuration = Duration(milliseconds: 900);
  static const Duration _heavyRenderDelay = Duration(milliseconds: 150);

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final int _initialPage;

  bool _renderHeavyQuran = false;
  bool _qcfGraceElapsed = false;

  Timer? _qcfGraceTimer;
  Timer? _heavyRenderTimer; // 🛡️ FIX: إدارة المؤقت لتفادي تسريب الذاكرة

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

    // 🛡️ FIX: استبدال Future.delayed بـ Timer آمن قابل للإلغاء
    _heavyRenderTimer = Timer(_heavyRenderDelay, () {
      if (mounted) {
        setState(() => _renderHeavyQuran = true);
      }
    });

    _qcfGraceTimer = Timer(_qcfGraceDuration, () {
      if (mounted) {
        setState(() => _qcfGraceElapsed = true);
      }
    });
  }

  @override
  void dispose() {
    // 🛡️ FIX: تنظيف كامل للمؤقتات والـ AnimationController
    _heavyRenderTimer?.cancel();
    _qcfGraceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qcfStatus = ref.watch(
      qcfFontBootstrapProvider.select((state) => state.status),
    );
    final canMountReader =
        qcfStatus == QcfFontBootstrapStatus.ready ||
        qcfStatus == QcfFontBootstrapStatus.failure ||
        _qcfGraceElapsed;

    final isReaderReady = _renderHeavyQuran && canMountReader;

    return FadeTransition(
      opacity: _fade,
      child: isReaderReady
          ? QuranPageReader(initialPage: _initialPage)
          : Scaffold(
              backgroundColor: isDark
                  ? AppColors.darkScaffold
                  : AppColors.parchment,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.maroon800,
                    ),
                  ),
                  // 🛡️ FIX: عزل الـ Probe وإزالته بمجرد جاهزية القارئ لمنع المعالجة الزائدة
                  if (!_renderHeavyQuran) const _QuranRenderWarmUpProbe(),
                ],
              ),
            ),
    );
  }
}

class _QuranRenderWarmUpProbe extends StatelessWidget {
  const _QuranRenderWarmUpProbe();

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: true,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SizedBox(width: 360, height: 640, child: QcfPage(pageNumber: 1)),
      ),
    );
  }
}
