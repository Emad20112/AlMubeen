import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/app_loading_overlay.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/domain/tafsir_defaults.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_html_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran/qcf_quran.dart';

class TafsirReaderContent extends ConsumerWidget {
  const TafsirReaderContent({
    required this.chapterNumber,
    required this.onOpenLibrary,
    this.ayahNumber,
    this.onClose,
    super.key,
  });

  final int chapterNumber;
  final int? ayahNumber;
  final VoidCallback onOpenLibrary;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTafsirId = ref.watch(selectedTafsirProvider);
    final tafsirsAsync = ref.watch(tafsirsProvider);
    final downloadedTafsirsAsync = ref.watch(downloadedTafsirsProvider);

    final downloadedTafsirs = _ensureDefaultTafsir(
      downloadedTafsirsAsync.maybeWhen(
        data: (tafsirs) => tafsirs,
        orElse: () => const <Tafsir>[],
      ),
    );
    final availableTafsirs = tafsirsAsync.maybeWhen(
      data: (tafsirs) => _ensureDefaultTafsir(tafsirs),
      orElse: () => downloadedTafsirs,
    );

    final selectedTafsir = _resolveSelectedTafsir(
      selectedTafsirId: selectedTafsirId,
      tafsirs: availableTafsirs,
      downloadedTafsirs: downloadedTafsirs,
    );

    final hasResolvedCatalog =
        tafsirsAsync.maybeWhen(data: (_) => true, orElse: () => false) ||
        downloadedTafsirsAsync.maybeWhen(
          data: (_) => true,
          orElse: () => false,
        );
    if (selectedTafsir == null &&
        selectedTafsirId != defaultTafsirResourceId &&
        hasResolvedCatalog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        ref.read(selectedTafsirProvider.notifier).state =
            defaultTafsirResourceId;
      });
    }

    final displayTafsirs = <Tafsir>[defaultBuiltInTafsir];
    if (selectedTafsir != null &&
        selectedTafsir.id != defaultTafsirResourceId) {
      displayTafsirs.add(selectedTafsir);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        _ReaderHeader(
          isDark: isDark,
          chapterNumber: chapterNumber,
          ayahNumber: ayahNumber,
          onOpenLibrary: onOpenLibrary,
          onClose: onClose,
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < displayTafsirs.length; index++) ...[
          _TafsirSectionCard(
            tafsir: displayTafsirs[index],
            chapterNumber: chapterNumber,
            ayahNumber: ayahNumber,
            isDefault: index == 0,
          ),
          if (index != displayTafsirs.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _ReaderHeader extends StatelessWidget {
  const _ReaderHeader({
    required this.isDark,
    required this.chapterNumber,
    required this.onOpenLibrary,
    this.ayahNumber,
    this.onClose,
  });

  final bool isDark;
  final int chapterNumber;
  final int? ayahNumber;
  final VoidCallback onOpenLibrary;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final cardBg = isDark ? const Color(0xFF231A17) : Colors.white;

    String? verseText;
    if (ayahNumber != null) {
      try {
        verseText = getVerse(chapterNumber, ayahNumber!, verseEndSymbol: true);
      } catch (_) {
        verseText = null;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (verseText != null) ...[
            Text(
              verseText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? AppColors.darkInk : AppColors.maroon800,
                fontSize: 20,
                height: 1.8,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'تفسير سورة ${getSurahName(chapterNumber)}',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (onClose != null) ...[
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TafsirSectionCard extends ConsumerWidget {
  const _TafsirSectionCard({
    required this.tafsir,
    required this.chapterNumber,
    required this.isDefault,
    this.ayahNumber,
  });

  final Tafsir tafsir;
  final int chapterNumber;
  final int? ayahNumber;
  final bool isDefault;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final tafsirAsync = ayahNumber != null
        ? ref.watch(
            tafsirAyahProvider((
              resourceId: tafsir.id,
              chapterNumber: chapterNumber,
              ayahNumber: ayahNumber!,
            )),
          )
        : ref.watch(
            tafsirChapterProvider((
              resourceId: tafsir.id,
              chapterNumber: chapterNumber,
            )),
          );

    final ({int resourceId, int chapterNumber, int ayahNumber})? providerKey =
        ayahNumber != null
        ? (
            resourceId: tafsir.id,
            chapterNumber: chapterNumber,
            ayahNumber: ayahNumber!,
          )
        : null;
    final resourceLabel = isDefault ? 'افتراضي' : 'محمّل';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF231A17) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.auto_stories_rounded, color: primaryColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tafsir.name,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (tafsir.authorName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'المفسر: ${tafsir.authorName!}',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black45,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    resourceLabel,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          tafsirAsync.when(
            loading: () => Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: AppLoadingOverlay(
                  icon: Icons.menu_book_rounded,
                  message: 'جاري تحميل ${tafsir.name}',
                  size: 50,
                ),
              ),
            ),
            error: (error, stackTrace) {
              return _TafsirSectionError(
                isDark: isDark,
                error: error.toString(),
                onRetry: () {
                  if (providerKey != null) {
                    ref.invalidate(tafsirAyahProvider(providerKey));
                  } else {
                    ref.invalidate(
                      tafsirChapterProvider((
                        resourceId: tafsir.id,
                        chapterNumber: chapterNumber,
                      )),
                    );
                  }
                },
              );
            },
            data: (tafsirText) {
              return TafsirHtmlContent(
                text: tafsirText.text,
                accentColor: primaryColor,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                scrollable: false,
                textStyle: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16.5,
                  height: 1.9,
                  fontFamily: 'Amiri',
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TafsirSectionError extends StatelessWidget {
  const _TafsirSectionError({
    required this.isDark,
    required this.error,
    required this.onRetry,
  });

  final bool isDark;
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 40, color: accentColor),
          const SizedBox(height: 12),
          Text(
            'حدث خطأ أثناء تحميل التفسير',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 12,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

List<Tafsir> _ensureDefaultTafsir(List<Tafsir> tafsirs) {
  return <Tafsir>[
    defaultBuiltInTafsir,
    ...tafsirs.where((tafsir) => tafsir.id != defaultTafsirResourceId),
  ];
}

Tafsir? _resolveSelectedTafsir({
  required int? selectedTafsirId,
  required List<Tafsir> tafsirs,
  required List<Tafsir> downloadedTafsirs,
}) {
  if (selectedTafsirId == null) {
    return null;
  }

  for (final tafsir in tafsirs) {
    if (tafsir.id == selectedTafsirId) {
      return tafsir;
    }
  }

  for (final tafsir in downloadedTafsirs) {
    if (tafsir.id == selectedTafsirId) {
      return tafsir;
    }
  }

  return null;
}
