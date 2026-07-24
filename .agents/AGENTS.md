# 🚀 THE ULTIMATE FLUTTER & DART CONSTITUTION (AI AGENT MASTER RULES)

**Project Name:** Al-Mubeen (تطبيق المبين للقرآن والأذكار)
**Target Era:** Flutter 3.24+ / Dart 3.5+ / Riverpod 2.5+ (Modern & Professional Era)
**SDK Constraint:** `^3.11.5`
**Database Schema Version:** 10

> **⚠️ ATTENTION AI AGENT:** You are acting as a **Principal Staff Flutter Engineer & Systems Architect**. Do NOT use legacy Flutter code, outdated patterns, or tutorials from pre-2024. Your outputs MUST strictly obey the performance, architectural, and design guidelines below. Every line of code must be optimized for **120 FPS, Zero-Jank, Zero-ANR, and DRY principles**.

---

## 📋 PROJECT OVERVIEW & IDENTITY

**Al-Mubeen** (المبين) is a high-performance Islamic mobile application providing:
- **Quran Reader** — Full Mushaf with QCF Madani font rendering (`qcf_quran`), page-by-page navigation (604 pages), per-ayah audio playback, tafsir, translations, bookmarks, and reading progress tracking.
- **Quran Audio** — Streaming and downloadable recitations from multiple reciters via `just_audio` + `LockCachingAudioSource`, with per-surah playlist player.
- **Adhkar (أذكار)** — Categories from Hisn Al-Muslim with per-item repeat counters and completion tracking.
- **Duas (أدعية)** — Categorized supplications sharing the same unified display system as Adhkar.
- **Names of Allah (أسماء الله الحسنى)** — 99 Names with meanings and explanations.
- **Hadith Nawawi (الأربعون النووية)** — 40 Hadith collection with full Arabic text.
- **Tasbih Counter (مسبحة)** — Digital counter with haptic feedback.
- **Qibla Compass (بوصلة القبلة)** — Magnetic compass with geolocation-based Qibla direction.
- **Tafsir & Translation Downloads** — Bulk download system for multiple tafsir and translation resources.
- **About App** — App information screen.

**Language:** The app is **100% Arabic (RTL)**. All user-facing text, errors, toasts, snackbars, and placeholders MUST be in fluent, grammatically correct, professional Arabic.

---

## 🏗️ ARCHITECTURE & TECH STACK

### A. Framework & Dependencies

| Category | Technology | Package |
|---|---|---|
| **Framework** | Flutter 3.24+ / Dart 3.5+ | `flutter` |
| **State Management** | Riverpod 2.5+ | `flutter_riverpod: ^3.3.1` |
| **Navigation** | GoRouter | `go_router: ^17.2.3` |
| **Database** | Drift (SQLite) | `drift: ^2.33.0`, `drift_flutter: ^0.3.0`, `sqlite3_flutter_libs` |
| **Audio Playback** | just_audio | `just_audio: ^0.10.5`, `audio_session: ^0.2.3`, `audio_service: ^0.18.18` |
| **Quran Rendering** | QCF Fonts | `qcf_quran: ^0.0.5` |
| **Downloads** | Background Downloader | `background_downloader: ^9.5.6` |
| **Network** | Connectivity Plus | `connectivity_plus: ^6.1.3` |
| **SVG** | flutter_svg | `flutter_svg: ^2.3.0` |
| **HTML Rendering** | Widget from HTML | `flutter_widget_from_html: ^0.17.2` |
| **Prayer Times** | Adhan | `adhan: ^2.0.0+1` |
| **Geolocation** | Geolocator | `geolocator: ^14.0.2` |
| **Compass** | Flutter Compass | `flutter_compass: ^0.8.1` |
| **Permissions** | Permission Handler | `permission_handler: ^12.0.2` |
| **Scrollable List** | Positioned List | `scrollable_positioned_list: ^0.3.8` |
| **Env Config** | dotenv | `flutter_dotenv: ^5.2.1` |
| **Preferences** | Custom JSON file store | `path_provider` + `dart:io` |
| **Marquee** | Marquee widget | `marquee: ^2.3.0` |
| **Code Gen** | Drift Dev + Build Runner | `drift_dev: ^2.33.0`, `build_runner: ^2.15.0` |

