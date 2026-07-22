import 'package:al_mubeen/app/al_mubeen_app.dart';
import 'package:al_mubeen/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global safety net: catches unhandled errors from platform plugins
  // and prevents the app from crashing.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformDispatcher error: $error');
    return true; // Prevent crash
  };

  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    debugPrint('FlutterError: ${details.exception}');
    debugPrint('${details.stack}');
  };

  await AppConfig.load();

  runApp(const ProviderScope(child: AlMubeenApp()));
}
