import 'package:al_mubeen/core/storage/kv_storage.dart';

final class MemoryKvStorage implements KvStorage {
  final Map<String, Object> _values = <String, Object>{};

  @override
  String? getString(String key) =>
      _values[key] is String ? _values[key] as String : null;

  @override
  bool? getBool(String key) =>
      _values[key] is bool ? _values[key] as bool : null;

  @override
  int? getInt(String key) => _values[key] is int ? _values[key] as int : null;

  @override
  double? getDouble(String key) =>
      _values[key] is double ? _values[key] as double : null;

  @override
  bool setString(String key, String value) => _set(key, value);

  @override
  bool setBool(String key, bool value) => _set(key, value);

  @override
  bool setInt(String key, int value) => _set(key, value);

  @override
  bool setDouble(String key, double value) => _set(key, value);

  @override
  bool containsKey(String key) => _values.containsKey(key);

  @override
  void remove(String key) => _values.remove(key);

  bool _set(String key, Object value) {
    _values[key] = value;
    return true;
  }
}
