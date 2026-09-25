import 'dart:async';

import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/data/local/wird_dao.dart';
import 'package:al_mubeen/features/quran/domain/wird_calculator.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final wirdControllerProvider = AsyncNotifierProvider<WirdNotifier, WirdEntry?>(
  WirdNotifier.new,
);

class WirdNotifier extends AsyncNotifier<WirdEntry?> {
  late final WirdDao _wirdDao;

  @override
  Future<WirdEntry?> build() async {
    _wirdDao = ref.watch(wirdDaoProvider);
    return _wirdDao.getWird();
  }

  Future<void> markAsRead() async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final now = DateTime.now();
    if (_isSameCalendarDay(current.lastReadDate, now)) {
      return;
    }

    final updated = current.copyWith(
      completedDaysCount: Value((current.completedDaysCount ?? 0) + 1),
      lastReadDate: Value(now),
    );

    state = AsyncData(updated);
    unawaited(_wirdDao.updateWird(updated));
  }

  Future<void> markTodayAsCompleted({
    required int plannedStartPage,
    required int plannedEndPage,
  }) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final todayTarget = plannedEndPage - plannedStartPage + 1;
    final now = DateTime.now();

    await _wirdDao.markWirdCompletedToday(
      wirdId: current.id,
      plannedStartPage: plannedStartPage,
      plannedEndPage: plannedEndPage,
      targetPages: todayTarget,
      at: now,
    );
  }

  Future<void> deleteWird() async {
    final current = state.value;
    if (current == null) return;

    await _wirdDao.deleteWird(current.id);
    state = const AsyncData(null);
  }

  Future<void> saveWirdSettings({
    required WirdAmountType amountType,
    required int amountMultiplier,
    required int durationDays,
    required String frequency,
    String? reminderTime,
  }) async {
    final now = DateTime.now();
    final current = state.value;

    if (current == null) {
      final id = await _wirdDao.insertWird(
        WirdsTableCompanion.insert(
          name: Value('Wird'),
          goalType: const Value('legacy'),
          status: const Value('active'),
          startPage: const Value(1),
          endPage: const Value(604),
          startDate: Value(now),
          updatedAt: Value(now),
          scheduleType: const Value('daily'),
          activeWeekdays: const Value('[1,2,3,4,5,6,7]'),
          isFlexible: const Value(false),
          allowCatchUp: const Value(false),
          autoStartNextKhatma: const Value(false),
          currentCycle: const Value(1),
          amountType: Value(amountType.name),
          amountMultiplier: Value(amountMultiplier),
          durationDays: Value(durationDays),
          frequency: Value(frequency),
          reminderTime: Value(reminderTime),
          createdAt: now,
          lastReadDate: const Value.absent(),
          completedDaysCount: const Value(0),
        ),
      );

      state = AsyncData(
        WirdEntry(
          id: id,
          name: 'Wird',
          goalType: 'legacy',
          status: 'active',
          startPage: 1,
          endPage: 604,
          pagesPerDay: null,
          startDate: now,
          targetDate: null,
          scheduleType: 'daily',
          activeWeekdays: '[1,2,3,4,5,6,7]',
          isFlexible: false,
          allowCatchUp: false,
          autoStartNextKhatma: false,
          currentCycle: 1,
          createdAt: now,
          updatedAt: now,
          completedAt: null,
          amountType: amountType.name,
          amountMultiplier: amountMultiplier,
          durationDays: durationDays,
          frequency: frequency,
          reminderTime: reminderTime,
          lastReadDate: null,
          completedDaysCount: 0,
        ),
      );
      return;
    }

    final updated = current.copyWith(
      amountType: Value(amountType.name),
      amountMultiplier: Value(amountMultiplier),
      durationDays: Value(durationDays),
      frequency: Value(frequency),
      reminderTime: Value(reminderTime),
    );

    state = AsyncData(updated);
    unawaited(_wirdDao.updateWird(updated));
  }

  bool _isSameCalendarDay(DateTime? previous, DateTime current) {
    if (previous == null) return false;
    return previous.year == current.year &&
        previous.month == current.month &&
        previous.day == current.day;
  }
}
