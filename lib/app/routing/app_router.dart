import 'package:al_mubeen/app/bootstrap/app_bootstrap.dart';
import 'package:al_mubeen/core/screens/category_grid_screen.dart';
import 'package:al_mubeen/core/screens/content_details_screen.dart';
import 'package:al_mubeen/features/about/presentation/screens/about_app_screen.dart';
import 'package:al_mubeen/features/adhkar/data/adhkar_providers.dart';
import 'package:al_mubeen/features/dua/data/dua_providers.dart';
import 'package:al_mubeen/features/hadith_nawawi/presentation/screens/hadith_nawawi_screen.dart';
import 'package:al_mubeen/features/names_of_allah/presentation/screens/names_of_allah_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_libraries_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_more_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_surah_player_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/tafsir_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/pages/translation_download_screen.dart';
import 'package:al_mubeen/features/tasbih/presentation/screens/tasbih_screen.dart';
import 'package:al_mubeen/features/qibla/presentation/screens/qibla_compass_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AppBootstrap()),
    GoRoute(
      path: '/adhkar',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) {
          final categoriesAsync = ref.watch(adhkarCategoriesProvider);
          final duasAsync = ref.watch(duaCategoriesProvider);
          return CategoryGridScreen(
            title: 'الأذكار والأدعية',
            categoriesAsync: categoriesAsync,
            onCategoryTap: (id) => context.push('/adhkar/$id'),
            type: 'adhkar',
            selectedTabIndex: 0,
            tabs: [
              CategoryGridScreenTab(
                label: 'الأذكار',
                routePath: '/adhkar',
                type: 'adhkar',
                categoriesAsync: categoriesAsync,
                onCategoryTap: (id) => context.push('/adhkar/$id'),
              ),
              CategoryGridScreenTab(
                label: 'الأدعية',
                routePath: '/duas',
                type: 'dua',
                categoriesAsync: duasAsync,
                onCategoryTap: (id) => context.push('/duas/$id'),
              ),
            ],
          );
        },
      ),
      routes: [
        GoRoute(
          path: ':categoryId',
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId'] ?? '';
            return Consumer(
              builder: (context, ref, _) {
                final categoryAsync = ref.watch(
                  adhkarCategoryProvider(categoryId),
                );
                final itemsAsync = ref.watch(adhkarItemsProvider(categoryId));
                return ContentDetailsScreen(
                  categoryId: categoryId,
                  categoryAsync: categoryAsync,
                  itemsAsync: itemsAsync,
                  enableProgress: true,
                  onRetry: () =>
                      ref.invalidate(adhkarItemsProvider(categoryId)),
                );
              },
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
      path: QuranLibrariesScreen.routePath,
      builder: (context, state) => const QuranLibrariesScreen(),
    ),
    GoRoute(
      path: QuranMoreScreen.routePath,
      builder: (context, state) => QuranMoreScreen(
        readerActions: state.extra as QuranReaderMoreActions?,
      ),
    ),
    GoRoute(
      path: QuranSurahPlayerScreen.routePath,
      builder: (context, state) => const QuranSurahPlayerScreen(),
    ),
    GoRoute(
      path: TafsirDownloadScreen.routeName,
      builder: (context, state) =>
          TafsirDownloadScreen(initialResourceId: state.extra as int?),
    ),
    GoRoute(
      path: TranslationDownloadScreen.routeName,
      builder: (context, state) =>
          TranslationDownloadScreen(initialResourceId: state.extra as int?),
    ),
    GoRoute(
      path: NamesOfAllahScreen.routePath,
      builder: (context, state) => const NamesOfAllahScreen(),
    ),
    GoRoute(
      path: HadithNawawiScreen.routePath,
      builder: (context, state) => const HadithNawawiScreen(),
    ),
    GoRoute(
      path: '/duas',
      builder: (context, state) => Consumer(
        builder: (context, ref, _) {
          final categoriesAsync = ref.watch(duaCategoriesProvider);
          final adhkarAsync = ref.watch(adhkarCategoriesProvider);
          return CategoryGridScreen(
            title: 'الأذكار والأدعية',
            categoriesAsync: categoriesAsync,
            onCategoryTap: (id) => context.push('/duas/$id'),
            type: 'dua',
            selectedTabIndex: 1,
            tabs: [
              CategoryGridScreenTab(
                label: 'الأذكار',
                routePath: '/adhkar',
                type: 'adhkar',
                categoriesAsync: adhkarAsync,
                onCategoryTap: (id) => context.push('/adhkar/$id'),
              ),
              CategoryGridScreenTab(
                label: 'الأدعية',
                routePath: '/duas',
                type: 'dua',
                categoriesAsync: categoriesAsync,
                onCategoryTap: (id) => context.push('/duas/$id'),
              ),
            ],
          );
        },
      ),
      routes: [
        GoRoute(
          path: ':categoryId',
          builder: (context, state) {
            final categoryId = state.pathParameters['categoryId'] ?? '';
            return Consumer(
              builder: (context, ref, _) {
                final categoryAsync = ref.watch(
                  duaCategoryProvider(categoryId),
                );
                final itemsAsync = ref.watch(duaItemsProvider(categoryId));
                return ContentDetailsScreen(
                  categoryId: categoryId,
                  categoryAsync: categoryAsync,
                  itemsAsync: itemsAsync,
                  enableProgress: false,
                  onRetry: () => ref.invalidate(duaItemsProvider(categoryId)),
                );
              },
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: TasbihScreen.routePath,
      builder: (context, state) => const TasbihScreen(),
    ),
    GoRoute(
      path: QiblaCompassScreen.routePath,
      builder: (context, state) => const QiblaCompassScreen(),
    ),
    GoRoute(
      path: AboutAppScreen.routePath,
      builder: (context, state) => const AboutAppScreen(),
    ),
  ],
);
