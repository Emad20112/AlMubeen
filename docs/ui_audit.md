# Al-Mubeen — UI/UX Audit (Task 1)

> **Status:** Audit only. This document records the *current* state of the UI layer.
> No feature was redesigned, no business logic touched, no dependency changed.
>
> **Scope of measurement:** all `lib/**/*.dart` except generated `*.g.dart` — **171 files**.
> Every number below was produced by scanning the source, not estimated.

---

## 0. Executive summary

| Dimension | Current state | Verdict |
|---|---|---|
| Distinct colours | **85** (20 in `AppColors` + **65** hardcoded `Color(0x…)` literals) | Worst offender |
| `AppColors` adoption | 607 references across 58 of 171 files (34 %) | Partial |
| `TextStyle(` literals | **199** — bypass `TextTheme` almost everywhere | Worst offender |
| Distinct `fontSize` | **24** | Fragmented |
| UI font families | **0 declared** in `pubspec.yaml` | Missing |
| Distinct radii | **24** (`BorderRadius.circular` 18 + `Radius.circular` 6) | Fragmented |
| Distinct `SizedBox` gaps | **33** | Fragmented |
| Distinct `EdgeInsets.all` | **15** | Fragmented |
| Distinct animation durations | **26** ms/second values, **7** curves | Fragmented |
| `Material AppBar` usages | 4 | Headers are ~all custom |
| `Card(` usages | **2** | Cards are ~all `Container` |
| Button widgets | 151 across 5 types, only **36** `styleFrom` calls | Un-themed |

**The single biggest structural finding:** there is no design system. `AppColors` is a raw
palette with **misleading names**, `AppTheme` styles **2 of 15** component themes, and every
other visual decision is inlined at the call site. `AppColors.maroon800` is actually a warm
brown (`#8A6B3B`), `AppColors.cardRed` is *not* red (`#7B5A44`), and `AppColors.maroon900`
is a blue-grey (`#101720`). The palette is honest about nothing.

---

## 1. Current Color System

### 1.1 The central palette — `lib/app/theme/app_colors.dart`

20 constants. Names describe *hues that no longer exist*.

| Constant | Actual hex | Name claims | Actually is |
|---|---|---|---|
| `maroon900` | `#101720` | deepest maroon | blue-grey / ink-navy |
| `maroon800` | `#8A6B3B` | primary maroon | **warm brown/bronze** — the de-facto brand colour (156 uses) |
| `maroon700` | `#8A7E68` | maroon | warm grey-taupe (69 uses) |
| `maroon600` | `#B9AB8E` | maroon | light sand |
| `parchment` | `#F5F1E8` | parchment | correct — light scaffold |
| `parchmentLight` | `#FFFFFCF7` | parchment | correct — light surface (102 uses) |
| `parchmentMuted` | `#E4D9C6` | muted parchment | correct — muted surface |
| `ink` | `#1E1E1E` | ink | correct — light text |
| `darkScaffold` | `#0B1018` | dark scaffold | correct — dark background |
| `darkSurface` | `#151C27` | dark surface | correct |
| `darkSurfaceHigh` | `#1F2835` | elevated surface | correct (27 uses) |
| `darkInk` | `#F6F0E5` | dark ink | correct |
| `goldenAccent` | `#D4AF37` | gold accent | correct — light `primary` |
| `goldenAccentDark` | `#E8D6A5` | gold (dark) | correct — dark `primary` |
| `cardCream` | `#FFFFF8E8` | cream card | correct |
| `cardRed` | `#7B5A44` | **red** | **brown** — not red at all |
| `cardRedDark` | `#E8D6C6` | dark red | **beige** — not red at all |

> **Problem:** the names are actively misleading. A developer reading
> `AppColors.cardRed` reasonably expects a red. It is a brown. This is why
> 65 colours leaked outside the palette in the first place — when the palette
> does not contain the colour you need, you hardcode one.

### 1.2 Hardcoded colours — the top offenders

**181 `Color(0x…)` literals** in total; **65 distinct**. Distribution:

