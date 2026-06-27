import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class AyahAudioPlayerBar extends ConsumerWidget {
  const AyahAudioPlayerBar({this.bottomInset = 60, super.key});

  final double bottomInset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioControllerProvider);
    
    // Only show if there's an active Ayah playing/loading
    if (audioState.currentAyah == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon700;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        bottom: true,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset, left: 20, right: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark 
                      ? const Color(0xFF2C2821).withValues(alpha: 0.8) 
                      : const Color(0xFFF7F4EB).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withValues(alpha: 0.1) 
                        : Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPlayPauseButton(context, ref, audioState, primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سورة ${getSurahNameArabic(audioState.currentAyah!.surah)} - الآية ${audioState.currentAyah!.ayah}',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          _buildReciterSelector(context, ref, audioState, primaryColor),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      onPressed: () {
                        ref.read(quranAudioControllerProvider.notifier).stop();
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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

  Widget _buildPlayPauseButton(BuildContext context, WidgetRef ref, QuranAudioState audioState, Color primaryColor) {
    if (audioState.isLoading) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(10),
        child: CircularProgressIndicator(strokeWidth: 2.5, color: primaryColor),
      );
    }

    final isPlaying = audioState.isPlaying;
    return InkWell(
      onTap: () {
        if (audioState.currentAyah != null && audioState.recitationId != null) {
          ref.read(quranAudioControllerProvider.notifier).playOrToggleAyah(
            ayahRef: audioState.currentAyah!,
            recitationId: audioState.recitationId!,
          );
        }
      },
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: primaryColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildReciterSelector(BuildContext context, WidgetRef ref, QuranAudioState audioState, Color primaryColor) {
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    
    return recitationsAsync.when(
      loading: () => Text('جاري التحميل...', style: _reciterTextStyle(context)),
      error: (e, s) => Text('خطأ في التحميل', style: _reciterTextStyle(context)),
      data: (recitations) {
        if (recitations.isEmpty) return const SizedBox.shrink();
        
        QuranRecitation activeRecitation = recitations.first;
        if (audioState.recitationId != null) {
          for (final r in recitations) {
            if (r.id == audioState.recitationId) {
              activeRecitation = r;
              break;
            }
          }
        }

        return PopupMenuButton<int>(
          initialValue: activeRecitation.id,
          tooltip: 'تغيير القارئ',
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _recitationLabel(activeRecitation),
                  style: _reciterTextStyle(context)?.copyWith(color: primaryColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: primaryColor),
            ],
          ),
          onSelected: (recitationId) {
            ref.read(selectedQuranRecitationProvider.notifier).state = recitations.firstWhere((r) => r.id == recitationId);
            if (audioState.currentAyah != null) {
              ref.read(quranAudioControllerProvider.notifier).playOrToggleAyah(
                ayahRef: audioState.currentAyah!,
                recitationId: recitationId,
              );
            }
          },
          itemBuilder: (context) {
            return recitations.map((r) => PopupMenuItem<int>(
              value: r.id,
              child: Text(
                _recitationLabel(r),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )).toList();
          },
        );
      },
    );
  }

  TextStyle? _reciterTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      fontSize: 11,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }

  String _recitationLabel(QuranRecitation recitation) {
    final translatedName = recitation.translatedName;
    final style = recitation.style;
    if (translatedName != null && translatedName != recitation.reciterName) {
      return '$translatedName - ${recitation.reciterName}';
    }
    if (style != null) {
      return '${recitation.reciterName} - $style';
    }
    return recitation.reciterName;
  }
}
