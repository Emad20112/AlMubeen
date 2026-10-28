import 'package:al_mubeen/features/quran/domain/ayah_ref.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:al_mubeen/features/quran/presentation/widgets/reciters/reciter_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:al_mubeen/features/quran/presentation/widgets/reciters/reciter_picker_sheet.dart';
export 'package:al_mubeen/features/quran/presentation/widgets/reciters/reciter_picker_tile.dart';
export 'package:al_mubeen/features/quran/presentation/widgets/reciters/reciter_sections.dart';

/// يعرض نافذة اختيار القارئ لمشغل السور (Surah Player).
Future<void> showReciterPickerForSurahPlayer({
  required BuildContext context,
  required QuranRecitation? activeRecitation,
  required ValueChanged<QuranRecitation> onChanged,
}) {
  return showAdaptiveReciterPicker(
    context: context,
    activeRecitation: activeRecitation,
    forSurahPlayer: true,
    onSurahPlayerChanged: onChanged,
  );
}

/// يعرض نافذة اختيار القارئ لتلاوة الآيات الكريمة مع التبديل السلس.
Future<void> showReciterPickerSheet({
  required BuildContext context,
  required AyahRef currentAyah,
  required int? currentRecitationId,
  bool playOnSelect = false,
}) {
  return showAdaptiveReciterPicker(
    context: context,
    currentAyah: currentAyah,
    currentRecitationId: currentRecitationId,
    playOnSelect: playOnSelect,
    forSurahPlayer: false,
  );
}

/// ودجت القراء القديمة المتوافقة مع الكود السابق (تستخدم المحتوى الموحد داخلياً).
class QuranRecitersListView extends ConsumerWidget {
  const QuranRecitersListView({
    super.key,
    required this.currentAyah,
    required this.recitationId,
  });

  final AyahRef currentAyah;
  final int? recitationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReciterPickerContent(
      currentAyah: currentAyah,
      currentRecitationId: recitationId,
      forSurahPlayer: false,
      showDragHandle: false,
    );
  }
}