| Count | Hex | Where | Current | Problem | Recommended semantic token |
|---|---|---|---|---|---|
| **44** | `#D8B457` | `isDark ? … : AppColors.maroon800` in 12 Quran sheets | Duplicates `goldenAccentDark` intent but is a *different* hex, hardcoded in every sheet | **Split-brain brand colour.** Light uses `maroon800`, dark uses this — and `maroon800` is not in the theme's `primary` | `AppColorScheme.primaryStrong` (dark) |
| **15** | `#10B981` | Qibla success state, `content_details_screen` completion chip | Material/Tailwind green, unrelated to the warm palette | Off-brand, no light/dark pair | `success` |
| **9** | `#231A17` | Tafsir/translation/Wird dark sheet background | Dark surface variant #3 | Three competing dark surfaces | `surface` (dark) |
| **7** | `#1A1210` | Reader search sheet, translation sheet | Dark surface variant #4 | ″ | `surfaceMuted` |
| **6** | `#2B201C` | Tafsir content dark card | Dark surface variant #5 | ″ | `surfaceElevated` (dark) |
| **5** | `#E8C860` | Reciters list title, ayah overlay | Near-duplicate of `goldenAccentDark` | Two golds for one job | `accent` (dark) |
| **5** | `#B8943A` | Gradient partner of `#D8B457` (3 sites) | Gradient only | Gradient defined inline, not tokenised | `accentGradient` |
| **5** | `#8B0000` | `network_error_banner` light error | True red, cold | Warm palette has no error colour | `error` |
| **4** | `#2E6E6A` | Reader settings accent option | Teal | Off-brand | `accentMuted` |
| **4** | `#2C2420` | Hadith screens text | Off-`ink` text colour | Text colour not from a token | `textPrimary` |
| **3** | `#9B5E2E` | — | Warm amber | Likely `warning` | `warning` |
| **3** | `#D4A0A0` | `network_error_banner` dark error | Muted red for dark | Pair for `#8B0000` | `error` (dark) |
| **3** | `#2A070D` | — | Maroon remnant | The only true maroon in the codebase — **unused by the theme** | drop or `primaryDeep` |
| **2** | `#3F1D20` | `network_error_banner` dark gradient | True maroon | Conflicts with `#D8B457` gradient partner | `errorSurface` (dark) |
| **2** | `#5A2A2E` | `network_error_banner` dark gradient | True maroon | ″ | ″ |
| **2** | `#8A7D72` | Hadith secondary text | Off-`ink` text | ″ | `textTertiary` |
| **2** | `#F7F4EB` | Reader header/scrim overlay | Mushaf page colour | Distinct semantic surface | `pageSurface` (light) |
| **2** | `#FFFCF3` | Translation/hadith light sheet | Off-`parchmentLight` | ″ | `surface` |
| 1 each | `#0D1117`, `#1A1A2E` | Tasbih | Unrelated navy/indigo | Off-palette feature | decide: brand or keep |
| 1 each | `#000000`, `#1C1C1E`, `#333333` | Sleep-timer sheet | Hardcoded **dark-only** | Ignores light theme entirely | `surface` variants |
| 1 each | `#4CDB5F`, `#1B401D` | Sleep-timer sheet | Hardcoded dark green | Same | `success` variants |
| 1 each | `#7B6A2E`, `#6A5A2E`, `#556B2F`, `#2E7D55`, `#8B2532`, `#5A3E3E`, `#5E5B8A`, `#2E1215`, `#3A1A1C`, `#8B3A3A`, `#5A1A1A`, `#FFE6E6`, `#FFF0F0`, `#241815`, `#1E1715`, `#2B211E`, `#2A2320`, `#2C2821`, `#171311`, `#161616`, `#FDF8F0`, `#F4EBDD`, `#FAF8F3` | scattered | One-off surfaces with no shared definition | — | mapped to `surface*` / `text*` |

### 1.3 Light vs Dark mode

- **Light** is well defined: `parchment` background, `parchmentLight` surface, `ink` text.
- **Dark** is **fragmented across at least 6 competing surface colours**
  (`#0B1018`, `#151C27`, `#1F2835`, `#231A17`, `#1A1210`, `#2B201C`, `#1E1715`, `#171311`)
  and **two competing brand golds** (`goldenAccentDark #E8D6A5` in the theme vs `#D8B457`
  hardcoded in 44 places).
- The theme's dark `secondary` is `parchmentMuted` (a *light* cream) — a light value in a
  dark scheme, so `onSecondary` is also forced to `darkScaffold`. Coincidentally readable,
  semantically wrong.

### 1.4 Verdict → semantic mapping

`AppColors` (raw palette) is **kept as-is** in Task 1 because 607 call sites depend on it.
A new `AppColorScheme` semantic layer is added, the `Theme` now consumes the semantic layer,
and migration of call sites is deferred to Task 2+.

---

## 2. Typography Audit

### 2.1 Font families

| Finding | Detail |
|---|---|
| `fonts:` section in `pubspec.yaml` | **ABSENT** — the app bundles **no** font at all |
| `fontFamily:` literals in `lib/` | only `'Amiri'` — **2 uses**, `tafsir_reader_content.dart:153,355` |
| Is `'Amiri'` actually available? | **No.** Not declared in `pubspec.yaml` → silently falls back to the platform font. This is a live bug, not a style choice. |
| `AGENTS.md` claims `DiwaniBent` at `assets/fonts/DiwaniBent.ttf` | **File does not exist.** `assets/` contains only `data/` (JSON/XML/PNG) and `svg/`. `DiwaniBent` is not in any theme either. Documentation is stale. |
| Google Fonts | **Not used.** No `google_fonts` dependency. |
| Quran font | Fully isolated **inside `qcf_quran` v0.0.5**, which registers 604 per-page
  families `QCF_P001 … QCF_P604` and renders through its own widgets. The app never names
  one of these families itself. **This separation is correct and must be preserved.** |

### 2.2 Sizes and weights

- **182 `fontSize:`** declarations across **24 distinct values**:
  `8, 9.5, 10, 10.5, 11, 11.5, 12, 12.5, 13, 13.5, 14, 14.5, 15, 15.5, 16, 16.5, 17, 18, 20, 22, 28, 30, 32, 42`
- **201 `FontWeight` usages**, spread across `w300 … w900` (incl. `w800`, which is not a
  standard design-system step).
- **199 raw `TextStyle(`** literals.
- **95 `textTheme.<role>` reads** but almost always immediately `.copyWith(color: …, fontSize: …, fontWeight: …)` — i.e. the `TextTheme` is used as a *starting point and then overridden*, so it provides no consistency.

The half-pixel values (`9.5, 10.5, 11.5, 12.5, 13.5, 14.5, 15.5, 16.5`) exist because the
app scales text globally. They are a symptom of hardcoding sizes that must then be fought
with `MediaQuery.textScaler` + user `fontScale` (clamped `[0.8, 1.45]` in `al_mubeen_app.dart:40-46`).

### 2.3 TextTheme

