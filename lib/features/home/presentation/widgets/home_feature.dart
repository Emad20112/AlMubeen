import 'package:flutter/material.dart';

class HomeFeature {
  const HomeFeature({
    required this.title,
    required this.icon,
    this.action,
    this.isImportant = false,
  });

  final String title;
  final IconData icon;
  final HomeFeatureAction? action;
  final bool isImportant;
}

enum HomeFeatureAction { openQuranReader, openAdhkarGrid, openQuranAudioDownload, openQuranSurahPlayer }