### B. Feature-First Clean Architecture

```
lib/
├── main.dart                          # Entry point (ProviderScope + global error handlers)
├── app/
│   ├── al_mubeen_app.dart             # MaterialApp.router (RTL root, theme, font scaling)
│   ├── bootstrap/
│   │   ├── app_bootstrap.dart         # Sequential startup pipeline + QuranLaunchShell
│   │   └── qcf_font_bootstrap.dart    # QCF font preloading
│   ├── routing/
│   │   └── app_router.dart            # GoRouter declarative routes
│   └── theme/
│       ├── app_colors.dart            # AppColors abstract final class (centralized palette)
│       └── app_theme.dart             # AppTheme.light() / AppTheme.dark() (Material 3)
├── core/
│   ├── audio/
│   │   ├── audio_player_service.dart  # Pure just_audio wrapper (play/pause/stop/seek/streams)
│   │   ├── audio_providers.dart       # Riverpod providers (DownloadManager, DownloadRepository, AudioRepository)
│   │   ├── audio_repository.dart      # Local vs network audio source resolution
│   │   ├── download_manager.dart      # background_downloader wrapper (enqueue/pause/resume/cancel)
│   │   └── download_repository.dart   # File persistence and verification
│   ├── config/
│   │   └── app_config.dart            # AppConfig.load() (env vars, backend URL)
│   ├── constants/
│   │   └── app_assets.dart            # Asset path constants
│   ├── data/
│   │   ├── category_favorites_data_source.dart
│   │   ├── category_favorites_provider.dart
│   │   ├── data_failure.dart          # DataFailure union type
│   │   ├── data_fetch_policy.dart     # DataFetchPolicy enum (cacheFirst, networkOnly, etc.)
│   │   ├── data_result.dart           # DataResult<T> wrapper
│   │   ├── json_map.dart              # JsonMap typedef
│   │   └── request_abort_handle.dart  # Request cancellation support
│   ├── database/
│   │   ├── app_database.dart          # Drift @DriftDatabase with 15 tables, schema v10
│   │   ├── app_database.g.dart        # Generated Drift code (~350KB)
│   │   └── app_database_provider.dart # Riverpod provider for AppDatabase
│   ├── layout/
│   │   └── adaptive_breakpoints.dart  # Responsive layout breakpoints
│   ├── models/
│   │   └── unified_content_item.dart  # UnifiedContentItem (adapts AdhkarItem & DuaItem)
│   ├── network/
│   │   ├── connectivity_providers.dart
│   │   ├── connectivity_service.dart  # ConnectivityService (stream + one-shot check)
│   │   └── no_internet_exception.dart
│   ├── preferences/
│   │   └── app_user_preferences.dart  # AppUserPreferences + JSON file-based store + AsyncNotifier
│   ├── screens/
│   │   ├── category_grid_screen.dart  # Reusable CategoryGridScreen (Adhkar & Duas share this)
│   │   ├── contact_style_menu_screen.dart
│   │   └── content_details_screen.dart # Reusable ContentDetailsScreen (Adhkar & Duas share this)
│   └── widgets/
│       ├── adhkar_counter.dart        # Tap counter widget with progress
│       ├── adhkar_custom_header.dart
│       ├── adhkar_grid_card.dart
│       ├── app_error_view.dart        # Unified error state with retry
│       ├── app_loading_overlay.dart
│       ├── app_loading_view.dart      # Unified loading state
│       ├── auto_scroll_text.dart      # Marquee-style auto-scrolling text
│       ├── custom_bottom_nav.dart     # Custom BottomNavigationBar
│       ├── decorative_badge.dart
│       ├── decorative_card.dart
│       ├── favorite_button.dart
│       ├── islamic_header.dart        # Decorative Islamic header component
│       ├── network_error_banner.dart  # Network error banner with auto-dismiss
│       ├── play_audio_button.dart
│       ├── section_title.dart
│       └── share_button.dart
└── features/
    ├── about/presentation/screens/    # AboutAppScreen
    ├── adhkar/
    │   ├── data/
    │   │   ├── adhkar_providers.dart   # adhkarCategoriesProvider, adhkarItemsProvider, etc.
    │   │   ├── data_sources/          # HisnContentCache + HisnContentItemCache data sources
    │   │   └── islam_house_adhkar_repository.dart
    │   ├── domain/
    │   │   ├── models/                # AdhkarCategory, AdhkarItem
    │   │   └── repositories/          # AdhkarRepository interface
    │   └── presentation/
    │       ├── controllers/           # Adhkar progress/counter controllers
    │       ├── screens/               # AdhkarDuaHubScreen
    │       └── widgets/
    ├── dua/
    │   ├── data/
    │   │   ├── data_sources/          # DuaLocalDataSource
    │   │   └── dua_providers.dart     # duaCategoriesProvider, duaItemsProvider, etc.
    │   └── domain/models/             # DuaItem, DuaCategory
    ├── hadith_nawawi/
    │   ├── data/
    │   │   ├── hadith_nawawi_local_data_source.dart  # JSON asset loader + warmUp()
    │   │   └── hadith_nawawi_providers.dart
    │   ├── domain/
    │   └── presentation/screens/      # HadithNawawiScreen
    ├── home/presentation/             # Home presentation layer
    ├── names_of_allah/
    │   ├── data/
    │   │   ├── names_of_allah_local_data_source.dart # JSON asset loader + warmUp()
    │   │   └── names_of_allah_providers.dart
    │   ├── domain/
    │   └── presentation/screens/      # NamesOfAllahScreen
    ├── onboarding/presentation/       # OnboardingScreen (first-launch flow)
    ├── qibla/
    │   ├── application/               # QiblaService (compass + geolocation)
    │   └── presentation/screens/      # QiblaCompassScreen
    ├── quran/
    │   ├── application/
    │   │   ├── default_tafsir_seed_service.dart       # Seeds ar_muyassar.json into Drift DB
    │   │   ├── quran_audio_controller.dart            # Per-ayah audio playback controller
    │   │   ├── quran_audio_download_controller.dart   # Bulk surah download controller
    │   │   ├── quran_download_recovery_service.dart   # Restores pending downloads after restart
    │   │   ├── quran_download_session_store.dart      # Download session persistence
    │   │   ├── quran_highlight_controller.dart        # Active ayah highlighting
    │   │   ├── quran_surah_player_controller.dart     # Full surah playlist player
    │   │   ├── quran_surah_player_provider.dart       # Provider for surah player
    │   │   ├── tafsir_download_controller.dart        # Bulk tafsir download (chapter-by-chapter)
    │   │   └── translation_download_controller.dart   # Bulk translation download
    │   ├── data/
    │   │   ├── contracts/             # QuranDataSource interface
    │   │   ├── local/
    │   │   │   ├── quran_bookmark_service.dart
    │   │   │   ├── quran_local_data_source.dart
    │   │   │   ├── quran_page_helpers.dart
    │   │   │   ├── quran_reciter_local_data_source.dart
    │   │   │   ├── quran_resource_catalog_storage.dart
    │   │   │   ├── tafsir_local_data_source.dart
    │   │   │   ├── tafsir_muyassar_asset_data_source.dart
    │   │   │   └── translation_local_data_source.dart
    │   │   ├── models/                # DTOs (QuranChapterDto, QuranVerseDto, TafsirDto, etc.)
    │   │   ├── quran_providers.dart   # 900+ lines of Riverpod providers (data layer wiring)
    │   │   ├── remote/
    │   │   │   ├── quran_com_api_client.dart          # HTTP client for Quran.com API
    │   │   │   └── quran_com_remote_data_source.dart  # Remote data source implementation
    │   │   └── repositories/
    │   │       ├── quran_audio_repository_impl.dart
    │   │       ├── quran_com_repository.dart           # Main QuranRepository implementation
    │   │       └── quran_reciter_repository_impl.dart
    │   ├── domain/
    │   │   ├── ayah_ref.dart
    │   │   ├── repositories/
    │   │   │   ├── quran_audio_repository.dart
    │   │   │   ├── quran_reciter_repository.dart       # QuranRecitation model
    │   │   │   └── quran_repository.dart               # Domain models (QuranChapter, QuranVerse, Tafsir, Translation, etc.)
    │   │   └── tafsir_defaults.dart
    │   └── presentation/
    │       ├── pages/
    │       │   ├── quran_audio_download_screen.dart    # Bulk audio download UI
    │       │   ├── quran_libraries_screen.dart         # Tafsir/Translation library selection
    │       │   ├── quran_more_screen.dart              # Settings/more options
    │       │   ├── quran_page_reader.dart              # Main Quran Mushaf reader (PageView)
    │       │   ├── quran_surah_player_screen.dart      # Full surah player UI
    │       │   ├── tafsir_download_screen.dart         # Tafsir bulk download UI
    │       │   ├── tafsir_viewer_screen.dart
    │       │   └── translation_download_screen.dart    # Translation bulk download UI
    │       └── widgets/
    │           ├── ayah_audio_player_bar.dart          # Mini player bar
    │           ├── ayah_interaction_overlay.dart       # Ayah tap/long-press overlay
    │           ├── quran_bookmarks_sheet.dart
    │           ├── quran_page_carousel.dart            # Page carousel for Mushaf
    │           ├── quran_reader_*.dart                 # Reader UI components (header, bottom panel, nav bar, scrim)
    │           ├── quran_reader_search_sheet.dart      # Search within Quran
    │           ├── quran_reader_settings_sheet.dart    # Reader settings
    │           ├── quran_sleep_timer_sheet.dart        # Sleep timer
    │           ├── surah_list_sheet.dart               # Surah selection
    │           ├── surah_picker.dart
    │           ├── surah_player_controls.dart
    │           ├── tafsir_bottom_sheet.dart
    │           ├── tafsir_html_content.dart
    │           ├── tafsir_reader_content.dart
    │           └── translation_bottom_sheet.dart
    └── tasbih/
        ├── application/               # TasbihController
        └── presentation/screens/      # TasbihScreen
```

