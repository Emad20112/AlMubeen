import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_controller.dart';
import 'package:al_mubeen/features/quran/application/quran_surah_player_provider.dart';

import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuranSleepTimerSheet extends ConsumerStatefulWidget {
  const QuranSleepTimerSheet({super.key});

  @override
  ConsumerState<QuranSleepTimerSheet> createState() =>
      _QuranSleepTimerSheetState();
}

class _QuranSleepTimerSheetState extends ConsumerState<QuranSleepTimerSheet> {
  Duration _selectedDuration = const Duration(minutes: 15);
  List<Duration> _recentTimers = [];

  @override
  void initState() {
    super.initState();
    // Use future microtask to read the provider after init
    Future.microtask(() {
      final playerState = ref.read(quranSurahPlayerProvider);
      if (playerState.sleepTimerSettings.isActive &&
          playerState.sleepTimerSettings.duration != null) {
        setState(() {
          _selectedDuration = playerState.sleepTimerSettings.duration!;
        });
      }

      final prefs = ref.read(appUserPreferencesProvider).value;
      if (prefs != null && prefs.recentSleepTimers.isNotEmpty) {
        setState(() {
          _recentTimers = prefs.recentSleepTimers
              .map((s) => Duration(seconds: s))
              .toList();
        });
      } else {
        setState(() {
          _recentTimers = [
            const Duration(minutes: 15),
            const Duration(minutes: 30),
            const Duration(hours: 1),
          ];
        });
      }
    });
  }

  Future<void> _saveRecentTimer(Duration duration) async {
    if (duration.inSeconds == 0) return;

    ref
        .read(appUserPreferencesProvider.notifier)
        .addRecentSleepTimer(duration.inSeconds);

    final recent = List<Duration>.from(_recentTimers);
    recent.remove(duration);
    recent.insert(0, duration);
    if (recent.length > 5) {
      recent.removeLast();
    }

    setState(() {
      _recentTimers = recent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(quranSurahPlayerProvider);
    final isActive = playerState.sleepTimerSettings.isActive;

    // For iOS-like dark theme
    final bgColor = const Color(0xFF000000);
    final surfaceColor = const Color(0xFF1C1C1E);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Top Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'تعديل',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.parchmentMuted,
                        ),
                      ),
                    ),
                    const Text(
                      'المؤقتات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 60), // Balance
                  ],
                ),

                const SizedBox(height: 20),

                // Picker
                SizedBox(
                  height: 216,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(brightness: Brightness.dark),
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hms,
                      initialTimerDuration: _selectedDuration,
                      onTimerDurationChanged: (Duration newDuration) {
                        setState(() {
                          _selectedDuration = newDuration;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel/Stop button
                    _CircleButton(
                      label: 'إلغاء',
                      color: isActive
                          ? Colors.red.withOpacity(0.2)
                          : const Color(0xFF333333),
                      textColor: isActive ? Colors.red : Colors.white70,
                      onTap: () {
                        if (isActive) {
                          ref
                              .read(quranSurahPlayerProvider.notifier)
                              .cancelSleepTimer();
                        }
                        Navigator.pop(context);
                      },
                    ),

                    // Start button
                    _CircleButton(
                      label: isActive ? 'تحديث' : 'بدء',
                      color: const Color(0xFF1B401D), // Greenish
                      textColor: const Color(0xFF4CDB5F), // Bright Green
                      onTap: () {
                        if (_selectedDuration.inSeconds > 0) {
                          ref
                              .read(quranSurahPlayerProvider.notifier)
                              .startSleepTimer(_selectedDuration);
                          _saveRecentTimer(_selectedDuration);
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Settings Block
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text(
                          'تسمية المؤقت',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: const Text(
                          'مؤقت النوم',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                      const Divider(
                        color: Colors.white12,
                        height: 1,
                        indent: 16,
                      ),
                      ListTile(
                        title: const Text(
                          'عند انتهاء المؤقت',
                          style: TextStyle(color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'إيقاف المشغّل',
                              style: TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Recents
                if (_recentTimers.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      'الحديثة',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),

                  for (final duration in _recentTimers)
                    Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          onTap: () {
                            ref
                                .read(quranSurahPlayerProvider.notifier)
                                .startSleepTimer(duration);
                            _saveRecentTimer(duration);
                            Navigator.pop(context);
                          },
                          title: Text(
                            _formatRecentDuration(duration),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: const Color(0xFF1B401D),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFF4CDB5F),
                            ),
                          ),
                        ),
                        const Divider(
                          color: Colors.white12,
                          height: 1,
                          indent: 8,
                        ),
                      ],
                    ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatRecentDuration(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
    }
    return '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