`AppTheme` sets:
```dart
textTheme: Typography.blackMountainView.apply(bodyColor: ink, displayColor: ink)
```
`blackMountainView` is a **colour-only** `TextTheme` (`fontFamily: 'Roboto'`, colours, no
geometry). `ThemeData` then merges it over `Typography.material2021`, which supplies all
geometry. Net effect: **Roboto + Material 3 geometry, tinted with brand ink.** For Arabic
text, the platform's Arabic fallback is used — i.e. there is effectively **no typographic
identity at all**.

### 2.4 Recommended system

```
Display      96 / 60 / 48    w300-w400   — onboarding hero, empty-state art
Headline     40 / 34 / 24    w400-w600   — screen titles
Title        22 / 16 / 14    w500-w600   — card & list titles
SectionTitle 16 / w700                 — section headers ("أذكار الصباح")
BodyLarge    16 / 1.50       w400
Body         14 / 1.43       w400
BodySmall    12 / 1.33       w400
Label        14 / 12 / 11    w500-w600   — buttons, chips
Caption      11 / 1.45       w500        — timestamps, counts
```

Weights restricted to `400 / 500 / 600 / 700`.

**Two hard rules encoded in the foundation:**
1. `UI Typography ≠ Quran Typography`. `AppTypography` exposes `uiFontFamily` (bundled UI
   font) and `quranFontFamily` (`null` — owned by `qcf_quran`) as *separate* constants, and
   `AppTypography.quranText(...)` never sets a UI family.
2. The UI family stays `null` (platform default) until a font asset is actually added, so
   Task 1 changes **zero** glyphs. One constant flip enables it later.

---

## 3. Spacing Audit

**335 `SizedBox(height:/width:)`** with **33 distinct values**, **39 `Gap()`** with 11
distinct values, **68 `EdgeInsets.all()`** with 15 distinct values.

| Value | Count | Verdict |
|---|---|---|
| 8 | 76 | on-grid |
| 4 / 12 / 16 / 24 | 32 / 34 / 35 / 9 | on-grid |
| 2 / 6 / 10 / 14 / 20 | 21 / 15 / 33 / 18 / 9 | **off-grid** |
| 3 / 5 / 1 | 5 / 4 / 1 | **off-grid** |
| 18 / 22 / 26 / 28 / 30 / 32 / 36 / 40 / 44 / 48 / 52 / 60 / 72 / 86 / 100 / 140 / 158 / 216 / 360 | 7 / 1 / 2 / 2 / 3 / 4 / 1 / 4 / 2 / 4 / 2 / 1 / 1 / 2 / 1 / 1 / 1 / 1 / 1 | **off-grid** — these are mostly layout-critical (carousels, sheets, page footers), not rhythm |

`EdgeInsets.all` values: `3, 4, 8, 9, 10, 12, 14, 16, 18, 20, 22, 24, 28, 48` — note
`9`, `14`, `18`, `22` are strictly off a 4-pt grid.

`EdgeInsets.symmetric` 111 · `EdgeInsets.all` 68 · `EdgeInsets.fromLTRB` 56 ·
`EdgeInsets.only` 13 · `EdgeInsetsDirectional` 3 · **`EdgeInsets.directional` 0**

The project already depends on `gap: ^3.0.1` and uses it in 39 places — but
`SizedBox` still dominates 335 : 39. `AGENTS.md` mandates `Gap()`.

**Proposed scale (4-pt base, absorbs 80 % of existing usage):**

| Token | Value | Existing `SizedBox` uses it replaces |
|---|---|---|
| `xs` | 4 | 4, 3, 5, 1 |
| `sm` | 8 | 8, 6, 10, 9 |
| `md` | 12 | 12, 14, 11 |
| `lg` | 16 | 16, 18, 15, 20 |
| `xl` | 24 | 24, 22, 26, 28 |
| `xxl` | 32 | 32, 30, 36, 40 |
| `xxxl` | 48 | 48, 44, 52, 60 |

Plus semantic aliases: `screenPadding` (16), `cardPadding` (16), `listItemSpacing` (12),
`sectionSpacing` (24), `touchTarget` (48), `appBarHeight` (56).

---

## 4. Radius Audit

**216 `BorderRadius.circular()`** — **18 distinct**; **14 `Radius.circular()`** — 6 distinct.
**24 distinct radii, 230 usages.**

| Value | `BR.circular` | Verdict |
|---|---|---|
| 2 | 8 | micro |
| 4 | 1 | micro |
| 6 | 8 | micro |
| **8** | **13** | → `small` |
| 9 | 1 | off-grid |
| **10** | **19** | → `small` |
| 11 | 2 | off-grid |
| **12** | **39** | → `medium` (most used) |
| **14** | **25** | → `medium` |
| **16** | **24** | → `large` |
| 18 | 9 | off-grid |
| **20** | **21** | → `large` |
| 22 | 5 | off-grid |
| 24 | 6 | → `extraLarge` |
| 26 | 2 | off-grid |
| 28 | 2 | off-grid |
| 30 | 6 | off-grid |
| **999** | **25** | → `pill` |
| `Radius.circular`: 8, 16, 20, 22, 24, 36 | 14 | fold into the above |

**Proposed scale** (chosen from observed frequency, not invented):

| Token | Value | Absorbs |
|---|---|---|
| `small` | 8 | 2, 4, 6, 8, 9, 10, 11 |
| `medium` | 14 | 12, 14, 16 |
| `large` | 20 | 18, 20, 22 |
| `extraLarge` | 28 | 24, 26, 28, 30, 36 |
| `pill` | 999 | 999 |

