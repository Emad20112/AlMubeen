import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/islamic_header.dart';
import 'package:al_mubeen/features/tasbih/application/tasbih_controller.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.parchmentLight,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'إضافة ذكر جديد',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: textController,
                  style: TextStyle(color: isDark ? AppColors.parchmentLight : AppColors.maroon800),
                  decoration: InputDecoration(
                    hintText: 'أدخل الذكر هنا',
                    hintStyle: TextStyle(color: (isDark ? AppColors.parchmentLight : AppColors.maroon800).withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.maroon700, width: 2),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.parchmentLight : AppColors.maroon800,
                      ),
                      child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isNotEmpty) {
                          ref.read(tasbihControllerProvider.notifier).addDhikr(text);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('إضافة', style: TextStyle(fontWeight: FontWeight.bold)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D1117) : const Color(0xFF1A1A2E),
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
                  foregroundColor: isDark ? AppColors.parchmentLight : AppColors.maroon800,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onPressed: _showAddDialog,
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _showSunnahReminder,
                child: dhikrs.isEmpty
                    ? const Center(
                        child: Text(
                          'لا يوجد أذكار، أضف ذكراً جديداً',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
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
                              isDark: isDark,
                              onTap: _showSunnahReminder,
                              onEdit: () => _showEditDialog(index, dhikrs[index]),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.parchmentLight,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تعديل الذكر',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: textController,
                  style: TextStyle(color: isDark ? AppColors.parchmentLight : AppColors.maroon800),
                  decoration: InputDecoration(
                    hintText: 'أدخل الذكر هنا',
                    hintStyle: TextStyle(color: (isDark ? AppColors.parchmentLight : AppColors.maroon800).withValues(alpha: 0.5)),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurface : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.maroon700, width: 2),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.parchmentLight : AppColors.maroon800,
                      ),
                      child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isNotEmpty) {
                          ref.read(tasbihControllerProvider.notifier).editDhikr(index, text);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.maroon700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.parchmentLight,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'حذف الذكر',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'هل أنت متأكد من حذف هذا الذكر؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.parchmentLight : AppColors.maroon800,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.parchmentLight : AppColors.maroon800,
                      ),
                      child: const Text('إلغاء', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(tasbihControllerProvider.notifier).removeDhikr(index);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('حذف', style: TextStyle(fontWeight: FontWeight.bold)),
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
    required this.isDark,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String dhikr;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? AppColors.parchmentLight : AppColors.maroon900;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkSurfaceHigh, AppColors.darkSurface]
                : [Colors.white, AppColors.parchmentLight],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.maroon900.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: AppColors.maroon700.withValues(alpha: 0.2),
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
                    icon: Icon(Icons.edit, size: 20, color: textColor.withValues(alpha: 0.6)),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20, color: Colors.red.withValues(alpha: 0.6)),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.parchmentLight : AppColors.maroon800;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurfaceHigh : AppColors.parchmentLight,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                const Icon(
                  FlutterIslamicIcons.tasbih2,
                  size: 48,
                  color: AppColors.maroon700,
                ),
                const SizedBox(height: 16),
                const Text(
                  'إحياء سنة التسبيح',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.maroon700,
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 12),
                Divider(color: AppColors.maroon700.withValues(alpha: 0.2)),
                const SizedBox(height: 12),
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
              icon: Icon(Icons.close, color: textColor.withValues(alpha: 0.6)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