### C. Backend (Node.js / TypeScript Proxy)

Located in `backend/`, deployed to **Vercel**. Acts as an API proxy to Quran.com API endpoints. The Flutter app communicates with this backend (configured via `env/app.env` → `QURAN_BACKEND_URL`).

### D. Database Schema (Drift/SQLite — 15 Tables)

| Table | Purpose |
|---|---|
| `QuranChapterCache` | Cached chapter metadata (114 surahs) |
| `QuranVerseCache` | Cached verse data with page/juz/hizb mappings |
| `QuranRecitationCache` | Cached reciter catalog |
| `QuranCacheMetadata` | Cache freshness timestamps |
| `AdhkarProgressCache` | Per-item completion tracking |
| `AdhkarFavorites` | Favorited adhkar items |
| `CategoryFavorites` | Favorited categories (adhkar/dua) |
| `QuranReadingProgressCache` | Last read page + surah |
| `QuranBookmarks` | User bookmarks (page + surah + ayah) |
| `DownloadedTafsirs` | Registry of downloaded tafsir resources |
| `DownloadedTranslations` | Registry of downloaded translation resources |
| `TafsirTextCache` | Cached tafsir text (per resource/chapter/ayah) |
| `TranslationTextCache` | Cached translation text (per resource/chapter/ayah) |
| `HisnContentCache` | Adhkar/Dua categories from Hisn Al-Muslim |
| `HisnContentItemCache` | Individual adhkar/dua items |