Also provided: `AppRadii.borderRadius(X)` returning `BorderRadius`, `AppRadii.of(context)`
reading from `ThemeExtension`, and a `ShapeBorder` variant for `Card`/`BottomSheet`.

---

## 5. Shadow Audit

- **44 `blurRadius:`** values across **13 distinct**: `3, 4, 8, 10, 12, 14, 15, 16, 18, 20, 22, 24, 40`
- **5 `sigmaX`/`sigmaY`** (BackdropFilter): `10, 12, 14, 18` (one is 4, counted as 5 entries)
- **8 `elevation:`** values: only `0` (6×) and `2` (2×)
- `spread` used **2×** (`2`, `4`)

Findings:
- **No `ThemeData.shadowColor` / no `cardTheme.elevation` policy** — elevation is per-widget.
- The same decorative header shadow `(blur 14, spread 0, offset (0,7))` is **copy-pasted** in
  `islamic_header.dart:29-39` and `adhkar_custom_header.dart:82-91`.
- A `blurRadius: 40` and a `blurRadius: 3` coexist — a 13× spread in one app.
- **No dark-mode shadow differentiation at all** — dark surfaces get the same black shadows,
  which is physically meaningless and makes elevation invisible in dark mode.

**Proposed scale (light / dark pairs):**

| Token | Blur | Spread | Offset Y | Light colour | Dark colour |
|---|---|---|---|---|---|
| `none` | — | — | — | — | — |
| `subtle` | 8 | 0 | 2 | `#1A120C` @ 6 % | `#000000` @ 40 % |
| `medium` | 16 | 0 | 4 | `#1A120C` @ 10 % | `#000000` @ 55 % |
| `elevated` | 28 | −2 | 10 | `#1A120C` @ 14 % | `#000000` @ 70 % |

(`subtle`/`medium` reuse the `blurRadius: 8 / 16` already in the codebase; `elevated` adopts
the existing 24-scale family.)

---

## 6. Motion Audit

**26 distinct durations** + **7 curves**.

| ms | Count | ms | Count |
|---|---|---|---|
| 16 | 2 | 320 | 2 |
| 150 | 2 | 350 | 5 |
| 180 | 7 | 400 | 4 |
| 200 | 3 | 500 | 5 |
| 220 | 2 | 600 | 1 |
| 250 | 1 | 900 | 4 |
| 260 | 1 | 1200 | 1 |
| 280 | **10** | 1400 | 1 |
| 300 | 6 | 1500 | 1 |

Seconds: `1,2,3,4,5,10,15,20` (8) · Minutes: `15,30` (3 — these are sleep-timer values, not animations).

Curves: `easeOutCubic` **15** · `easeOut` 5 · `easeInOutCubic` 4 · `easeInOut` 2 ·
`easeInCubic` 1 · `easeOutQuint` 1 · `elasticOut` 1.

Widgets: `AnimationController` 15 · `AnimatedContainer` 9 · `FadeTransition` 6 ·
`AnimatedBuilder` 4 · `SlideTransition` 2 · `ScaleTransition` 2 · `AnimatedScale` 2 ·
`AnimatedOpacity` 1 · `AnimatedSwitcher` 1. `TweenAnimationBuilder` **0**.

**Findings:**
- `easeOutCubic` is already the de-facto default (15 uses) — keep it, promote it to `AppMotion`.
- The **280 ms** cluster (10 uses) is the Quran reader's own timing (highlight/overlay) and
  should stay feature-local, not become a global token.
- **Zero `TweenAnimationBuilder`** despite a skill-level mandate — all implicit animation
  goes through hand-rolled `AnimationController`s.
- **No `PageTransitionsTheme`** anywhere. `go_router` uses the platform default
  (`ZoomPageTransitionsBuilder` on Android) for all 16 routes. Four sheets/dialogs hand-roll
  their own `transitionBuilder` (`adhkar_counter.dart:66`,
  `quran_reader_search_sheet.dart:48`, `quran_reader_settings_sheet.dart:39`,
  `wird_dialog.dart:24`) with no shared timing.
- `ShimmerGroup` runs a `1400 ms` `repeat(reverse: true)` (`shimmer_group.dart:17`).

**Proposed scale:**

| Token | Duration | Curve | Use |
|---|---|---|---|
| `instant` | 100 ms | `linear` | press/release |
| `micro` | 150 ms | `easeOut` | icon swap, ripple, checkbox |
| `fast` | 200 ms | `easeOutCubic` | hover, small fade |
| `standard` | 280 ms | `easeOutCubic` | expand/collapse, sheet content |
| `page` | 320 ms | `easeOutCubic` | route transitions |
| `modal` | 400 ms | `easeOutCubic` | dialog / bottom sheet |
| `hero` | 600 ms | `easeInOutCubic` | Hero flights |

Curves centralised: `standard = easeOutCubic`, `emphasized = easeOutCubic`,
`decelerate = easeOut`, `accelerate = easeInCubic`, `symmetric = easeInOutCubic`.

---

## 7. Loading Audit

| Pattern | Count | Locations |
|---|---|---|
| `CircularProgressIndicator` | **19** | bootstrap ×2, adhkar nav bar, qibla ×2, audio download, surah player ×3, tafsir download ×2, translation download ×2, bookmarks sheet, reader search, reciters list ×2, player controls, wird dialog |
| `LinearProgressIndicator` | **11** | `app_loading_view.dart:67`, audio download, surah player, tafsir download ×3, translation download ×3, wird dialog ×2 |
| `Skeleton*` / `shimmer` references | 23 | `shimmer_group.dart` + 2 screens |
| `RefreshIndicator` | 1 | — |
| `FutureBuilder` | 0 | ✅ already fully on `AsyncValue` |
| `ErrorWidget.builder` | **0** | ❌ never overridden |

