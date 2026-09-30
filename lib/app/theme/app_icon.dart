import 'package:flutter/material.dart';

/// سُلّم الأيقونات وأحجامها (Design Token: Iconography).
///
/// التطبيق كان يمرّر `size: 20` و `22` و `24` و `28` و `32` و `44` مباشرة في
/// عشرات المواضع. هذا الملف يجعل الحجم قرارًا دلاليًا بدل رقمًا متكررًا،
/// ويجمع أسماء الأيقونات المتكرّرة في مكان واحد حتى لا تنتشر
/// `Icons.error_outline` في 12 ملفًا.
abstract final class AppIcon {
  const AppIcon._();

  // ---------------------------------------------------------------------------
  // السُلّم العددي
  // ---------------------------------------------------------------------------

  /// 16 — أيقونة مدمجة داخل نص أو زر صغير.
  static const double sm = 16;

  /// 20 — الأيقونة الافتراضية داخل القوائم والبنود.
  static const double md = 20;

  /// 24 — الأيقونات التفاعلية: أزرار وحقول.
  static const double lg = 24;

  /// 28 — العناوين والوسوم وأشرطة التطبيق.
  static const double xl = 28;

  /// 40 — الحالات الفارغة والأخطاء.
  static const double xxl = 40;

  /// 64 — الأيقونة البطلية في شاشة الخطأ/التحميل.
  static const double huge = 64;

  // ---------------------------------------------------------------------------
  // أسماء الأيقونات المتكرّرة
  // ---------------------------------------------------------------------------

  static const IconData empty = Icons.inbox_outlined;
  static const IconData error = Icons.error_outline;
  static const IconData offline = Icons.cloud_off_outlined;
  static const IconData info = Icons.info_outline;
  static const IconData refresh = Icons.refresh;
  static const IconData search = Icons.search;
  static const IconData settings = Icons.settings_outlined;
  static const IconData favorite = Icons.favorite_border;
  static const IconData favoriteFilled = Icons.favorite;
  static const IconData share = Icons.share_outlined;
  static const IconData play = Icons.play_arrow_rounded;
  static const IconData pause = Icons.pause_rounded;
  static const IconData book = Icons.auto_stories_outlined;
  static const IconData chevronForward = Icons.arrow_back_rounded;
  static const IconData chevronEnd = Icons.arrow_forward_rounded;
  static const IconData close = Icons.close;
  static const IconData download = Icons.download_outlined;
  static const IconData check = Icons.check_circle_outline;
  static const IconData warning = Icons.warning_amber_rounded;
}
