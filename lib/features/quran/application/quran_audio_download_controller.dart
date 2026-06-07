import 'dart:io';

import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_key.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

final quranAudioDownloadProvider =
    NotifierProvider<QuranAudioDownloadController, QuranAudioDownloadState>(
  QuranAudioDownloadController.new,
);

enum QuranAudioDownloadStatus { idle, downloading, completed, failed }

@immutable
final class QuranAudioDownloadState {
  const QuranAudioDownloadState({
    this.status = QuranAudioDownloadStatus.idle,
    this.progress = 0.0,
    this.totalCount = 0,
    this.completedCount = 0,
    this.currentVerse = '',
    this.reciterName,
    this.savePath,
    this.message,
    this.errorMessage,
  });

  final QuranAudioDownloadStatus status;
  final double progress;
  final int totalCount;
  final int completedCount;
  final String currentVerse;
  final String? reciterName;
  final String? savePath;
  final String? message;
  final String? errorMessage;

  bool get isDownloading => status == QuranAudioDownloadStatus.downloading;

  QuranAudioDownloadState copyWith({
    QuranAudioDownloadStatus? status,
    double? progress,
    int? totalCount,
    int? completedCount,
    String? currentVerse,
    String? reciterName,
    String? savePath,
    String? message,
    String? errorMessage,
  }) {
    return QuranAudioDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalCount: totalCount ?? this.totalCount,
      completedCount: completedCount ?? this.completedCount,
      currentVerse: currentVerse ?? this.currentVerse,
      reciterName: reciterName ?? this.reciterName,
      savePath: savePath ?? this.savePath,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final class QuranAudioDownloadController
    extends Notifier<QuranAudioDownloadState> {
  @override
  QuranAudioDownloadState build() {
    return const QuranAudioDownloadState();
  }

  Future<void> downloadFullQuran({
    required QuranRecitation recitation,
  }) async {
    if (state.isDownloading) {
      return;
    }

    final saveRoot = await _prepareSaveDirectory(recitation.reciterName);
    final totalVerses = _countTotalVerses();
    state = state.copyWith(
      status: QuranAudioDownloadStatus.downloading,
      totalCount: totalVerses,
      completedCount: 0,
      progress: 0.0,
      currentVerse: 'جاري التحضير...',
      reciterName: recitation.reciterName,
      savePath: saveRoot.path,
      message: 'جاري تنزيل صوت القرآن الكريم بالقارئ المحدد.',
      errorMessage: null,
    );

    final client = HttpClient();
    var downloaded = 0;
    var errors = 0;

    try {
      for (var surah = 1; surah <= totalSurahCount; surah++) {
        final verseCount = getVerseCount(surah);
        final chapterDir = Directory(
          path.join(saveRoot.path, 'surah_${surah.toString().padLeft(3, '0')}'),
        );
        await chapterDir.create(recursive: true);

        for (var ayah = 1; ayah <= verseCount; ayah++) {
          final verseKey = QuranVerseKey(surah: surah, ayah: ayah);
          final currentVerse = 'سورة ${getSurahNameArabic(surah)} - آية $ayah';
          state = state.copyWith(
            completedCount: downloaded,
            progress: downloaded / totalVerses,
            currentVerse: currentVerse,
            message: 'تحميل $currentVerse',
          );

          final result = await ref
              .read(quranAudioRepositoryProvider)
              .getAyahAudio(
                verseKey: verseKey,
                recitationId: recitation.id,
              );

          final audioFile = result.valueOrNull;
          if (audioFile == null) {
            errors++;
            downloaded++;
            continue;
          }

          final extension = path.extension(audioFile.url.path).isNotEmpty
              ? path.extension(audioFile.url.path)
              : '.mp3';
          final destination = File(
            path.join(
              chapterDir.path,
              'ayah_${ayah.toString().padLeft(3, '0')}$extension',
            ),
          );

          if (!await destination.exists()) {
            await _downloadAudioFile(
              client: client,
              source: audioFile.url,
              destination: destination,
            );
          }

          downloaded++;
          state = state.copyWith(
            completedCount: downloaded,
            progress: downloaded / totalVerses,
          );
        }
      }

      state = state.copyWith(
        status: errors > 0
            ? QuranAudioDownloadStatus.failed
            : QuranAudioDownloadStatus.completed,
        progress: 1.0,
        completedCount: totalVerses,
        currentVerse: 'اكتمل التنزيل.',
        message: errors > 0
            ? 'اكتمل التنزيل مع بعض الأخطاء.'
            : 'اكتمل تنزيل جميع ملفات الصوت.',
        errorMessage: errors > 0
            ? 'فشل تنزيل بعض الآيات. راجع الاتصال وحاول مرة أخرى.'
            : null,
      );
    } on Object catch (error, stackTrace) {
      state = state.copyWith(
        status: QuranAudioDownloadStatus.failed,
        errorMessage: error.toString(),
        message: 'حدث خطأ أثناء تنزيل الصوت.',
      );
      debugPrint('Quran audio download error: $error');
      debugPrint('$stackTrace');
    } finally {
      client.close(force: true);
    }
  }

  Future<Directory> _prepareSaveDirectory(String reciterName) async {
    final baseDirectory = await getApplicationDocumentsDirectory();
    final sanitizedReciterName = _sanitizeFileName(reciterName);
    final saveDirectory = Directory(
      path.join(baseDirectory.path, 'quran-audio', sanitizedReciterName),
    );
    await saveDirectory.create(recursive: true);
    return saveDirectory;
  }

  int _countTotalVerses() {
    var total = 0;
    for (var surah = 1; surah <= totalSurahCount; surah++) {
      total += getVerseCount(surah);
    }
    return total;
  }

  Future<void> _downloadAudioFile({
    required HttpClient client,
    required Uri source,
    required File destination,
  }) async {
    final request = await client.getUrl(source);
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'تعذر تنزيل الملف: ${response.statusCode}',
        uri: source,
      );
    }

    final bytes = await consolidateHttpClientResponseBytes(response);
    await destination.writeAsBytes(bytes, flush: true);
  }

  String _sanitizeFileName(String input) {
    return input
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^\w\-_.]'), '');
  }
}
