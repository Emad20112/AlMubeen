import 'package:al_mubeen/core/storage/kv_storage.dart';
import 'package:mmkv/mmkv.dart';

final class MmkvKvStorage implements KvStorage {
  MmkvKvStorage(this._storage);

  final MMKV _storage;

  @override
  String? getString(String key) => _storage.decodeString(key);

  @override
  bool? getBool(String key) =>
      _storage.containsKey(key) ? _storage.decodeBool(key) : null;

  @override
  int? getInt(String key) =>
      _storage.containsKey(key) ? _storage.decodeInt(key) : null;

  @override
  double? getDouble(String key) =>
      _storage.containsKey(key) ? _storage.decodeDouble(key) : null;

  @override
  bool setString(String key, String value) => _storage.encodeString(key, value);

  @override
  bool setBool(String key, bool value) => _storage.encodeBool(key, value);

  @override
  bool setInt(String key, int value) => _storage.encodeInt(key, value);

  @override
  bool setDouble(String key, double value) => _storage.encodeDouble(key, value);

  @override
  bool containsKey(String key) => _storage.containsKey(key);

  @override
  void remove(String key) => _storage.removeValue(key);
}
