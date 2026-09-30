import 'dart:convert';

import 'package:al_mubeen/core/storage/kv_storage.dart';
import 'package:al_mubeen/core/storage/kv_storage_provider.dart';
import 'package:al_mubeen/core/storage_keys.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihNotifier extends Notifier<List<String>> {
  late final KvStorage _storage;

  static const List<String> _defaultDhikrs = [
    'سبحان الله',
    'أستغفر الله',
    'لا حول ولا قوة إلا بالله العلي العظيم',
    'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
    'سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر',
    'الله أكبر',
  ];

  @override
  List<String> build() {
    _storage = ref.read(kvStorageProvider);
    final encoded = _storage.getString(StorageKeys.tasbihDhikrList);
    final stored = switch (encoded) {
      String value => _decodeDhikrs(value),
      _ => const <String>[],
    };
    return stored.isEmpty ? _defaultDhikrs : stored;
  }

  void _saveState() {
    _storage.setString(StorageKeys.tasbihDhikrList, jsonEncode(state));
  }

  List<String> _decodeDhikrs(String encoded) {
    try {
      final decoded = jsonDecode(encoded);
      if (decoded is! List) return const <String>[];
      return decoded.whereType<String>().toList(growable: false);
    } on Object {
      return const <String>[];
    }
  }

  void addDhikr(String dhikr) {
    if (dhikr.trim().isNotEmpty) {
      state = [...state, dhikr.trim()];
      _saveState();
    }
  }

  void editDhikr(int index, String newText) {
    if (index >= 0 && index < state.length && newText.trim().isNotEmpty) {
      final newList = List<String>.from(state);
      newList[index] = newText.trim();
      state = newList;
      _saveState();
    }
  }

  void removeDhikr(int index) {
    if (index >= 0 && index < state.length) {
      final newList = List<String>.from(state);
      newList.removeAt(index);
      state = newList;
      _saveState();
    }
  }
}

final tasbihControllerProvider =
    NotifierProvider<TasbihNotifier, List<String>>(TasbihNotifier.new);
