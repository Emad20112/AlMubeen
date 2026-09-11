# Al-Mubeen — Quran Wird System Implementation Plan

**Document type:** Engineering implementation plan  
**Target:** Flutter + Dart + Riverpod 3 + Drift/SQLite + Clean Architecture  
**Project:** Al-Mubeen / Al-Kawthar  
**Status:** Ready for AI-assisted implementation  
**Primary goal:** Build a production-grade Quran Wird system inspired by the strongest patterns used by modern Quran applications, while preserving Al-Mubeen's current architecture and offline-first philosophy.

---

## 1. Executive Summary

The current application already contains a Quran Wird feature and the required foundations for expanding it:

- `features/quran/` already contains the Wird feature.
- `WirdsTable` already exists in the Drift database.
- `WirdController` already exists.
- `QuranReadingProgressCache` already tracks reading position.
- Quran content is available locally.
- The project uses Riverpod 3.
- The project uses Feature-first Clean Architecture.
- Drift/SQLite is used for local persistence.
- The application is designed to work offline to a significant degree.

The new system must turn the existing Wird feature into a complete **personal Quran reading plan engine**.

The user must be able to create a daily Wird such as:

- 1 page/day
- 2 pages/day
- 3 pages/day
- 5 pages/day
- 10 pages/day
- Any custom number of pages/day

The system must also support:

- Custom start page
- Custom end page
- Full Quran
- Specific surah/range
- Daily schedules
- Selected weekdays
- Pause/resume
- Flexible plans
- Fixed daily portions
- Progress tracking
- Streaks
- Completion tracking
- Multiple active or archived plans
- Catch-up behavior
- Daily dashboard
- Monthly/weekly statistics
- Achievements/badges
- Khatma progress
- Local-first operation
- Migration from the current `WirdsTable`
- Future integration with memorization/review features

