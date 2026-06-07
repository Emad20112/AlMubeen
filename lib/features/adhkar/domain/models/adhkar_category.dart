import 'package:flutter/foundation.dart';

@immutable
class AdhkarCategory {
  const AdhkarCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.count,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final int count;

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) {
    return AdhkarCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconKey: json['icon_key'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'icon_key': iconKey,
      'count': count,
    };
  }

  AdhkarCategory copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? iconKey,
    int? count,
  }) {
    return AdhkarCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconKey: iconKey ?? this.iconKey,
      count: count ?? this.count,
    );
  }
}
