import 'dart:collection';

import 'package:flutter/foundation.dart';

@immutable
final class ResourceChapterKey {
  const ResourceChapterKey({
    required this.resourceId,
    required this.chapterNumber,
  });

  final int resourceId;
  final int chapterNumber;

  @override
  bool operator ==(Object other) {
    return other is ResourceChapterKey &&
        other.resourceId == resourceId &&
        other.chapterNumber == chapterNumber;
  }

  @override
  int get hashCode => Object.hash(resourceId, chapterNumber);
}

final class ChapterLruCache<T> {
  ChapterLruCache({required this.maxEntries});

  final int maxEntries;
  final LinkedHashMap<ResourceChapterKey, T> _entries =
      LinkedHashMap<ResourceChapterKey, T>();

  T? get(ResourceChapterKey key) {
    final value = _entries.remove(key);
    if (value != null) {
      _entries[key] = value;
    }
    return value;
  }

  void put(ResourceChapterKey key, T value) {
    _entries.remove(key);
    _entries[key] = value;

    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void clear() {
    _entries.clear();
  }
}
