import 'package:flutter/foundation.dart';

@immutable
class DuaItem {
  const DuaItem({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.source,
    this.fadl,
    this.reference,
    this.translation,
  });

  final String id;
  final String categoryId;
  final String text;
  final String source;
  final String? fadl;
  final String? reference;
  final String? translation;

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      text: json['text'] as String,
      source: json['source'] as String,
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
      'fadl': fadl,
      'reference': reference,
      'translation': translation,
    };
  }

  DuaItem copyWith({
    String? id,
    String? categoryId,
    String? text,
    String? source,
    String? fadl,
    String? reference,
    String? translation,
  }) {
    return DuaItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      text: text ?? this.text,
      source: source ?? this.source,
      fadl: fadl ?? this.fadl,
      reference: reference ?? this.reference,
      translation: translation ?? this.translation,
    );
  }
}
