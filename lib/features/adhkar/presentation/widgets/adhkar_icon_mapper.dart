import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

abstract final class AdhkarIconMapper {
  static IconData iconFor(String key) {
    return switch (key) {
      'sun' => Icons.wb_sunny_outlined,
      'moon' => FlutterIslamicIcons.crescentMoon,
      'sleep' => Icons.bedtime_outlined,
      'mosque' => FlutterIslamicIcons.mosque,
      'alarm' => Icons.alarm_outlined,
      'door' => Icons.door_front_door_outlined,
      'home_exit' => Icons.sensor_door_outlined,
      'dua' => FlutterIslamicIcons.prayer,
      'tasbih' => FlutterIslamicIcons.tasbih,
      'quran' => FlutterIslamicIcons.quran2,
      _ => FlutterIslamicIcons.tawhid,
    };
  }
}
