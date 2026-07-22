import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/dua/domain/models/dua_item.dart';
import 'package:al_mubeen/features/dua/domain/models/dua_category.dart';

const Map<String, int> _duaPriorityMap = {
  'دعاء الاستخارة': 1,
  'دعاء السفر': 2,
  'دعاء الهم والحزن': 3,
  'دعاء الكرب': 4,
  'دعاء زيارة القبور': 5,
  'دعاء زيارة المريض': 5,
  'الدعاء لمن لبس ثوباً جديداً': 5,
  'دعاء قضاء الدين': 6,
  'دعاء لبس الثوب': 7,
  'دعاء دخول الخلاء': 8,
  'دعاء الخروج من الخلاء': 9,
  'دعاء الذهاب إلى المسجد': 10,
  'دعاء دخول المسجد': 11,
  'دعاء الخروج من المسجد': 12,
  'دعاء قبل الطعام': 13,
  'دعاء عند الفراغ من الطعام': 14,
  'دعاء الرعد': 15,
  'الدعاء إذا نزل المطر': 16,
  'دعاء دخول السوق': 17,
  'دعاء الغضب': 18,
  'دعاء يوم عرفة': 19,
  'دعاء صلاة الاستخارة': 1,
};

class DuaLocalDataSource {
  DuaLocalDataSource._(this._db);
  static DuaLocalDataSource? _instance;

  final AppDatabase _db;

  List<DuaCategory>? _categories;
  Map<String, List<DuaItem>>? _itemsMap;
  Completer<void>? _loadingCompleter;

  factory DuaLocalDataSource(AppDatabase db) {
    _instance ??= DuaLocalDataSource._(db);
    return _instance!;
  }

  List<DuaCategory>? get cachedCategories => _categories;

  static const String _jsonPath = 'assets/data/hisn_almuslim.json';

  Future<void> _ensureLoaded() async {
    if (_categories != null) return;
    if (_loadingCompleter != null) return _loadingCompleter!.future;

    _loadingCompleter = Completer<void>();
    try {
      // Try loading from SQLite first
      final cachedCategories = await (_db.select(_db.hisnContentCache)
            ..where((t) => t.type.equals('dua')))
          .get();
      if (cachedCategories.isNotEmpty) {
        _categories = cachedCategories
            .map(
              (e) => DuaCategory(
                id: e.id,
                title: e.title,
                subtitle: e.subtitle,
                iconKey: e.iconKey,
                count: e.count,
                arabicTitle: e.arabicTitle,
                priority: e.priority,
              ),
            )
            .toList();
        _itemsMap = {};
        final cachedItems = await (_db.select(_db.hisnContentItemCache)
              ..where((t) => t.type.equals('dua')))
            .get();
        for (final item in cachedItems) {
          final duaItem = DuaItem(
            id: item.id,
            categoryId: item.categoryId,
            text: item.contentText,
            source: item.source,
            fadl: item.fadl,
            reference: item.reference,
            translation: item.translation,
          );
          _itemsMap!.putIfAbsent(item.categoryId, () => []).add(duaItem);
        }
        _loadingCompleter!.complete();
        return;
      }

      // Parse JSON in background isolate, then persist to SQLite
      final jsonString = await rootBundle.loadString(_jsonPath);
      final result = await compute(_parseAndSort, jsonString);
      _categories = result.categories;
      _itemsMap = result.itemsMap;

      await _persistToDb(result.categories, result.itemsMap);
      _loadingCompleter!.complete();
    } catch (e, st) {
      _loadingCompleter!.completeError(e, st);
    } finally {
      _loadingCompleter = null;
    }
  }