### 7.1 Real vs fake progress

| Value | Site | Real? |
|---|---|---|
| `progress: 0.1` | `qcf_font_bootstrap.dart:70` | **Fake** — a hardcoded hint, not a measurement. QCF has no byte-level progress. |
| `progress: 0.6` | `qcf_font_bootstrap.dart:78` | **Fake** — same. |
| `progress: 0.0` | `quran_audio_download_controller.dart:185,364` | Initial state, becomes real via `background_downloader`. ✅ |

**Conclusion:** the two `0.72`-style hardcoded progress values flagged in the brief **do not
exist** in this codebase. The only hardcoded progress is the QCF bootstrap pair
(`0.1` / `0.6`), which is an indeterminate boot stage disguised as determinate. Every
`LinearProgressIndicator` elsewhere is bound to a real `background_downloader` or DB
fraction. **Recorded, not changed.**

### 7.2 Skeleton vs spinner

| Location | Current | Recommended |
|---|---|---|
| `names_of_allah_screen.dart:726+` | `_AllahNameSkeletonCard` | ✅ correct |
| `category_grid_screen.dart:151-154` | sliver skeletons | ✅ correct |
| `hadith_nawawi_screen.dart:85-90` | spinner | → skeleton |
| `quran_reciters_list_view.dart:303` | spinner | → skeleton |
| `qibla_compass_screen.dart:183-190, 336-342` | spinner, **no timeout, no escape** | keep spinner (sensor-bound) but add a terminal state |
| `quran_bookmarks_sheet.dart:90-91` | spinner | → skeleton |
| `app_loading_view.dart:67` | linear, always | correct (supports real `progress`) |
| 14 other sites | spinner | keep — all bound to short, non-predictable ops |

### 7.3 The real loading problem

`AppLoadingOverlay` (`core/widgets/app_loading_overlay.dart:27-32`) runs an **unbounded
`repeat()` with no timeout and no error exit.** A caller that forgets to clear it
deadlocks the surface permanently. It has 4 call sites.

---

## 8. Button Audit

**151 button widgets**, 5 types, only **36 `styleFrom` overrides**.

| Type | Usages | `styleFrom` |
|---|---|---|
| `IconButton` | 64 | 10 |
| `TextButton` | 40 | 14 |
| `FilledButton` | 24 | 7 |
| `ElevatedButton` | 13 | 3 |
| `OutlinedButton` | 10 | 2 |
| `SegmentedButton` / `ChoiceChip` / `FilterChip` | **0** | 0 |

### 8.1 Inconsistencies

| Dimension | Current state |
|---|---|
| **height** | 2 declared `minimumSize` values only — `Size(0, 30)` and `Size(0, 36)`. The other 149 buttons use the M3 default (40). **34 px of unused vertical variance.** |
| **radius** | **0** button styles set `shape`. All 151 inherit M3's `StadiumBorder`. But every *card* the button sits in is `BorderRadius.circular(12)`. Buttons and cards have **unrelated** shape systems. |
| **colour** | Ad-hoc per call site. `FilledButton` with no style uses `colorScheme.primary` = `#D4AF37` gold; hand-styled ones use `#8A6B3B` brown. **Two different "primary button" colours.** |
| **text size** | M3 default `labelLarge` (14/w500) — but `fontSize:` overrides appear throughout. |
| **icon size** | **0** `iconSize:` declarations. M3 default 18. |
| **padding** | M3 default only. |
| **border** | 0 custom borders on `OutlinedButton`. |
| **animation** | 0 press-scale animations anywhere. |
| **disabled state** | 0 explicit. Falls back to M3 `onSurface @ 12 %` — on a gold primary this is barely visible. |
| **loading state** | **0 buttons have a loading state.** 15 spinners sit *beside* buttons rather than inside them. |

### 8.2 Classification

| Class | Exists today | Canonical example |
|---|---|---|
| Primary | ✅ ad-hoc | gold fill, no text |
| Secondary | ⚠️ inconsistent | brown `#8A6B3B` fill |
| Outlined | ✅ | M3 default outline on primary |
| Text | ✅ (40×, the most-used) | M3 default |
| Icon | ✅ (64×) | M3 default |
| Danger | ❌ **missing** — errors are red *backgrounds*, never red buttons | — |
| Loading | ❌ **missing** | — |

---

## 9. Card Audit

`Card(` appears **only 2×** in the entire app
(`tafsir_download_screen.dart:949`, `translation_download_screen.dart:1075`).
Cards are otherwise `Container` + `BoxDecoration`, `DecoratedBox`, `ClipRRect`,
`BackdropFilter` (19 combined).

Classification of what plays the role of a card:

| Class | Count | Evidence |
|---|---|---|
| **Normal Card** | ~14 | `app_loading_view`/`app_error_view` shells, sheets, most `Container` panels |
| **Elevated Card** | ~2 | `0xFF2B201C` / `0xFF231A17` dark panels in tafsir & translation content |
| **Glass Card** | ~5 | `BackdropFilter` in `ayah_interaction_overlay.dart`, `network_error_banner.dart`, `quran_page_carousel` footer |
| **Interactive Card** | 2 | `adhkar_grid_card.dart`, `decorative_card.dart` (SVG-framed Islamic style) |
| **Selected Card** | ~6 | `wird` cycles, `tasbih` presets, reciters list, `quran_reader_settings` — each with its own selected treatment |

