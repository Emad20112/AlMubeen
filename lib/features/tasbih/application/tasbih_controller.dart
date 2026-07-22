import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihNotifier extends Notifier<List<String>> {
  static const String _dhikrListKey = 'tasbih_dhikr_list';

  static const List<String> _defaultDhikrs = [
    'سبحان الله',
    'أستغفر الله',
    'لا حول ولا قوة إلا بالله العلي العظيم',
    'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
    'سبحان الله، والحمد لله، ولا إله إلا الله، والله أكبر',
    'الله أكبر',
  ];

  @override
  List<String> build() {
    _loadState();
    return _defaultDhikrs;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dhikrListKey);
    if (list != null && list.isNotEmpty) {
      state = list;
    } else {
      state = _defaultDhikrs;
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dhikrListKey, state);
  }

  void addDhikr(String dhikr) {
    if (dhikr.trim().isNotEmpty) {
      state = [...state, dhikr.trim()];
      _saveState();
    }
  }

  void editDhikr(int index, String newText) {
    if (index >= 0 && index < state.length && newText.trim().isNotEmpty) {
      final newList = List<String>.from(state);
      newList[index] = newText.trim();
      state = newList;
      _saveState();
    }
  }

  void removeDhikr(int index) {
    if (index >= 0 && index < state.length) {
      final newList = List<String>.from(state);
      newList.removeAt(index);
      state = newList;
      _saveState();
    }
  }
}

final tasbihControllerProvider =
    NotifierProvider<TasbihNotifier, List<String>>(TasbihNotifier.new);
