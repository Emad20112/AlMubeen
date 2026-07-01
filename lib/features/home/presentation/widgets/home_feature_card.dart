import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/auto_scroll_text.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_feature.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_page_reader.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_surah_player_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeFeatureCard extends ConsumerWidget {
  const HomeFeatureCard({required this.feature, super.key});

  final HomeFeature feature;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textScaler = MediaQuery.textScalerOf(context);

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => _handleTap(context, ref),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.parchmentLight,
                  Color(0xFFF2EDDF),
                  AppColors.parchmentMuted,
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.maroon700.withValues(
                  alpha: feature.isImportant ? 0.92 : 0.72,
                ),
                width: feature.isImportant ? 1.4 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon900.withValues(
                    alpha: feature.isImportant ? 0.34 : 0.28,
                  ),
                  blurRadius: (feature.isImportant ? 14.0 : 8.0),
                  offset: Offset(0, (feature.isImportant ? 7.0 : 5.0)),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.maroon800.withValues(alpha: 0.92),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Icon(
                            feature.icon,
                            color: AppColors.maroon800,
                            size: textScaler
                                .scale(feature.isImportant ? 44.0 : 34.0)
                                .clamp(
                                  feature.isImportant ? 38.0 : 30.0,
                                  feature.isImportant ? 58.0 : 46.0,
                                )
                                .toDouble(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Flexible(
                          child: Center(
                            child: AutoScrollText(
                              text: feature.title,
                              maxLines: 2,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.maroon700,
                                fontFamily: 'DiwaniBent',
                                fontSize: feature.isImportant ? 30.0 : 24.0,
                                height: 1.05,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, WidgetRef ref) {
    if (feature.action == HomeFeatureAction.openQuranReader) {
      _openQuranReader(context, ref);
      return;
    }

    if (feature.action == HomeFeatureAction.openAdhkarGrid) {
      context.push('/adhkar');
      return;
    }

    if (feature.action == HomeFeatureAction.openQuranAudioDownload) {
      context.push(QuranAudioDownloadScreen.routePath);
      return;
    }

    if (feature.action == HomeFeatureAction.openQuranSurahPlayer) {
      context.push(QuranSurahPlayerScreen.routePath);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'هذه الميزة ستضاف في مرحلة لاحقة.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          softWrap: true,
          textAlign: TextAlign.right,
        ),
      ),
    );
  }

  Future<void> _openQuranReader(BuildContext context, WidgetRef ref) async {
    // Instrumentation: log and defensively parse the saved page value.
    try {
      final service = ref.read(quranReadingProgressServiceProvider);
      final entry = await service.getLastPosition();

      // Access as dynamic to guard against unexpected runtime types.
      final rawLastPage = (entry as dynamic)?.lastPage;
      debugPrint('HomeFeatureCard: lastPosition entry=$entry');
      debugPrint(
        'HomeFeatureCard: rawLastPage=$rawLastPage runtimeType=${rawLastPage.runtimeType}',
      );

      final page = _extractPageSafe(rawLastPage);

      if (!context.mounted) return;

      Navigator.of(context).push(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              QuranPageReader(initialPage: page),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation =
                Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(position: slideAnimation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e, st) {
      // Log full error and fallback to page 1
      debugPrint('HomeFeatureCard._openQuranReader error: $e\n$st');
      if (!context.mounted) return;
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const QuranPageReader(initialPage: 1),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation =
                Tween<Offset>(
                  begin: const Offset(0, 0.04),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );

            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
              child: SlideTransition(position: slideAnimation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  // Robust extractor to convert various runtime values into an int page number.
  int _extractPageSafe(dynamic raw) {
    try {
      if (raw == null) return 1;
      if (raw is int) return raw;
      if (raw is double) return raw.toInt();
      if (raw is String) return int.tryParse(raw) ?? 1;
      if (raw is Map) {
        // Common keys expected if a map was stored accidentally
        for (final key in ['lastPage', 'last_page', 'page', 'value']) {
          if (raw.containsKey(key)) {
            final v = raw[key];
            if (v is int) return v;
            if (v is double) return v.toInt();
            if (v is String) return int.tryParse(v) ?? 1;
          }
        }
        // If map has a single integer value, pick it
        if (raw.values.length == 1) {
          final v = raw.values.first;
          if (v is int) return v;
          if (v is double) return v.toInt();
          if (v is String) return int.tryParse(v) ?? 1;
        }
      }
    } catch (err, st) {
      debugPrint('Failed to extract page from $raw: $err\n$st');
    }
    return 1;
  }
}
