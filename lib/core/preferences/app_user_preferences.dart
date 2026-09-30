import 'dart:convert';

import 'package:al_mubeen/core/storage/kv_storage.dart';
import 'package:al_mubeen/core/storage/kv_storage_provider.dart';
import 'package:al_mubeen/core/storage_keys.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    required this.lastQuranPage,
  });

  const AppUserPreferences.initial()
    : hasCompletedWelcome = false,
      themePreference = AppThemePreference.system,
      fontScale = 0.85,
      preferredReciterId = null,
      preferredReciterName = null,
      autoContinueFromLastPosition = true,
      easyListeningMode = true,
      recentSleepTimers = const [],
      lastQuranPage = null;

  final bool hasCompletedWelcome;
  final AppThemePreference themePreference;
  final double fontScale;
  final int? preferredReciterId;
  final String? preferredReciterName;
  final bool autoContinueFromLastPosition;
  final bool easyListeningMode;
  final List<int> recentSleepTimers;
  final int? lastQuranPage;

  ThemeMode get resolvedThemeMode => switch (themePreference) {
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
    AppThemePreference.system => ThemeMode.system,
  };

  bool get hasSavedPreferences {
    return themePreference != AppThemePreference.system ||
        (fontScale - 0.85).abs() > 0.001 ||
        preferredReciterId != null ||
        !autoContinueFromLastPosition ||
        !easyListeningMode ||
        recentSleepTimers.isNotEmpty ||
        lastQuranPage != null;
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
    Object? lastQuranPage = _unset,
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
      lastQuranPage: lastQuranPage == _unset
          ? this.lastQuranPage
          : lastQuranPage as int?,
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
      'lastQuranPage': lastQuranPage,
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
      recentSleepTimers:
          (json['recentSleepTimers'] as List<dynamic>?)
              ?.map((e) => _readInt(e) ?? 0)
              .where((e) => e > 0)
              .toList() ??
          const [],
      lastQuranPage: _readInt(json['lastQuranPage']),
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
  AppUserPreferencesStore([KvStorage? storage])
      : _storage = storage ?? currentKvStorage;

  final KvStorage _storage;

  AppUserPreferences read() {
    final recentTimersJson = _storage.getString(
      StorageKeys.appPreferencesRecentSleepTimers,
    );
    final recentSleepTimers = switch (recentTimersJson) {
      String value => _decodeSleepTimers(value),
      _ => const <int>[],
    };

    return AppUserPreferences(
      hasCompletedWelcome: _storage.getBool(
            StorageKeys.appPreferencesHasCompletedWelcome,
          ) ??
          false,
      themePreference: switch (_storage.getString(StorageKeys.appPreferencesTheme)) {
        'light' => AppThemePreference.light,
        'dark' => AppThemePreference.dark,
        _ => AppThemePreference.system,
      },
      fontScale: _storage.getDouble(StorageKeys.appPreferencesFontScale) ?? 0.85,
      preferredReciterId: _storage.getInt(
        StorageKeys.appPreferencesPreferredReciterId,
      ),
      preferredReciterName: _storage.getString(
        StorageKeys.appPreferencesPreferredReciterName,
      ),
      autoContinueFromLastPosition: _storage.getBool(
            StorageKeys.appPreferencesAutoContinue,
          ) ??
          true,
      easyListeningMode: _storage.getBool(
            StorageKeys.appPreferencesEasyListening,
          ) ??
          true,
      recentSleepTimers: recentSleepTimers,
      lastQuranPage: _storage.getInt(StorageKeys.appPreferencesLastQuranPage),
    );
  }

  void write(AppUserPreferences preferences) {
    _storage.setBool(
      StorageKeys.appPreferencesHasCompletedWelcome,
      preferences.hasCompletedWelcome,
    );
    _storage.setString(
      StorageKeys.appPreferencesTheme,
      preferences.themePreference.name,
    );
    _storage.setDouble(
      StorageKeys.appPreferencesFontScale,
      preferences.fontScale,
    );
    _writeNullableInt(
      StorageKeys.appPreferencesPreferredReciterId,
      preferences.preferredReciterId,
    );
    _writeNullableString(
      StorageKeys.appPreferencesPreferredReciterName,
      preferences.preferredReciterName,
    );
    _storage.setBool(
      StorageKeys.appPreferencesAutoContinue,
      preferences.autoContinueFromLastPosition,
    );
    _storage.setBool(
      StorageKeys.appPreferencesEasyListening,
      preferences.easyListeningMode,
    );
    _storage.setString(
      StorageKeys.appPreferencesRecentSleepTimers,
      jsonEncode(preferences.recentSleepTimers),
    );
    _writeNullableInt(
      StorageKeys.appPreferencesLastQuranPage,
      preferences.lastQuranPage,
    );
  }

  void _writeNullableInt(String key, int? value) {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage.setInt(key, value);
    }
  }

  void _writeNullableString(String key, String? value) {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage.setString(key, value);
    }
  }

  static List<int> _decodeSleepTimers(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const <int>[];
      return decoded
          .whereType<num>()
          .map((item) => item.toInt())
          .where((item) => item > 0)
          .toList(growable: false);
    } on Object {
      return const <int>[];
    }
  }
}

final appUserPreferencesStoreProvider = Provider<AppUserPreferencesStore>((
  ref,
) {
  return AppUserPreferencesStore(ref.watch(kvStorageProvider));
});

final appUserPreferencesProvider =
    AsyncNotifierProvider<AppUserPreferencesController, AppUserPreferences>(
      AppUserPreferencesController.new,
    );

class AppUserPreferencesController extends AsyncNotifier<AppUserPreferences> {
  late final AppUserPreferencesStore _store;
  AppUserPreferences? _cachedValue;

  @override
  AppUserPreferences build() {
    _store = ref.watch(appUserPreferencesStoreProvider);
    final preferences = _store.read();
    _cachedValue = preferences;
    return preferences;
  }

  AppUserPreferences get _currentValue {
    final cachedValue = _cachedValue;
    if (cachedValue != null) {
      return cachedValue;
    }

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
      _currentValue.copyWith(fontScale: scale.clamp(0.55, 1.25).toDouble()),
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

  Future<void> setLastQuranPage(int page) {
    return _save(
      _currentValue.copyWith(lastQuranPage: page.clamp(1, 604)),
      notifyListeners: false,
    );
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

  Future<void> _save(
    AppUserPreferences updated, {
    bool notifyListeners = true,
  }) async {
    _cachedValue = updated;
    if (notifyListeners) {
      state = AsyncData(updated);
    }

    try {
      _store.write(updated);
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
