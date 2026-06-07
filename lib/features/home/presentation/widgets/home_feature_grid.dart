import 'dart:math' as math;

import 'package:al_mubeen/features/home/presentation/widgets/home_feature.dart';
import 'package:al_mubeen/features/home/presentation/widgets/home_feature_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

class HomeFeatureGrid extends StatelessWidget {
  const HomeFeatureGrid({super.key});

  static const List<HomeFeature> _features = [
    HomeFeature(
      title: 'الأذكار',
      icon: FlutterIslamicIcons.tasbih,
      action: HomeFeatureAction.openAdhkarGrid,
    ),
    HomeFeature(
      title: 'قراءة القرآن الكريم',
      icon: FlutterIslamicIcons.quran2,
      action: HomeFeatureAction.openSurahPicker,
    ),
    HomeFeature(
      title: 'استماع القرآن',
      icon: Icons.headphones_outlined,
      action: HomeFeatureAction.openQuranAudioDownload,
    ),
    HomeFeature(
      title: 'أدعية\nآمل أن يستجيب الله',
      icon: Icons.volunteer_activism_outlined,
    ),
    HomeFeature(title: 'منبه المهام اليومية', icon: Icons.alarm_rounded),
    HomeFeature(title: 'أسماء الله الحسنى', icon: FlutterIslamicIcons.allah99),
    HomeFeature(title: 'الأربعون النووية', icon: Icons.menu_book_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final spacing = width < 390 ? 12.0 : 16.0;
        final cardWidth = width < 620
            ? math.max(0.0, (width - spacing) / 2)
            : math.min(220.0, math.max(0.0, (width - spacing * 2) / 4));
        final minExtentForText = 102.0 + (math.max(textScale, 1) - 1) * 42;
        final cardHeight = math.max(cardWidth / 1.5, minExtentForText);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: [
            for (final feature in _features)
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: HomeFeatureCard(feature: feature),
              ),
          ],
        );
      },
    );
  }
}
