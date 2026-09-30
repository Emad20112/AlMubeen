abstract interface class KvStorage {
  String? getString(String key);
  bool? getBool(String key);
  int? getInt(String key);
  double? getDouble(String key);
  bool setString(String key, String value);
  bool setBool(String key, bool value);
  bool setInt(String key, int value);
  bool setDouble(String key, double value);
  bool containsKey(String key);
  void remove(String key);
}
