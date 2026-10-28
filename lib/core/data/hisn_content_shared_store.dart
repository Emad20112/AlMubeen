import 'dart:async';

import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/core/database/app_database_provider.dart';
import 'package:al_mubeen/core/database/static_data_seeds.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hisnContentSharedStoreProvider = Provider<HisnContentSharedStore>((ref) {
  return HisnContentSharedStore(ref.watch(appDatabaseProvider));
});

enum HisnContentKind { adhkar, dua }

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
    var fromDb = await _loadFromDatabase();
    if (fromDb != null) {
      _snapshot = fromDb;
      return fromDb;
    }

    // Self-healing fallback: populate from static pre-compiled seeds directly
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.hisnContentCache, staticHisnCategorySeeds);
      batch.insertAllOnConflictUpdate(_db.hisnContentItemCache, staticHisnItemSeeds);
    });

    fromDb = await _loadFromDatabase();
    if (fromDb != null) {
      _snapshot = fromDb;
      return fromDb;
    }

    throw StateError('Unable to load Hisn Al-Muslim content from database');
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
}