### E. Data Assets (Bundled JSON/XML)

| File | Size | Purpose |
|---|---|---|
| `ar_muyassar.json` | ~3MB | Default Tafsir Muyassar (seeded into DB at first launch) |
| `hisn_almuslim.json` | ~134KB | Hisn Al-Muslim adhkar and duas |
| `Names_Of_Allah.json` | ~25KB | 99 Names of Allah |
| `40-hadith-nawawi.json` | ~164KB | 40 Hadith Nawawi |
| `quran-uthmani.xml` | ~1.5MB | Full Quran Uthmani text |

### F. Design System — AppColors Palette

```dart
// Light Theme
AppColors.maroon900    = Color(0xFF2A070D)   // Deepest maroon
AppColors.maroon800    = Color(0xFF3F1D20)   // Primary brand color
AppColors.maroon700    = Color(0xFF5A2A2E)   // Secondary
AppColors.maroon600    = Color(0xFF6F3437)   // Tertiary
AppColors.parchment    = Color(0xFFF6F0E5)   // Light scaffold background
AppColors.parchmentLight = Color(0xFFFFFCF3) // Surface color
AppColors.parchmentMuted = Color(0xFFE8E1D4) // Muted surface
AppColors.ink          = Color(0xFF2C1A1B)   // Light mode text

// Dark Theme
AppColors.darkScaffold    = Color(0xFF171111) // Dark scaffold background
AppColors.darkSurface     = Color(0xFF24191A) // Dark surface
AppColors.darkSurfaceHigh = Color(0xFF312223) // Elevated dark surface
AppColors.darkInk         = Color(0xFFF7EFE4) // Dark mode text

// Accents
AppColors.goldenAccent    = Color(0xFFD4AF37) // Gold accent (light)
AppColors.goldenAccentDark = Color(0xFFE8C860) // Gold accent (dark)
AppColors.cardCream       = Color(0xFFFFF8E7)  // Card background
AppColors.cardRed         = Color(0xFF8B0000)  // Card accent
AppColors.cardRedDark     = Color(0xFFD4A0A0)  // Card accent (dark)
```

