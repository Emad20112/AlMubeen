import 'package:al_mubeen/features/hadith_nawawi/data/hadith_nawawi_local_data_source.dart';
import 'package:al_mubeen/features/hadith_nawawi/domain/models/hadith_nawawi_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hadithNawawiLocalDataSourceProvider =
    Provider<HadithNawawiLocalDataSource>((ref) {
  return HadithNawawiLocalDataSource();
});

final hadithNawawiEntriesProvider =
    FutureProvider<List<HadithNawawiEntry>>((ref) async {
  final dataSource = ref.watch(hadithNawawiLocalDataSourceProvider);
  return dataSource.getEntries();
});
