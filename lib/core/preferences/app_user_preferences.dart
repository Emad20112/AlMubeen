import 'dart:convert';
import 'dart:io';

import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const Object _unset = Object();

enum AppThemePreference { system, light, dark }

@immutable
class AppUserPreferences {
  const AppUserPreferences({
    required this.hasCompletedWelcome,
    required this.themePreference,
    required this.fontScale,
    required this.preferredReciterId,
    required this.preferredReciterName,
    required this.autoContinueFromLastPosition,
    required this.easyListeningMode,
    required this.recentSleepTimers,
  });

  const AppUserPreferences.initial()
    : hasCompletedWelcome = false,
      themePreference = AppThemePreference.system,
      fontScale = 1.0,
      preferredReciterId = null,
      preferredReciterName = null,
      autoContinueFromLastPosition = true,
      easyListeningMode = true,
      recentSleepTimers = const [];

  final bool hasCompletedWelcome;
  final AppThemePreference themePreference;
  final double fontScale;
  final int? preferredReciterId;
  final String? preferredReciterName;
  final bool autoContinueFromLastPosition;
  final bool easyListeningMode;
  final List<int> recentSleepTimers;

  ThemeMode get resolvedThemeMode => switch (themePreference) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
    AppThemePreference.system => ThemeMode.system,
  };

  bool get hasSavedPreferences {
    return themePreference != AppThemePreference.system ||
        (fontScale - 1.0).abs() > 0.001 ||
        preferredReciterId != null ||
        !autoContinueFromLastPosition ||
        !easyListeningMode ||
        recentSleepTimers.isNotEmpty;
  }

  AppUserPreferences copyWith({
    bool? hasCompletedWelcome,
    AppThemePreference? themePreference,
    double? fontScale,
    Object? preferredReciterId = _unset,
    Object? preferredReciterName = _unset,
    bool? autoContinueFromLastPosition,
    bool? easyListeningMode,
    List<int>? recentSleepTimers,
  }) {
    return AppUserPreferences(
      hasCompletedWelcome: hasCompletedWelcome ?? this.hasCompletedWelcome,
      themePreference: themePreference ?? this.themePreference,
      fontScale: fontScale ?? this.fontScale,
      preferredReciterId: preferredReciterId == _unset
          ? this.preferredReciterId
          : preferredReciterId as int?,
      preferredReciterName: preferredReciterName == _unset
          ? this.preferredReciterName
          : preferredReciterName as String?,
      autoContinueFromLastPosition:
          autoContinueFromLastPosition ?? this.autoContinueFromLastPosition,
      easyListeningMode: easyListeningMode ?? this.easyListeningMode,
      recentSleepTimers: recentSleepTimers ?? this.recentSleepTimers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCompletedWelcome': hasCompletedWelcome,
      'themePreference': themePreference.name,
      'fontScale': fontScale,
      'preferredReciterId': preferredReciterId,
      'preferredReciterName': preferredReciterName,
      'autoContinueFromLastPosition': autoContinueFromLastPosition,
      'easyListeningMode': easyListeningMode,
      'recentSleepTimers': recentSleepTimers,
    };
  }

  factory AppUserPreferences.fromJson(Map<String, dynamic> json) {
    return AppUserPreferences(
      hasCompletedWelcome: json['hasCompletedWelcome'] as bool? ?? false,
      themePreference: _themePreferenceFromJson(
        json['themePreference'] as String?,
      ),
      fontScale: _readDouble(json['fontScale']) ?? 1.0,
      preferredReciterId: _readInt(json['preferredReciterId']),
      preferredReciterName: json['preferredReciterName'] as String?,
      autoContinueFromLastPosition:
          json['autoContinueFromLastPosition'] as bool? ?? true,
      easyListeningMode: json['easyListeningMode'] as bool? ?? true,
      recentSleepTimers: (json['recentSleepTimers'] as List<dynamic>?)
              ?.map((e) => _readInt(e) ?? 0)
              .where((e) => e > 0)
              .toList() ??
          const [],
    );
  }

  static double? _readDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _readInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static AppThemePreference _themePreferenceFromJson(String? value) {
    return switch (value) {
      'light' => AppThemePreference.light,
      'dark' => AppThemePreference.dark,
      _ => AppThemePreference.system,
    };
  }
}

