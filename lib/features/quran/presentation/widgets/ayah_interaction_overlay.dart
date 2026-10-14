import 'dart:ui';

import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/preferences/app_user_preferences.dart';
import 'package:al_mubeen/features/quran/application/quran_audio_controller.dart';
import 'package:al_mubeen/features/quran/data/quran_providers.dart';
import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/translation_bottom_sheet.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/tafsir_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qcf_quran/qcf_quran.dart';

import 'package:flutter/services.dart';

void showAyahOverlay({
  required BuildContext context,
  required AyahRef ayahRef,
  required Offset globalPosition,
  required bool isHighlighted,
  required VoidCallback onToggleHighlight,
  required VoidCallback onClearHighlight,
  VoidCallback? onPlayRequested,
}) {
  HapticFeedback.mediumImpact();
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.12),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, animation, secondaryAnimation) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.97, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: FadeTransition(
          opacity: animation,
          child: _AyahOverlayWidget(
            ayahRef: ayahRef,
            globalPosition: globalPosition,
            isHighlighted: isHighlighted,
            onToggleHighlight: onToggleHighlight,
            onClearHighlight: onClearHighlight,
            onPlayRequested: onPlayRequested,
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
    this.onPlayRequested,
  });

  final AyahRef ayahRef;
  final Offset globalPosition;
  final bool isHighlighted;
  final VoidCallback onToggleHighlight;
  final VoidCallback onClearHighlight;
  final VoidCallback? onPlayRequested;

  @override
  ConsumerState<_AyahOverlayWidget> createState() => _AyahOverlayWidgetState();
}

class _AyahOverlayWidgetState extends ConsumerState<_AyahOverlayWidget> {
  final GlobalKey _cardKey = GlobalKey();
  double _cardHeight = 148.0;

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

    final isTopHalf = dy < size.height / 2;

    double toolbarY;
    double? cardY;
    double? cardBottom;

    const toolbarHeight = 68.0;

    if (isTopHalf) {
      toolbarY = dy - toolbarHeight - 14;
      if (toolbarY < padding.top + 8) {
        toolbarY = padding.top + 8;
      }
      cardY = dy + 22;
      if (cardY + _cardHeight > size.height - padding.bottom - 8) {
        cardY = size.height - padding.bottom - _cardHeight - 8;
      }
    } else {
      toolbarY = dy + 14;
      if (toolbarY + toolbarHeight > size.height - padding.bottom - 8) {
        toolbarY = size.height - padding.bottom - toolbarHeight - 8;
      }
      cardBottom = size.height - dy + 16;
      if (size.height - cardBottom - _cardHeight < padding.top + 8) {
        cardBottom = size.height - (padding.top + 8 + _cardHeight);
      }
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            top: toolbarY,
            left: 16,
            right: 16,
            child: Center(
              child: _GlassToolbar(
                ayahRef: widget.ayahRef,
                isHighlighted: widget.isHighlighted,
                onToggleHighlight: widget.onToggleHighlight,
                onClearHighlight: widget.onClearHighlight,
                onPlayRequested: widget.onPlayRequested,
              ),
            ),
          ),
          Positioned(
            top: cardY,
            bottom: cardBottom,
            left: 16,
            right: 16,
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
    this.borderRadius = 18,
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
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 6),
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
    this.onPlayRequested,
  });

  final AyahRef ayahRef;
  final bool isHighlighted;
  final VoidCallback onToggleHighlight;
  final VoidCallback onClearHighlight;
  final VoidCallback? onPlayRequested;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFFD8B457) : AppColors.maroon700;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 330),
      child: _GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        borderRadius: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildPlayAction(context, ref, iconColor),
            _buildActionButton(
              context,
              label: 'نسخ',
              color: iconColor,
              icon: Icon(Icons.copy_rounded, color: iconColor, size: 18),
              onTap: () => Navigator.pop(context),
            ),
            _buildActionButton(
              context,
              label: 'ترجمة',
              color: iconColor,
              icon: Icon(Icons.g_translate_rounded, color: iconColor, size: 18),
              onTap: () {
                Navigator.pop(context);
                showTranslationBottomSheet(context: context, ayahRef: ayahRef);
              },
            ),
            _buildActionButton(
              context,
              label: 'حفظ',
              color: iconColor,
              icon: Icon(
                isHighlighted
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: iconColor,
                size: 18,
              ),
              onTap: () async {
                await ref
                    .read(quranBookmarkServiceProvider)
                    .toggleAyahBookmark(ayahRef: ayahRef);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            _buildActionButton(
              context,
              label: 'مشاركة',
              color: iconColor,
              icon: Icon(Icons.share_rounded, color: iconColor, size: 18),
              onTap: () => Navigator.pop(context),
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
    final preferencesAsync = ref.watch(appUserPreferencesProvider);
    final preferredReciterId = preferencesAsync.maybeWhen(
      data: (p) => p.preferredReciterId,
      orElse: () => null,
    );
    final audioState = ref.watch(quranAudioControllerProvider);

    return recitationsAsync.when(
      loading: () => _buildActionButton(
        context,
        label: 'تشغيل',
        color: iconColor,
        icon: Icon(Icons.play_arrow_rounded, color: iconColor, size: 18),
        onTap: null,
      ),
      error: (e, s) => _buildActionButton(
        context,
        label: 'تشغيل',
        color: iconColor,
        icon: Icon(Icons.play_arrow_rounded, color: iconColor, size: 18),
        onTap: null,
      ),
      data: (recitations) {
        if (recitations.isEmpty) {
          return _buildActionButton(
            context,
            label: 'تشغيل',
            color: iconColor,
            icon: Icon(Icons.play_arrow_rounded, color: iconColor, size: 18),
            onTap: null,
          );
        }

        QuranRecitation activeRecitation = recitations.first;
        final targetId = selectedRecitation?.id ?? preferredReciterId;
        if (targetId != null) {
          for (final r in recitations) {
            if (r.id == targetId) {
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
          return _buildActionButton(
            context,
            label: 'تحميل',
            color: iconColor,
            icon: Icon(Icons.play_arrow_rounded, color: iconColor, size: 18),
            onTap: null,
          );
        }

        return _buildActionButton(
          context,
          label: isPlaying ? 'إيقاف' : 'تشغيل',
          color: iconColor,
          icon: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: iconColor,
            size: 18,
          ),
          onTap: () {
            Navigator.pop(context);
            onPlayRequested?.call();
            ref
                .read(quranAudioControllerProvider.notifier)
                .playOrToggleAyah(
                  ayahRef: ayahRef,
                  recitationId: activeRecitation.id,
                );
          },
        );
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required Color color,
    required Widget icon,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      width: 52,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
    final secondaryColor = isDark
        ? AppColors.parchmentMuted
        : AppColors.maroon700.withValues(alpha: 0.78);
    final surahName = getSurahNameArabic(ayahRef.surah);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: _GlassContainer(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سورة $surahName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الآية ${ayahRef.ayah}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: secondaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: primaryColor,
                      size: 16,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : color.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
