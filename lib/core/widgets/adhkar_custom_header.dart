import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdhkarCustomHeader extends StatefulWidget {
  const AdhkarCustomHeader({
    required this.title,
    required this.onSearch,
    this.onBack,
    this.tabs,
    super.key,
  });

  final String title;
  final void Function(String) onSearch;
  final VoidCallback? onBack;
  final Widget? tabs;

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
    final gregorianYear = now.year;
    final hijriYear = gregorianYear - 622 + (gregorianYear - 622) ~/ 32;
    final hijriMonth = (now.month - 3 + 12) % 12 + 1;
    final hijriDay = now.day;

    final arabicMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];

    setState(() {
      _hijriDate = '$hijriDay ${arabicMonths[hijriMonth - 1]} $hijriYear';
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final backgroundColor = colors.surface;
    final foregroundColor = colors.textPrimary;

    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: context.tokens.shadows.medium,
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
                const SizedBox(width: AppSpacing.touchTarget),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
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
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: colors.border),
            ),
            child: TextField(
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: 'البحث بإسم الذكر',
                hintStyle: TextStyle(
                  color: colors.textTertiary,
                  fontSize: 12,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: colors.textSecondary,
                  size: 18,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(color: foregroundColor, fontSize: 13),
            ),
          ),
          if (widget.tabs != null) ...[
            const SizedBox(height: AppSpacing.sm),
            widget.tabs!,
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            _hijriDate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
