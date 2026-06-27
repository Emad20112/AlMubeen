import 'package:al_mubeen/app/al_mubeen_app.dart';
import 'package:al_mubeen/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment configuration (throws if required values are missing).
  await AppConfig.load();

  runApp(const ProviderScope(child: AlMubeenApp()));
}
