import 'package:al_mubeen/core/data/json_map.dart';
import 'package:al_mubeen/features/quran/data/models/quran_verse_dto.dart';
import 'package:al_mubeen/features/quran/domain/repositories/quran_repository.dart';
import 'package:flutter/foundation.dart';

@immutable
final class QuranPaginationDto {
  const QuranPaginationDto({
    required this.currentPage,
    required this.perPage,
    this.nextPage,
    this.totalPages,
    this.totalRecords,
  });

  factory QuranPaginationDto.fromJson(JsonMap json) {
    return QuranPaginationDto(
      currentPage: _intValue(json['current_page']) ?? 1,
      perPage: _intValue(json['per_page']) ?? 50,
      nextPage: _intValue(json['next_page']),
      totalPages: _intValue(json['total_pages']),
      totalRecords: _intValue(json['total_records']),
    );
  }

  final int currentPage;
  final int perPage;
  final int? nextPage;
  final int? totalPages;
  final int? totalRecords;

  QuranPagination toDomain() {
    return QuranPagination(
      currentPage: currentPage,
      perPage: perPage,
      nextPage: nextPage,
      totalPages: totalPages,
      totalRecords: totalRecords,
    );
  }

  static int? _intValue(Object? value) {
    return switch (value) {
      int() => value,
      num() => value.toInt(),
      String() => int.tryParse(value),
      _ => null,
    };
  }
}

@immutable
final class QuranVersesPageDto {
  const QuranVersesPageDto({required this.verses, this.pagination});

  final List<QuranVerseDto> verses;
  final QuranPaginationDto? pagination;

  QuranVersesPage toDomain() {
    return QuranVersesPage(
      verses: verses.map((verse) => verse.toDomain()).toList(growable: false),
      pagination: pagination?.toDomain(),
    );
  }
}
