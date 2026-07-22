import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';

const int defaultTafsirResourceId = 16;
const String defaultTafsirAssetPath = 'assets/data/ar_muyassar.json';

const Tafsir defaultBuiltInTafsir = Tafsir(
  id: defaultTafsirResourceId,
  name: 'تفسير الميسر',
  slug: 'ar-tafsir-muyassar',
  resourceName: 'تفسير الميسر',
);
