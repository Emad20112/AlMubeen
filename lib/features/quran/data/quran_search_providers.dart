import 'package:al_mubeen/features/quran/data/local/tafsir_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/local/translation_local_data_source.dart';
import 'package:al_mubeen/features/quran/data/quran_catalog_providers.dart';
import 'package:al_mubeen/features/quran/data/quran_data_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// معرّفات البحث (Search) عبر التفسير والترجمة والقرّاء.
///
/// تم فصل هذا الملف من `quran_providers.dart` لتسريع الـ incremental
/// compilation وتسهيل الصيانة. استخدم `quran_providers.dart` كـ barrel.
/// ─────────────────────────────────────────────────────────────────────────────

final tafsirSearchProvider = FutureProvider.autoDispose
    .family<List<TafsirSearchResult>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <TafsirSearchResult>[];
      }

      final localDataSource = ref.watch(tafsirLocalDataSourceProvider);
      return localDataSource.searchTafsirTexts(trimmedQuery);
    });

final translationSearchProvider = FutureProvider.autoDispose
    .family<List<TranslationSearchResult>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <TranslationSearchResult>[];
      }

      final localDataSource = ref.watch(translationLocalDataSourceProvider);
      return localDataSource.searchTexts(trimmedQuery);
    });

final recitationSearchProvider = FutureProvider.autoDispose
    .family<List<QuranRecitation>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <QuranRecitation>[];
      }

      final localDataSource = ref.watch(quranReciterLocalDataSourceProvider);
      final result = await localDataSource.searchRecitations(trimmedQuery);
      return result.when(
        success: (recitations) => recitations,
        error: (_) => const <QuranRecitation>[],
      );
    });

/// Search tafsir books by name/author
final tafsirNameSearchProvider = FutureProvider.autoDispose
    .family<List<Tafsir>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <Tafsir>[];
      }
      final normalized = _normalizeForSearch(trimmedQuery);
      final tafsirs = await ref.watch(tafsirsProvider.future);
      return tafsirs.where((t) {
        final searchable = [
          t.name,
          t.authorName,
          t.translatedAuthorName,
          t.resourceName,
          t.slug,
        ].whereType<String>().join(' ');
        return _normalizeForSearch(searchable).contains(normalized);
      }).toList();
    });

/// Search translation books by name/author
final translationNameSearchProvider = FutureProvider.autoDispose
    .family<List<Translation>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <Translation>[];
      }
      final normalized = _normalizeForSearch(trimmedQuery);
      final translations = await ref.watch(translationsProvider.future);
      return translations.where((t) {
        final searchable = [
          t.name,
          t.authorName,
          t.translatedAuthorName,
          t.resourceName,
          t.slug,
        ].whereType<String>().join(' ');
        return _normalizeForSearch(searchable).contains(normalized);
      }).toList();
    });

/// Search reciters by name
final reciterNameSearchProvider = FutureProvider.autoDispose
    .family<List<QuranRecitation>, String>((ref, query) async {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) {
        return const <QuranRecitation>[];
      }
      final normalized = _normalizeForSearch(trimmedQuery);
      final recitations = await ref.watch(quranRecitationsProvider.future);
      return recitations.where((r) {
        final searchable = [
          r.reciterName,
          r.translatedName,
          r.style,
        ].whereType<String>().join(' ');
        return _normalizeForSearch(searchable).contains(normalized);
      }).toList();
    });

/// 🛡️ PERF: تطبيع النص العربي للبحث — إزالة التشكيل وتوحيد الألف/الهمزة.
String _normalizeForSearch(String input) {
  return input
      .replaceAll('ٱ', 'ا')
      .replaceAll('آ', 'ا')
      .replaceAll('أ', 'ا')
      .replaceAll('إ', 'ا')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ى', 'ي')
      .replaceAll('ـ', '')
      .replaceAll(
        RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
        '',
      )
      .toLowerCase()
      .trim();
}