class AppUserPreferencesStore {
  AppUserPreferencesStore({this.fileName = 'app_user_preferences.json'});

  final String fileName;
  File? _cachedFile;

  Future<AppUserPreferences> read() async {
    final file = await _resolveFile();

    if (!await file.exists()) {
      return const AppUserPreferences.initial();
    }

    try {
      final encoded = await file.readAsString();
      final decoded = jsonDecode(encoded);
      if (decoded is Map<String, dynamic>) {
        return AppUserPreferences.fromJson(decoded);
      }
      if (decoded is Map) {
        return AppUserPreferences.fromJson(decoded.cast<String, dynamic>());
      }
    } catch (error, stackTrace) {
      debugPrint('AppUserPreferencesStore.read failed: $error\n$stackTrace');
    }

    return const AppUserPreferences.initial();
  }

  Future<void> write(AppUserPreferences preferences) async {
    final file = await _resolveFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(preferences.toJson()));
  }

  Future<File> _resolveFile() async {
    final cached = _cachedFile;
    if (cached != null) {
      return cached;
    }

    Directory directory;
    try {
      directory = await getApplicationSupportDirectory();
    } catch (error, stackTrace) {
      debugPrint(
        'AppUserPreferencesStore: falling back to temp storage: $error\n$stackTrace',
      );
      directory = Directory.systemTemp;
    }
    final file = File(p.join(directory.path, fileName));
    _cachedFile = file;
    return file;
  }
}

final appUserPreferencesStoreProvider = Provider<AppUserPreferencesStore>((
  ref,
) {
  return AppUserPreferencesStore();
});

final appUserPreferencesProvider =
    AsyncNotifierProvider<AppUserPreferencesController, AppUserPreferences>(
      AppUserPreferencesController.new,
    );

class AppUserPreferencesController extends AsyncNotifier<AppUserPreferences> {
  late final AppUserPreferencesStore _store;

  @override
  Future<AppUserPreferences> build() async {
    _store = ref.watch(appUserPreferencesStoreProvider);
    return _store.read();
  }

  AppUserPreferences get _currentValue {
    return state.maybeWhen(
      data: (value) => value,
      orElse: () => const AppUserPreferences.initial(),
    );
  }

  Future<void> completeWelcome() {
    return _save(_currentValue.copyWith(hasCompletedWelcome: true));
  }

  Future<void> setThemePreference(AppThemePreference preference) {
    return _save(_currentValue.copyWith(themePreference: preference));
  }

  Future<void> setFontScale(double scale) {
    return _save(
      _currentValue.copyWith(fontScale: scale.clamp(0.9, 1.25).toDouble()),
    );
  }

  Future<void> setPreferredReciter(QuranRecitation? recitation) {
    return _save(
      _currentValue.copyWith(
        preferredReciterId: recitation?.id,
        preferredReciterName: recitation == null
            ? null
            : _recitationLabel(recitation),
      ),
    );
  }

  Future<void> setAutoContinueFromLastPosition(bool value) {
    return _save(_currentValue.copyWith(autoContinueFromLastPosition: value));
  }

  Future<void> setEasyListeningMode(bool value) {
    return _save(_currentValue.copyWith(easyListeningMode: value));
  }

  Future<void> addRecentSleepTimer(int seconds) async {
    if (seconds <= 0) return;
    final list = List<int>.from(_currentValue.recentSleepTimers);
    list.remove(seconds);
    list.insert(0, seconds);
    if (list.length > 5) {
      list.removeLast();
    }
    return _save(_currentValue.copyWith(recentSleepTimers: list));
  }

  Future<void> _save(AppUserPreferences updated) async {
    state = AsyncData(updated);
    try {
      await _store.write(updated);
    } catch (error, stackTrace) {
      debugPrint(
        'AppUserPreferencesController save failed: $error\n$stackTrace',
      );
    }
  }

  String _recitationLabel(QuranRecitation recitation) {
    final translatedName = recitation.translatedName;
    final style = recitation.style;
    if (translatedName != null && translatedName != recitation.reciterName) {
      return '$translatedName - ${recitation.reciterName}';
    }
    if (style != null && style.trim().isNotEmpty) {
      return '${recitation.reciterName} - $style';
    }
    return recitation.reciterName;
  }
}
