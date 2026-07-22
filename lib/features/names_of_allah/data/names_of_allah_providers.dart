import 'package:al_mubeen/features/names_of_allah/data/names_of_allah_local_data_source.dart';
import 'package:al_mubeen/features/names_of_allah/domain/models/allah_name_entry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final namesOfAllahLocalDataSourceProvider =
    Provider<NamesOfAllahLocalDataSource>((ref) {
  return NamesOfAllahLocalDataSource();
});

final namesOfAllahEntriesProvider =
    FutureProvider<List<AllahNameEntry>>((ref) async {
  final dataSource = ref.watch(namesOfAllahLocalDataSourceProvider);
  return dataSource.getEntries();
});
