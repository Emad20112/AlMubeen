import 'dart:async';
import 'dart:convert';

import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hisnContentSharedStoreProvider = Provider<HisnContentSharedStore>((ref) {
  return HisnContentSharedStore(ref.watch(appDatabaseProvider));
});

enum HisnContentKind { adhkar, dua }

extension on HisnContentKind {
  String get dbType => switch (this) {
    HisnContentKind.adhkar => 'adhkar',
    HisnContentKind.dua => 'dua',
  };
}

@immutable
class HisnCategoryRecord {
  const HisnCategoryRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.count,
    required this.arabicTitle,
    required this.priority,
    required this.kind,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final int count;
  final String? arabicTitle;
  final int priority;
  final HisnContentKind kind;
}

@immutable
class HisnItemRecord {
  const HisnItemRecord({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.source,
    required this.repeatCount,
    required this.fadl,
    required this.reference,
    required this.translation,
    required this.kind,
  });

  final String id;
  final String categoryId;
  final String text;
  final String source;
  final int repeatCount;
  final String? fadl;
  final String? reference;
  final String? translation;
  final HisnContentKind kind;
}

@immutable
class HisnContentSnapshot {
  const HisnContentSnapshot({
    required this.categories,
    required this.itemsByCategory,
  });

  final List<HisnCategoryRecord> categories;
  final Map<String, List<HisnItemRecord>> itemsByCategory;
}

final class HisnContentSharedStore {
  HisnContentSharedStore(this._db);

  final AppDatabase _db;

  static const String _jsonPath = 'assets/data/hisn_almuslim.json';

  HisnContentSnapshot? _snapshot;
  Future<HisnContentSnapshot>? _loadingFuture;

  Future<List<HisnCategoryRecord>> getCategories(HisnContentKind kind) async {
    final snapshot = await _ensureLoaded();
    return snapshot.categories
        .where((category) => category.kind == kind)
        .toList(growable: false);
  }

  Future<HisnCategoryRecord?> getCategoryById(
    String categoryId,
    HisnContentKind kind,
  ) async {
    final categories = await getCategories(kind);
    for (final category in categories) {
      if (category.id == categoryId) {
        return category;
      }
    }
    return null;
  }

  Future<List<HisnItemRecord>> getItemsByCategory(
    String categoryId,
    HisnContentKind kind,
  ) async {
    final snapshot = await _ensureLoaded();
    final items =
        snapshot.itemsByCategory[categoryId] ?? const <HisnItemRecord>[];
    return items.where((item) => item.kind == kind).toList(growable: false);
  }

  Future<HisnContentSnapshot> _ensureLoaded() {
    final cached = _snapshot;
    if (cached != null) {
      return Future<HisnContentSnapshot>.value(cached);
    }

    final loadingFuture = _loadingFuture;
    if (loadingFuture != null) {
      return loadingFuture;
    }

    final loadFuture = _loadSnapshot();
    _loadingFuture = loadFuture;
    return loadFuture.whenComplete(() {
      if (identical(_loadingFuture, loadFuture)) {
        _loadingFuture = null;
      }
    });
  }

  Future<HisnContentSnapshot> _loadSnapshot() async {
    final fromDb = await _loadFromDatabase();
    if (fromDb != null) {
      _snapshot = fromDb;
      return fromDb;
    }

    final jsonString = await rootBundle.loadString(_jsonPath);
    final parsed = await compute(_parseHisnContent, jsonString);
    await _persistParsed(parsed);

    final snapshot = HisnContentSnapshot(
      categories: List<HisnCategoryRecord>.unmodifiable(parsed.categories),
      itemsByCategory: {
        for (final entry in parsed.itemsByCategory.entries)
          entry.key: List<HisnItemRecord>.unmodifiable(entry.value),
      },
    );

    _snapshot = snapshot;
    return snapshot;
  }

