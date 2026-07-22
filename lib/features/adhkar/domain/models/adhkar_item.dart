import 'package:flutter/foundation.dart';

@immutable
class AdhkarItem {
  const AdhkarItem({
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

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      text: json['text'] as String,
      source: json['source'] as String,
      repeatCount: json['repeat_count'] as int,
      fadl: json['fadl'] as String?,
      reference: json['reference'] as String?,
      translation: json['translation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'text': text,
      'source': source,
      'repeat_count': repeatCount,
      'fadl': fadl,
      'reference': reference,
      'translation': translation,
    };
  }

  AdhkarItem copyWith({
    String? id,
    String? categoryId,
    String? text,
    String? source,
    int? repeatCount,
    String? fadl,
    String? reference,
    String? translation,
  }) {
    return AdhkarItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      text: text ?? this.text,
      source: source ?? this.source,
      repeatCount: repeatCount ?? this.repeatCount,
      fadl: fadl ?? this.fadl,
      reference: reference ?? this.reference,
      translation: translation ?? this.translation,
    );
  }
}
