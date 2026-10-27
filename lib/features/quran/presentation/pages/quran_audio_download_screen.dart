import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/core/design/app_design_components.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/audio/audio_download_library_body.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_empty_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة تنزيل التلاوات الصوتية والمكتبة الصوتية.
///
/// تم تفكيكها وفق Clean Architecture:
/// - شاشة قراءة حالة معمارية خفيفة بدون أي منطق بحث أو حالات محلية.
/// - تفويض العرض إلى [AudioDownloadLibraryBody].
/// - استخدام المكونات الموحدة في `widgets/downloads/shared/`.
class QuranAudioDownloadScreen extends ConsumerWidget {
  const QuranAudioDownloadScreen({super.key});

  static const String routePath = '/quran/audio-download';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.semanticColors;
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final preferencesAsync = ref.watch(appUserPreferencesProvider);
    final selectedRecitation = ref.watch(selectedQuranRecitationProvider);
    final downloadState = ref.watch(quranAudioDownloadProvider);
    final preferredReciterId = preferencesAsync.maybeWhen(
      data: (preferences) => preferences.preferredReciterId,
      orElse: () => null,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.canvas,
        body: SafeArea(
          child: Column(
            children: [
              IslamicHeader(
                title: 'المكتبة الصوتية',
                subtitle: 'اختر قارئًا واجعله الافتراضي أو نزّل التلاوة كاملة.',
                leading: IconButton(
                  tooltip: 'رجوع',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: colors.primaryStrong,
                  ),
                ),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryStrong.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    Icons.headphones_rounded,
                    color: colors.primaryStrong,
                    size: 21,
                  ),
                ),
              ),
              Expanded(
                child: recitationsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => AppStateView.error(
                    title: 'تعذر تحميل قائمة القراء',
                    message:
                        'تحقق من الاتصال بالإنترنت ثم أعد المحاولة لعرض مكتبة الاستماع.',
                    retryLabel: 'إعادة المحاولة',
                    onAction: () => ref.invalidate(quranRecitationsProvider),
                  ),
                  data: (recitations) {
                    final playable = recitations
                        .where((r) => r.hasAyahAudio)
                        .toList();

                    if (playable.isEmpty) {
                      return ResourceEmptyMessage(
                        icon: Icons.record_voice_over_outlined,
                        title: 'لا توجد تلاوات قابلة للتنزيل الآن',
                        message: 'جرّب تحديث القائمة بعد قليل.',
                        actionLabel: 'تحديث',
                        onAction: () =>
                            ref.invalidate(quranRecitationsProvider),
                      );
                    }

                    final effectiveSelected = _resolveSelectedRecitation(
                      recitations: playable,
                      selectedRecitation: selectedRecitation,
                      preferredReciterId: preferredReciterId,
                    );

                    if (selectedRecitation == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;
                        ref
                                .read(selectedQuranRecitationProvider.notifier)
                                .state =
                            effectiveSelected;
                      });
                    }

                    return AudioDownloadLibraryBody(
                      recitations: playable,
                      selectedRecitation: effectiveSelected,
                      downloadState: downloadState,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  QuranRecitation _resolveSelectedRecitation({
    required List<QuranRecitation> recitations,
    required QuranRecitation? selectedRecitation,
    required int? preferredReciterId,
  }) {
    if (selectedRecitation != null) {
      for (final recitation in recitations) {
        if (recitation.id == selectedRecitation.id) {
          return recitation;
        }
      }
    }

    if (preferredReciterId != null) {
      for (final recitation in recitations) {
        if (recitation.id == preferredReciterId) {
          return recitation;
        }
      }
    }

    return recitations.first;
  }
}
