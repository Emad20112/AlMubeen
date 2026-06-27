import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/translation_bottom_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

import 'package:flutter/services.dart';

void showAyahOverlay({
  required BuildContext context,
  required AyahRef ayahRef,
  required Offset globalPosition,
  required bool isHighlighted,
  required VoidCallback onToggleHighlight,
  required VoidCallback onClearHighlight,
}) {
  HapticFeedback.mediumImpact();
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.1),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        ),
        child: FadeTransition(
          opacity: animation,
          child: _AyahOverlayWidget(
            ayahRef: ayahRef,
            globalPosition: globalPosition,
            isHighlighted: isHighlighted,
            onToggleHighlight: onToggleHighlight,
            onClearHighlight: onClearHighlight,
          ),
        ),
      );
    },
  );
}

class _AyahOverlayWidget extends ConsumerStatefulWidget {
  const _AyahOverlayWidget({
    required this.ayahRef,
    required this.globalPosition,
    required this.isHighlighted,
    required this.onToggleHighlight,
    required this.onClearHighlight,
  });

  final AyahRef ayahRef;
  final Offset globalPosition;
  final bool isHighlighted;
  final VoidCallback onToggleHighlight;
  final VoidCallback onClearHighlight;

  @override
  ConsumerState<_AyahOverlayWidget> createState() => _AyahOverlayWidgetState();
}

