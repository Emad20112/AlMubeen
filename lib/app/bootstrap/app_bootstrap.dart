import 'dart:async';

import 'package:al_mubeen/app/bootstrap/qcf_font_bootstrap.dart';
import 'package:al_mubeen/features/home/presentation/home_page.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key});

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(qcfFontBootstrapProvider.notifier).start();
      unawaited(_warmUpQuranCatalogs());
    });
  }

  Future<void> _warmUpQuranCatalogs() async {
    await Future.wait([
      _ignoreWarmUpFailure(ref.read(quranRecitationsProvider.future), 'القراء'),
      _ignoreWarmUpFailure(ref.read(translationsProvider.future), 'الترجمات'),
      _ignoreWarmUpFailure(ref.read(tafsirsProvider.future), 'التفاسير'),
    ]);
  }

  Future<void> _ignoreWarmUpFailure<T>(Future<T> future, String label) async {
    try {
      await future;
    } catch (error, stackTrace) {
      debugPrint('Quran $label warmup failed: $error');
      debugPrint('$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
