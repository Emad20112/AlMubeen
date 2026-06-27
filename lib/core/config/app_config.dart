import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Public app configuration loaded from `env/app.env`.
///
/// This file must never contain OAuth secrets. Credentials live in `backend/.env`.
class AppConfig {
  AppConfig._();

  static const String _envAssetPath = 'env/app.env';

  static late final Uri quranBackendUrl;

  static Future<void> load() async {
    await _loadPublicEnvFile();

    final backendUrl = _findVar([
      'QURAN_BACKEND_URL',
      'BACKEND_URL',
      'API_BACKEND_URL',
    ]);

    quranBackendUrl = _resolveBackendUrl(backendUrl);
  }

  static Future<void> _loadPublicEnvFile() async {
    try {
      await dotenv.load(fileName: _envAssetPath);
      return;
    } catch (error) {
      debugPrint('AppConfig: could not load $_envAssetPath ($error)');
    }

    if (!kReleaseMode) {
      debugPrint(
        'AppConfig: using development backend defaults. '
        'Copy env/app.env.example to env/app.env for local overrides.',
      );
    }
  }

  static String _findVar(List<String> candidates) {
    for (final key in candidates) {
      final fromDotenv = dotenv.env[key]?.trim();
      if (fromDotenv != null && fromDotenv.isNotEmpty) {
        return fromDotenv;
      }

      final fromSystem = Platform.environment[key]?.trim();
      if (fromSystem != null && fromSystem.isNotEmpty) {
        return fromSystem;
      }
    }
    return '';
  }

  static Uri _resolveBackendUrl(String explicit) {
    if (explicit.isNotEmpty) {
      return Uri.parse(explicit.replaceAll(RegExp(r'/+$'), ''));
    }

    if (Platform.isAndroid) {
      return Uri.parse('http://10.0.2.2:3000');
    }

    return Uri.parse('http://localhost:3000');
  }
}