Radii across these 5 classes range 10–30. Elevation ranges 0–2. Backgrounds: flat, gradient,
and glass. **No shared surface contract.**

`AGENTS.md` correctly warns against `BackdropFilter` inside scrollable list items — 3 of the
5 glass surfaces are in scroll contexts (reader overlay, reciters list, page carousel).

---

## 10. Header Audit

**4 real `Material AppBar(`** usages: `about_app_screen.dart:21`,
`tafsir_download_screen.dart:52`, `tafsir_viewer_screen.dart:75`,
`translation_download_screen.dart:62`. Each overrides 2–3 of the 5 properties
`appBarTheme` already sets, so the theme contributes almost nothing.

**4 distinct custom top-header designs:**

| | `IslamicHeader` | `AdhkarCustomHeader` | `QuranReaderHeader` | surah-player `_TopBar` |
|---|---|---|---|---|
| File | `core/widgets/islamic_header.dart:4` | `core/widgets/adhkar_custom_header.dart:5` | `quran/…/quran_reader_header.dart:8` | `quran_surah_player_screen.dart:202` |
| Height | intrinsic | intrinsic | **52, not 56** | intrinsic |
| Padding | `fromLTRB(14,12,14,0)` | `fromLTRB(16,12,16,16)` | `symmetric(12,8)` | `fromLTRB(8,8,8,0)` |
| SafeArea | ❌ | ❌ | ✅ `bottom:false` | ❌ |
| Title | `headlineSmall` w800, `maxLines:1` | `headlineSmall` w700, **no maxLines** | none (search) | raw `TextStyle(18)` |
| Max width | 420 in `Expanded` | **unbounded** | `Expanded` | **unbounded** |
| Background | flat + shadow | flat + shadow | **glass blur σ18** + border | none |
| Dark branch | ✅ | ✅ | ✅ | ❌ |

Also: `_AllahNamesHeaderDelegate` (`names_of_allah_screen.dart:238`) is the **only**
text-scale-aware header — it clamps `max(72, 182 - 100·scale)`.

**Dead code:** `kQuranReaderHeaderHeight = 56` (`quran_reader_header.dart:6`) is declared and
**referenced nowhere**. `AGENTS.md` documents a `DiwaniBent` header font that does not exist.

**Dead components** (class defined, zero instantiations): `HomeBottomNavigation`,
`CustomBottomNav`, `AdhkarNavigationBar`, `QuranReaderBackButton`. Notably
`home_bottom_navigation.dart:32-42` is the best `LayoutBuilder`/breakpoint code in the
project and is never rendered.

Target shape: `AppHeader` (base) → `HomeHeader` (decorated SVG + subtitle) →
`QuranReaderHeader` (glass, search slot, SafeArea-aware). **Not built in Task 1.**

---

## 11. Error / Empty / Offline Audit

### 11.1 Shared components exist but are barely adopted

| Component | Definition | Live call sites |
|---|---|---|
| `AppErrorView` | `core/widgets/app_error_view.dart:5` | **4 — all in `content_details_screen.dart`** |
| `AppLoadingView` | `core/widgets/app_loading_view.dart:5` | **2 — both in `content_details_screen.dart`** |
| `AppLoadingOverlay` | `core/widgets/app_loading_overlay.dart:7` | 4 |
| `NetworkErrorBanner` | `core/widgets/network_error_banner.dart:12` | **2 — Quran audio surfaces only** |
| `ShimmerGroup` / `SkeletonBox` | `core/widgets/shimmer_group.dart` | 2 |

`AppErrorView` and `AppLoadingView` are effectively single-screen helpers. **12 routed
screens hand-roll their own.**

### 11.2 Duplication

**6 hand-rolled copies of `AppErrorView`**, all the same shape
(`Icon(error_outline, 40-56)` + `w700` title + 12-13px body + `FilledButton.icon('إعادة المحاولة')`):
`hadith_nawawi_screen.dart:335-365`, `names_of_allah_screen.dart:688-718`,
`tafsir_reader_content.dart:385-411`, `translation_bottom_sheet.dart:443-481`,
`qibla_compass_screen.dart:203-331`, plus the shared one.

**6 different empty-state implementations** across `category_grid_screen`, `tasbih_screen`,
`quran_bookmarks_sheet`, `quran_reciters_list_view`, `quran_audio_download_screen`,
`names_of_allah_screen` — differing in icon, size, message length, and vertical centring.

### 11.3 SnackBars — 11 sites, 4 styles, 0 actions

| Style | Sites |
|---|---|
| floating + rounded | `allah_name_detail_sheet.dart:345`, `hadith_detail_screen.dart:311` |
| floating + rounded + 2 s | `quran_reader_search_sheet.dart:150` |
| floating + **red bg** + 4 s | `quran_page_reader.dart:503` |
| **plain M3 default** | `quran_surah_player_screen.dart:518`, `translation_bottom_sheet.dart:228`, `ayah_audio_player_bar.dart:291`, `translation_download_screen.dart:345`, `tafsir_download_screen.dart:365`, `content_details_screen.dart:622` (1 s) |

**None of the 11 has an `action`.** Every toast is a dead end the user must wait out —
including the 4 s error in the reader and the two "download already running" guards where an
"إلغاء"/"بانتظار" action would be genuinely useful. `content_details_screen.dart:622`
styles a **success** message ("تم نسخ النص") as a plain default bar.

### 11.4 Gaps

- **`ErrorWidget.builder` is never overridden** → any framework build error shows the grey
  box in production.
- **`isConnectedProvider` is declared and never watched** by any widget
  (`core/network/connectivity_providers.dart:12-18`). Connectivity is instead read ad hoc
  inside `quran_audio_controller.dart:135`. **There is no global offline state.**
