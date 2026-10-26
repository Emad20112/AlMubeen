import 'dart:async';
import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_radii.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/tasbih/application/tasbih_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  static const String routePath = '/tasbih';

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final colors = context.semanticColors;
        final textTheme = Theme.of(context).textTheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          backgroundColor: colors.surfaceElevated,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ø¥Ø¶Ø§ÙØ© Ø°ÙƒØ± Ø¬Ø¯ÙŠØ¯',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: textController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Ø£Ø¯Ø®Ù„ Ø§Ù„Ø°ÙƒØ± Ù‡Ù†Ø§',
                    hintStyle: TextStyle(color: colors.textTertiary),
                    filled: true,
                    fillColor: colors.surfaceSunken,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(
                        color: colors.primaryStrong,
                        width: 2,
                      ),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                      ),
                      child: const Text(
                        'Ø¥Ù„ØºØ§Ø¡',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isNotEmpty) {
                          ref
                              .read(tasbihControllerProvider.notifier)
                              .addDhikr(text);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryStrong,
                        foregroundColor: colors.onPrimaryStrong,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text(
                        'Ø¥Ø¶Ø§ÙØ©',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSunnahReminder() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _SunnahDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dhikrs = ref.watch(tasbihControllerProvider);
    final colors = context.semanticColors;
    final textTheme = Theme.of(context).textTheme;
    final bodyLarge = textTheme.bodyLarge;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            IslamicHeader(
              title: 'Ø§Ù„ØªØ³Ø¨ÙŠØ­',
              subtitle: 'Ø¥Ø­ÙŠØ§Ø¡Ù‹ Ù„Ø³Ù†Ø© Ø§Ù„Ù†Ø¨ÙŠ ï·º',
              leading: IconButton(
                tooltip: 'Ø±Ø¬ÙˆØ¹',
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              trailing: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Ø¥Ø¶Ø§ÙØ© Ø°ÙƒØ±'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primaryStrong,
                  textStyle: bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                onPressed: _showAddDialog,
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _showSunnahReminder,
                child: dhikrs.isEmpty
                    ? Center(
                        child: Text(
                          'Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø£Ø°ÙƒØ§Ø±ØŒ Ø£Ø¶Ù Ø°ÙƒØ±Ø§Ù‹ Ø¬Ø¯ÙŠØ¯Ø§Ù‹',
                          style: textTheme.titleMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: dhikrs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 40.0,
                            ),
                            child: _DhikrCard(
                              dhikr: dhikrs[index],
                              onTap: _showSunnahReminder,
                              onEdit: () =>
                                  _showEditDialog(index, dhikrs[index]),
                              onDelete: () => _showDeleteDialog(index),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(int index, String currentText) {
    final textController = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (context) {
        final colors = context.semanticColors;
        final textTheme = Theme.of(context).textTheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          backgroundColor: colors.surfaceElevated,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø°ÙƒØ±',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: textController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Ø£Ø¯Ø®Ù„ Ø§Ù„Ø°ÙƒØ± Ù‡Ù†Ø§',
                    hintStyle: TextStyle(color: colors.textTertiary),
                    filled: true,
                    fillColor: colors.surfaceSunken,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      borderSide: BorderSide(
                        color: colors.primaryStrong,
                        width: 2,
                      ),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                      ),
                      child: const Text(
                        'Ø¥Ù„ØºØ§Ø¡',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isNotEmpty) {
                          ref
                              .read(tasbihControllerProvider.notifier)
                              .editDhikr(index, text);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primaryStrong,
                        foregroundColor: colors.onPrimaryStrong,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text(
                        'Ø­ÙØ¸',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final colors = context.semanticColors;
        final textTheme = Theme.of(context).textTheme;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xl),
          ),
          backgroundColor: colors.surfaceElevated,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ø­Ø°Ù Ø§Ù„Ø°ÙƒØ±',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø­Ø°Ù Ù‡Ø°Ø§ Ø§Ù„Ø°ÙƒØ±ØŸ',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                      ),
                      child: const Text(
                        'Ø¥Ù„ØºØ§Ø¡',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(tasbihControllerProvider.notifier)
                            .removeDhikr(index);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: colors.onError,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text(
                        'Ø­Ø°Ù',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DhikrCard extends StatelessWidget {
  const _DhikrCard({
    required this.dhikr,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String dhikr;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final textColor = colors.textPrimary;
    // ðŸ“ Ø³Ù„Ù… Ø§Ù„Ø·Ø¨Ø§Ø¹Ø©: Ø­Ø¬Ù… Ø§Ù„ØªØ£Ù…Ù‘Ù„ ÙŠÙ†ØªÙ‚Ù„ Ù…Ù† Ø±Ù‚Ù… Ø«Ø§Ø¨Øª (32) Ø¥Ù„Ù‰ `headlineSmall`
    // ÙÙŠÙƒØ¨Ø±/ÙŠØµØºØ± Ù…Ø¹ Ù…Ù‚ÙŠØ§Ø³ Ø®Ø· Ø§Ù„Ù†Ø¸Ø§Ù… Ø¨Ø¯Ù„ Ø§Ù„ØªØ¬Ù…Ù‘Ø¯ Ø¹Ù†Ø¯ Ù‚ÙŠÙ…Ø© ÙˆØ§Ø­Ø¯Ø©.
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          boxShadow: context.tokens.shadows.medium,
          border: Border.all(
            color: colors.border,
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20,
                      color: colors.textSecondary,
                    ),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      size: 20,
                      color: colors.error,
                    ),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 40.0,
                ),
                child: Text(
                  dhikr,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunnahDialog extends StatefulWidget {
  const _SunnahDialog();

  @override
  State<_SunnahDialog> createState() => _SunnahDialogState();
}

class _SunnahDialogState extends State<_SunnahDialog> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final textColor = colors.textPrimary;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      backgroundColor: colors.surfaceElevated,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Icon(
                  FlutterIslamicIcons.tasbih2,
                  size: 48,
                  color: colors.primaryStrong,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Ø¥Ø­ÙŠØ§Ø¡ Ø³Ù†Ø© Ø§Ù„ØªØ³Ø¨ÙŠØ­',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primaryStrong,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Â«Ø¹Ù„ÙŠÙƒÙÙ†Ù‘ÙŽ Ø¨Ø§Ù„ØªÙ‘ÙŽØ³Ø¨ÙŠØ­ÙØŒ ÙˆØ§Ù„ØªÙ‘ÙŽÙ‡Ù„ÙŠÙ„ÙØŒ ÙˆØ§Ù„ØªÙ‘ÙŽÙ‚Ø¯ÙŠØ³ÙØŒ ÙˆØ§Ø¹Ù‚ÙØ¯Ù’Ù†ÙŽ Ø¨Ø§Ù„Ø£Ù†Ø§Ù…Ù„ÙØ› ÙØ¥Ù†Ù‘ÙŽÙ‡Ù†Ù‘ÙŽ Ù…ÙŽØ³Ø¤ÙˆÙ„Ø§ØªÙŒ Ù…ÙØ³ØªÙŽÙ†Ø·ÙŽÙ‚Ø§ØªÙŒ.Â»\n(Ø±ÙˆØ§Ù‡ Ø£Ø¨Ùˆ Ø¯Ø§ÙˆØ¯ ÙˆØ§Ù„ØªØ±Ù…Ø°ÙŠ)',
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(color: colors.divider),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Â«Ø±Ø£ÙŠØªÙ Ø±Ø³ÙˆÙ„ÙŽ Ø§Ù„Ù„Ù‡Ù ï·º ÙŠÙŽØ¹Ù‚ÙØ¯Ù Ø§Ù„ØªÙ‘ÙŽØ³Ø¨ÙŠØ­ÙŽ Ø¨ÙŠÙŽÙ…ÙŠÙ†ÙÙ‡.Â»\n(ØµØ­ÙŠØ­ Ø£Ø¨ÙŠ Ø¯Ø§ÙˆØ¯)',
                  style: textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: Icon(Icons.close, color: colors.textSecondary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
