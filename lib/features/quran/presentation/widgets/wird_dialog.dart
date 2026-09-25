import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/application/wird_controller.dart';
import 'package:al_mubeen/features/quran/domain/wird_calculator.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:qcf_quran/qcf_quran.dart';

Future<void> showWirdHotelDoorsDialog(
  BuildContext context, {
  required Function(int) onNavigateToPage,
  Function(int)? onNavigateToWirdEnd,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Wird Dialog',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: Center(
          child: _WirdHotelDoorsDialog(
            onNavigateToPage: onNavigateToPage,
            onNavigateToWirdEnd: onNavigateToWirdEnd,
            animation: curved,
          ),
        ),
      );
    },
  );
}

class _WirdHotelDoorsDialog extends ConsumerStatefulWidget {
  const _WirdHotelDoorsDialog({
    required this.onNavigateToPage,
    this.onNavigateToWirdEnd,
    required this.animation,
  });

  final Function(int) onNavigateToPage;
  final Function(int)? onNavigateToWirdEnd;
  final Animation<double> animation;

  @override
  ConsumerState<_WirdHotelDoorsDialog> createState() =>
      _WirdHotelDoorsDialogState();
}

class _WirdHotelDoorsDialogState extends ConsumerState<_WirdHotelDoorsDialog> {
  late final TextEditingController _durationController;
  WirdAmountType _selectedType = WirdAmountType.quarter;
  int _multiplier = 1;
  int _durationDays = 30;
  bool _reminderEnabled = false;
  TimeOfDay? _selectedTime;
  String _frequency = 'daily';
  bool _initializedFromStore = false;
  bool _showSettings = false;

  AsyncValue<WirdEntry?> get _wirdState => ref.watch(wirdControllerProvider);
  WirdEntry? get _currentWird => _wirdState.value;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(text: '30');
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  WirdAmountType _parseAmountType(String raw) {
    return WirdAmountType.values.firstWhere(
      (type) => type.name == raw,
      orElse: () => WirdAmountType.quarter,
    );
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return TimeOfDay.now();
    final hour = int.tryParse(parts[0]) ?? TimeOfDay.now().hour;
    final minute = int.tryParse(parts[1]) ?? TimeOfDay.now().minute;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'اختر الوقت';
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(time, alwaysUse24HourFormat: true);
  }

  String _amountTypeLabel(WirdAmountType type) {
    switch (type) {
      case WirdAmountType.quarter:
        return 'ربع';
      case WirdAmountType.halfHizb:
        return 'نصف حزب';
      case WirdAmountType.hizb:
        return 'حزب';
      case WirdAmountType.juz:
        return 'جزء';
      case WirdAmountType.juzAndHalf:
        return 'جزء ونصف';
      case WirdAmountType.twoJuzs:
        return 'جزآن';
    }
  }

  Future<void> _saveSettings() async {
    final daysText = _durationController.text.trim();
    final parsedDays = int.tryParse(daysText);
    final durationDays = parsedDays != null && parsedDays > 0 ? parsedDays : 30;

    await ref
        .read(wirdControllerProvider.notifier)
        .saveWirdSettings(
          amountType: _selectedType,
          amountMultiplier: _multiplier < 1 ? 1 : _multiplier,
          durationDays: durationDays,
          frequency: _frequency,
          reminderTime: _selectedTime == null
              ? null
              : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
        );
    if (mounted) {
      setState(() => _showSettings = false);
    }
  }

  Future<void> _createNewWird() async {
    await ref.read(wirdControllerProvider.notifier).deleteWird();
    if (mounted) setState(() => _showSettings = true);
  }

