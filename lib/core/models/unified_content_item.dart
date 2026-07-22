import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';
import 'package:al_mubeen/features/dua/domain/models/dua_item.dart';

class UnifiedContentItem {
  const UnifiedContentItem({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.source,
    required this.repeatCount,
    this.fadl,
    this.reference,
    this.translation,
  });

  final String id;
  final String categoryId;
  final String text;
  final String source;
  final int repeatCount;
  final String? fadl;
  final String? reference;
  final String? translation;

  factory UnifiedContentItem.fromAdhkar(AdhkarItem item) {
    return UnifiedContentItem(
      id: item.id,
      categoryId: item.categoryId,
      text: item.text,
      source: item.source,
      repeatCount: item.repeatCount,
      fadl: item.fadl,
      reference: item.reference,
      translation: item.translation,
    );
  }

  factory UnifiedContentItem.fromDua(DuaItem item) {
    return UnifiedContentItem(
      id: item.id,
      categoryId: item.categoryId,
      text: item.text,
      source: item.source,
      repeatCount: 1,
      fadl: item.fadl,
      reference: item.reference,
      translation: item.translation,
    );
  }

  factory UnifiedContentItem.fromDynamic(dynamic item) {
    if (item is AdhkarItem) return UnifiedContentItem.fromAdhkar(item);
    if (item is DuaItem) return UnifiedContentItem.fromDua(item);
    throw ArgumentError('Unknown item type: ${item.runtimeType}');
  }
}
