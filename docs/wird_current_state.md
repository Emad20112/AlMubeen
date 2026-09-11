# Wird Feature - Current State Audit

## Overview
The current "Wird" implementation is a basic daily reading goal system. It supports selecting a fixed amount (e.g., 1 Juz, 1 Hizb) and tracks how many days the user has completed it.

## Existing Components

### 1. Database Schema (`WirdsTable`)
Located in `lib/core/database/app_database.dart`:
- `id`: Auto-incrementing ID.
- `amountType`: String (maps to `WirdAmountType` enum: quarter, halfHizb, hizb, juz, juzAndHalf, twoJuzs).
- `amountMultiplier`: Integer (default 1).
- `durationDays`: Integer (how many days the plan lasts).
- `frequency`: String (e.g., "daily").
- `reminderTime`: String (nullable).
- `createdAt`: DateTime.
- `lastReadDate`: DateTime (nullable) - tracks the last time the user marked the Wird as read.
- `completedDaysCount`: Integer - total number of days completed.

### 2. Domain Logic (`WirdCalculator`)
Located in `lib/features/quran/domain/wird_calculator.dart`:
- Calculates `startPage` and `endPage` based on `amountType` and `completedDaysCount`.
- Uses `qcf_quran` package for Quran metadata.
- Logic is based on "traversing" the Quran by the specified amount.

### 3. Application Layer (`WirdNotifier`)
Located in `lib/features/quran/application/wird_controller.dart`:
- `wirdControllerProvider`: An `AsyncNotifier` managing a single `WirdEntry?`.
- `markAsRead()`: Increments `completedDaysCount` and updates `lastReadDate`. Prevents multiple updates on the same calendar day.
- `saveWirdSettings()`: Creates or updates the single Wird.

### 4. Data Layer (`WirdDao`)
Located in `lib/features/quran/data/local/wird_dao.dart`:
- Standard CRUD for `WirdsTable`.
- Only retrieves the *latest* created Wird (`limit(1)`).

### 5. Presentation Layer
- `lib/features/quran/presentation/widgets/wird_dialog.dart`: UI for setting up/editing the Wird.

## Analysis & Gaps vs. Implementation Plan

1.  **Multiple Wirds**: The current logic is designed for a single active Wird (the DAO only fetches the latest one).
2.  **Goal Types**: Currently only supports fixed portions (portions of Juz/Hizb). Needs support for daily pages, custom ranges, and flexible goals.
3.  **Progress Tracking**: Only tracks `completedDaysCount` and `lastReadDate`. It lacks a history of *what* was read on *which* day. No support for partial completion.
4.  **Streaks**: No dedicated streak logic; only a simple counter.
5.  **Achievements**: None implemented.
6.  **Khatma History**: No tracking of multiple traversals (cycles).
7.  **Architecture**: Current files are scattered in `lib/features/quran/`. The plan suggests moving to a dedicated `lib/features/quran/wird/` directory with a more structured approach.

## Recommended First Actions
1.  Define new Domain Models in `lib/features/quran/wird/domain/models/`.
2.  Plan the database migration to support multiple Wirds and historical progress.
3.  Refactor existing logic into the new structure while maintaining backward compatibility.