### G. Routing Map

| Path | Screen | Description |
|---|---|---|
| `/` | `AppBootstrap` | Entry point (preferences → onboarding or Quran reader) |
| `/adhkar-dua-hub` | `AdhkarDuaHubScreen` | Hub for Adhkar and Duas |
| `/adhkar` | `CategoryGridScreen` | Adhkar categories grid |
| `/adhkar/:categoryId` | `ContentDetailsScreen` | Adhkar items with counters |
| `/duas` | `CategoryGridScreen` | Duas categories grid |
| `/duas/:categoryId` | `ContentDetailsScreen` | Dua items list |
| `/quran-audio-download` | `QuranAudioDownloadScreen` | Bulk audio download |
| `/quran-libraries` | `QuranLibrariesScreen` | Library selection |
| `/quran-more` | `QuranMoreScreen` | Settings & more |
| `/quran-surah-player` | `QuranSurahPlayerScreen` | Full surah player |
| `/tafsir-download` | `TafsirDownloadScreen` | Tafsir download |
| `/translation-download` | `TranslationDownloadScreen` | Translation download |
| `/names-of-allah` | `NamesOfAllahScreen` | 99 Names |
| `/hadith-nawawi` | `HadithNawawiScreen` | 40 Hadith |
| `/tasbih` | `TasbihScreen` | Tasbih counter |
| `/qibla` | `QiblaCompassScreen` | Qibla compass |
| `/about` | `AboutAppScreen` | About app |

### H. User Preferences System

Preferences are stored as a **JSON file** (not SharedPreferences) via `AppUserPreferencesStore`:
- `hasCompletedWelcome` — First-launch onboarding completion flag
- `themePreference` — system / light / dark
- `fontScale` — 0.55 to 1.25 (default: 0.85)
- `preferredReciterId` / `preferredReciterName` — Selected reciter
- `autoContinueFromLastPosition` — Resume from last read page
- `easyListeningMode` — Audio playback mode
- `recentSleepTimers` — Last 5 used sleep timer durations
- `lastQuranPage` — Last read Quran page (1–604)

Managed by `AppUserPreferencesController` (Riverpod `AsyncNotifier`), accessed via `appUserPreferencesProvider`.

---

## 1. 🌟 MODERN FLUTTER & DART 3.x+ MANDATES (THE NEW ERA RULES)

### A. Spacing & Layout Optimization (`Gap` over `SizedBox`)
- **NEVER** use `SizedBox(height: X)` or `SizedBox(width: X)` for spacing inside `Column`, `Row`, or `Flex` layouts.
- **ALWAYS** use the `Gap(X)` widget (from the `gap` package) for layout spacing.
  - *Bad:* `SizedBox(height: 16)` inside a Column.
  - *Good:* `Gap(16)` inside a Column or Row (adapts automatically to main axis).
- Use `SliverGap(X)` for spacing inside `CustomScrollView` slivers.
- For conditional spacing or shrinking, use `const SizedBox.shrink()`.

