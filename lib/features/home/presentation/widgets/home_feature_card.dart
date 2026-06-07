import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:al_mubeen/core/widgets/auto_scroll_text.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_feature.dart';
import 'package:al_mubeen/features/quran/presentation/pages/quran_audio_download_screen.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/surah_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({required this.feature, super.key});

  final HomeFeature feature;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);

    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            if (feature.action == HomeFeatureAction.openSurahPicker) {
              openSurahPickerAndReader(context);
              return;
            }

            if (feature.action == HomeFeatureAction.openAdhkarGrid) {
              context.push('/adhkar');
              return;
            }

            if (feature.action == HomeFeatureAction.openQuranAudioDownload) {
              context.push(QuranAudioDownloadScreen.routePath);
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'هذه الميزة ستضاف في مرحلة لاحقة.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  textAlign: TextAlign.right,
                ),
              ),
            );
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppColors.parchmentLight,
                  Color(0xFFF2EDDF),
                  AppColors.parchmentMuted,
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.maroon700.withValues(
                  alpha: feature.isImportant ? 0.92 : 0.72,
                ),
                width: feature.isImportant ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.maroon900.withValues(
                    alpha: feature.isImportant ? 0.34 : 0.28,
                  ),
                  blurRadius: feature.isImportant ? 14 : 8,
                  offset: Offset(0, feature.isImportant ? 7 : 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 7,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.maroon800.withValues(alpha: 0.92),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(6),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Icon(
                            feature.icon,
                            color: AppColors.maroon800,
                            size: textScaler
                                .scale(feature.isImportant ? 44 : 34)
                                .clamp(
                                  feature.isImportant ? 38 : 30,
                                  feature.isImportant ? 58 : 46,
                                )
                                .toDouble(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Flexible(
                          child: Center(
                            child: AutoScrollText(
                              text: feature.title,
                              maxLines: 2,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.maroon700,
                                fontFamily: 'DiwaniBent',
                                fontSize: feature.isImportant ? 30 : 24,
                                height: 1.05,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
