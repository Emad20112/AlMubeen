import 'package:mmkv/mmkv.dart';

Future<void> initializeNativeKvStorage() async {
  await MMKV.initialize();
}
