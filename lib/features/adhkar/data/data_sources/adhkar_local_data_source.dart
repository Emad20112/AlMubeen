import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_category.dart';

const Map<String, int> _adhkarPriorityMap = {
  'أذكار الصباح': 1,
  'أذكار المساء': 2,
  'أذكار النوم': 3,
  'أذكار الاستيقاظ من النوم': 4,
  'الأذكار بعد السلام من الصلاة': 5,
  'أذكار بعد السلام من الصلاة': 5,
  'الذكر بعد الفراغ من الوضوء': 6,
  'الذكر قبل الوضوء': 7,
  'أذكار الأذان': 8,
  'أذكار دخول المسجد': 9,
  'أذكار الخروج من المسجد': 10,
  'الذكر عند الخروج من المنزل': 11,
  'الذكر عند الدخول المنزل': 12,
  'الذكر عند الدخول منزلا في سفر أو غيره': 13,
};

class AdhkarLocalDataSource {
  AdhkarLocalDataSource._(this._db);
  static AdhkarLocalDataSource? _instance;

  final AppDatabase _db;

  List<AdhkarCategory>? _categories;
  Map<String, List<AdhkarItem>>? _itemsMap;
  Completer<void>? _loadingCompleter;

  factory AdhkarLocalDataSource(AppDatabase db) {
    _instance ??= AdhkarLocalDataSource._(db);
    return _instance!;
  }

  List<AdhkarCategory>? get cachedCategories => _categories;

  static const String _jsonPath = 'assets/data/hisn_almuslim.json';

  Future<void> _ensureLoaded() async {
    if (_categories != null) return;
    if (_loadingCompleter != null) return _loadingCompleter!.future;

    _loadingCompleter = Completer<void>();
    try {
      // Try loading from SQLite first
      final cachedCategories = await (_db.select(_db.hisnContentCache)
            ..where((t) => t.type.equals('adhkar')))
          .get();
      if (cachedCategories.isNotEmpty) {
        _categories = cachedCategories
            .map(
              (e) => AdhkarCategory(
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
              ..where((t) => t.type.equals('adhkar')))
            .get();
        for (final item in cachedItems) {
          final adhkarItem = AdhkarItem(
            id: item.id,
            categoryId: item.categoryId,
            text: item.contentText,
            source: item.source,
            repeatCount: item.repeatCount,
            fadl: item.fadl,
            reference: item.reference,
            translation: item.translation,
          );
          _itemsMap!.putIfAbsent(item.categoryId, () => []).add(adhkarItem);
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
    List<AdhkarCategory> categories,
    Map<String, List<AdhkarItem>> itemsMap,
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
              type: 'adhkar',
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
                repeatCount: Value(item.repeatCount),
                fadl: Value(item.fadl),
                reference: Value(item.reference),
                translation: Value(item.translation),
                type: 'adhkar',
              ),
            ),
          );
        }
      },
    );
  }

  Future<List<AdhkarCategory>> getCategories() async {
    await _ensureLoaded();
    return _categories!;
  }

  Future<AdhkarCategory?> getCategoryById(String id) async {
    await _ensureLoaded();
    for (final c in _categories!) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<List<AdhkarItem>> getItemsByCategory(String categoryId) async {
    await _ensureLoaded();
    return _itemsMap?[categoryId] ?? const [];
  }
}

class _ParseResult {
  final List<AdhkarCategory> categories;
  final Map<String, List<AdhkarItem>> itemsMap;
  _ParseResult(this.categories, this.itemsMap);
}

_ParseResult _parseAndSort(String jsonString) {
  final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
  final categories = <AdhkarCategory>[];
  final itemsMap = <String, List<AdhkarItem>>{};
  int catIdx = 0;

  for (final entry in jsonData.entries) {
    final title = entry.key;
    final data = entry.value;
    if (data is! Map<String, dynamic>) continue;
    if (_isDuaCategory(title)) continue;

    final id = 'cat_${catIdx++}';
    final textList = data['text'] as List<dynamic>?;
    final footList = data['footnote'] as List<dynamic>?;
    final items = <AdhkarItem>[];

    if (textList != null) {
      for (int i = 0; i < textList.length; i++) {
        final footnote =
            footList != null && i < footList.length ? footList[i] as String : null;
        items.add(AdhkarItem(
          id: '${id}_item_$i',
          categoryId: id,
          text: textList[i] as String,
          source: footnote ?? '',
          repeatCount: 1,
          fadl: null,
          reference: footnote,
          translation: null,
        ));
      }
    }

    itemsMap[id] = items;
    categories.add(AdhkarCategory(
      id: id,
      title: _mapTitle(title),
      subtitle: '${items.length} أذكار',
      iconKey: _mapIcon(title),
      count: items.length,
      arabicTitle: title,
      priority: _adhkarPriorityMap[title] ?? 99,
    ));
  }

  categories.sort((a, b) => a.priority.compareTo(b.priority));
  return _ParseResult(categories, itemsMap);
}

bool _isDuaCategory(String t) {
  return t.contains('دعاء') || t.contains('أدعية') || t.contains('الدعاء');
}

String _mapTitle(String t) {
  return t == 'أذكار الاستيقاظ من النوم' ? 'أذكار الاستيقاظ' : t;
}

String _mapIcon(String t) {
  if (t.contains('الصباح') || t.contains('صباح')) return 'sun';
  if (t.contains('المساء') || t.contains('مساء')) return 'moon';
  if (t.contains('النوم') || t.contains('نوم')) return 'sleep';
  if (t.contains('الصلاة') || t.contains('صلاة')) return 'mosque';
  if (t.contains('الاستيقاظ') || t.contains('استيقاظ')) return 'alarm';
  if (t.contains('الخلاء') || t.contains('خلاء')) return 'door';
  if (t.contains('المنزل') || t.contains('خروج')) return 'home_exit';
  if (t.contains('المسجد')) return 'mosque';
  if (t.contains('الوضوء') || t.contains('وضوء')) return 'water';
  if (t.contains('الأذان') || t.contains('أذان')) return 'loudspeaker';
  if (t.contains('الحج') || t.contains('العمرة') || t.contains('المحرم')) return 'kaaba';
  if (t.contains('السفر')) return 'travel';
  if (t.contains('تسبيح')) return 'tasbih';
  if (t.contains('الذكر') || t.contains('ذكر')) return 'dhikr';
  return 'quran';
}
