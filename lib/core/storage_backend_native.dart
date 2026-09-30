import 'package:al_mubeen/core/storage/kv_storage.dart';
import 'package:al_mubeen/core/storage/mmkv_kv_storage.dart';
import 'package:mmkv/mmkv.dart';

KvStorage createNativeKvStorage() => MmkvKvStorage(MMKV.defaultMMKV());
