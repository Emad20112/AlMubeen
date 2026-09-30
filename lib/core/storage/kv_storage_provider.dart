import 'package:al_mubeen/core/storage/kv_storage.dart';
import 'package:al_mubeen/core/storage/memory_kv_storage.dart';
import 'package:al_mubeen/core/storage_backend.dart';
import 'package:al_mubeen/core/storage_initializer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

KvStorage? _nativeStorage;
final KvStorage _fallbackStorage = MemoryKvStorage();

KvStorage get currentKvStorage => _nativeStorage ?? _fallbackStorage;

Future<void> initializeKvStorage() async {
  if (kIsWeb || _nativeStorage != null) return;
  await initializeNativeKvStorage();
  _nativeStorage = createNativeKvStorage();
}

final kvStorageProvider = Provider<KvStorage>((ref) {
  return currentKvStorage;
});
