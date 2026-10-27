import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_provider.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/floating_player_bar.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_list_tile.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_header.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/player/surah_player_state_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// شاشة الاستماع لسور القرآن الكريم (Quran Surah Player Screen).
///
/// تم تقسيم مكوناتها وفق Clean Architecture:
/// - نماذج حالة العرض: [PlayerShell], [PlayerBarState], [ExpandedControlsState].
/// - ترويسة واختيار القراء: [SurahPlayerTopBar], [SurahPlayerReciterRow].
/// - قائمة السور وبطاقات التشغيل: [SurahListView], [SurahListTile].
/// - شريط المشغل العائم والتحكم الموسع: [FloatingPlayerBar], [ExpandedControls].
class QuranSurahPlayerScreen extends ConsumerStatefulWidget {
  const QuranSurahPlayerScreen({super.key});

  static const String routePath = '/quran/surah-player';

  @override
  ConsumerState<QuranSurahPlayerScreen> createState() =>
      _QuranSurahPlayerScreenState();
}

class _QuranSurahPlayerScreenState extends ConsumerState<QuranSurahPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  bool _isPlayerExpanded = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ PERF: حقل محدود يمنع إعادة بناء القائمة مع كل نبضة تقدّم (350ms).
    final playerShell = ref.watch(
      quranSurahPlayerProvider.select(PlayerShell.from),
    );
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final downloadState = ref.watch(quranAudioDownloadProvider);
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final preferredReciterId = ref.watch(
      appUserPreferencesProvider.select(
        (p) => p.maybeWhen(
          data: (value) => value.preferredReciterId,
          orElse: () => null,
        ),
      ),
    );

    // Restore download progress from disk whenever the reciter list is ready
    // or the preferred reciter changes (covers app restart + reciter switch).
    ref.listen(quranRecitationsProvider, (previous, next) {
      next.maybeWhen(
        data: (recitations) {
          if (recitations.isEmpty) return;
          final reciterId =
              playerShell.recitationId ??
              preferredReciterId ??
              recitations.first.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ref
                  .read(quranAudioDownloadProvider.notifier)
                  .refreshDownloadedSurahs(reciterId: reciterId);
            }
          });
        },
        orElse: () {},
      );
    });

    final activeRecitation = recitationsAsync.maybeWhen(
      data: (recitations) {
        if (recitations.isEmpty) return null;
        if (playerShell.recitationId != null) {
          for (final r in recitations) {
            if (r.id == playerShell.recitationId) return r;
          }
        }
        if (preferredReciterId != null) {
          for (final r in recitations) {
            if (r.id == preferredReciterId) return r;
          }
        }
        return recitations.first;
      },
      orElse: () => null,
    );

    final accentColor = isDark ? AppColors.goldDeep : AppColors.maroon800;
    final bgGradient = ListeningPalette.pageGradientFor(brightness);

    final showPlayerBar =
        playerShell.isPlaying ||
        playerShell.isLoading ||
        playerShell.hasError ||
        playerShell.currentSurah != 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: bgGradient),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  // ── Top bar ──
                  SurahPlayerTopBar(isDark: isDark, accentColor: accentColor),

                  // ── Reciter row: dropdown + audio library button ──
                  SurahPlayerReciterRow(
                    recitationsAsync: recitationsAsync,
                    activeRecitation: activeRecitation,
                    downloadState: downloadState,
                    isDark: isDark,
                    accentColor: accentColor,
                    onReciterChanged: (recitation) {
                      ref.read(selectedQuranRecitationProvider.notifier).state =
                          recitation;
                      ref
                          .read(appUserPreferencesProvider.notifier)
                          .setPreferredReciter(recitation);
                      // فحص الملفات المحلية للقارئ الجديد (islamic.app أو quran.com)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          ref
                              .read(quranAudioDownloadProvider.notifier)
                              .refreshDownloadedSurahs(
                                reciterId: recitation.id,
                              );
                        }
                      });
                    },
                    onDownloadAll: activeRecitation != null
                        ? () => context.push(QuranAudioDownloadScreen.routePath)
                        : null,
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  // ── Surah list ──
                  Expanded(
                    child: SurahListView(
                      currentSurah: playerShell.currentSurah,
                      isPlaying: playerShell.isPlaying,
                      activeRecitation: activeRecitation,
                      downloadState: downloadState,
                      isDark: isDark,
                      accentColor: accentColor,
                    ),
                  ),

                  // ── Floating player bar ──
                  if (showPlayerBar)
                    FloatingPlayerBar(
                      activeRecitation: activeRecitation,
                      isDark: isDark,
                      accentColor: accentColor,
                      isExpanded: _isPlayerExpanded,
                      onExpandToggle: () => setState(
                        () => _isPlayerExpanded = !_isPlayerExpanded,
                      ),
                      onClose: () {
                        ref.read(quranSurahPlayerProvider.notifier).stop();
                        setState(() => _isPlayerExpanded = false);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
