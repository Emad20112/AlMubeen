import 'package:flutter/foundation.dart';

@immutable
class AdhkarItem {
  const AdhkarItem({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.source,
    required this.repeatCount,
    this.audioUrl,
  });

  final String id;
  final String categoryId;
  final String text;
  final String source;
  final int repeatCount;
  final String? audioUrl;

  factory AdhkarItem.fromJson(Map<String, dynamic> json) {
    return AdhkarItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      text: json['text'] as String,
      source: json['source'] as String,
      repeatCount: json['repeat_count'] as int,
      audioUrl: json['audio_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'text': text,
      'source': source,
      'repeat_count': repeatCount,
      'audio_url': audioUrl,
    };
  }

  AdhkarItem copyWith({
    String? id,
    String? categoryId,
    String? text,
    String? source,
    int? repeatCount,
    String? audioUrl,
  }) {
    return AdhkarItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      text: text ?? this.text,
      source: source ?? this.source,
      repeatCount: repeatCount ?? this.repeatCount,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }
}
