import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdhkarCustomHeader extends StatefulWidget {
  const AdhkarCustomHeader({
    required this.title,
    required this.onSearch,
    this.onBack,
    super.key,
  });

  final String title;
  final void Function(String) onSearch;
  final VoidCallback? onBack;

  @override
  State<AdhkarCustomHeader> createState() => _AdhkarCustomHeaderState();
}

class _AdhkarCustomHeaderState extends State<AdhkarCustomHeader> {
  String _currentTime = '';
  String _hijriDate = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _updateHijriDate();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm').format(now);
    });
  }

  void _updateHijriDate() {
    final now = DateTime.now();
    // Simple Hijri approximation (not precise, for display purposes)
    final gregorianYear = now.year;
    final hijriYear = gregorianYear - 622 + (gregorianYear - 622) ~/ 32;
    final hijriMonth = (now.month - 3 + 12) % 12 + 1;
    final hijriDay = now.day;
    
    final arabicMonths = [
      'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 
      'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
      'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
    ];
    
    setState(() {
      _hijriDate = '$hijriDay ${arabicMonths[hijriMonth - 1]} $hijriYear';
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkSurface
        : AppColors.parchmentLight;
    final foregroundColor = isDark
        ? AppColors.parchmentLight
        : AppColors.maroon800;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.maroon900.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: widget.onBack,
                  color: foregroundColor,
                )
              else
                const SizedBox(width: 48),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'DiwaniBent',
                ),
              ),
              Text(
                _currentTime,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceHigh
                  : AppColors.parchment,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.maroon700.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: 'البحث بإسم الذكر',
                hintStyle: TextStyle(
                  color: foregroundColor.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: foregroundColor.withValues(alpha: 0.7),
                  size: 18,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _hijriDate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: foregroundColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
