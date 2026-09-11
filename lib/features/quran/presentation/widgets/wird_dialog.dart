import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/database/app_database.dart';
import 'package:al_mubeen/features/quran/application/wird_controller.dart';
import 'package:al_mubeen/features/quran/domain/wird_calculator.dart';
import 'package:al_mubeen/features/quran/data/local/quran_page_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
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
  bool _completedManually = false;

  AsyncValue<WirdEntry?> get _wirdState => ref.watch(wirdControllerProvider);
  WirdEntry? get _currentWird => _wirdState.value;

  bool get _isCompletedToday {
    final lastRead = _currentWird?.lastReadDate;
    if (lastRead == null) return false;
    final now = DateTime.now();
    return lastRead.year == now.year &&
        lastRead.month == now.month &&
        lastRead.day == now.day;
  }

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

  void _saveSettings() {
    final daysText = _durationController.text.trim();
    final parsedDays = int.tryParse(daysText);
    final durationDays = parsedDays != null && parsedDays > 0 ? parsedDays : 30;

    ref
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
  }

  void _markWirdComplete() {
    final boundaries = _todayBoundaries;
    final targetPages = (boundaries.endPage - boundaries.startPage + 1);

    ref
        .read(wirdControllerProvider.notifier)
        .markTodayAsCompleted(
          plannedStartPage: boundaries.startPage,
          plannedEndPage: boundaries.endPage,
        );

    setState(() {
      _completedManually = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تسجيل إنجاز الوِرد اليومي (${convertToArabicDigits(targetPages)} صفحة).',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
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
              dayPeriodTextColor: MaterialStateColor.resolveWith(
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

    final dialogWidth = MediaQuery.of(context).size.width * 0.92;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.goldenAccentDark : AppColors.maroon800;
    final boundaries = _todayBoundaries;
    final startSurah = getSurahNameArabic(
      getSurahNumberFromPage(boundaries.startPage),
    );
    final endSurah = getSurahNameArabic(
      getSurahNumberFromPage(boundaries.endPage),
    );

    final leftSlide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(widget.animation);
    final rightSlide = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(widget.animation);

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
                color: Colors.black.withOpacity(0.24),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Row(
              children: [
                Expanded(
                  child: SlideTransition(
                    position: leftSlide,
                    child: _buildLeftPanel(context, accent, boundaries),
                  ),
                ),
                Expanded(
                  child: SlideTransition(
                    position: rightSlide,
                    child: _buildRightPanel(
                      context,
                      accent,
                      startSurah,
                      endSurah,
                      boundaries,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          const SizedBox(height: 14),
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 22),
          FilledButton(
            onPressed: _saveSettings,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ الإعدادات'),
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 12),
          if (widget.onNavigateToWirdEnd != null)
            OutlinedButton.icon(
              onPressed: () => widget.onNavigateToWirdEnd!(boundaries.endPage),
              icon: const Icon(Icons.flag_rounded),
              label: const Text('إلى نهاية الوِرد'),
            ),
          const SizedBox(height: 18),
          Text(
            'تقدم الخطة',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 8,
            color: accent,
            backgroundColor: accent.withOpacity(0.16),
          ),
          const SizedBox(height: 12),
          Text(
            '${convertToArabicDigits(_completedDaysCount)} من ${convertToArabicDigits(_durationDays)} يوم',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: 6),
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: WirdAmountType.values.map((type) {
              final selected = type == _selectedType;
              return ChoiceChip(
                label: Text(_amountTypeLabel(type)),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedType = type;
                  });
                },
                selectedColor: accent.withOpacity(0.14),
                backgroundColor: Theme.of(context).colorScheme.surface,
                labelStyle: TextStyle(
                  color: selected
                      ? accent
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
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
          const SizedBox(height: 22),
          Text(
            'ورد اليوم',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
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
                    onTap: () => _navigateToStartPage(boundaries.startPage),
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
          const SizedBox(height: 16),
          Text(
            'اضغط على اسم السورة للانتقال إلى بداية الورد.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(0.72),
            ),
          ),
        ],
      ),
    );
  }
}
