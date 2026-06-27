import 'package:flutter/foundation.dart';

@immutable
class AdhkarItem {
  const AdhkarItem({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.source,
    required this.repeatCount,
  });

  final String id;
  final String categoryId;
  final String text;
  final String source;
  final int repeatCount;

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      text: json['text'] as String,
      source: json['source'] as String,
      repeatCount: json['repeat_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'text': text,
      'source': source,
      'repeat_count': repeatCount,
    };
  }

  AdhkarItem copyWith({
    String? id,
    String? categoryId,
    String? text,
    String? source,
    int? repeatCount,
  }) {
    return AdhkarItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      text: text ?? this.text,
      source: source ?? this.source,
      repeatCount: repeatCount ?? this.repeatCount,
    );
  }
}
