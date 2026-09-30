import 'package:al_mubeen/core/storage/memory_kv_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MemoryKvStorage', () {
    late MemoryKvStorage storage;

    setUp(() => storage = MemoryKvStorage());

    test('stores and reads typed values', () {
      expect(storage.setString('text', 'المبين'), isTrue);
      expect(storage.setBool('flag', true), isTrue);
      expect(storage.setInt('count', 42), isTrue);
      expect(storage.setDouble('ratio', 0.85), isTrue);

      expect(storage.getString('text'), 'المبين');
      expect(storage.getBool('flag'), isTrue);
      expect(storage.getInt('count'), 42);
      expect(storage.getDouble('ratio'), 0.85);
    });

    test('supports missing keys, overwrite, contains, and remove', () {
      expect(storage.getString('missing'), isNull);
      expect(storage.containsKey('value'), isFalse);
      storage.setString('value', 'first');
      storage.setString('value', 'second');
      expect(storage.getString('value'), 'second');
      expect(storage.containsKey('value'), isTrue);
      storage.remove('value');
      expect(storage.getString('value'), isNull);
      expect(storage.containsKey('value'), isFalse);
    });

    test('keeps empty strings and Unicode', () {
      storage.setString('empty', '');
      storage.setString('arabic', 'أذكار الصباح');
      expect(storage.getString('empty'), isEmpty);
      expect(storage.getString('arabic'), 'أذكار الصباح');
    });
  });
}
