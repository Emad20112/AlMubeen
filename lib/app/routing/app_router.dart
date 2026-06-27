import 'package:al_mubeen/app/bootstrap/app_bootstrap.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/translation_download_screen.dart';
import 'package:al_mubeen/features/adhkar/presentation/screens/adhkar_details_screen.dart';
import 'package:al_mubeen/features/adhkar/presentation/screens/adhkar_grid_screen.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AppBootstrap()),
    GoRoute(
      path: AdhkarGridScreen.routePath,
      builder: (context, state) => const AdhkarGridScreen(),
      routes: [
        GoRoute(
          path: ':categoryId',
          builder: (context, state) {
            return AdhkarDetailsScreen(
              categoryId: state.pathParameters['categoryId'] ?? '',
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: QuranAudioDownloadScreen.routePath,
      builder: (context, state) => const QuranAudioDownloadScreen(),
    ),
    GoRoute(
      path: TranslationDownloadScreen.routeName,
      builder: (context, state) => const TranslationDownloadScreen(),
    ),
  ],
);
