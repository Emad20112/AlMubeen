import 'package:al_mubeen/app/routing/app_router.dart';
import 'package:al_mubeen/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AlMubeenApp extends StatelessWidget {
  const AlMubeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Al-Mubeen',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
