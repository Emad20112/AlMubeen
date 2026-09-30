import 'package:al_mubeen/core/storage/kv_storage.dart';
import 'package:al_mubeen/core/storage/memory_kv_storage.dart';

KvStorage createNativeKvStorage() => MemoryKvStorage();
