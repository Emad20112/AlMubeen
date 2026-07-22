import 'dart:convert';

import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuranTextDownloadStatus {
  downloading,
  paused,
}

enum QuranTextDownloadKind {
  tafsir,
  translation,
}

enum QuranAudioDownloadKind {
  fullQuran,
  surah,
}

@immutable
final class QuranTextDownloadSession {
  const QuranTextDownloadSession({
    required this.kind,
    required this.status,
    required this.resourceId,
    required this.name,
    this.authorName,
    this.translatedAuthorName,
    this.slug,
    this.languageName,
    this.resourceName,
    required this.selectOnComplete,
    required this.updatedAt,
  });

  final QuranTextDownloadKind kind;
  final QuranTextDownloadStatus status;
  final int resourceId;
  final String name;
  final String? authorName;
  final String? translatedAuthorName;
  final String? slug;
  final String? languageName;
  final String? resourceName;
  final bool selectOnComplete;
  final DateTime updatedAt;

  bool get isDownloading => status == QuranTextDownloadStatus.downloading;

  Tafsir toTafsir() {
    return Tafsir(
      id: resourceId,
      name: name,
      authorName: authorName,
      translatedAuthorName: translatedAuthorName,
      slug: slug,
      languageName: languageName,
      resourceName: resourceName,
    );
  }