  Future<void> _persistToDb(
    List<DuaCategory> categories,
    Map<String, List<DuaItem>> itemsMap,
  ) async {
    await _db.batch(
      (batch) {
        batch.insertAll(
          _db.hisnContentCache,
          categories.map(
            (c) => HisnContentCacheCompanion.insert(
              id: c.id,
              title: c.title,
              subtitle: c.subtitle,
              iconKey: c.iconKey,
              count: c.count,
              arabicTitle: Value(c.arabicTitle),
              priority: Value(c.priority),
              type: 'dua',
            ),
          ),
        );
        for (final entry in itemsMap.entries) {
          batch.insertAll(
            _db.hisnContentItemCache,
            entry.value.map(
              (item) => HisnContentItemCacheCompanion.insert(
                id: item.id,
                categoryId: item.categoryId,
                contentText: item.text,
                source: item.source,
                fadl: Value(item.fadl),
                reference: Value(item.reference),
                translation: Value(item.translation),
                type: 'dua',
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<DuaCategory>> getCategories() async {
    await _ensureLoaded();
    return _categories!;
  }

  Future<DuaCategory?> getCategoryById(String id) async {
    await _ensureLoaded();
    for (final c in _categories!) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<List<DuaItem>> getItemsByCategory(String categoryId) async {
    await _ensureLoaded();
    return _itemsMap?[categoryId] ?? const [];
  }
}

class _ParseResult {
  final List<DuaCategory> categories;
  final Map<String, List<DuaItem>> itemsMap;
  _ParseResult(this.categories, this.itemsMap);
}

_ParseResult _parseAndSort(String jsonString) {
  final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
  final categories = <DuaCategory>[];
  final itemsMap = <String, List<DuaItem>>{};
  int catIdx = 0;

  for (final entry in jsonData.entries) {
    final title = entry.key;
    final data = entry.value;
    if (data is! Map<String, dynamic>) continue;
    if (!_isDuaCategory(title)) continue;

    final id = 'dua_cat_${catIdx++}';
    final textList = data['text'] as List<dynamic>?;
    final footList = data['footnote'] as List<dynamic>?;
    final items = <DuaItem>[];

    if (textList != null) {
      for (int i = 0; i < textList.length; i++) {
        final footnote =
            footList != null && i < footList.length ? footList[i] as String : null;
        items.add(DuaItem(
          id: '${id}_item_$i',
          categoryId: id,
          text: textList[i] as String,
          source: footnote ?? '',
          fadl: null,
          reference: footnote,
          translation: null,
        ));
      }
    }

    itemsMap[id] = items;
    categories.add(DuaCategory(
      id: id,
      title: _mapTitle(title),
      subtitle: '${items.length} أدعية',
      iconKey: _mapIcon(title),
      count: items.length,
      arabicTitle: title,
      priority: _duaPriorityMap[title] ?? 99,
    ));
  }

  categories.sort((a, b) => a.priority.compareTo(b.priority));
  return _ParseResult(categories, itemsMap);
}

bool _isDuaCategory(String t) {
  return t.contains('دعاء') || t.contains('أدعية') || t.contains('الدعاء');
}

String _mapTitle(String t) {
  const mappings = {
    'دعاء دخول الخلاء': 'دخول الخلاء',
    'دعاء الخروج من الخلاء': 'الخروج من الخلاء',
    'دعاء دخول المنزل': 'دخول المنزل',
    'دعاء الخروج من المنزل': 'الخروج من المنزل',
    'دعاء لبس الثوب': 'لبس الثوب',
    'دعاء الخروج من الثوب': 'الخروج من الثوب',
    'دعاء الأكل': 'قبل الأكل',
    'دعاء بعد الأكل': 'بعد الأكل',
    'دعاء الشرب': 'قبل الشرب',
    'دعاء بعد الشرب': 'بعد الشرب',
  };
  return mappings[t] ?? t;
}

String _mapIcon(String t) {
  if (t.contains('الخلاء') || t.contains('خلاء')) return 'door';
  if (t.contains('المنزل') || t.contains('خروج')) return 'home_exit';
  if (t.contains('الأكل') || t.contains('أكل')) return 'food';
  if (t.contains('الشرب') || t.contains('شرب')) return 'drink';
  if (t.contains('الثوب') || t.contains('لبس')) return 'clothes';
  if (t.contains('السفر') || t.contains('سفر')) return 'travel';
  if (t.contains('المرض') || t.contains('مريض')) return 'health';
  if (t.contains('الصلاة') || t.contains('صلاة')) return 'mosque';
  return 'dua';
}