> **⚠️ NOTE:** The `gap` package is NOT yet in `pubspec.yaml`. If you need `Gap`, add it first: `gap: ^3.0.1`.

### B. High-Performance List & Grid Rendering
- **ALWAYS** provide `itemExtent` or `prototypeItem` to `ListView.builder` when items have fixed heights. This reduces Flutter's layout computation time by 90% during fast scrolling ($O(1)$ layout calculation).
- **ALWAYS** use `SliverGrid.builder` with `SliverGridDelegateWithFixedCrossAxisCount` and explicit `mainAxisExtent` for cards.
- **NEVER** wrap scrollable grids in layout calculation widgets (like `SliverLayoutBuilder` or `LayoutBuilder`) if they recalculate constraints on every scroll frame. Use `MediaQuery.sizeOf(context)` ONCE in the parent `build` method.
- **ALWAYS** provide a unique `ValueKey(item.id)` to every item built inside a grid or list to optimize the RenderObject diffing engine.

### C. Modern Dart 3 Syntax & Typing
- **No `dynamic`:** Explicitly type every variable, return type, and generic. Using `dynamic` or `List<dynamic>` is a Hard Fail.
- **Pattern Matching & Destructuring:** Use Dart 3 pattern matching, records, and switch expressions instead of chained `if-else` blocks or ternary operators.
  - *Good:* `final (title, count) = getCategoryData();`
  - *Good:* `final status = switch (mode) { Mode.off => 'Off', Mode.on => 'On' };`
- **Null Safety & Extensions:** Use null-aware operators (`?.`, `??`, `??=`) and create syntax-sugar Dart extensions for repetitive tasks (e.g., parsing Arabic numbers or date formatting).

---

## 2. 🛡️ STRICT PERFORMANCE & MEMORY ARCHITECTURE (ZERO-ANR / ZERO-JANK)

### A. Zero Main-Thread IO & JSON Parsing (Isolate Mandate)
- **NEVER** parse JSON files, decode assets, or manipulate large lists (> 50 items) on the Main UI Isolate.
- **ALWAYS** wrap asset loading (`rootBundle.loadString`) and JSON decoding inside **`Isolate.run()`** or `compute()`.
- *Example:*
  ```dart
  final jsonString = await rootBundle.loadString('assets/data/large_file.json');
  final items = await Isolate.run(() => parseJsonToModels(jsonString));
  ```
- **Applies to:** `ar_muyassar.json` (3MB), `hisn_almuslim.json` (134KB), `40-hadith-nawawi.json` (164KB), `Names_Of_Allah.json` (25KB), `quran-uthmani.xml` (1.5MB).

### B. High-Speed Database Operations (Drift / SQLite)
- **NEVER** execute database insertions sequentially inside a `for` loop. This locks the database and freezes the UI.
- **ALWAYS** use `batch()` for bulk insertions or updates.
  ```dart
  // ✅ Good: Single transaction with batch
  await db.batch((b) => b.insertAll(table, rows));

  // ❌ Bad: Sequential insertions
  for (final row in rows) {
    await db.into(table).insert(row);
  }
  ```
- Ensure queries run cleanly without blocking UI animations.
- All Drift table definitions are in `lib/core/database/app_database.dart`. Generated code is in `app_database.g.dart`. Run `dart run build_runner build` to regenerate.

### C. Progressive Audio Streaming & Network Resilience (The 4 Guardrails)
When managing audio streaming with `just_audio` and `LockCachingAudioSource` (local proxy caching):

1. **Stream Error Interception:** Listen to `player.playbackEventStream.onError` and `player.playerStateStream.onError`. **NEVER** let local proxy network drops (`SocketException`, `HttpException`, `TimeoutException`) bubble up to Dart VM as Unhandled Exceptions (causes ANR Signal 3).

2. **Safe Source Setting:** Wrap `player.setAudioSource()` with explicit `.catchError()`.
   ```dart
   await player.setAudioSource(source).catchError((error) {
     debugPrint('Audio source error: $error');
   });
   ```

3. **No Infinite Rebuild Loops:** In state listeners (`_onPlayerState`), **NEVER** call `player.stop()` synchronously if the player is entering an idle state during a loading failure. Silently update UI error states instead.

