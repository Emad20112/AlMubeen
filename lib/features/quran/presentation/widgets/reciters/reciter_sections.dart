import 'package:al_mubeen/app/theme/app_design_tokens.dart';
import 'package:al_mubeen/app/theme/app_spacing.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_reciter_repository.dart';
import 'package:flutter/material.dart';

/// تعريفات أقسام وتصنيفات القراء الثابتة.
const List<(String key, String title, String subtitle)> kReciterSectionDefs = [
  (
    'قراء الحرمين الشريفين',
    'قراء الحرمين الشريفين',
    'أئمة وقراء المسجد الحرام والمسجد النبوي الشريف',
  ),
  (
    'تلاوات التراويح والصلوات',
    'تلاوات التراويح والصلوات',
    'تسجيلات خاشعة ومميزة من صلوات التراويح والقيام',
  ),
  (
    'قراء للتعلم والتجويد',
    'قراء للتعلم والتجويد',
    'تلاوات ومصحف معلم للتعليم والترتيل والتجويد',
  ),
  (
    'قراء خدمة Quran.com',
    'قراء خدمة Quran.com',
    'المكتبة الصوتية الشاملة من شبكة Quran.com',
  ),
  (
    'قراء خدمة Islamic.app',
    'قراء خدمة Islamic.app',
    'مكتبة صوتية عالية الجودة من منصة Islamic.app',
  ),
];

@immutable
final class ReciterSectionItem {
  const ReciterSectionItem({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
}

/// تجميع القراء حسب التصنيف وإدراج ترويسة [ReciterSectionItem] قبل كل مجموعة.
List<Object> groupAndBuildReciterItems(List<QuranRecitation> reciters) {
  final Map<String, List<QuranRecitation>> grouped = {};
  for (final r in reciters) {
    final cat = r.category ?? 'قراء خدمة Quran.com';
    grouped.putIfAbsent(cat, () => []).add(r);
  }

  final List<Object> result = [];
  for (final (key, title, subtitle) in kReciterSectionDefs) {
    final list = grouped[key];
    if (list == null || list.isEmpty) continue;
    result.add(ReciterSectionItem(title: title, subtitle: subtitle));
    result.addAll(list);
  }

  final knownKeys = kReciterSectionDefs.map((d) => d.$1).toSet();
  for (final entry in grouped.entries) {
    if (!knownKeys.contains(entry.key)) {
      result.add(ReciterSectionItem(title: entry.key, subtitle: ''));
      result.addAll(entry.value);
    }
  }

  return result;
}

/// ودجت ترويسة قسم القراء.
class ReciterSectionHeader extends StatelessWidget {
  const ReciterSectionHeader({super.key, required this.header});

  final ReciterSectionItem header;

  @override
  Widget build(BuildContext context) {
    final colors = context.semanticColors;
    final titleColor = colors.accent;
    final subtitleColor = colors.textSecondary;
    final dividerColor = colors.border;

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10, left: 6, right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: colors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  header.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          if (header.subtitle.isNotEmpty) ...[
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(right: 11),
              child: Text(
                header.subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                  height: 1.3,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, thickness: 1, color: dividerColor),
        ],
      ),
    );
  }
}


/// تصفية القراء بحسب نص البحث.
List<QuranRecitation> filterRecitationsList(
  List<QuranRecitation> recitations,
  String rawQuery,
) {
  final q = rawQuery.trim().toLowerCase();
  if (q.isEmpty) return recitations;
  return recitations.where((r) {
    return [
      r.reciterName,
      r.translatedName,
      r.style,
      r.languageName,
      r.category,
    ].any((v) => v != null && v.toLowerCase().contains(q));
  }).toList();
}
