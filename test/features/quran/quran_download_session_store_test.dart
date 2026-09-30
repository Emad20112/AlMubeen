import 'package:al_mubeen/core/storage/memory_kv_storage.dart';
import 'package:al_mubeen/features/quran/application/quran_download_session_store.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranDownloadSessionStore', () {
    late QuranDownloadSessionStore store;

    setUp(() {
      store = QuranDownloadSessionStore(MemoryKvStorage());
    });

    test('saves and restores tafsir sessions', () async {
      const tafsir = Tafsir(
        id: 16,
        name: 'Tafsir Al-Muyassar',
        authorName: 'مجمع الملك فهد',
        slug: 'ar-tafsir-muyassar',
        languageName: 'Arabic',
        resourceName: 'ar.muyassar',
      );

      await store.saveTafsirSession(
        tafsir,
        selectOnComplete: true,
      );

      final session = await store.readTafsirSession();
      expect(session, isNotNull);
      expect(session!.isDownloading, isTrue);
      expect(session.resourceId, tafsir.id);
      expect(session.name, tafsir.name);
      expect(session.selectOnComplete, isTrue);
      expect(session.toTafsir().resourceName, tafsir.resourceName);
    });

    test('updates status and clears translation sessions', () async {
      const translation = Translation(
        id: 23,
        name: 'English Translation',
        authorName: 'Translator',
        slug: 'en-translation',
        languageName: 'English',
        resourceName: 'en.translation',
      );

      await store.saveTranslationSession(
        translation,
        selectOnComplete: false,
      );
      await store.updateTranslationStatus(QuranTextDownloadStatus.paused);

      final pausedSession = await store.readTranslationSession();
      expect(pausedSession, isNotNull);
      expect(pausedSession!.status, QuranTextDownloadStatus.paused);

      await store.clearTranslationSession();
      expect(await store.readTranslationSession(), isNull);
    });
  });
}
