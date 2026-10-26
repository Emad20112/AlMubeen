import 'dart:async';

import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// حقل بحث موحد (Unified App Search Bar).
///
/// يدعم:
/// - مؤشر مسح ذكي عند وجود نص.
/// - مؤقت تأخير مدمج (Debounce) لمنع الضغط على مصادر البيانات مع كل حرف.
/// - مؤشر تحميل داخلي أثناء الاستعلامات.
/// - تكامل كامل مع `context.semanticColors`.
class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'بحث...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.isLoading = false,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.autofocus = false,
    this.height = 48.0,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool isLoading;
  final Duration debounceDuration;
  final bool autofocus;
  final double height;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  bool _isLocalController = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isLocalController = true;
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (_isLocalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (widget.onChanged == null) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onChanged!(text);
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    _debounceTimer?.cancel();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    if (widget.onClear != null) {
      widget.onClear!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.surfaceSunken.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        onChanged: _onTextChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        cursorColor: colors.primaryStrong,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: colors.textSecondary.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.textSecondary,
            size: 22,
          ),
          suffixIcon: widget.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.primaryStrong,
                      ),
                    ),
                  ),
                )
              : ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      tooltip: 'مسح',
                      onPressed: _clearSearch,
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    );
                  },
                ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 13,
          ),
        ),
      ),
    );
  }
}