The design should be inspired by established Quran apps, especially the concept of Goals, daily portions, progress sessions, completions, flexible versus portion-based goals, and achievement tracking. Tarteel documents these concepts explicitly in its Goals and Memorization & Progress documentation. [Tarteel Goals](https://support.tarteel.ai/en/articles/12782033-how-do-i-use-the-goals-feature)

---

# 2. Product Vision

The Wird feature should answer one simple user question:

> "What should I read today, and how am I progressing toward my Quran goal?"

The experience must be understandable in seconds.

The user's main screen should show:

```text
Today's Wird

Page 121 → 123

3 pages
██████████░░ 80%

✓ 2 / 3 pages completed

Continue Wird
```

The user should never need to manually calculate where today's reading starts.

The application must calculate:

- today's target
- starting page
- ending page
- progress
- completion state
- remaining amount
- current streak
- estimated completion date

---

# 3. Product Principles

## 3.1 Simple by default

A beginner should be able to create a Wird with three actions:

1. Choose "Daily Pages"
2. Enter number of pages
3. Press "Create"

Example:

```text
Daily amount
[ 3 ] pages/day

[ Create Wird ]
```

## 3.2 Advanced when needed

Advanced users may configure:

- start/end range
- weekdays
- fixed vs flexible
- target date
- automatic continuation
- catch-up policy
- reminder
- completion behavior

Do not expose advanced settings on the first screen.

## 3.3 Local-first

The Wird system must work without internet.

Wird creation, progress, streaks, statistics, completion calculations, and history must all work offline.

No remote dependency should be required for normal Wird operation.

## 3.4 Deterministic calculations

The same database state must always produce the same plan.

Do not make the daily target dependent on unpredictable network calls.

---

# 4. Supported Goal Types

The system should support at least these goal types.

## 4.1 Daily Pages

Example:

```text
3 pages every day
```

This is the primary MVP goal.

## 4.2 Daily Juz

Example:

```text
1 Juz/day
```

A Juz maps to its configured Quran page range.

## 4.3 Custom Range

Example:

```text
Pages 100 → 200
2 pages/day
```

## 4.4 Surah Range

Example:

```text
Al-Baqarah → Al-Imran
3 pages/day
```

Internally this should still resolve to Quran page ranges.

## 4.5 Target Date

Example:

```text
Finish pages 1 → 604 by
2026-12-31
```

The engine calculates the required daily amount.

## 4.6 Flexible Goal

The user chooses a Quran range and a deadline, while the engine adjusts the remaining workload according to completed progress.

This is conceptually similar to Tarteel's flexible goals, where remaining sessions can be adjusted based on whether the user is ahead or behind. [Tarteel Goals](https://support.tarteel.ai/en/articles/12782033-how-do-i-use-the-goals-feature)

## 4.7 Portion-Based Goal

The user explicitly chooses a fixed portion such as:

```text
3 pages/day
```

The application does not automatically increase the daily amount because of missed previous sessions unless the user chooses catch-up.

This corresponds to the fixed "portion-based" model documented by Tarteel. [Tarteel Goals](https://support.tarteel.ai/en/articles/12782033-how-do-i-use-the-goals-feature)

---

# 5. Core User Stories

## User Story 1 — Create a 3-page daily Wird

As a user, I want to choose 3 pages per day so that I can consistently read a manageable amount.

Expected behavior:

```text
Day 1: pages 1–3
Day 2: pages 4–6
Day 3: pages 7–9
...
```

## User Story 2 — Create a 2-page Wird starting from current page

The user can choose:

```text
Start from current page
Daily amount = 2 pages
```

If the current page is 121:

```text
Day 1: 121–122
Day 2: 123–124
...
```

## User Story 3 — Read fewer pages than planned

If the target is 3 pages and the user reads 2:

```text
Target: 3
Completed: 2
Remaining: 1
```

The system must preserve the actual progress.

## User Story 4 — Complete today's Wird

When the target is completed:

```text
Today's Wird ✓
3 / 3 pages
```

The day counts toward the streak according to the configured streak rules.

## User Story 5 — Miss a day

If the user does not complete the day's target, the system must not corrupt progress.

The next day should show a clear state:

```text
Yesterday: missed
Today: pages 10–12
```

The user may optionally use catch-up.

## User Story 6 — Pause the Wird

While paused:

- no missed-day penalties
- no new daily target generation
- streak behavior follows pause policy
- existing history remains unchanged

## User Story 7 — Finish the Quran

When the plan reaches page 604:

```text
Khatma completed 🎉
```

The user can either:

- manually start another Khatma
- automatically start another Khatma
- stop the plan

---

# 6. Page Model

The system must use a stable Quran page coordinate system.

The standard Mushaf contains 604 pages in the current application dataset.

Therefore:

```text
first page = 1
last page = 604
```

All calculations should use inclusive ranges.

Example:

```text
startPage = 10
endPage = 12
```

means:

```text
3 pages
```

Formula:

```text
pageCount = endPage - startPage + 1
```

Never use:

```text
endPage - startPage
```

because that introduces an off-by-one error.

---

# 7. Domain Model

Create a clear domain model.

Recommended model:

```dart
enum WirdGoalType {
  dailyPages,
  dailyJuz,
  customRange,
  targetDate,
  flexible,
}

enum WirdScheduleType {
  daily,
  selectedWeekdays,
}

enum WirdStatus {
  active,
  paused,
  completed,
  archived,
}

enum WirdProgressStatus {
  pending,
  partial,
  completed,
  missed,
  skipped,
}
```

Main entity:

```dart
class QuranWird {
  final String id;
  final String name;

  final WirdGoalType goalType;
  final WirdStatus status;

  final int startPage;
  final int endPage;

  final int? pagesPerDay;

  final DateTime startDate;
  final DateTime? targetDate;

  final WirdScheduleType scheduleType;
  final List<int> activeWeekdays;

  final bool isFlexible;

  final bool allowCatchUp;

  final bool autoStartNextKhatma;

  final DateTime createdAt;
  final DateTime updatedAt;
}
```

Do not store derived values if they can be calculated safely.

For example, do not persist:

```text remainingPages
completionPercentage
currentDayTarget
```

unless there is a measured performance reason.

Derived values should preferably be calculated from persisted state.

---

# 8. Database Design

The current database uses Drift/SQLite and already contains `WirdsTable`. The new implementation should extend the existing schema through a proper migration.

## 8.1 Existing Table

First inspect the existing:

```text
WirdsTable
```

before changing it.

Do not delete or recreate user data.

Create a migration strategy from the current schema version.

The current project database is version 12. [Project analysis](see `analysis_full.md`)

---

## 8.2 Recommended WirdsTable Fields

The table should eventually support:

```text
id
name
goal_type
status
start_page
end_page
pages_per_day
start_date
target_date
schedule_type
active_weekdays
is_flexible
allow_catch_up
auto_start_next_khatma
current_cycle
created_at
updated_at
completed_at
```

Use stable primitive SQLite-compatible types.

For a weekday list, store a normalized JSON string or a normalized child table.

Preferred approach for long-term flexibility:

### Main table

```text
WirdsTable
```

### Child table

```text
WirdSchedulesTable
```

### Progress table

```text
WirdDailyProgressTable
```

### Achievement table

```text
WirdAchievementsTable
```

This keeps the architecture extensible.

---

# 9. Daily Progress Table

Create a separate table for per-day progress.

Recommended fields:

```text
id
wird_id
date_key
planned_start_page
planned_end_page
actual_start_page
actual_end_page
target_pages
completed_pages
status
completed_at
created_at
updated_at
```

`date_key` should represent the user's local calendar date.

Recommended format:

```text
YYYY-MM-DD
```

Example:

```text
2026-09-01
```

Use the date key to prevent duplicate daily records.

Add a unique constraint:

```text
UNIQUE(wird_id, date_key)
```

---

# 10. Why Daily Progress Must Be Stored

Do not calculate the entire history from the current page alone.

The application needs historical records for:

- streaks
- weekly statistics
- missed days
- partial days
- achievements
- charts
- future smart scheduling
- user history

Example:

```text
Sept 1: 3/3
Sept 2: 3/3
Sept 3: 1/3
Sept 4: 3/3
```

Without daily records, the application cannot reliably answer:

> "How many complete days did I have this month?"

---

# 11. Plan Generation Algorithm

For fixed daily-page goals:

Inputs:

```text
startPage
endPage
pagesPerDay
schedule
```

Example:

```text
start = 1
end = 604
pagesPerDay = 3
```

Generated sequence:

```text
Day 1: 1–3
Day 2: 4–6
Day 3: 7–9
...
```

The final day can contain fewer pages:

```text
Day N: 604 only
```

Never create page 605.

Formula:

```dart
remaining = endPage - currentPage + 1;
todayCount = min(pagesPerDay, remaining);
todayStart = currentPage;
todayEnd = currentPage + todayCount - 1;
```

---

# 12. Range Validation

The domain layer must validate:

```text
1 <= startPage <= 604
1 <= endPage <= 604
startPage <= endPage
pagesPerDay > 0
```

Also:

```text
targetDate >= startDate
```

when targetDate exists.

Invalid input must return a typed domain failure.

Do not throw generic exceptions from the UI.

Use the existing project's `DataResult/DataFailure` pattern where appropriate.

---

# 13. Progress Semantics

The most important rule:

> Reading progress and Wird completion are related but not identical.

For example, if a user opens the Quran and reads pages 1–10 outside the Wird session, the application needs a clear policy.

Recommended MVP:

### Automatic page progress

A Wird may count reading progress based on page completion when:

- the user opens a page belonging to today's range
- the user actually navigates through the planned pages

But do not automatically mark an entire page complete merely because the page was opened.

Recommended rule:

A page becomes completed when the user reaches the next page or explicitly marks it complete.

This prevents accidental progress.

---

# 14. Manual Completion

The user should be able to manually finish a day's Wird.

Example:

```text
Today's Wird
3 pages

[ Mark as Complete ]
```

If the user chooses this:

```text
completed_pages = target_pages
status = completed
```

This should be allowed because real-world Quran reading may occur outside the app.

---

# 15. Today's Wird

Create a service:

```text
WirdTodayService
```

Responsibilities:

- find active Wirds
- determine today's scheduled state
- create today's daily progress record if missing
- calculate today's target
- calculate completion state
- calculate remaining pages
- expose today's Wirds

Expected output:

```dart
class TodaysWird {
  final QuranWird wird;
  final WirdDailyProgress progress;
  final int targetPages;
  final int completedPages;
  final int remainingPages;
  final double progressRatio;
}
```

---

# 16. Multiple Wirds

Allow multiple plans.

Examples:

```text
Daily Reading
3 pages/day

Surah Al-Kahf
Every Friday

Ramadan Khatma
10 pages/day
```

The dashboard should show all active plans without overwhelming the user.

Recommended sorting:

1. overdue/current critical item
2. today's primary Wird
3. remaining active goals

---

# 17. Primary Wird

The user should be able to select one Wird as:

```text
Primary Wird
```

The primary Wird gets priority on the home screen.

Do not enforce only one active Wird globally.

---

# 18. Flexible Goal Algorithm

For a flexible goal:

Inputs:

```text
startPage
endPage
startDate
targetDate
completedPages
remainingScheduledDays
```

Calculate:

```text
remainingPages = endPage - currentProgressPage + 1
requiredPerRemainingDay =
    ceil(remainingPages / remainingScheduledDays)
```

Example:

```text
Remaining = 100 pages
Remaining scheduled days = 20

Required = 5 pages/day
```

If the user is ahead:

```text
Remaining = 80
Days = 20

Required = 4 pages/day
```

This mirrors the core concept of dynamically adjusting flexible goals based on progress. [Tarteel Goals](https://support.tarteel.ai/en/articles/12782033-how-do-i-use-the-goals-feature)

---

# 19. Catch-up Policy

Catch-up must be explicit.

Recommended configuration:

```text
Catch-up:
○ Never increase today's amount
● Add missed pages to the next available day
○ Recalculate remaining plan
```

MVP default:

> Do not automatically punish the user by doubling the next day's workload.

Instead show:

```text
You missed 2 pages yesterday.

Would you like to:
[ Continue normally ]
[ Catch up 2 pages ]
```

This creates a healthier user experience.

---

# 20. Streak System

Streak should be based on meaningful completion, not app opening.

Recommended default:

A day counts toward streak when:

```text
completed_pages >= target_pages
```

For flexible goals:

```text
completed_pages >= calculated_daily_target
```

Potential states:

```text
Current streak: 12 days
Best streak: 27 days
```

Do not reset streak during an intentional pause.

---

# 21. Streak Rules

Define rules before coding.

### Normal day

Completed target:

```text
streak += 1
```

### Missed day

If not paused:

```text
streak = 0
```

### Partial day

Do not count as completed unless configured threshold is reached.

### Paused day

Do not break streak.

### Catch-up

Recommended:

Catching up yesterday's pages today should complete the catch-up requirement, but the user must not earn two separate streak days from a single day's reading.

This avoids gaming the streak.

---

# 22. Khatma / Completion System

A Khatma is one full traversal of the selected Quran range.

For a full Quran Wird:

```text
1 → 604
```

When progress reaches:

```text
604
```

the current cycle becomes:

```text
completed
```

Then, if:

```text
autoStartNextKhatma = true
```

create:

```text
cycle = 2
```

starting at page 1.

The system should preserve previous cycle history.

---

# 23. Khatma History

Do not overwrite the completed cycle.

Create a history record:

```text
WirdCycleHistoryTable
```

Fields:

```text
id
wird_id
cycle_number
start_date
completed_date
start_page
end_page
actual_completed_pages
created_at
```

This enables:

```text
Khatma #1 — 32 days
Khatma #2 — 29 days
Khatma #3 — in progress
```

---

# 24. Achievement System

Create a lightweight achievement system inspired by modern Quran progress applications.

Achievements should encourage consistency without turning Quran worship into an excessive game.

Recommended achievements:

## First Steps

- First Wird created
- First daily target completed
- First 7-day streak
- First 30-day streak

## Reading

- 10 pages completed
- 100 pages completed
- 500 pages completed
- 1,000 pages completed

## Khatma

- First Khatma completed
- 2 Khatmas
- 5 Khatmas
- 10 Khatmas

## Consistency

- 7 consecutive completed days
- 30 consecutive completed days
- 100 active reading days
- 365 active reading days

## Discipline

- 7 days with no missed target
- 30 days with no missed target

Do not reward raw app opens.

Reward actual meaningful reading behavior.

---

# 25. Achievement Data Model

Recommended:

```dart
class WirdAchievement {
  final String id;
  final String type;
  final int threshold;
  final bool unlocked;
  final DateTime? unlockedAt;
}
```

The achievement catalog should be data-driven.

Example:

```json
{
  "id": "pages_100",
  "type": "total_pages",
  "threshold": 100
}
```

This avoids hardcoding every achievement in UI code.

---

# 26. Achievement Evaluation

Create:

```text
AchievementEngine
```

It should evaluate after meaningful events:

```text
onDailyProgressChanged()
onWirdCompleted()
onKhatmaCompleted()
onStreakChanged()
```

Avoid checking every achievement on every widget rebuild.

Achievement calculations belong in application/domain services.

---

# 27. Weekly Statistics

Provide:

```text
This Week

Pages read: 21
Completed days: 7/7
Current streak: 12
Average: 3 pages/day
```

Optional chart:

```text
Sat  ███
Sun  ███
Mon  ███
Tue  ██
Wed  ███
Thu  ███
Fri  ███
```

Keep the first version simple and performant.

---

# 28. Monthly Statistics

Show:

```text
September

Pages: 83
Completed days: 25
Missed days: 2
Average/day: 3.3
Best streak: 14
```

Use SQLite aggregation rather than loading all history into Dart if the dataset becomes large.

---

# 29. Completion Percentage

For a selected range:

```text
totalPages = endPage - startPage + 1
completedPages = pagesReadWithinRange
percentage = completedPages / totalPages
```

Clamp:

```text
0.0 <= percentage <= 1.0
```

Display:

```text
37%
```

---

# 30. Estimated Completion Date

For fixed daily goals:

```text
remainingPages
pagesPerScheduledDay
```

Estimate based on the active schedule.

For daily 3 pages:

```text
remaining = 90
=> approximately 30 reading days
```

For selected weekdays:

calculate actual future schedule dates.

Never assume every plan is daily.

---

# 31. Schedule System

Support:

```text
Every day

or

Specific days:
☑ Saturday
☑ Sunday
☑ Monday
☐ Tuesday
☑ Wednesday
☐ Thursday
☐ Friday
```

Store weekdays using a stable convention.

Recommended:

```text
1 = Monday
2 = Tuesday
...
7 = Sunday
```

Document this convention in code.

Do not rely on platform-specific weekday numbering without explicit conversion.

---

# 32. Ramadan / Seasonal Use

Do not hardcode Ramadan logic into the base Wird engine.

Instead make schedule rules extensible.

Future versions may support:

- Ramadan daily plan
- Hajj-related plans
- Friday Surah plan
- custom seasonal plans

The core model should remain generic.

---

# 33. Preset Wirds

The app should offer quick presets.

Examples:

```text
1 page/day
2 pages/day
3 pages/day
5 pages/day
10 pages/day
Half Juz/day
1 Juz/day
```

The user can still enter any custom number.

Presets are convenience only.

They must not limit the domain model.

---

# 34. Create-Wird UX

Recommended flow:

## Step 1

```text
Create Wird
```

## Step 2

```text
What do you want to read?

● Entire Quran
○ Custom range
○ Surah
```

## Step 3

```text
How much per day?

[ 3 ] pages
```

Quick buttons:

```text
1   2   3   5   10
```

## Step 4

```text
When?

● Every day
○ Specific days
```

## Step 5

```text
Start from

● Page 1
○ Current page
○ Choose page
```

## Step 6

```text
Review

3 pages/day
604 pages
~202 reading days

Create Wird
```

The estimated duration should be visible before confirmation.

---

# 35. Advanced Configuration

Put advanced settings behind:

```text
Advanced Settings
```

Options:

```text
End page
Target date
Flexible plan
Catch-up
Reminder
Automatic next Khatma
```

Do not overwhelm a new user.

---

# 36. Today's Wird UI

The home card should show:

```text
Today's Wird

Daily Quran
Pages 121–123

2 / 3 pages
████████░░

1 page remaining

[ Continue ]
```

After completion:

```text
Today's Wird ✓

3 / 3 pages

Excellent!
```

Avoid excessive animation.

The Quran application should remain calm and focused.

---

# 37. Wird Detail Screen

Show:

```text
Daily Quran

3 pages/day

Progress
████████░░ 38%

Page 121 → 604

Current streak
12 days

Best streak
28 days

Total pages
483

Estimated completion
Jan 14, 2027
```

Actions:

```text
Continue
Edit Wird
Pause
Archive
View History
```

---

# 38. History Screen

Display daily history:

```text
September 1
✓ 3/3

September 2
✓ 3/3

September 3
◐ 2/3

September 4
✕ 0/3
```

Use text/icons rather than relying on color alone.

Accessibility requirement:

- color must never be the only indicator
- provide icon/state text

---

# 39. Progress Synchronization With Quran Reader

The Quran reader already has:

```text
QuranReadingProgressCache
```

The new Wird system must not duplicate the reader's global reading position.

Separate:

### Global reading position

"Where did the user last read?"

from:

### Wird progress

"How much of today's assigned portion has been completed?"

Both can reference the same Quran page coordinates.

---

# 40. Integration Strategy

Create a domain/application service:

```text
WirdProgressTracker
```

When a user navigates through Quran pages:

```text
Quran Reader
      ↓
Reading Progress Event
      ↓
WirdProgressTracker
      ↓
WirdDailyProgress
```

Do not make the Quran UI directly write to `WirdDailyProgressTable`.

Use an application service.

This preserves Clean Architecture.

---

# 41. Riverpod Architecture

Recommended providers:

```dart
wirdRepositoryProvider

activeWirdsProvider

primaryWirdProvider

todaysWirdsProvider

wirdDetailProvider

wirdHistoryProvider

wirdStatisticsProvider

wirdStreakProvider

achievementProvider
```

Use `Notifier` / `AsyncNotifier` where state mutation or asynchronous work is required.

Avoid a single huge `WirdController`.

Split responsibilities.

---

# 42. Repository Layer

Recommended interface:

```dart
abstract class WirdRepository {
  Future<DataResult<List<QuranWird>>> getActiveWirds();

  Future<DataResult<QuranWird?>> getWirdById(String id);

  Future<DataResult<void>> createWird(QuranWird wird);

  Future<DataResult<void>> updateWird(QuranWird wird);

  Future<DataResult<void>> pauseWird(String id);

  Future<DataResult<void>> resumeWird(String id);

  Future<DataResult<void>> archiveWird(String id);

  Future<DataResult<WirdDailyProgress>> getTodayProgress(
    String wirdId,
    DateTime date,
  );

  Future<DataResult<void>> saveDailyProgress(
    WirdDailyProgress progress,
  );
}
```

Use the project's existing `DataResult`/`DataFailure` conventions.

---

# 43. Data Source Layer

Use:

```text
local/
  wird_local_data_source.dart
  wird_daily_progress_local_data_source.dart
  achievement_local_data_source.dart
```

No network data source is necessary for the core MVP.

Do not send personal reading history to the server in the first implementation.

---

# 44. Service Layer

Recommended application services:

```text
WirdPlanner
WirdTodayService
WirdProgressTracker
WirdStatisticsService
WirdStreakService
WirdAchievementService
KhatmaService
```

Responsibilities must be narrow.

---

# 45. Migration Strategy

Before modifying Drift:

1. Inspect the current `WirdsTable`.
2. Identify all existing columns.
3. Identify how `WirdController` currently reads/writes data.
4. Search for every reference to `WirdsTable`.
5. Search for every reference to `WirdController`.
6. Search for UI screens consuming Wird state.
7. Preserve existing user data.

Then:

```text
schemaVersion = 13
```

or the next available version.

Add migration safely.

Example:

```dart
if (from < 13) {
  await m.addColumn(wirdsTable, wirdsTable.status);
  ...
}
```

The exact Drift migration syntax must match the project's actual generated schema.

Never guess generated table definitions.

---

# 46. Backward Compatibility

Existing Wird records must remain usable.

For legacy records:

- assign safe defaults
- infer missing values where possible
- never silently delete records

Example:

```text
legacy daily amount
→ map to pagesPerDay
```

If the old model is fundamentally different, add a migration adapter rather than destructive conversion.

---

# 47. Notifications

Notifications should be designed as a separate layer.

MVP:

```text
Your Quran Wird is ready
3 pages today
```

Do not make notifications a dependency of the core planner.

A user may deny notification permission and the Wird system must still work perfectly.

---

# 48. Offline Requirements

The following must work without internet:

- Create Wird
- Edit Wird
- Pause/resume
- Daily progress
- Streak
- Statistics
- Achievements
- Khatma tracking
- History
- Daily target calculation

Online connectivity must not block any of these.

This is consistent with the project's existing local-first architecture.

---

# 49. Performance Requirements

The Wird dashboard must remain lightweight.

Do not:

- scan the entire Quran on every widget build
- query thousands of history rows repeatedly
- recalculate every achievement on every rebuild
- rebuild the entire Quran reader when Wird progress changes

Use:

- targeted Drift queries
- Riverpod selectors
- cached aggregates when justified
- event-driven updates

---

# 50. Query Requirements

Create efficient database queries for:

```text
today's progress
active Wirds
current streak
monthly statistics
weekly statistics
total pages
completed Khatmas
achievement thresholds
```

Add indexes for:

```text
wird_id
date_key
status
```

Especially:

```text
UNIQUE(wird_id, date_key)
```

---

# 51. Testing Strategy

Testing is mandatory.

## Unit tests

Test:

```text
page range calculations
daily portion calculation
final partial day
date calculations
selected weekdays
flexible goals
catch-up
streak rules
Khatma completion
achievement unlocking
```

Examples:

### 604 / 3

```text
604 pages
3 pages/day
```

Expected:

```text
201 full days + 1 page
```

### 10 / 3

```text
Day 1 = 1–3
Day 2 = 4–6
Day 3 = 7–9
Day 4 = 10
```

### Start at 604

```text
Day 1 = 604
```

No page 605.

---

# 52. Edge Case Matrix

The implementation must test:

- start page = 1
- end page = 604
- one-page range
- daily target larger than entire range
- zero pages
- negative pages
- start > end
- target date = today
- target date in past
- paused plan
- archived plan
- duplicate daily record
- timezone/date boundary
- device restart
- app killed during progress
- multiple Wirds on same day
- selected weekdays
- leap year
- monthly boundary
- year boundary
- Khatma completion
- automatic next Khatma

---

# 53. Timezone Rules

Daily progress is based on the user's local calendar date.

Do not use UTC date strings directly for the UI.

Use:

```text
local DateTime
→ normalized local date key
→ YYYY-MM-DD
```

Be careful around midnight.

A reading at:

```text
23:59
```

and a reading at:

```text
00:01
```

must belong to different local dates.

---

# 54. Date Utility

Create one shared utility:

```text
WirdDateUtils
```

Responsibilities:

```text
toDateKey()
isSameDate()
startOfLocalDay()
addLocalDays()
calculateScheduledDays()
```

Do not scatter date arithmetic across UI controllers.

---

# 55. Achievement Presentation

Example:

```text
🏅 First Wird
Completed your first daily Quran goal.

🏅 Consistent Reader
7 completed days in a row.

🏅 Hundred Pages
You completed 100 pages.
```

Use respectful wording.

Avoid:

```text
"score"
"XP"
"battle"
"rank above others"
```

The product tone should remain spiritual and calm.

---

# 56. Optional Future Achievements

Keep the architecture ready for future:

- first Juz
- first Surah completed
- 1,000 pages
- 5,000 pages
- 100 active days
- 365 active days
- 10 Khatmas
- consistent Friday reading
- consistent Ramadan reading

These should be added by catalog data, not by rewriting engine logic.

---

# 57. Future Memorization Integration

The Wird architecture must not block future memorization.

Later we should be able to have:

```text
Reading Goal
Memorization Goal
Review Goal
Recitation Goal
```

The current daily-progress model can eventually become a generic:

```text
QuranGoal
GoalSession
GoalProgress
```

However:

> Do NOT refactor the whole feature into a generic goal framework during the first Wird implementation.

First make the Wird system stable.

Generalization can come later.

---

# 58. Future Tarteel-Like Integration

The current plan deliberately does not require speech recognition.

Later:

```text
Microphone
   ↓
Recitation recognition
   ↓
Ayah/page detection
   ↓
Mistake detection
   ↓
Wird progress
   ↓
Memorization statistics
```

This can integrate into the same progress engine.

Tarteel currently distinguishes Recite, Memorize, and Review goal actions and can use hidden-ayah recitation to measure memorization/review progress. [Tarteel Goals](https://support.tarteel.ai/en/articles/12782033-how-do-i-use-the-goals-feature)

---

# 59. Recommended MVP Scope

The first implementation should contain only:

### Core

- Create Wird
- Edit Wird
- Delete/archive
- Pause/resume
- Daily pages
- Custom start/end range
- Daily/selected weekdays
- Today's target
- Progress
- History
- Streak
- Khatma completion
- Basic statistics

### Achievements

- First Wird
- 7-day streak
- 30-day streak
- 100 pages
- First Khatma

Do not implement:

- AI
- social groups
- leaderboards
- cloud sync
- complex recommendation engine

in the first milestone.

---

# 60. Implementation Milestones

## Milestone 0 — Codebase Audit

AI must first inspect:

```text
features/quran/wird/
WirdsTable
WirdController
QuranReadingProgressCache
Quran reader navigation
database schema/version
routing
existing tests
```

Deliverable:

```text
docs/wird_current_state.md
```

Do not modify code yet.

---

## Milestone 1 — Domain Models

Implement:

```text
QuranWird
WirdDailyProgress
WirdSchedule
WirdCycle
WirdAchievement
```

Add enums and validation.

Add unit tests.

---

## Milestone 2 — Drift Schema

Implement:

```text
WirdsTable
WirdDailyProgressTable
WirdCycleHistoryTable
WirdAchievementsTable
```

or minimally extend the existing schema if the current implementation can support the same behavior without unnecessary tables.

Add migration.

Run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Verify generated Drift code.

---

## Milestone 3 — Planner Engine

Implement:

```text
WirdPlanner
```

It must correctly calculate:

- page ranges
- daily portions
- final day
- schedules
- flexible targets

No UI yet.

Write comprehensive unit tests first.

---

## Milestone 4 — Repository

Implement:

```text
WirdRepository
WirdLocalDataSource
WirdRepositoryImpl
```

Connect to Drift.

Verify CRUD and daily progress.

---

## Milestone 5 — Today Engine

Implement:

```text
WirdTodayService
```

Expose through Riverpod.

Expected provider:

```text
todaysWirdsProvider
```

Test app restart and offline behavior.

---

## Milestone 6 — Reader Integration

Connect Quran reader page navigation to:

```text
WirdProgressTracker
```

Important:

The reader remains responsible for reading.

The Wird tracker observes progress.

Avoid coupling page widgets directly to database writes.

---

## Milestone 7 — User Interface

Implement:

```text
Wird Dashboard
Create Wird
Edit Wird
Wird Details
Wird History
Statistics
```

Follow the existing Material 3 and RTL design system.

Do not introduce another UI framework.

---

## Milestone 8 — Streaks

Implement:

```text
WirdStreakService
```

Add:

```text
currentStreak
bestStreak
```

Test all date boundary cases.

---

## Milestone 9 — Achievements

Implement:

```text
AchievementEngine
AchievementRepository
Achievement UI
```

Start with MVP achievements only.

---

## Milestone 10 — Khatma History

Implement:

```text
WirdCycleHistoryTable
KhatmaService
```

Support:

```text
Khatma #1
Khatma #2
Khatma #3
```

---

## Milestone 11 — Statistics

Implement:

```text
weekly pages
monthly pages
completed days
missed days
average pages/day
current streak
best streak
```

Optimize queries before adding charts.

---

## Milestone 12 — Notifications

Only after the core system is stable.

Implement reminders separately.

---

# 61. AI Agent Execution Rules

An AI coding agent must follow these rules:

## Rule 1

Read the entire current Wird implementation before changing it.

## Rule 2

Never overwrite existing user data.

## Rule 3

Never invent table columns without checking the actual Drift schema.

## Rule 4

Never invent Riverpod providers that duplicate existing providers.

## Rule 5

Search the repository before creating a new helper.

## Rule 6

Reuse:

```text
DataResult
DataFailure
Riverpod
Drift
go_router
```

where appropriate.

## Rule 7

Do not add dependencies unless necessary.

## Rule 8

Do not introduce a new architecture.

## Rule 9

Keep the feature local-first.

## Rule 10

Every milestone must end with tests.

---

# 62. AI Agent Prompt Template

For each implementation task, the agent should work in this order:

```text
1. Inspect existing implementation.
2. Identify relevant files.
3. Explain the intended changes.
4. Implement the smallest coherent change.
5. Run formatter.
6. Run analyzer.
7. Run relevant tests.
8. Fix failures.
9. Verify migration if database schema changed.
10. Report changed files and test results.
```

Do not allow the agent to implement the entire feature in one giant uncontrolled patch.

---

# 63. Definition of Done

The Wird feature is complete only when:

### Functional

- [ ] User can create a daily page Wird.
- [ ] User can choose any positive page count.
- [ ] User can choose a Quran range.
- [ ] User can start at the current page.
- [ ] User can select schedule days.
- [ ] Today's target is calculated correctly.
- [ ] Partial progress is stored.
- [ ] Completed days are stored.
- [ ] Missed days are handled correctly.
- [ ] Streak is calculated correctly.
- [ ] Khatma completion works.
- [ ] History works.
- [ ] Statistics work.
- [ ] Achievements work.
- [ ] Pause/resume works.
- [ ] Archive works.
- [ ] App restart preserves state.
- [ ] Offline operation works.

### Engineering

- [ ] Drift migration is tested.
- [ ] Unit tests cover planner logic.
- [ ] Unit tests cover streak logic.
- [ ] Unit tests cover date boundaries.
- [ ] Analyzer passes.
- [ ] Formatter passes.
- [ ] No unnecessary dependency was introduced.
- [ ] No duplicated source of truth was created.

### UX

- [ ] Create flow is simple.
- [ ] Today's target is obvious.
- [ ] Remaining pages are obvious.
- [ ] Progress is understandable without color alone.
- [ ] RTL works correctly.
- [ ] Dark mode works.
- [ ] Large text settings work.
- [ ] UI remains responsive.

---

# 64. Recommended Initial Data Examples

After implementation, seed no fake production user data.

Use test fixtures only:

```text
Wird A
Full Quran
3 pages/day
Start: 1

Wird B
Pages 100–200
2 pages/day

Wird C
Pages 550–604
5 pages/day
```

Test expected outputs with deterministic dates.

---

# 65. Suggested File Structure

Prefer:

```text
lib/features/quran/wird/
├── data/
│   ├── local/
│   │   ├── wird_local_data_source.dart
│   │   ├── wird_daily_progress_local_data_source.dart
│   │   └── achievement_local_data_source.dart
│   ├── models/
│   └── repositories/
│       └── wird_repository_impl.dart
│
├── domain/
│   ├── models/
│   │   ├── quran_wird.dart
│   │   ├── wird_daily_progress.dart
│   │   ├── wird_schedule.dart
│   │   ├── wird_cycle.dart
│   │   └── wird_achievement.dart
│   ├── repositories/
│   │   └── wird_repository.dart
│   └── services/
│       ├── wird_planner.dart
│       ├── wird_streak_service.dart
│       ├── wird_statistics_service.dart
│       ├── achievement_engine.dart
│       └── khatma_service.dart
│
├── application/
│   ├── controllers/
│   │   ├── wird_controller.dart
│   │   └── wird_today_controller.dart
│   └── providers/
│
└── presentation/
    ├── pages/
    │   ├── wird_page.dart
    │   ├── create_wird_page.dart
    │   ├── edit_wird_page.dart
    │   ├── wird_details_page.dart
    │   ├── wird_history_page.dart
    │   └── wird_statistics_page.dart
    └── widgets/
        ├── today_wird_card.dart
        ├── wird_progress_indicator.dart
        ├── streak_card.dart
        ├── achievement_card.dart
        └── daily_portion_selector.dart
```

Adjust names to the project's existing conventions instead of blindly creating duplicates.

---

# 66. Important Design Decision: Pages First

For the first public version, the primary unit should be:

> **Pages per day**

This is the simplest mental model.

The UI may later support:

- Juz
- Hizb
- Rub'
- Surah
- Ayah
- Minutes

But these should map internally to Quran ranges or measurable units.

Do not make the first release unnecessarily complicated.

---

# 67. Recommended User Experience

The ideal user journey is:

```text
Open app
   ↓
See Today's Wird
   ↓
"3 pages"
   ↓
Tap Continue
   ↓
Quran opens at correct page
   ↓
User reads
   ↓
Progress updates
   ↓
3/3 completed
   ↓
Streak +1
   ↓
Achievement checked
   ↓
Dashboard updates
```

Everything else should be secondary.

---

# 68. Product Positioning

The final Wird system should make Al-Mubeen feel like:

> "A Quran companion that gives me a clear daily amount and remembers my journey."

Not:

> "A complicated Quran task manager."

The user should feel guided, not burdened.

---

# 69. Future Roadmap After MVP

Once the basic Wird system is stable:

### Phase 2

- Multiple goal types
- Smart catch-up
- Target-date planning
- Khatma templates
- Ramadan presets
- Friday presets
- Better statistics

### Phase 3

- Memorization plans
- Review plans
- Hidden-ayah sessions
- Recitation sessions
- Mistake history

### Phase 4

- Voice recognition
- Automatic recitation tracking
- AI-assisted memorization
- Smart review recommendations

The current architecture should leave room for these features without implementing them prematurely.

---

# 70. References

Primary product inspiration:

- Tarteel Goals and planning:
  https://support.tarteel.ai/en/articles/12782033-how-do-i-use-the-goals-feature
- Tarteel Today's Goals:
  https://support.tarteel.ai/en/articles/12414404-what-are-today-s-goals
- Tarteel Memorization & Progress:
  https://support.tarteel.ai/en/collections/14742698-memorization-progress

The Tarteel Goals documentation confirms support for:

- custom goals
- memorization/review/recitation goal types
- ranges
- portions such as pages or Juz
- daily/weekly schedules
- flexible goals
- portion-based goals
- multiple ranges
- reverse-order ranges
- completion/Khatma handling
- progress tracking

The Al-Mubeen project analysis confirms that the current project already contains:

- `WirdsTable`
- `WirdController`
- `QuranReadingProgressCache`
- Drift/SQLite
- Riverpod 3
- Feature-first Clean Architecture
- local Quran content
- offline-capable infrastructure

Therefore this plan is intentionally designed as an extension of the existing implementation, not a rewrite.

---

# 71. Final Implementation Principle

The most important engineering principle for this feature is:

> **Build the planner and progress engine first. Build the UI second.**

The core logic must be correct independently of Flutter widgets.

The implementation order should therefore be:

```text
Existing Wird audit
        ↓
Domain models
        ↓
Database migration
        ↓
Planner
        ↓
Daily progress
        ↓
Repository
        ↓
Today engine
        ↓
Reader integration
        ↓
Streaks
        ↓
Khatma
        ↓
Achievements
        ↓
Statistics
        ↓
UI polish
        ↓
Notifications
```

This sequence gives the project a stable foundation and prevents UI code from becoming the source of business logic.

