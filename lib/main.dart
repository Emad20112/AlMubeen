import 'package:al_mubeen/app/al_mubeen_app.dart';
import 'package:al_mubeen/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:qcf_quran_plus/src/services/get_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.load();

  GetPage().getQuran(totalPagesCount);

  runApp(const ProviderScope(child: AlMubeenApp()));
}
