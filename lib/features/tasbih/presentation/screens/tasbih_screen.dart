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
                  'إضافة ذكر جديد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: textController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'أدخل الذكر هنا',
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
                        'إلغاء',
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
                        'إضافة',
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

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            IslamicHeader(
              title: 'التسبيح',
              subtitle: 'إحياءً لسنة النبي ﷺ',
              leading: IconButton(
                tooltip: 'رجوع',
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              trailing: TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة ذكر'),
                style: TextButton.styleFrom(
                  foregroundColor: colors.primaryStrong,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                          'لا يوجد أذكار، أضف ذكراً جديداً',
                          style: TextStyle(
                            fontSize: 18,
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
                  'تعديل الذكر',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: textController,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'أدخل الذكر هنا',
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
                        'إلغاء',
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
                        'حفظ',
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
                  'حذف الذكر',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'هل أنت متأكد من حذف هذا الذكر؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
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
                        'إلغاء',
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
                        'حذف',
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
                  style: TextStyle(
                    fontSize: 32,
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
                  'إحياء سنة التسبيح',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.primaryStrong,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '«عليكُنَّ بالتَّسبيحِ، والتَّهليلِ، والتَّقديسِ، واعقِدْنَ بالأناملِ؛ فإنَّهنَّ مَسؤولاتٌ مُستَنطَقاتٌ.»\n(رواه أبو داود والترمذي)',
                  style: TextStyle(
                    fontSize: 16,
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
                  '«رأيتُ رسولَ اللهِ ﷺ يَعقِدُ التَّسبيحَ بيَمينِه.»\n(صحيح أبي داود)',
                  style: TextStyle(
                    fontSize: 16,
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