  Translation toTranslation() {
    return Translation(
      id: resourceId,
      name: name,
      authorName: authorName,
      translatedAuthorName: translatedAuthorName,
      slug: slug,
      languageName: languageName,
      resourceName: resourceName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'status': status.name,
      'resourceId': resourceId,
      'name': name,
      'authorName': authorName,
      'translatedAuthorName': translatedAuthorName,
      'slug': slug,
      'languageName': languageName,
      'resourceName': resourceName,
      'selectOnComplete': selectOnComplete,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory QuranTextDownloadSession.fromJson(Map<String, dynamic> json) {
    return QuranTextDownloadSession(
      kind: _kindFromJson(json['kind'] as String?),
      status: _statusFromJson(json['status'] as String?),
      resourceId: _readInt(json['resourceId']) ?? 0,
      name: json['name'] as String? ?? '',
      authorName: json['authorName'] as String?,
      translatedAuthorName: json['translatedAuthorName'] as String?,
      slug: json['slug'] as String?,
      languageName: json['languageName'] as String?,
      resourceName: json['resourceName'] as String?,
      selectOnComplete: json['selectOnComplete'] as bool? ?? true,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  QuranTextDownloadSession copyWith({
    QuranTextDownloadStatus? status,
    DateTime? updatedAt,
  }) {
    return QuranTextDownloadSession(
      kind: kind,
      status: status ?? this.status,
      resourceId: resourceId,
      name: name,
      authorName: authorName,
      translatedAuthorName: translatedAuthorName,
      slug: slug,
      languageName: languageName,
      resourceName: resourceName,
      selectOnComplete: selectOnComplete,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static QuranTextDownloadKind _kindFromJson(String? value) {
    return switch (value) {
      'translation' => QuranTextDownloadKind.translation,
      _ => QuranTextDownloadKind.tafsir,
    };
  }

  static QuranTextDownloadStatus _statusFromJson(String? value) {
    return switch (value) {
      'paused' => QuranTextDownloadStatus.paused,
      _ => QuranTextDownloadStatus.downloading,
    };
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

@immutable
final class QuranAudioDownloadSession {
  const QuranAudioDownloadSession({
    required this.kind,
    required this.recitationId,
    required this.reciterName,
    this.style,
    this.translatedName,
    this.languageName,
    this.surahNumber,
    required this.updatedAt,
  });

  final QuranAudioDownloadKind kind;
  final int recitationId;
  final String reciterName;
  final String? style;
  final String? translatedName;
  final String? languageName;
  final int? surahNumber;
  final DateTime updatedAt;

  bool get isFullQuran => kind == QuranAudioDownloadKind.fullQuran;

  QuranRecitation toRecitation() {
    return QuranRecitation(
      id: recitationId,
      reciterName: reciterName,
      style: style,
      translatedName: translatedName,
      languageName: languageName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'recitationId': recitationId,
      'reciterName': reciterName,
      'style': style,
      'translatedName': translatedName,
      'languageName': languageName,
      'surahNumber': surahNumber,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory QuranAudioDownloadSession.fromJson(Map<String, dynamic> json) {
    return QuranAudioDownloadSession(
      kind: _audioKindFromJson(json['kind'] as String?),
      recitationId: _readInt(json['recitationId']) ?? 0,
      reciterName: json['reciterName'] as String? ?? '',
      style: json['style'] as String?,
      translatedName: json['translatedName'] as String?,
      languageName: json['languageName'] as String?,
      surahNumber: _readInt(json['surahNumber']),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static QuranAudioDownloadKind _audioKindFromJson(String? value) {
    return switch (value) {
      'surah' => QuranAudioDownloadKind.surah,
      _ => QuranAudioDownloadKind.fullQuran,
    };
  }
}

class QuranDownloadSessionStore {
  static const String _tafsirSessionKey = 'quran_text_download_session_tafsir';
  static const String _translationSessionKey =
      'quran_text_download_session_translation';

  Future<void> saveTafsirSession(
    Tafsir tafsir, {
    required bool selectOnComplete,
    QuranTextDownloadStatus status = QuranTextDownloadStatus.downloading,
  }) async {
    await _saveSession(
      _tafsirSessionKey,
      QuranTextDownloadSession(
        kind: QuranTextDownloadKind.tafsir,
        status: status,
        resourceId: tafsir.id,
        name: tafsir.name,
        authorName: tafsir.authorName,
        translatedAuthorName: tafsir.translatedAuthorName,
        slug: tafsir.slug,
        languageName: tafsir.languageName,
        resourceName: tafsir.resourceName,
        selectOnComplete: selectOnComplete,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateTafsirStatus(QuranTextDownloadStatus status) async {
    final session = await readTafsirSession();
    if (session == null) return;
    await _saveSession(
      _tafsirSessionKey,
      session.copyWith(status: status, updatedAt: DateTime.now()),
    );
  }

  Future<QuranTextDownloadSession?> readTafsirSession() async {
    return _readSession(_tafsirSessionKey);
  }

  Future<void> clearTafsirSession() async {
    await _clearSession(_tafsirSessionKey);
  }

  Future<void> saveTranslationSession(
    Translation translation, {
    required bool selectOnComplete,
    QuranTextDownloadStatus status = QuranTextDownloadStatus.downloading,
  }) async {
    await _saveSession(
      _translationSessionKey,
      QuranTextDownloadSession(
        kind: QuranTextDownloadKind.translation,
        status: status,
        resourceId: translation.id,
        name: translation.name,
        authorName: translation.authorName,
        translatedAuthorName: translation.translatedAuthorName,
        slug: translation.slug,
        languageName: translation.languageName,
        resourceName: translation.resourceName,
        selectOnComplete: selectOnComplete,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateTranslationStatus(QuranTextDownloadStatus status) async {
    final session = await readTranslationSession();
    if (session == null) return;
    await _saveSession(
      _translationSessionKey,
      session.copyWith(status: status, updatedAt: DateTime.now()),
    );
  }

  Future<QuranTextDownloadSession?> readTranslationSession() async {
    return _readSession(_translationSessionKey);
  }

  Future<void> clearTranslationSession() async {
    await _clearSession(_translationSessionKey);
  }

  Future<void> saveAudioSession(
    QuranAudioDownloadSession session,
  ) async {
    await _saveSession(_audioSessionKey(session.kind), session.toJson());
  }

  Future<QuranAudioDownloadSession?> readAudioSession({
    QuranAudioDownloadKind? kind,
  }) async {
    if (kind != null) {
      return _readAudioSession(_audioSessionKey(kind));
    }

    final fullQuranSession = await _readAudioSession(
      _audioSessionKey(QuranAudioDownloadKind.fullQuran),
    );
    if (fullQuranSession != null) {
      return fullQuranSession;
    }

    return _readAudioSession(_audioSessionKey(QuranAudioDownloadKind.surah));
  }

  Future<void> clearAudioSession({
    QuranAudioDownloadKind? kind,
  }) async {
    if (kind != null) {
      await _clearSession(_audioSessionKey(kind));
      return;
    }

    await _clearSession(_audioSessionKey(QuranAudioDownloadKind.fullQuran));
    await _clearSession(_audioSessionKey(QuranAudioDownloadKind.surah));
  }

  Future<void> _saveSession(
    String key,
    Object session,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final json = switch (session) {
      QuranTextDownloadSession value => value.toJson(),
      QuranAudioDownloadSession value => value.toJson(),
      Map<String, dynamic> value => value,
      _ => throw ArgumentError.value(session, 'session'),
    };
    await prefs.setString(key, jsonEncode(json));
  }

  Future<QuranTextDownloadSession?> _readSession(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(key);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return QuranTextDownloadSession.fromJson(decoded);
      }
      if (decoded is Map) {
        return QuranTextDownloadSession.fromJson(
          decoded.cast<String, dynamic>(),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('QuranDownloadSessionStore._readSession failed: $error');
      debugPrint('$stackTrace');
    }

    return null;
  }

  Future<void> _clearSession(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  String _audioSessionKey(QuranAudioDownloadKind kind) {
    return switch (kind) {
      QuranAudioDownloadKind.fullQuran =>
        'quran_audio_download_session_full_quran',
      QuranAudioDownloadKind.surah => 'quran_audio_download_session_surah',
    };
  }

  Future<QuranAudioDownloadSession?> _readAudioSession(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(key);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return QuranAudioDownloadSession.fromJson(decoded);
      }
      if (decoded is Map) {
        return QuranAudioDownloadSession.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (error, stackTrace) {
      debugPrint('QuranDownloadSessionStore._readAudioSession failed: $error');
      debugPrint('$stackTrace');
    }

    return null;
  }
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