  Future<void> _cancelWird() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الورد؟'),
        content: const Text('سيتم حذف خطة الورد وتقدمها من هذا الجهاز.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('تراجع'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إلغاء الورد'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(wirdControllerProvider.notifier).deleteWird();
      if (mounted) setState(() => _showSettings = true);
    }
  }

  Future<void> _pickReminderTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: Theme.of(context).colorScheme.surface,
              dayPeriodTextColor: WidgetStateColor.resolveWith(
                (_) => AppColors.maroon800,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedTime = result;
      });
    }
  }

  void _navigateToStartPage(int page) {
    Navigator.of(context).pop();
    widget.onNavigateToPage(page);
  }

  int get _completedDaysCount => _currentWird?.completedDaysCount ?? 0;

  WirdBoundaries get _todayBoundaries {
    return WirdCalculator.calculateCurrentWird(
      _selectedType,
      _multiplier < 1 ? 1 : _multiplier,
      _completedDaysCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_wirdState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_wirdState.hasError) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('تعذر تحميل إعدادات الورد. أغلق النافذة وحاول مرة أخرى.'),
      );
    }
    if (_wirdState is AsyncData<WirdEntry?> && !_initializedFromStore) {
      final entry = (_wirdState as AsyncData<WirdEntry?>).value;
      if (entry != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            final amountTypeValue =
                entry.amountType ?? WirdAmountType.quarter.name;
            final multiplierValue = entry.amountMultiplier ?? 1;
            final durationValue = entry.durationDays ?? 30;
            final frequencyValue = entry.frequency ?? 'daily';
            final reminderValue = entry.reminderTime;

            _selectedType = _parseAmountType(amountTypeValue);
            _multiplier = multiplierValue;
            _durationDays = durationValue;
            _frequency = frequencyValue;
            _reminderEnabled = reminderValue != null;
            _selectedTime = reminderValue == null
                ? null
                : _parseTime(reminderValue);
            _durationController.text = durationValue.toString();
            _initializedFromStore = true;
          });
        });
      }
    }

    final dialogWidth = MediaQuery.sizeOf(context).width * 0.92;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.goldenAccentDark : AppColors.maroon800;
    final boundaries = _todayBoundaries;
    final startSurah = getSurahNameArabic(
      getSurahNumberFromPage(boundaries.startPage),
    );
    final endSurah = getSurahNameArabic(
      getSurahNumberFromPage(boundaries.endPage),
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.82,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_stories_rounded, color: accent),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            'إعداد الورد اليومي',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        IconButton(
                          tooltip: 'إغلاق',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    if (_showSettings || _currentWird == null)
                      _buildSettingsPanel(context, accent)
                    else
                      _buildDetailsPanel(
                        context,
                        accent,
                        startSurah,
                        endSurah,
                        boundaries,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel(BuildContext context, Color accent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<WirdAmountType>(
          initialValue: _selectedType,
          isDense: true,
          decoration: InputDecoration(
            labelText: 'مقدار الورد اليومي',
            prefixIcon: const Icon(Icons.menu_book_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          items: WirdAmountType.values
              .map(
                (type) => DropdownMenuItem<WirdAmountType>(
                  value: type,
                  child: Text(_amountTypeLabel(type)),
                ),
              )
              .toList(),
          onChanged: (type) {
            if (type != null) setState(() => _selectedType = type);
          },
        ),
        const Gap(10),
        TextField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'عدد أيام الخطة',
            prefixIcon: const Icon(Icons.event_available_rounded),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (value) {
            final parsed = int.tryParse(value);
            if (parsed != null && parsed > 0) {
              setState(() => _durationDays = parsed);
            }
          },
        ),
        const Gap(8),
        SwitchListTile.adaptive(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: const Text('تذكير يومي'),
          value: _reminderEnabled,
          onChanged: (value) => setState(() {
            _reminderEnabled = value;
            if (!value) _selectedTime = null;
          }),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: _reminderEnabled ? _pickReminderTime : null,
            icon: const Icon(Icons.schedule_rounded, size: 18),
            label: Text(
              _selectedTime == null
                  ? 'اختيار وقت التذكير'
                  : _formatTimeOfDay(_selectedTime),
            ),
            style: TextButton.styleFrom(
              foregroundColor: accent,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const Gap(8),
        FilledButton(
          onPressed: _saveSettings,
          style: FilledButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            visualDensity: VisualDensity.compact,
          ),
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  Widget _buildDetailsPanel(
    BuildContext context,
    Color accent,
    String startSurah,
    String endSurah,
    WirdBoundaries boundaries,
  ) {
    final pageCount = boundaries.endPage - boundaries.startPage + 1;
    final progress =
        (_completedDaysCount / (_durationDays <= 0 ? 1 : _durationDays)).clamp(
          0.0,
          1.0,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: accent.withValues(alpha: 0.18)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ورد اليوم',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Gap(8),
                Text(
                  'من $startSurah إلى $endSurah  •  ${convertToArabicDigits(pageCount)} صفحة',
                ),
                const Gap(8),
                Text(
                  '${_amountTypeLabel(_selectedType)} يومياً  •  خطة ${convertToArabicDigits(_durationDays)} يوماً',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_reminderEnabled && _selectedTime != null) ...[
                  const Gap(4),
                  Text(
                    'التذكير يومياً الساعة ${_formatTimeOfDay(_selectedTime)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const Gap(10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  color: accent,
                ),
                const Gap(6),
                Text(
                  '${convertToArabicDigits(_completedDaysCount)} من ${convertToArabicDigits(_durationDays)} يوم',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onNavigateToWirdEnd == null
                    ? null
                    : () => widget.onNavigateToWirdEnd!(boundaries.endPage),
                icon: const Icon(Icons.flag_rounded, size: 18),
                label: const Text('نهاية الورد'),
              ),
            ),
            const Gap(8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _navigateToStartPage(boundaries.startPage),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('بدء الورد'),
              ),
            ),
          ],
        ),
        const Gap(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _createNewWird,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: const Text('ورد جديد'),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            const Gap(8),
            TextButton.icon(
              onPressed: _cancelWird,
              icon: const Icon(Icons.delete_outline_rounded, size: 17),
              label: const Text('إلغاء الورد'),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /*
  Widget _buildLeftPanel(
    BuildContext context,
    Color accent,
    WirdBoundaries boundaries,
  ) {
    final progressValue =
        (_completedDaysCount / (_durationDays <= 0 ? 1 : _durationDays)).clamp(
          0.0,
          1.0,
        );

    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.parchmentLight,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'تنبيهات ورد القرآن',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Gap(14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'تفعيل تذكير يومي',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Switch.adaptive(
                value: _reminderEnabled,
                onChanged: (value) {
                  setState(() {
                    _reminderEnabled = value;
                    if (!value) _selectedTime = null;
                  });
                },
              ),
            ],
          ),
          const Gap(8),
          TextButton(
            onPressed: _reminderEnabled ? _pickReminderTime : null,
            style: TextButton.styleFrom(
              foregroundColor: _reminderEnabled
                  ? accent
                  : Theme.of(context).hintColor,
            ),
            child: Text(
              _selectedTime == null
                  ? 'اختر وقت التذكير'
                  : 'وقت التذكير: ${_formatTimeOfDay(_selectedTime)}',
            ),
          ),
          const Gap(22),
          FilledButton(
            onPressed: _saveSettings,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ الإعدادات'),
          ),
          const Gap(10),
          FilledButton(
            onPressed:
                _currentWird != null &&
                    !_completedManually &&
                    !_isCompletedToday
                ? _markWirdComplete
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
            ),
            child: Text(
              _completedManually || _isCompletedToday
                  ? 'تم تسجيل إنجاز الوِرد'
                  : 'أكملت الوِرد',
            ),
          ),
          const Gap(12),
          if (widget.onNavigateToWirdEnd != null)
            OutlinedButton.icon(
              onPressed: () => widget.onNavigateToWirdEnd!(boundaries.endPage),
              icon: const Icon(Icons.flag_rounded),
              label: const Text('إلى نهاية الوِرد'),
            ),
          const Gap(18),
          Text(
            'تقدم الخطة',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Gap(10),
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 8,
            color: accent,
            backgroundColor: accent.withValues(alpha: 0.16),
          ),
          const Gap(12),
          Text(
            '${convertToArabicDigits(_completedDaysCount)} من ${convertToArabicDigits(_durationDays)} يوم',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.82),
            ),
          ),
          const Gap(6),
          Text(
            'اليوم ${convertToArabicDigits(_completedDaysCount + 1)} من الخطة',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  */

  /*
  Widget _buildRightPanel(
    BuildContext context,
    Color accent,
    String startSurah,
    String endSurah,
    WirdBoundaries boundaries,
  ) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurfaceHigh
          : AppColors.parchment,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ورد يومي',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Gap(12),
          DropdownButtonFormField<WirdAmountType>(
            initialValue: _selectedType,
            isDense: true,
            decoration: InputDecoration(
              labelText: 'مقدار الورد اليومي',
              prefixIcon: const Icon(Icons.menu_book_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            items: WirdAmountType.values
                .map(
                  (type) => DropdownMenuItem<WirdAmountType>(
                    value: type,
                    child: Text(_amountTypeLabel(type)),
                  ),
                )
                .toList(),
            onChanged: (type) {
              if (type != null) setState(() => _selectedType = type);
            },
          ),
          const Gap(18),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'عدد أيام الخطة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (value) {
              final parsed = int.tryParse(value);
              if (parsed != null && parsed > 0) {
                setState(() => _durationDays = parsed);
              }
            },
          ),
          const Gap(22),
          Text(
            'ورد اليوم',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const Gap(10),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'من '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => _navigateToStartPage(boundaries.startPage),
                    child: Text(
                      startSurah,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' إلى '),
                TextSpan(
                  text: 'ص ${convertToArabicDigits(boundaries.endPage)} من ',
                ),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () => _navigateToStartPage(boundaries.endPage),
                    child: Text(
                      endSurah,
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          Text(
            'اضغط على اسم السورة للانتقال إلى بداية الورد.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
  */
}