4. **UI Slider Protection:** Protect all slider widgets against network dropouts that produce `NaN` or `Infinity`:
   ```dart
   value: (total > 0 && current.isFinite && !current.isNaN)
       ? current.clamp(0.0, total)
       : 0.0
   ```

- **Audio architecture:** `AudioPlayerService` (`lib/core/audio/audio_player_service.dart`) wraps `just_audio` — NO downloading logic. Downloads are handled by `DownloadManager` (`lib/core/audio/download_manager.dart`) using `background_downloader`.

### D. Sequential Bootstrapping & App Startup (`AppBootstrap`)
- **NEVER** use random `Timer(Duration(seconds: X))` for background tasks during app launch. They collide with user gestures.
- **ALWAYS** implement a **Sequential Waterfall Pipeline** (`async/await` chaining) after the first frame renders (`WidgetsBinding.instance.addPostFrameCallback`):
  ```
  await recoverDownloads() → await seedTafsirInIsolate() → await warmUpNamesOfAllah() → await warmUpHadith()
  ```
- **Silent Preloading:** During clean install onboarding (`OnboardingScreen`), preload Quran Page 1 (Fatiha QCF glyphs and reader providers) in the background so the transition to the heavy reader screen is instant and jank-free.
- **Transition Buffering:** Do NOT build heavy screens (`QuranPageReader`) synchronously during entrance animations (`FadeTransition`). Use a **150ms buffer delay** before mounting heavy widgets (see `_QuranLaunchShell` in `app_bootstrap.dart`).

---

## 3. 🏗️ STATE MANAGEMENT & ROUTING (RIVERPOD 2.5+ & GOROUTER)

### State Management Rules
- **Modern Providers:** Use `Provider`, `FutureProvider`, `AsyncNotifierProvider`, `NotifierProvider`. The codebase currently uses these Riverpod patterns.
- **Consumer Widgets:** Use `ConsumerWidget`, `ConsumerStatefulWidget`, or `HookConsumerWidget`.
- **Async Handling:** Always handle all 3 states of `AsyncValue` (`data`, `loading`, `error`). Never unwrap with `.value!` without null and loading checks.
- **Memoized Lookups:** When checking item states (e.g., favorites or completed Adhkar inside grid builders), convert lists to sets (`toSet()`) in computed providers **BEFORE** the builder to guarantee $O(1)$ instant lookups instead of $O(N)$ nested loops.
- **Provider organization:** Feature-specific providers live in `<feature>/data/<feature>_providers.dart`. Core providers live in `core/<subsystem>/<subsystem>_providers.dart`.

### Routing Rules
- **Declarative Routing:** Use `go_router` with clean URL paths.
- **Static Route Paths:** Define `static const String routePath` on screen classes.
- **Consumer in Routes:** When routes need Riverpod, wrap builders with `Consumer` widget (see `app_router.dart` pattern).
- **GoRouter extras:** Use `state.extra` for complex objects (e.g., `QuranReaderMoreActions`).

---

## 4. 🎨 DESIGN SYSTEM, THEME TOKENS & ARABIC/RTL EXCELLENCE

### A. Design Tokens & Styling (Material 3)
- **NEVER** hardcode hex colors (e.g., `Color(0xFF800000)`) directly inside UI widgets.
- **ALWAYS** use the project's centralized design system: `AppColors`, `Theme.of(context).colorScheme`, or custom `ThemeExtension` classes.
- `AppTheme.light()` and `AppTheme.dark()` are defined in `lib/app/theme/app_theme.dart`.
- Use `BackdropFilter` with `ImageFilter.blur` sparingly, and **NEVER** place blurred containers inside scrollable list items (GPU heavy).
- Use `SelectionArea` for selectable text blocks instead of wrapping individual texts in `SelectableText`.
- Custom font: `DiwaniBent` (from `assets/fonts/DiwaniBent.ttf`) for decorative Islamic headers.

