import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/core/design/app_design_components.dart';
import 'package:al_mubeen/features/quran/application/tafsir_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/shared/resource_empty_views.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/downloads/tafsir/tafsir_library_body.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// شاشة تحميل التفاسير.
///
/// تم تفكيكها وفق Clean Architecture:
/// - مسؤولة فقط عن قراءة الحالة من المزوّدات (Riverpod Providers).
/// - عزل حالة البحث والفلترة وقائمة العناصر في [TafsirLibraryBody].
/// - استخدام المكونات المشتركة الموحدة [ResourceFilterBar] و [ResourceTile] و [ResourceDownloadProgressBanner].
class TafsirDownloadScreen extends ConsumerWidget {
  const TafsirDownloadScreen({super.key, this.initialResourceId});

  static const String routeName = '/tafsir-download';

  final int? initialResourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.semanticColors;
    final tafsirsAsync = ref.watch(tafsirsProvider);
    final downloadedTafsirsAsync = ref.watch(downloadedTafsirsProvider);
    final downloadState = ref.watch(tafsirDownloadControllerProvider);
    final selectedTafsirId = ref.watch(selectedTafsirProvider);
    final downloadedTafsirs = downloadedTafsirsAsync.maybeWhen(
      data: (tafsirs) => tafsirs,
      orElse: () => const <Tafsir>[],
    );
    final downloadedTafsirIds = downloadedTafsirs
        .map((tafsir) => tafsir.id)
        .toSet();

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(title: const Text('تحميل التفاسير')),
      body: tafsirsAsync.when(
        loading: () {
          if (downloadedTafsirs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildLibraryBody(
            context: context,
            ref: ref,
            tafsirs: downloadedTafsirs,
            downloadedTafsirIds: downloadedTafsirIds,
            selectedTafsirId: selectedTafsirId,
            downloadState: downloadState,
            showFallbackNotice: true,
          );
        },
        error: (error, stack) {
          if (downloadedTafsirs.isEmpty) {
            return AppStateView.error(
              title: 'حدث خطأ أثناء تحميل التفاسير',
              message: kDebugMode
                  ? error.toString()
                  : 'تعذّر تحميل قائمة التفاسير. تحقّق من اتصالك ثم أعد المحاولة.',
              retryLabel: 'إعادة المحاولة',
              onAction: () => ref.invalidate(tafsirsProvider),
            );
          }

          return _buildLibraryBody(
            context: context,
            ref: ref,
            tafsirs: downloadedTafsirs,
            downloadedTafsirIds: downloadedTafsirIds,
            selectedTafsirId: selectedTafsirId,
            downloadState: downloadState,
            showFallbackNotice: true,
          );
        },
        data: (tafsirs) {
          if (tafsirs.isEmpty) {
            if (downloadedTafsirs.isNotEmpty) {
              return _buildLibraryBody(
                context: context,
                ref: ref,
                tafsirs: downloadedTafsirs,
                downloadedTafsirIds: downloadedTafsirIds,
                selectedTafsirId: selectedTafsirId,
                downloadState: downloadState,
                showFallbackNotice: true,
              );
            }

            return ResourceEmptyMessage(
              icon: Icons.menu_book_rounded,
              title: 'لا توجد تفاسير متاحة',
              message: 'جرّب تحديث القائمة بعد قليل.',
              actionLabel: 'إعادة المحاولة',
              onAction: () => ref.invalidate(tafsirsProvider),
            );
          }

          return _buildLibraryBody(
            context: context,
            ref: ref,
            tafsirs: tafsirs,
            downloadedTafsirIds: downloadedTafsirIds,
            selectedTafsirId: selectedTafsirId,
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
    required List<Tafsir> tafsirs,
    required Set<int> downloadedTafsirIds,
    required int? selectedTafsirId,
    required TafsirDownloadState downloadState,
    required bool showFallbackNotice,
  }) {
    _ensureSelection(
      context: context,
      ref: ref,
      tafsirs: tafsirs,
      selectedTafsirId: selectedTafsirId,
      downloadState: downloadState,
    );

    return TafsirLibraryBody(
      tafsirs: tafsirs,
      downloadedTafsirIds: downloadedTafsirIds,
      selectedTafsirId: selectedTafsirId,
      downloadState: downloadState,
      showFallbackNotice: showFallbackNotice,
      onRetry: () => ref.invalidate(tafsirsProvider),
    );
  }

  void _ensureSelection({
    required BuildContext context,
    required WidgetRef ref,
    required List<Tafsir> tafsirs,
    required int? selectedTafsirId,
    required TafsirDownloadState downloadState,
  }) {
    final needsSelection =
        selectedTafsirId == null &&
        tafsirs.isNotEmpty &&
        !downloadState.isActiveDownload;
    if (!needsSelection) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }
      ref.read(selectedTafsirProvider.notifier).state = tafsirs.first.id;
    });
  }
}
