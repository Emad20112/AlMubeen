import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:al_mubeen/features/adhkar/domain/models/adhkar_item.dart';

class AdhkarLocalDataSource {
  AdhkarLocalDataSource();

  static const String _jsonPath = 'assets/data/hisn_almuslim.json';
  
  // ذاكرة تخزين مؤقت في الذاكرة لمنع قراءة الملف من القرص عدة مرات
  final Map<String, List<AdhkarItem>> _cache = {};
  bool _isLoaded = false;

  Future<void> _loadIfNeeded() async {
    if (_isLoaded) return;
    
    try {
      final jsonString = await rootBundle.loadString(_jsonPath);
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;

      for (final categoryJson in jsonList) {
        if (categoryJson is Map<String, dynamic>) {
          final categoryId = categoryJson['category_id'] as String;
          final itemsList = categoryJson['items'] as List<dynamic>;
          
          final items = itemsList
              .map((itemJson) => AdhkarItem.fromJson(itemJson as Map<String, dynamic>))
              .toList(growable: false);
              
          _cache[categoryId] = items;
        }
      }
      _isLoaded = true;
    } catch (e) {
      // طباعة الخطأ للتشخيص
      debugPrint('Error loading local hisn_almuslim database: $e');
    }
  }

  Future<List<AdhkarItem>> getItemsByCategory(String categoryId) async {
    await _loadIfNeeded();
    return _cache[categoryId] ?? const [];
  }
}