### B. RTL & Arabic Typography
- The app is **100% Arabic (RTL)**. `Directionality(textDirection: TextDirection.rtl)` is set in `AlMubeenApp.build()`.
- All user-facing text, error toasts, snackbars, and placeholders **MUST** be in fluent, grammatically correct, professional Arabic.
- Use directional padding and margins (`EdgeInsets.directional(start: X, end: Y)`) instead of `left`/`right` to maintain flawless RTL scaling.
- Font scaling is combined: `systemTextScale × userFontScale` clamped to `[0.8, 1.45]`.

---

## 5. ✂️ THE "DRY" ARCHITECTURE & CODE COMPLETENESS PROTOCOL

### DRY (Don't Repeat Yourself)
- Actively identify similar UI layouts (e.g., `AdhkarGridScreen` vs. `DuaGridScreen`) and merge them into generic, highly customizable, parameterized components.
- **Already implemented DRY patterns:**
  - `CategoryGridScreen` — Shared grid for Adhkar and Duas categories.
  - `ContentDetailsScreen` — Shared detail view for Adhkar and Duas items.
  - `UnifiedContentItem` — Adapter that normalizes `AdhkarItem` and `DuaItem` into a single interface.
- When adding new features similar to existing ones, **extend** the existing generic components instead of creating new copies.

### Complete Delivery
- **NEVER** return partial code, abbreviated snippets, or `// TODO: implement later` comments.
- Write out the **FULL, robust, production-ready implementation** of every file requested.

### Defensive UI
- Every screen must be fortified against missing data, network failures, or empty lists by implementing dedicated fallback views:
  - `AppLoadingView` — Loading state with Islamic-themed indicator
  - `AppErrorView` — Error state with Arabic message and retry button
  - Empty state — Meaningful Arabic message when lists are empty

---

## 6. 🛑 AI SELF-CORRECTION CHECKLIST (MANDATORY GATEKEEPER)

Before outputting **ANY** code response, you **MUST** silently verify this checklist. If any item fails, rewrite the code immediately:

- [ ] Did I use `Gap()` instead of `SizedBox()` for layout spacing? *(if `gap` package is added)*
- [ ] Is every `ListView.builder` or `SliverGrid.builder` using a unique `ValueKey` and fixed extent (`itemExtent` / `mainAxisExtent`) where possible?
- [ ] Are all JSON parsing or asset loading functions safely isolated inside `Isolate.run()`?
- [ ] Are all Drift/SQLite insertions using `.batch()`?
- [ ] Is the audio player protected against Proxy ANR exceptions with explicit error listeners and `catchError`?
- [ ] Did I eliminate all `dynamic` types and use explicit Dart 3 typing/pattern matching?
- [ ] Is the code **100% complete, DRY**, and free of placeholder TODO comments?
- [ ] Are all colors using `AppColors` constants, NOT hardcoded hex values?
- [ ] Is all UI text in proper Arabic?
- [ ] Are directional paddings using `EdgeInsets.directional` instead of `left`/`right`?
- [ ] Did I handle all 3 states of `AsyncValue` (`data`, `loading`, `error`)?
- [ ] Did I preserve existing performance optimizations (`ValueKey`, `Isolate.run`, `batch()`) when editing files?
- [ ] Are heavy widgets deferred from entrance animations (150ms buffer)?

---

## 7. 📝 RESPONSE INSTRUCTIONS FOR AI

1. When asked to create or modify code, perform a mental check against the **Strict Performance Guardrails** and **Self-Correction Checklist** before outputting the solution.
2. Explain technical regressions or performance impacts briefly when suggesting architectural refactors.
3. **Do NOT remove** existing performance optimizations (like `ValueKey`, `Isolate.run`, or `batch()`) when editing an existing file.
4. When creating new files, follow the **Feature-First Clean Architecture** pattern: `lib/features/<feature_name>/{domain,data,presentation,application}`.
5. When creating new providers, follow the existing Riverpod pattern used in the codebase (not code-gen `@riverpod` — the project uses manual provider definitions).
6. When creating new Drift tables, add them to the `@DriftDatabase` annotation in `app_database.dart` and update `schemaVersion`. Create proper migration logic in `onUpgrade`.
7. All code comments can be in English or technical Arabic. All UI-facing strings must be in Arabic.
8. When working with the Quran data, be respectful and precise — the Quran text must be rendered with utmost accuracy using the Uthmani script.