- **4 states with no retry action:** `quran_bookmarks_sheet.dart:92`,
  `quran_reciters_list_view.dart:305`, `wird_dialog.dart:218`, `quran_surah_player_screen.dart:313`.
- **Qibla** (`qibla_compass_screen.dart:336-342`): if not loading, no error, and
  `_currentDirection == null`, the UI shows a spinner with **no timeout and no escape** except
  the sensor stream.

---

## 12. Responsive Audit

`lib/core/layout/adaptive_breakpoints.dart` defines compact `<600` / medium `<1024` /
expanded `≥1024`.

**`AdaptiveBreakpoints` has 8 consumers** of 171 files:
`category_grid_screen`, `content_details_screen`, `hadith_detail_screen`,
`hadith_nawawi_screen`, `home_bottom_navigation` *(dead)*, `names_of_allah_screen`,
`quran_reciters_list_view`, `surah_picker`.

Primitives: `Expanded` 97 · `SafeArea` 27 · `Flexible` 8 · `Wrap` 8 · `LayoutBuilder` 14 ·
`MediaQuery.sizeOf` 18 · `AspectRatio` 1 · `maxWidth` caps in ~23 files.
`textScaleFactor` **0** — ✅ fully migrated to `TextScaler`.

### 12.1 Good

- `ContactStyleMenuScreen` caps at `maxWidth: 560` in a `CustomScrollView` (`:58,82`).
- `SurahPicker` switches `showModalBottomSheet` ↔ `Dialog` and recomputes `crossAxisCount`
  from `constraints.maxWidth` (`:25-59,265-305`).
- Reader settings sheet folds 1↔2 columns with `LayoutBuilder` + `Wrap` at 390 dp.
- Qibla error view wraps an infinite-width card in `SingleChildScrollView` (`:218-223`).
- **Mushaf font sizing is genuinely adaptive:** `screenWidth/390` clamped `[0.82,1.18]`,
  then user `fontScale` clamped `[0.55,1.15]`, then
  `verseHeight = (availableHeight − 62) / (15 × fontSize)` (`quran_page_reader.dart:287-301`).

### 12.2 Weak / overflow risk

| Site | Risk |
|---|---|
| `adhkar_custom_header.dart:124-148` | fixed 36 dp `TextField`, `fontSize: 12`, `contentPadding: EdgeInsets.zero` — at the app's own 1.45× ceiling it **clips its own text** |
| `adhkar_custom_header.dart:106-119` | title has **no `maxLines`**, in a `spaceBetween` `Row` with a live Hijri clock — collides instead of ellipsizing |
| `quran_reader_header.dart:124-170` | fixed 36 dp icon/search boxes + `maxLines: 1` → truncates at 1.45× |
| `quran_sleep_timer_sheet.dart:130-131` | hard `height: 216` for `CupertinoTimerPicker` |
| `quran_surah_player_screen.dart:309-312` | hard `height: 44` with a spinner |
| `ayah_interaction_overlay.dart:397-425` | `width: 52`, `fontSize: 10`, `maxLines: 1` |
| `quran_page_carousel.dart:332-376` | `fontSize: 9.5/10`, `height: 1.1`, fixed 86 dp slots |
| `islamic_header.dart:89` | decorative `height: 18` rule |

**Pattern:** the risk is concentrated in **fixed-height containers holding text**, not in
missing `Flexible`. Overflow will occur on a 320 dp phone or at the 1.45× text ceiling.

### 12.3 RTL safety

`EdgeInsets.symmetric` 111 · `all` 68 · **`fromLTRB` 56** · `only(left/right)` 2 ·
`EdgeInsetsDirectional` 3 · **`EdgeInsets.directional` 0**

- **2 genuine RTL bugs** (asymmetric `fromLTRB` in a forced-RTL app):
  `quran_reciters_list_view.dart:861`, `:892`.
- 3 redundant hard `Directionality(textDirection: rtl)` overrides:
  `quran_reader_header.dart:44`, `quran_page_carousel.dart:327`, `contact_style_menu_screen.dart:45`.
- **2 deprecated `MediaQuery.of(context).size`** calls (should be `MediaQuery.sizeOf`):
  `quran_page_reader.dart:534-537`, `translation_bottom_sheet.dart:297`.

### 12.4 Sleep-timer sheet ignores theming entirely

`quran_sleep_timer_sheet.dart:78-281` hardcodes `#000000`, `#1C1C1E`, `#333333`,
`#1B401D`, `#4CDB5F` — a **dark-only** surface that looks broken in light mode. One of the
clearest single bugs found.

---

## 13. Dependencies (verified, unchanged)

| Item | Status |
|---|---|
| `qcf_quran` | `^0.0.5` ✅ **unchanged**. 20 import sites across 15 files. Owns 604 `QCF_P*` families. Untouched. |
| `gap` | `^3.0.1` present ✅ (contradicts the note in `AGENTS.md` that it is missing) |
| `google_fonts` | not present — no network font fetching |
| New deps added | **none** |

`flutter analyze` baseline: **No issues found.**

---

## 14. Priority matrix for Task 2+

