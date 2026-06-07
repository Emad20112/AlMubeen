# ROLE

Act as a Senior Flutter Architect, UI Engineer, SVG Designer, and Clean Architecture Expert.

You are working on an Islamic Quran & Adhkar application.

Your task is NOT to explain.
Your task is to ANALYZE, PLAN, CREATE FILES, REFACTOR, and IMPLEMENT.

Follow the instructions exactly.

--------------------------------------------------
PROJECT GOAL
--------------------------------------------------

Build a premium Islamic experience inspired by luxury Quran applications.

The UI style must be:

- Elegant
- Minimal
- Islamic
- Luxury manuscript inspired
- Warm ivory background
- Deep burgundy accents
- Decorative but lightweight
- RTL first

Reference design language:

- Ornamental Islamic header
- Custom bottom navigation
- Decorative cards
- Reusable SVG assets
- Reusable UI components

--------------------------------------------------
PHASE 1
HOME SCREEN REFACTOR
--------------------------------------------------

Modify the existing Home Screen.

REMOVE:

- Morning Adhkar card
- Evening Adhkar card
- Sleep Adhkar card
- Prayer Adhkar card
- Any adhkar category cards

KEEP:

- One single card:
    "الأذكار"

The card must:

- Be visually important
- Be centered
- Open AdhkarGridScreen
- Follow premium Islamic styling

DO NOT leave empty spaces.

Reorganize the layout professionally.

--------------------------------------------------
PHASE 2
SVG DESIGN SYSTEM
--------------------------------------------------

Create reusable SVG assets.

Create:

assets/svg/

header_frame.svg

header_corner_left.svg

header_corner_right.svg

decorative_divider.svg

decorative_card_frame.svg

decorative_badge.svg

bottom_nav_frame.svg

counter_frame.svg

section_frame.svg

Requirements:

- SVG must not contain hardcoded texts
- SVG must be scalable
- SVG must support dynamic content
- SVG must be optimized
- SVG must use lightweight paths
- SVG must be reusable

--------------------------------------------------
PHASE 3
REUSABLE UI COMPONENTS
--------------------------------------------------

Create reusable widgets.

Create:

lib/core/widgets/

islamic_header.dart

decorative_card.dart

adhkar_grid_card.dart

adhkar_counter.dart

decorative_badge.dart

section_title.dart

custom_bottom_nav.dart

play_audio_button.dart

favorite_button.dart

share_button.dart

Each widget must:

- Support dark mode
- Support RTL
- Support responsive layouts
- Support customization

Avoid duplicated code.

--------------------------------------------------
PHASE 4
ADHKAR GRID SCREEN
--------------------------------------------------

Create:

AdhkarGridScreen

Path:

lib/features/adhkar/presentation/screens/

Design:

Top:

IslamicHeader

Title:
الأذكار

Subtitle:
ذكر الله تعالى يطمئن القلب

Below header:

Quick actions row:

- المفضلة
- تم قراءته
- التسبيح اليومي
- البحث

Below:

GridView (2 columns)

Cards:

- أذكار الصباح
- أذكار المساء
- أذكار النوم
- أذكار بعد الصلاة
- أذكار الاستيقاظ
- أذكار دخول الخلاء
- أذكار الخروج من المنزل
- أدعية متنوعة
- التسبيح
- أذكار من القرآن والسنة

Each card contains:

- Icon
- Title
- Subtitle
- Count badge

Use reusable widgets only.

No duplicated UI.

--------------------------------------------------
PHASE 5
SELECTED ADHKAR SCREEN
--------------------------------------------------

Create:

AdhkarDetailsScreen

Design inspired by premium Quran applications.

Top:

IslamicHeader

Back button

Title

Subtitle

Then:

Large decorative card.

Contains:

Current Adhkar Index

Example:

1 من 8

Main Adhkar Text

Source

Example:

رواه البخاري

Below:

Action Bar

Contains:

Share

Favorite

Play Audio

Auto Repeat

Next Adhkar

Below:

Counter Section

Contains:

Minus button

Current count

Plus button

Animated updates

Below:

Adhkar List

Shows all adhkar in category.

Current item highlighted.

Support:

Scroll to current item.

--------------------------------------------------
PHASE 6
DATA LAYER
--------------------------------------------------

Create models.

Create:

AdhkarCategory

AdhkarItem

Create mock repository.

Repository must support:

Get Categories

Get Category Details  Get Adhkar Items

Prepare for future API integration.

--------------------------------------------------
PHASE 7
NAVIGATION
--------------------------------------------------

Implement navigation:

HomeScreen
      ↓
AdhkarGridScreen
      ↓
AdhkarDetailsScreen

Use:

go_router

or

auto_route

Choose the cleaner architecture.

--------------------------------------------------
PHASE 8
RESPONSIVE DESIGN
--------------------------------------------------

Support:

320 width

360 width

390 width

430 width

Tablet

Avoid fixed dimensions.

Use adaptive spacing.

--------------------------------------------------
PHASE 9
CLEAN ARCHITECTURE
--------------------------------------------------

Organize folders:

lib/

core/

theme/

constants/

widgets/

features/

home/

adhkar/

data/

domain/

presentation/

assets/

svg/

fonts/

No business logic inside UI widgets.

Separate responsibilities correctly.

--------------------------------------------------
PHASE 10
FINAL OUTPUT
--------------------------------------------------

Generate:

1. Folder structure

2. SVG files

3. Theme system

4. Reusable widgets

5. Home screen

6. Adhkar grid screen

7. Adhkar details screen

8. Mock data

9. Navigation setup

10. Responsive implementation

11. Refactoring notes

IMPORTANT:

Do not explain first.

Start implementing immediately.

Generate production-quality Flutter code.

Prioritize maintainability, scalability, and reusable architecture.