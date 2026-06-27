import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/presentation/pages/translation_download_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

void showTranslationBottomSheet({
  required BuildContext context,
  required AyahRef ayahRef,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TranslationBottomSheet(ayahRef: ayahRef),
  );
}

class TranslationBottomSheet extends ConsumerStatefulWidget {
  const TranslationBottomSheet({required this.ayahRef, super.key});

  final AyahRef ayahRef;

  @override
  ConsumerState<TranslationBottomSheet> createState() =>
      _TranslationBottomSheetState();
}

class _TranslationBottomSheetState
    extends ConsumerState<TranslationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedTranslationId = ref.watch(selectedTranslationProvider);
    final translationsAsync = ref.watch(translationsProvider);
    final downloadedTranslationsAsync = ref.watch(
      downloadedTranslationsProvider,
    );

    final downloadedTranslations = downloadedTranslationsAsync.maybeWhen(
      data: (translations) => translations,
      orElse: () => <Translation>[],
    );

    final availableTranslations = translationsAsync.maybeWhen(
      data: (translations) => translations,
      orElse: () => downloadedTranslations,
    );

    final activeTranslation = _resolveActiveTranslation(
      selectedTranslationId: selectedTranslationId,
      translations: availableTranslations,
      downloadedTranslations: downloadedTranslations,
    );

    if (selectedTranslationId == null && activeTranslation != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(selectedTranslationProvider.notifier).state =
            activeTranslation.id;
      });
    }

    if (translationsAsync.isLoading && activeTranslation == null) {
      return _TranslationSheetFrame(
        isDark: isDark,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (activeTranslation == null) {
      return _TranslationSheetFrame(
        isDark: isDark,
        child: _TranslationSheetError(
          isDark: isDark,
          onRetry: () => ref.invalidate(translationsProvider),
          onOpenLibrary: () {
            Navigator.of(context).pop();
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute<void>(
                builder: (context) => const TranslationDownloadScreen(),
              ),
            );
          },
        ),
      );
    }

    final translationAsync = ref.watch(
      translationAyahProvider((
        resourceId: activeTranslation.id,
        chapterNumber: widget.ayahRef.surah,
        ayahNumber: widget.ayahRef.ayah,
      )),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: _TranslationSheetFrame(
        isDark: isDark,
        child: Column(
          children: [
            _TranslationSheetHeader(
              ayahRef: widget.ayahRef,
              translation: activeTranslation,
              onClose: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1),
            Expanded(
              child: translationAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _TranslationSheetError(
                  isDark: isDark,
                  error: error.toString(),
                  onRetry: () {
                    ref.invalidate(
                      translationAyahProvider((
                        resourceId: activeTranslation.id,
                        chapterNumber: widget.ayahRef.surah,
                        ayahNumber: widget.ayahRef.ayah,
                      )),
                    );
                  },
                  onOpenLibrary: () {
                    Navigator.of(context).pop();
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const TranslationDownloadScreen(),
                      ),
                    );
                  },
                ),
                data: (translationText) {
                  final cleanedText = _normalizeTranslationText(
                    translationText.text,
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF231A17)
                                : const Color(0xFFFFFCF3),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  (isDark
                                          ? const Color(0xFFD8B457)
                                          : AppColors.maroon800)
                                      .withValues(alpha: 0.14),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.translate_rounded,
                                    color: isDark
                                        ? const Color(0xFFD8B457)
                                        : AppColors.maroon800,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      translationText.resourceName,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black87,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SelectableText(
                                cleanedText,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontSize: 18,
                                  height: 1.95,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: cleanedText),
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('تم نسخ نص الترجمة.'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.copy_rounded),
                                label: const Text('نسخ النص'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Translation? _resolveActiveTranslation({
    required int? selectedTranslationId,
    required List<Translation> translations,
    required List<Translation> downloadedTranslations,
  }) {
    if (selectedTranslationId != null) {
      for (final translation in translations) {
        if (translation.id == selectedTranslationId) {
          return translation;
        }
      }

      for (final translation in downloadedTranslations) {
        if (translation.id == selectedTranslationId) {
          return translation;
        }
      }
    }

    if (translations.isNotEmpty) {
      return translations.first;
    }

    if (downloadedTranslations.isNotEmpty) {
      return downloadedTranslations.first;
    }

    return null;
  }
}

class _TranslationSheetFrame extends StatelessWidget {
  const _TranslationSheetFrame({required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1210).withValues(alpha: 0.98)
                : AppColors.parchment.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _TranslationSheetHeader extends StatelessWidget {
  const _TranslationSheetHeader({
    required this.ayahRef,
    required this.translation,
    required this.onClose,
  });

  final AyahRef ayahRef;
  final Translation translation;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final surahName = getSurahNameArabic(ayahRef.surah);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.translate_rounded, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ترجمة الآية',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$surahName - الآية ${ayahRef.ayah}',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: primaryColor.withValues(alpha: 0.15)),
              ),
              child: Text(
                translation.name,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslationSheetError extends StatelessWidget {
  const _TranslationSheetError({
    required this.isDark,
    required this.onRetry,
    required this.onOpenLibrary,
    this.error,
  });

  final bool isDark;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onOpenLibrary;

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon800;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF231A17) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentColor.withValues(alpha: 0.14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 52, color: accentColor),
              const SizedBox(height: 16),
              Text(
                'تعذر تحميل الترجمة',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onOpenLibrary,
                      child: const Text('فتح المكتبة'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onRetry,
                      child: const Text('إعادة المحاولة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _normalizeTranslationText(String source) {
  final trimmed = source.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  final withoutTags = trimmed
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&nbsp;', ' ')
      .trim();

  return withoutTags.isEmpty ? trimmed : withoutTags;
}