class _AyahOverlayWidgetState extends ConsumerState<_AyahOverlayWidget> {
  final GlobalKey _cardKey = GlobalKey();
  double _cardHeight = 180.0; // Estimate, will update after build if needed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _cardKey.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.size.height != _cardHeight) {
          if (mounted) {
            setState(() {
              _cardHeight = box.size.height;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final dy = widget.globalPosition.dy;

    // Determine positions
    final isTopHalf = dy < size.height / 2;

    double toolbarY;
    double? cardY;
    double? cardBottom;

    final toolbarHeight = 85.0; // Increased for labels

    if (isTopHalf) {
      // Toolbar ABOVE tap, Card BELOW tap
      toolbarY = dy - toolbarHeight - 20;
      if (toolbarY < padding.top + 10) {
        toolbarY = padding.top + 10;
      }
      cardY = dy + 30;
      if (cardY + _cardHeight > size.height - padding.bottom - 10) {
        cardY = size.height - padding.bottom - _cardHeight - 10;
      }
    } else {
      // Toolbar BELOW tap, Card ABOVE tap
      toolbarY = dy + 20;
      if (toolbarY + toolbarHeight > size.height - padding.bottom - 10) {
        toolbarY = size.height - padding.bottom - toolbarHeight - 10;
      }
      cardBottom = size.height - dy + 20;
      if (size.height - cardBottom - _cardHeight < padding.top + 10) {
        cardBottom = size.height - (padding.top + 10 + _cardHeight);
      }
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Background tap to dismiss handled by GeneralDialog barrier
          Positioned(
            top: toolbarY,
            left: 20,
            right: 20,
            child: Center(
              child: _GlassToolbar(
                ayahRef: widget.ayahRef,
                isHighlighted: widget.isHighlighted,
                onToggleHighlight: widget.onToggleHighlight,
                onClearHighlight: widget.onClearHighlight,
              ),
            ),
          ),
          Positioned(
            top: cardY,
            bottom: cardBottom,
            left: 20,
            right: 20,
            child: Center(
              child: _GlassCard(key: _cardKey, ayahRef: widget.ayahRef),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  const _GlassContainer({
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2C2821).withValues(alpha: 0.75)
                : const Color(0xFFF7F4EB).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassToolbar extends ConsumerWidget {
  const _GlassToolbar({
    required this.ayahRef,
    required this.isHighlighted,
    required this.onToggleHighlight,
    required this.onClearHighlight,
  });

  final AyahRef ayahRef;
  final bool isHighlighted;
  final VoidCallback onToggleHighlight;
  final VoidCallback onClearHighlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon700;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: _GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlayAction(context, ref, iconColor),
            _buildIconBtn(context, 'نسخ', Icons.copy_rounded, iconColor, () {
              Navigator.pop(context);
              // Implement copy
            }),
            _buildIconBtn(
              context,
              'ترجمة',
              Icons.g_translate_rounded,
              iconColor,
              () {
                Navigator.pop(context);
                showTranslationBottomSheet(context: context, ayahRef: ayahRef);
              },
            ),
            _buildIconBtn(
              context,
              'حفظ',
              Icons.bookmark_border_rounded,
              iconColor,
              () async {
                await ref
                    .read(quranBookmarkServiceProvider)
                    .toggleAyahBookmark(ayahRef: ayahRef);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            _buildIconBtn(
              context,
              'مشاركة',
              Icons.share_rounded,
              iconColor,
              () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayAction(
    BuildContext context,
    WidgetRef ref,
    Color iconColor,
  ) {
    final recitationsAsync = ref.watch(quranRecitationsProvider);
    final selectedRecitation = ref.watch(selectedQuranRecitationProvider);
    final audioState = ref.watch(quranAudioControllerProvider);

    return recitationsAsync.when(
      loading: () => _buildIconBtn(
        context,
        'تشغيل',
        Icons.play_arrow_rounded,
        iconColor,
        null,
      ),
      error: (e, s) => _buildIconBtn(
        context,
        'تشغيل',
        Icons.play_arrow_rounded,
        iconColor,
        null,
      ),
      data: (recitations) {
        if (recitations.isEmpty) {
          return _buildIconBtn(
            context,
            'تشغيل',
            Icons.play_arrow_rounded,
            iconColor,
            null,
          );
        }

        QuranRecitation activeRecitation = recitations.first;
        if (selectedRecitation != null) {
          for (final r in recitations) {
            if (r.id == selectedRecitation.id) {
              activeRecitation = r;
              break;
            }
          }
        }

        final isCurrent = audioState.isCurrent(
          ayahRef: ayahRef,
          recitationId: activeRecitation.id,
        );
        final isLoading = isCurrent && audioState.isLoading;
        final isPlaying = isCurrent && audioState.isPlaying;

        if (isLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor,
              ),
            ),
          );
        } else if (isPlaying) {
          return _buildIconBtn(
            context,
            'إيقاف',
            Icons.pause_rounded,
            iconColor,
            () {
              Navigator.pop(context);
              ref
                  .read(quranAudioControllerProvider.notifier)
                  .playOrToggleAyah(
                    ayahRef: ayahRef,
                    recitationId: activeRecitation.id,
                  );
            },
          );
        } else {
          return _buildIconBtn(
            context,
            'تشغيل',
            Icons.play_arrow_rounded,
            iconColor,
            () {
              Navigator.pop(context);
              ref
                  .read(quranAudioControllerProvider.notifier)
                  .playOrToggleAyah(
                    ayahRef: ayahRef,
                    recitationId: activeRecitation.id,
                  );
            },
          );
        }
      },
    );
  }

  Widget _buildIconBtn(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassCard extends ConsumerWidget {
  const _GlassCard({super.key, required this.ayahRef});

  final AyahRef ayahRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon700;

    final surahName = getSurahNameArabic(ayahRef.surah);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: _GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with close button
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FlutterIslamicIcons.quran2, color: primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'سورة $surahName - الآية ${ayahRef.ayah}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                        fontFamily: 'DiwaniBent',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: primaryColor, size: 20),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _buildCardOption(
                  context,
                  'التفاسير',
                  FlutterIslamicIcons.quran,
                  primaryColor,
                  () {
                    showTafsirBottomSheet(
                      context: context,
                      chapterNumber: ayahRef.surah,
                      ayahNumber: ayahRef.ayah,
                    );
                  },
                ),
                _buildCardOption(
                  context,
                  'معاني الكلمات',
                  Icons.menu_book_rounded,
                  primaryColor,
                  () {},
                ),
                _buildCardOption(
                  context,
                  'أسباب النزول',
                  FlutterIslamicIcons.solidLantern,
                  primaryColor,
                  () {},
                ),
                _buildCardOption(
                  context,
                  'الإعراب',
                  Icons.text_snippet_rounded,
                  primaryColor,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
