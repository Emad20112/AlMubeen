import 'dart:convert';
import 'dart:io';

import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// يخزّن قائمة قراء خدمة Islamic.app في ملف JSON محلي.
///
/// السبب: قراء Quran.com يُحفظون في قاعدة البيانات المحلية عبر
/// [QuranReciterLocalDataSource] لذا يظهرون دائماً حتى بدون إنترنت، بينما كان
/// قراء Islamic.app يُجلبون من الشبكة فقط في كل مرة، ويختفون تماماً عند الانقطاع
/// رغم وجود ملفاتهم الصوتية المحلية. هذا المخزن يجعل بياناتهم متاحة دائماً.
class IslamicAppRecitationStore {
  IslamicAppRecitationStore({this.fileName = 'islamic_app_recitations.json'});

  final String fileName;
  File? _cachedFile;

  Future<List<QuranRecitation>> load() async {
    try {
      final file = await _resolveFile();
      if (!await file.exists()) return const [];

      final encoded = await file.readAsString();
      if (encoded.trim().isEmpty) return const [];

      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map((e) => _fromJson(e.cast<String, dynamic>()))
          .whereType<QuranRecitation>()
          .toList(growable: false);
    } on Object catch (error, stackTrace) {
      debugPrint('IslamicAppRecitationStore.load failed: $error\n$stackTrace');
      return const [];
    }
  }

  Future<void> save(List<QuranRecitation> recitations) async {
    try {
      final file = await _resolveFile();
      await file.parent.create(recursive: true);
      final encoded = jsonEncode([for (final r in recitations) _toJson(r)]);
      await file.writeAsString(encoded, flush: true);
    } on Object catch (error, stackTrace) {
      debugPrint('IslamicAppRecitationStore.save failed: $error\n$stackTrace');
    }
  }

  Future<void> clear() async {
    try {
      final file = await _resolveFile();
      if (await file.exists()) {
        await file.delete();
      }
    } on Object catch (error, stackTrace) {
      debugPrint('IslamicAppRecitationStore.clear failed: $error\n$stackTrace');
    }
  }

  Future<File> _resolveFile() async {
    final cached = _cachedFile;
    if (cached != null) return cached;

    Directory directory;
    try {
      directory = await getApplicationSupportDirectory();
    } on Object catch (error, stackTrace) {
      debugPrint(
        'IslamicAppRecitationStore: falling back to temp storage: '
        '$error\n$stackTrace',
      );
      directory = Directory.systemTemp;
    }

    final file = File(p.join(directory.path, fileName));
    _cachedFile = file;
    return file;
  }

  static Map<String, dynamic> _toJson(QuranRecitation r) {
    return {
      'id': r.id,
      'reciterName': r.reciterName,
      'style': r.style,
      'translatedName': r.translatedName,
      'languageName': r.languageName,
      'identifier': r.identifier,
      'hasAyahAudio': r.hasAyahAudio,
      'hasSurahAudio': r.hasSurahAudio,
      'category': r.category,
    };
  }

  static QuranRecitation? _fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) return null;

    final reciterName = json['reciterName'];
    if (reciterName is! String || reciterName.isEmpty) return null;

    return QuranRecitation(
      id: id,
      reciterName: reciterName,
      style: _readString(json['style']),
      translatedName: _readString(json['translatedName']),
      languageName: _readString(json['languageName']),
      identifier: _readString(json['identifier']),
      hasAyahAudio: json['hasAyahAudio'] as bool? ?? true,
      hasSurahAudio: json['hasSurahAudio'] as bool? ?? true,
      category: _readString(json['category']),
    );
  }

  static String? _readString(Object? value) {
    final string = value?.toString().trim();
    return string == null || string.isEmpty ? null : string;
  }
}
