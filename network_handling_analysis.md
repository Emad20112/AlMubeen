# Network Handling Analysis — Al-Mubeen

> Generated: 2026-07-18  
> Package under analysis: `connectivity_plus ^6.1.3`

---

## 1. Executive Summary

The Al-Mubeen app currently has **zero proactive connectivity guards**. All error handling is reactive — network failures are caught *after* they occur via `try/catch` blocks in controllers. The `connectivity_plus` package should be introduced as a thin `ConnectivityService` wrapper (`lib/core/network/connectivity_service.dart`) exposed through Riverpod providers, enabling any controller or widget to **intercept offline states early** and present a clean UI instead of letting raw `SocketException` / `TimeoutException` propagate.

---

## 2. Discovered Network-Dependent Workflows

| # | Workflow | File Path | Current Error Strategy | `connectivity_plus` Integration |
|---|----------|-----------|----------------------|---------------------------------|
| 1 | **Ayah Audio Playback (fetch URI)** | `lib/features/quran/application/quran_audio_controller.dart` | Generic `catch (error)` → sets `errorMessage` on state | **Priority 1** — `_loadAyahUri` should call `Connectivity().checkConnectivity()` before hitting the API. Throw `NoInternetException` if offline to avoid raw `StateError` timeout. |
| 2 | **Surah Audio Playback (fetch chapter URL)** | `lib/features/quran/application/quran_surah_player_controller.dart` | Sophisticated: timeout catches, buffering watchdog, `_handleNetworkError()`, retry count | **Priority 1** — `_loadAndPlayChapter` should check connectivity before the API call. Already has excellent error categorization; adding early offline detection prevents the 15s timeout wait. |
| 3 | **Quran Audio Repository (API calls)** | `lib/features/quran/data/repositories/quran_audio_repository_impl.dart` | Returns `DataResult` with `DataFailureKind.network`/`timeout` | **Priority 2** — Optionally add a connectivity check inside the repository to wrap failures more cleanly, or leave this to controllers (recommended — keep repositories thin). |
| 4 | **Quran Com API Client (raw HTTP)** | `lib/features/quran/data/remote/quran_com_api_client.dart` | Catches `SocketException`, `TimeoutException`, maps to `DataFailure` | **Priority 2** — The API client already handles raw exceptions well. Connectivity check at the controller level is sufficient. No changes needed here. |
| 5 | **Quran Com Remote Data Source** | `lib/features/quran/data/remote/quran_com_remote_data_source.dart` | Wraps API client, maps to `DataResult` | **Priority 3** — No changes needed. The remote data source is a thin pass-through. |
| 6 | **Reciter Repository (fetch recitations)** | `lib/features/quran/data/repositories/quran_reciter_repository_impl.dart` | Network-first with local cache fallback | **Priority 3** — Already resilient due to local cache. No urgent changes needed. |
| 7 | **Quran Audio Download Controller** | `lib/features/quran/application/quran_audio_download_controller.dart` | Uses `background_downloader` which has its own error handling | **Priority 2** — Download controller should show a `NetworkErrorBanner` when offline. Downloads already fail gracefully but the user gets no clear feedback. |
| 8 | **Tafsir Download Controller** | `lib/features/quran/application/tafsir_download_controller.dart` | Similar to audio download | **Priority 3** — Low risk; tafsir data is often already cached locally. |
| 9 | **Translation Download Controller** | `lib/features/quran/application/translation_download_controller.dart` | Similar to audio download | **Priority 3** — Low risk; translations cached locally. |
| 10 | **Adhkar Repository (IslamHouse API)** | `lib/features/adhkar/data/islam_house_adhkar_repository.dart` | Network fetch with local fallback | **Priority 3** — Adhkar data is fetched once at startup. Offline state is unlikely to cause a crash but should show a banner. |

---

## 3. Critical Path: Quran Audio Player

The most impactful integration point is the **ayah-level audio player** (`QuranAudioController`):

```
User taps play
  → playOrToggleAyah()
    → _playWindow()
      → _fetchAyahUri()  ← calls quranAudioRepositoryProvider.getAyahAudio()
        → HTTP GET to api.quran.com
          → TimeoutException after 30s
            → StateError thrown
              → Caught generically → "تعذر تشغيل تلاوة هذه الآية."
```

**Problem:** When offline, the user waits ~30 seconds for a timeout before seeing a generic error. The `StateError` message is not meaningful.

**Solution with `connectivity_plus`:**
```
User taps play
  → playOrToggleAyah()
    → Connectivity().checkConnectivity()  ← instant check
      → if offline → throw NoInternetException("لا يوجد اتصال بالإنترنت")
        → Caught specifically → state.errorMessage = "لا يوجد اتصال بالإنترنت"
          → UI renders NetworkErrorBanner with retry button
```

---

## 4. Integration Architecture

```
lib/core/network/
├── connectivity_service.dart       ← Wraps Connectivity() with stream + one-shot check
├── connectivity_providers.dart     ← Riverpod providers (connectivityServiceProvider, isConnectedProvider)
└── no_internet_exception.dart      ← Clean typed exception for offline interception
```

### Provider Wiring
```
connectivityServiceProvider (Provider<ConnectivityService>)
  └─ used by QuranAudioController._loadAyahUri()
  └─ used by QuranSurahPlayerController._loadAndPlayChapter()
  └─ watched by AyahAudioPlayerBar (to show/hide NetworkErrorBanner)
  └─ watched by QuranSurahPlayerScreen._FloatingPlayerBar
```

---

## 5. Files Modified

| File | Change |
|------|--------|
| `pubspec.yaml` | Added `connectivity_plus: ^6.1.3` |
| `lib/core/network/connectivity_service.dart` | **NEW** — ConnectivityService wrapper |
| `lib/core/network/connectivity_providers.dart` | **NEW** — Riverpod providers |
| `lib/core/network/no_internet_exception.dart` | **NEW** — Typed offline exception |
| `lib/core/widgets/network_error_banner.dart` | **NEW** — Reusable error banner widget |
| `lib/features/quran/application/quran_audio_controller.dart` | Connectivity check in `_loadAyahUri` |
| `lib/features/quran/presentation/widgets/ayah_audio_player_bar.dart` | `NetworkErrorBanner` integration |
| `lib/features/quran/presentation/pages/quran_surah_player_screen.dart` | `NetworkErrorBanner` in floating player bar |

---

## 6. Remaining Recommendations (Future Work)

1. **QuranSurahPlayerController** — Add the same early connectivity check in `_loadAndPlayChapter` before the API call (currently relies on timeout detection).
2. **Download Controllers** — Show `NetworkErrorBanner` when a download is attempted offline.
3. **App-Level Connectivity Listener** — Consider a `ProviderScope`-level overlay that shows a persistent `NetworkErrorBanner` at the top of the screen when the device goes offline, affecting all screens.
4. **Reconnection Auto-Retry** — When connectivity returns, auto-retry the last failed operation (e.g., resume audio playback).
5. **Tafsir/Translation Fetchers** — Add connectivity guards to `tafsirChapterProvider` and `translationChapterProvider` FutureProviders.