  Future<HisnContentSnapshot?> _loadFromDatabase() async {
    final categoryRows = await _db.select(_db.hisnContentCache).get();
    if (categoryRows.isEmpty) {
      return null;
    }

    final itemRows = await _db.select(_db.hisnContentItemCache).get();

    final categories =
        categoryRows
            .map(
              (row) => HisnCategoryRecord(
                id: row.id,
                title: row.title,
                subtitle: row.subtitle,
                iconKey: row.iconKey,
                count: row.count,
                arabicTitle: row.arabicTitle,
                priority: row.priority,
                kind: row.type == 'dua'
                    ? HisnContentKind.dua
                    : HisnContentKind.adhkar,
              ),
            )
            .toList(growable: true)
          ..sort((a, b) {
            final kindCompare = a.kind.index.compareTo(b.kind.index);
            if (kindCompare != 0) {
              return kindCompare;
            }
            return a.priority.compareTo(b.priority);
          });

    final itemsByCategory = <String, List<HisnItemRecord>>{};
    for (final row in itemRows) {
      final item = HisnItemRecord(
        id: row.id,
        categoryId: row.categoryId,
        text: row.contentText,
        source: row.source,
        repeatCount: row.repeatCount,
        fadl: row.fadl,
        reference: row.reference,
        translation: row.translation,
        kind: row.type == 'dua' ? HisnContentKind.dua : HisnContentKind.adhkar,
      );
      itemsByCategory
          .putIfAbsent(row.categoryId, () => <HisnItemRecord>[])
          .add(item);
    }

    return HisnContentSnapshot(
      categories: List<HisnCategoryRecord>.unmodifiable(categories),
      itemsByCategory: {
        for (final entry in itemsByCategory.entries)
          entry.key: List<HisnItemRecord>.unmodifiable(entry.value),
      },
    );
  }

  Future<void> _persistParsed(_ParsedHisnContent parsed) {
    return _db.batch((batch) {
      batch.insertAll(
        _db.hisnContentCache,
        parsed.categories.map(
          (category) => HisnContentCacheCompanion.insert(
            id: category.id,
            title: category.title,
            subtitle: category.subtitle,
            iconKey: category.iconKey,
            count: category.count,
            arabicTitle: Value(category.arabicTitle),
            priority: Value(category.priority),
            type: category.kind.dbType,
          ),
        ),
      );

      batch.insertAll(
        _db.hisnContentItemCache,
        parsed.itemsByCategory.values.expand(
          (items) => items.map(
            (item) => HisnContentItemCacheCompanion.insert(
              id: item.id,
              categoryId: item.categoryId,
              contentText: item.text,
              source: item.source,
              repeatCount: Value(item.repeatCount),
              fadl: Value(item.fadl),
              reference: Value(item.reference),
              translation: Value(item.translation),
              type: item.kind.dbType,
            ),
          ),
        ),
      );
    });
  }
}

@immutable
class _ParsedHisnContent {
  const _ParsedHisnContent({
    required this.categories,
    required this.itemsByCategory,
  });

  final List<HisnCategoryRecord> categories;
  final Map<String, List<HisnItemRecord>> itemsByCategory;
}

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

