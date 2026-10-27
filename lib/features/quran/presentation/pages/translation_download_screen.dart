import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/core/design/app_design_components.dart';
import 'package:al_mubeen/features/quran/application/translation_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_empty_views.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/translations/translation_library_body.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة تحميل الترجمات.
///
/// مسؤوليتها الوحيدة: قراءة الحالة من المزوّدات وتقرير أي حالة عرض تُبنى
/// (تحميل / خطأ / احتياطي محلي / قائمة). كل الودجات في
/// `presentation/widgets/downloads/`.
class TranslationDownloadScreen extends ConsumerWidget {
  const TranslationDownloadScreen({super.key, this.initialResourceId});

  static const String routeName = '/translation-download';

  final int? initialResourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.semanticColors;
    final translationsAsync = ref.watch(translationsProvider);
    final downloadedTranslationsAsync = ref.watch(
      downloadedTranslationsProvider,
    );
    final downloadState = ref.watch(translationDownloadControllerProvider);
    final selectedTranslationId = ref.watch(selectedTranslationProvider);
    final downloadedTranslations = downloadedTranslationsAsync.maybeWhen(
      data: (translations) => translations,
      orElse: () => const <Translation>[],
    );
    final downloadedTranslationIds = downloadedTranslations
        .map((translation) => translation.id)
        .toSet();

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(title: const Text('تحميل الترجمات')),
      body: translationsAsync.when(
        loading: () {
          if (downloadedTranslations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildLibraryBody(
            context: context,
            ref: ref,
            translations: downloadedTranslations,
            downloadedTranslationIds: downloadedTranslationIds,
            selectedTranslationId: selectedTranslationId,
            downloadState: downloadState,
            showFallbackNotice: true,
          );
        },
        error: (error, stack) {
          if (downloadedTranslations.isEmpty) {
            return AppStateView.error(
              title: 'حدث خطأ أثناء تحميل الترجمات',
              message: kDebugMode
                  ? error.toString()
                  : 'تعذّر تحميل قائمة الترجمات. تحقّق من اتصالك ثم أعد المحاولة.',
              retryLabel: 'إعادة المحاولة',
              onAction: () => ref.invalidate(translationsProvider),
            );
          }

          return _buildLibraryBody(
            context: context,
            ref: ref,
            translations: downloadedTranslations,
            downloadedTranslationIds: downloadedTranslationIds,
            selectedTranslationId: selectedTranslationId,
            downloadState: downloadState,
            showFallbackNotice: true,
          );
        },
        data: (translations) {
          if (translations.isEmpty) {
            if (downloadedTranslations.isNotEmpty) {
              return _buildLibraryBody(
                context: context,
                ref: ref,
                translations: downloadedTranslations,
                downloadedTranslationIds: downloadedTranslationIds,
                selectedTranslationId: selectedTranslationId,
                downloadState: downloadState,
                showFallbackNotice: true,
              );
            }

            return ResourceEmptyMessage(
              icon: Icons.translate_rounded,
              title: 'لا توجد ترجمات متاحة',
              message: 'جرّب تحديث القائمة بعد قليل.',
              actionLabel: 'إعادة المحاولة',
              onAction: () => ref.invalidate(translationsProvider),
            );
          }

          return _buildLibraryBody(
            context: context,
            ref: ref,
            translations: translations,
            downloadedTranslationIds: downloadedTranslationIds,
            selectedTranslationId: selectedTranslationId,
            downloadState: downloadState,
            showFallbackNotice: false,
          );
        },
      ),
    );
  }

  Widget _buildLibraryBody({
    required BuildContext context,
    required WidgetRef ref,
    required List<Translation> translations,
    required Set<int> downloadedTranslationIds,
    required int? selectedTranslationId,
    required TranslationDownloadState downloadState,
    required bool showFallbackNotice,
  }) {
    _ensureSelection(
      context: context,
      ref: ref,
      translations: translations,
      selectedTranslationId: selectedTranslationId,
      downloadState: downloadState,
    );

    return TranslationLibraryBody(
      translations: translations,
      downloadedTranslationIds: downloadedTranslationIds,
      selectedTranslationId: selectedTranslationId,
      downloadState: downloadState,
      showFallbackNotice: showFallbackNotice,
      onRetry: () => ref.invalidate(translationsProvider),
    );
  }

  /// يضمن وجود ترجمة محددة عند فتح الشاشة، دون إطلاق `setState` داخل
  /// `build` — لذلك يُنفَّذ في ما بعد الإطار.
  void _ensureSelection({
    required BuildContext context,
    required WidgetRef ref,
    required List<Translation> translations,
    required int? selectedTranslationId,
    required TranslationDownloadState downloadState,
  }) {
    final needsSelection =
        selectedTranslationId == null &&
        translations.isNotEmpty &&
        !downloadState.isActiveDownload;
    if (!needsSelection) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      ref.read(selectedTranslationProvider.notifier).state =
          translations.first.id;
    });
  }
}
