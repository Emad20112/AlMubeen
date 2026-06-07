// ignore_for_file: deprecated_member_use
import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_download_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranAudioDownloadScreen extends ConsumerWidget {
  const QuranAudioDownloadScreen({super.key});

  static const String routePath = '/quran/audio-download';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final selectedRecitation = ref.watch(selectedQuranRecitationProvider);
    final downloadState = ref.watch(quranAudioDownloadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحميل صوت القرآن الكريم'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: recitationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(
                'تعذر تحميل قائمة القراء. حاول مرة أخرى لاحقاً.',
                textAlign: TextAlign.center,
              ),
            ),
            data: (recitations) {
              final activeRecitation = _activeRecitation(
                recitations,
                selectedRecitation,
              );

              if (selectedRecitation == null && activeRecitation != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(selectedQuranRecitationProvider.notifier).state =
                      activeRecitation;
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اختر قارئاً ثم اضغط زر التنزيل لتنزيل المصحف كاملاً بصيغة صوتية.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 18),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSurfaceHigh
                          : AppColors.parchmentLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'قائمة القراء المتاحة',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          for (final recitation in recitations)
                            RadioListTile<int>(
                              value: recitation.id,
                              groupValue: activeRecitation?.id,
                              onChanged: (recitationId) {
                                if (recitationId == null) {
                                  return;
                                }

                                ref
                                    .read(selectedQuranRecitationProvider.notifier)
                                    .state = recitations.firstWhere(
                                  (item) => item.id == recitationId,
                                );
                              },
                              title: Text(_recitationLabel(recitation)),
                              subtitle: recitation.languageName != null
                                  ? Text(recitation.languageName!)
                                  : null,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (downloadState.status != QuranAudioDownloadStatus.idle) ...[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurfaceHigh
                            : AppColors.parchmentLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              downloadState.message ?? '',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: downloadState.progress.clamp(0.0, 1.0),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'تم تنزيل ${downloadState.completedCount} من ${downloadState.totalCount}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            if (downloadState.currentVerse.isNotEmpty)
                              Text(
                                downloadState.currentVerse,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (downloadState.savePath != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                'المجلد: ${downloadState.savePath!}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            if (downloadState.errorMessage != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                downloadState.errorMessage!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Theme.of(context).colorScheme.error),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: activeRecitation == null || downloadState.isDownloading
                        ? null
                        : () {
                            ref
                                .read(quranAudioDownloadProvider.notifier)
                                .downloadFullQuran(
                                  recitation: activeRecitation,
                                );
                          },
                    icon: Icon(
                      downloadState.isDownloading
                          ? Icons.downloading
                          : Icons.cloud_download,
                    ),
                    label: Text(
                      downloadState.isDownloading
                          ? 'جاري تنزيل المصحف...' 
                          : 'تحميل المصحف كامل',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ملحوظة: قد يستغرق التحميل وقتاً طويلاً بسبب عدد الآيات الكبير. سيتم حفظ الملفات داخل مجلد التطبيق.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.right,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  QuranRecitation? _activeRecitation(
    List<QuranRecitation> recitations,
    QuranRecitation? selectedRecitation,
  ) {
    if (selectedRecitation != null) {
      for (final recitation in recitations) {
        if (recitation.id == selectedRecitation.id) {
          return recitation;
        }
      }
    }

    if (recitations.isNotEmpty) {
      return recitations.first;
    }

    return null;
  }

  String _recitationLabel(QuranRecitation recitation) {
    final translatedName = recitation.translatedName;
    final style = recitation.style;
    if (translatedName != null && translatedName != recitation.reciterName) {
      return '$translatedName - ${recitation.reciterName}';
    }
    if (style != null) {
      return '${recitation.reciterName} - $style';
    }
    return recitation.reciterName;
  }
}
