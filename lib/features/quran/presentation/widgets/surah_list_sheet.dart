import 'package:al_mubeen/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

/// A bottom sheet that displays a searchable list of all 114 surahs.
/// Returns the selected surah number when tapped.
class SurahListSheet extends StatefulWidget {
  const SurahListSheet({this.currentSurah = 1, super.key});

  final int currentSurah;

  @override
  State<SurahListSheet> createState() => _SurahListSheetState();
}

class _SurahListSheetState extends State<SurahListSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor =
        isDark ? const Color(0xFFD8B457) : AppColors.maroon800;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.parchmentLight;
    final titleColor =
        isDark ? AppColors.parchmentLight : AppColors.maroon800;
    final mutedColor =
        isDark ? AppColors.parchmentMuted : AppColors.maroon700;

    final allSurahs = List.generate(totalSurahCount, (i) => i + 1);
    final filteredSurahs = _query.isEmpty
        ? allSurahs
        : allSurahs.where((surah) {
            final name = getSurahNameArabic(surah).toLowerCase();
            final englishName = getSurahName(surah).toLowerCase();
            final q = _query.toLowerCase();
            return name.contains(q) ||
                englishName.contains(q) ||
                surah.toString().contains(q);
          }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.queue_music_rounded,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'اختر سورة',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: titleColor,
                              ),
                            ),
                            Text(
                              '${_toArabicNum(totalSurahCount)} سورة',
                              style: TextStyle(
                                fontSize: 13,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                // Search
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _query = val),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن سورة...',
                      hintStyle: TextStyle(color: mutedColor),
                      prefixIcon: Icon(Icons.search, color: mutedColor),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: Icon(Icons.clear, color: mutedColor),
                            )
                          : null,
                      filled: true,
                      fillColor: accentColor.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Surah list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = filteredSurahs[index];
                      final isSelected = surah == widget.currentSurah;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context, surah),
                            borderRadius: BorderRadius.circular(16),
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accentColor.withValues(
                                        alpha: isDark ? 0.15 : 0.08,
                                      )
                                    : accentColor.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? accentColor.withValues(alpha: 0.3)
                                      : accentColor.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Number badge
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accentColor
                                          .withValues(alpha: 0.1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _toArabicNum(surah),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: accentColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Names
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'سورة ${getSurahNameArabic(surah)}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: titleColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${getSurahName(surah)}  •  ${_toArabicNum(getVerseCount(surah))} آيات',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: mutedColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.equalizer_rounded,
                                      color: accentColor,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _toArabicNum(int number) {
  const digits = {
    '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
    '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩',
  };
  return number
      .toString()
      .split('')
      .map((d) => digits[d] ?? d)
      .join();
}
