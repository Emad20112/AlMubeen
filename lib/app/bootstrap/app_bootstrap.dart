import 'package:al_mubeen/app/bootstrap/qcf_font_bootstrap.dart';
import 'package:al_mubeen/features/home/presentation/home_page.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
