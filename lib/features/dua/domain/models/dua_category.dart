import 'package:flutter/foundation.dart';

@immutable
class DuaCategory {
  const DuaCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.count,
    this.arabicTitle,
    this.priority = 99,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final int count;
  final String? arabicTitle;
  final int priority;

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconKey: json['icon_key'] as String,
      count: json['count'] as int,
      arabicTitle: json['arabic_title'] as String?,
      priority: json['priority'] as int? ?? 99,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'icon_key': iconKey,
      'count': count,
      'arabic_title': arabicTitle,
      'priority': priority,
    };
  }

  DuaCategory copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? iconKey,
    int? count,
    String? arabicTitle,
    int? priority,
  }) {
    return DuaCategory(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconKey: iconKey ?? this.iconKey,
      count: count ?? this.count,
      arabicTitle: arabicTitle ?? this.arabicTitle,
      priority: priority ?? this.priority,
    );
  }
}