_ParsedHisnContent _parseHisnContent(String jsonString) {
  final decoded = jsonDecode(jsonString);
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException(
      'Expected Hisn Al-Muslim JSON to be an object.',
    );
  }

  final categories = <HisnCategoryRecord>[];
  final itemsByCategory = <String, List<HisnItemRecord>>{};

  var adhkarIndex = 0;
  var duaIndex = 0;

  for (final entry in decoded.entries) {
    final title = entry.key;
    final rawData = entry.value;
    if (rawData is! Map<String, dynamic>) {
      continue;
    }

    final isDua = _isDuaCategory(title);
    final kind = isDua ? HisnContentKind.dua : HisnContentKind.adhkar;

    final categoryId = isDua ? 'dua_cat_${duaIndex++}' : 'cat_${adhkarIndex++}';
    final textList = _stringList(rawData['text']);
    final footnotes = _stringList(rawData['footnote']);

    final items = <HisnItemRecord>[];
    for (var i = 0; i < textList.length; i++) {
      final footnote = i < footnotes.length ? footnotes[i] : null;
      items.add(
        HisnItemRecord(
          id: '${categoryId}_item_$i',
          categoryId: categoryId,
          text: textList[i],
          source: footnote ?? '',
          repeatCount: kind == HisnContentKind.adhkar ? 1 : 1,
          fadl: null,
          reference: footnote,
          translation: null,
          kind: kind,
        ),
      );
    }

    itemsByCategory[categoryId] = items;

    categories.add(
      HisnCategoryRecord(
        id: categoryId,
        title: kind == HisnContentKind.adhkar
            ? _mapAdhkarTitle(title)
            : _mapDuaTitle(title),
        subtitle: kind == HisnContentKind.adhkar
            ? '${items.length} أذكار'
            : '${items.length} أدعية',
        iconKey: kind == HisnContentKind.adhkar
            ? _mapAdhkarIcon(title)
            : _mapDuaIcon(title),
        count: items.length,
        arabicTitle: title,
        priority: kind == HisnContentKind.adhkar
            ? (_adhkarPriorityMap[title] ?? 99)
            : (_duaPriorityMap[title] ?? 99),
        kind: kind,
      ),
    );
  }

  categories.sort((a, b) {
    final kindCompare = a.kind.index.compareTo(b.kind.index);
    if (kindCompare != 0) {
      return kindCompare;
    }
    return a.priority.compareTo(b.priority);
  });

  return _ParsedHisnContent(
    categories: categories,
    itemsByCategory: itemsByCategory,
  );
}

bool _isDuaCategory(String title) {
  return title.contains('دعاء') ||
      title.contains('أدعية') ||
      title.contains('الدعاء');
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const <String>[];
  }

  return value
      .whereType<String>()
      .map((text) => text.trim())
      .where((text) => text.isNotEmpty)
      .toList(growable: false);
}

String _mapAdhkarTitle(String title) {
  return title == 'أذكار الاستيقاظ من النوم' ? 'أذكار الاستيقاظ' : title;
}

String _mapAdhkarIcon(String title) {
  if (title.contains('الصباح') || title.contains('صباح')) return 'sun';
  if (title.contains('المساء') || title.contains('مساء')) return 'moon';
  if (title.contains('النوم') || title.contains('نوم')) return 'sleep';
  if (title.contains('الصلاة') || title.contains('صلاة')) return 'mosque';
  if (title.contains('الاستيقاظ') || title.contains('استيقاظ')) return 'alarm';
  if (title.contains('الخلاء') || title.contains('خلاء')) return 'door';
  if (title.contains('المنزل') || title.contains('خروج')) return 'home_exit';
  if (title.contains('المسجد')) return 'mosque';
  if (title.contains('الوضوء') || title.contains('وضوء')) return 'water';
  if (title.contains('الأذان') || title.contains('أذان')) return 'loudspeaker';
  if (title.contains('الحج') ||
      title.contains('العمرة') ||
      title.contains('المحرم')) {
    return 'kaaba';
  }
  if (title.contains('السفر')) return 'travel';
  if (title.contains('تسبيح')) return 'tasbih';
  if (title.contains('الذكر') || title.contains('ذكر')) return 'dhikr';
  return 'quran';
}

String _mapDuaTitle(String title) {
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
  return mappings[title] ?? title;
}

String _mapDuaIcon(String title) {
  if (title.contains('الخلاء') || title.contains('خلاء')) return 'door';
  if (title.contains('المنزل') || title.contains('خروج')) return 'home_exit';
  if (title.contains('الأكل') || title.contains('أكل')) return 'food';
  if (title.contains('الشرب') || title.contains('شرب')) return 'drink';
  if (title.contains('الثوب') || title.contains('لبس')) return 'clothes';
  if (title.contains('السفر') || title.contains('سفر')) return 'travel';
  if (title.contains('المرض') || title.contains('مريض')) return 'health';
  if (title.contains('الصلاة') || title.contains('صلاة')) return 'mosque';
  return 'dua';
}