| # | Issue | Severity | Fix |
|---|---|---|---|
| 1 | 65 hardcoded colours, 6 competing dark surfaces, 2 competing golds | 🔴 | Migrate call sites to `AppColorScheme` |
| 2 | 199 raw `TextStyle` bypassing `TextTheme` | 🔴 | Adopt `AppTypography` roles |
| 3 | 24 radii / 33 gaps / 15 paddings / 24 font sizes | 🔴 | Adopt `AppRadii` / `AppSpacing` |
| 4 | `sleep_timer_sheet` is hardcoded dark-only | 🔴 | Theme it |
| 5 | `fontFamily: 'Amiri'` resolves to nothing | 🔴 | Either add the font or remove the declaration |
| 6 | 4 unrelated header designs + dead `kQuranReaderHeaderHeight` | 🟠 | `AppHeader` / `HomeHeader` / `QuranReaderHeader` |
| 7 | 6 copies of `AppErrorView`; `AppErrorView` used on 1 screen | 🟠 | `AppErrorState` / `AppEmptyState` / `AppOfflineState` |
| 8 | 11 SnackBars, 4 styles, **0 actions** | 🟠 | `AppSnackBar` helpers |
| 9 | No `ErrorWidget.builder`; `isConnectedProvider` unwatched | 🟠 | Global error + offline layer |
| 10 | 151 buttons with 0 radius / 0 disabled / 0 loading styles | 🟠 | `AppButton` / `AppIconButton` |
| 11 | 2 RTL `fromLTRB` bugs; 56 LTR-typed paddings | 🟠 | `EdgeInsetsDirectional` |
| 12 | `AppLoadingOverlay` can deadlock forever | 🟡 | Timeout + error exit |
| 13 | 4 states with no retry | 🟡 | Add actions |
| 14 | Dead components: `HomeBottomNavigation`, `CustomBottomNav`, `AdhkarNavigationBar`, `QuranReaderBackButton` | 🟡 | Wire up or delete |
| 15 | `AGENTS.md` documents a non-existent `DiwaniBent` font | 🟡 | Fix docs |
| 16 | `layout/adaptive_breakpoints.dart` used by 8 of 171 files | 🟡 | Adopt in feature migration |

---

## 15. Task 1 deliverables - what now exists

This section records the foundation built **in the same task** as the audit.
Nothing here is wired into `lib/features/` yet - call-site migration is
Task 2+ by design, so this task carries zero behavioural risk.

### 15.1 Design tokens - `lib/app/theme/`

| File | Provides | Replaces |
|---|---|---|
| `app_colors.dart` | Raw palette (renamed) + `AppColorScheme` (29 semantic roles, Light + Dark) | 65 hardcoded colours |
| `app_spacing.dart` | 4/8/12/16/24/32/48 scale + semantic spacing + `EdgeInsets` helpers | 33 distinct `SizedBox` gaps, 15 paddings |
| `app_radii.dart` | `xs/sm/md/lg/xl/pill` + `AppRadiusTokens` | 24 distinct radii |
| `app_motion.dart` | 7 durations + 4 curves + `tween()` + `stagger()` | 26 durations, 7 curves |
| `app_shadows.dart` | 3 elevation levels, per-brightness + glass helpers | 13 blur values, black-only shadows |
| `app_typography.dart` | 4 weights, `TextTheme` builders, 11 semantic roles, `quranText()` | 199 raw `TextStyle` |
| `app_icon.dart` | 6-step size scale + 18 shared `IconData` | inline `size:` + repeated `Icons.*` |
| `app_shapes.dart` | Button/segment/input shapes + `CardThemeData` | 28 inline `OutlineInputBorder` |
| `app_design_tokens.dart` | `AppDesignTokens` `ThemeExtension` + `context.tokens` | no single source for spacing/radii/motion/shadows |
| `app_theme.dart` | 20 component themes registered in one place | 151 ad-hoc `styleFrom` calls |

### 15.2 Core components - `lib/core/design/`

| Component | Solves |
|---|---|
| `AppSurface` | 181 inline `BoxDecoration` colours via `AppSurfaceRole` |
| `AppStateView` | 6 copies of `AppErrorView`, 4 states with no retry action |
| `AppAsyncView` / `AppAsyncContentView` | per-screen `AsyncValue.when` trees; empty vs error conflation |
| `AppErrorBoundary` | 0 `ErrorWidget.builder` -> red screen in debug, **black screen in release** |
| `AppPageHeader` | 4 competing header designs across 12 routed screens |
| `AppSkeleton` | non-terminating `repeat()` in `ShimmerGroup` / `AppLoadingOverlay` |

### 15.3 Three real defects found by the new tests

These were **not** visible from the audit counts; the contrast and hierarchy
tests surfaced them:

1. **Inverted surface hierarchy.** `surfaceElevated` (card) was *darker* than
   `surface` (background) in light mode, so cards read as recessed. Fixed by
   introducing `AppColorScheme.canvas` for the page background and keeping
   `surfaceElevated` strictly above `canvas` in luminance in both modes.
2. **Success green failed WCAG AA.** `#10B981` measured **2.48:1** on the
   parchment background (limit 3.0:1 for non-text UI). Split into
   `successLight` `#047857` (5.4:1) and `successDark` `#34D399` (7.4:1).
3. **`LayoutBuilder` inside `SingleChildScrollView`.** The first
   `AppStateView` draft read `constraints.maxHeight` from inside the scroll
   view, where height is `infinity` - it threw at layout. Reordered to match
   the working `AppErrorView` pattern, plus a `hasBoundedHeight` guard.

### 15.4 Visual-preservation guards

`test/theme/design_system_test.dart` (25 tests) locks the exact original
surface/appBar/primary values so a future token edit cannot silently change
the look. It also asserts the UI font family is still whatever
`Typography.blackMountainView` produced before (`Roboto` on Android) and
that no `QCF_*` Quran family leaks into the UI `TextTheme`.
