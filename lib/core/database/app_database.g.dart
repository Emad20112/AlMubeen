// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QuranChapterCacheTable extends QuranChapterCache
    with TableInfo<$QuranChapterCacheTable, QuranChapterCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranChapterCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameArabicMeta = const VerificationMeta(
    'nameArabic',
  );
  @override
  late final GeneratedColumn<String> nameArabic = GeneratedColumn<String>(
    'name_arabic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameSimpleMeta = const VerificationMeta(
    'nameSimple',
  );
  @override
  late final GeneratedColumn<String> nameSimple = GeneratedColumn<String>(
    'name_simple',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameComplexMeta = const VerificationMeta(
    'nameComplex',
  );
  @override
  late final GeneratedColumn<String> nameComplex = GeneratedColumn<String>(
    'name_complex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versesCountMeta = const VerificationMeta(
    'versesCount',
  );
  @override
  late final GeneratedColumn<int> versesCount = GeneratedColumn<int>(
    'verses_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagesJsonMeta = const VerificationMeta(
    'pagesJson',
  );
  @override
  late final GeneratedColumn<String> pagesJson = GeneratedColumn<String>(
    'pages_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revelationPlaceMeta = const VerificationMeta(
    'revelationPlace',
  );
  @override
  late final GeneratedColumn<String> revelationPlace = GeneratedColumn<String>(
    'revelation_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revelationOrderMeta = const VerificationMeta(
    'revelationOrder',
  );
  @override
  late final GeneratedColumn<int> revelationOrder = GeneratedColumn<int>(
    'revelation_order',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bismillahPreMeta = const VerificationMeta(
    'bismillahPre',
  );
  @override
  late final GeneratedColumn<bool> bismillahPre = GeneratedColumn<bool>(
    'bismillah_pre',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("bismillah_pre" IN (0, 1))',
    ),
  );
  static const VerificationMeta _translatedNameMeta = const VerificationMeta(
    'translatedName',
  );
  @override
  late final GeneratedColumn<String> translatedName = GeneratedColumn<String>(
    'translated_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    nameArabic,
    nameSimple,
    nameComplex,
    versesCount,
    pagesJson,
    revelationPlace,
    revelationOrder,
    bismillahPre,
    translatedName,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_chapter_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranChapterCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    }
    if (data.containsKey('name_arabic')) {
      context.handle(
        _nameArabicMeta,
        nameArabic.isAcceptableOrUnknown(data['name_arabic']!, _nameArabicMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArabicMeta);
    }
    if (data.containsKey('name_simple')) {
      context.handle(
        _nameSimpleMeta,
        nameSimple.isAcceptableOrUnknown(data['name_simple']!, _nameSimpleMeta),
      );
    } else if (isInserting) {
      context.missing(_nameSimpleMeta);
    }
    if (data.containsKey('name_complex')) {
      context.handle(
        _nameComplexMeta,
        nameComplex.isAcceptableOrUnknown(
          data['name_complex']!,
          _nameComplexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameComplexMeta);
    }
    if (data.containsKey('verses_count')) {
      context.handle(
        _versesCountMeta,
        versesCount.isAcceptableOrUnknown(
          data['verses_count']!,
          _versesCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versesCountMeta);
    }
    if (data.containsKey('pages_json')) {
      context.handle(
        _pagesJsonMeta,
        pagesJson.isAcceptableOrUnknown(data['pages_json']!, _pagesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_pagesJsonMeta);
    }
    if (data.containsKey('revelation_place')) {
      context.handle(
        _revelationPlaceMeta,
        revelationPlace.isAcceptableOrUnknown(
          data['revelation_place']!,
          _revelationPlaceMeta,
        ),
      );
    }
    if (data.containsKey('revelation_order')) {
      context.handle(
        _revelationOrderMeta,
        revelationOrder.isAcceptableOrUnknown(
          data['revelation_order']!,
          _revelationOrderMeta,
        ),
      );
    }
    if (data.containsKey('bismillah_pre')) {
      context.handle(
        _bismillahPreMeta,
        bismillahPre.isAcceptableOrUnknown(
          data['bismillah_pre']!,
          _bismillahPreMeta,
        ),
      );
    }
    if (data.containsKey('translated_name')) {
      context.handle(
        _translatedNameMeta,
        translatedName.isAcceptableOrUnknown(
          data['translated_name']!,
          _translatedNameMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  QuranChapterCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranChapterCacheEntry(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      nameArabic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_arabic'],
      )!,
      nameSimple: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_simple'],
      )!,
      nameComplex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_complex'],
      )!,
      versesCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verses_count'],
      )!,
      pagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pages_json'],
      )!,
      revelationPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revelation_place'],
      ),
      revelationOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revelation_order'],
      ),
      bismillahPre: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}bismillah_pre'],
      ),
      translatedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_name'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuranChapterCacheTable createAlias(String alias) {
    return $QuranChapterCacheTable(attachedDatabase, alias);
  }
}

class QuranChapterCacheEntry extends DataClass
    implements Insertable<QuranChapterCacheEntry> {
  final int chapterId;
  final String nameArabic;
  final String nameSimple;
  final String nameComplex;
  final int versesCount;
  final String pagesJson;
  final String? revelationPlace;
  final int? revelationOrder;
  final bool? bismillahPre;
  final String? translatedName;
  final DateTime updatedAt;
  const QuranChapterCacheEntry({
    required this.chapterId,
    required this.nameArabic,
    required this.nameSimple,
    required this.nameComplex,
    required this.versesCount,
    required this.pagesJson,
    this.revelationPlace,
    this.revelationOrder,
    this.bismillahPre,
    this.translatedName,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<int>(chapterId);
    map['name_arabic'] = Variable<String>(nameArabic);
    map['name_simple'] = Variable<String>(nameSimple);
    map['name_complex'] = Variable<String>(nameComplex);
    map['verses_count'] = Variable<int>(versesCount);
    map['pages_json'] = Variable<String>(pagesJson);
    if (!nullToAbsent || revelationPlace != null) {
      map['revelation_place'] = Variable<String>(revelationPlace);
    }
    if (!nullToAbsent || revelationOrder != null) {
      map['revelation_order'] = Variable<int>(revelationOrder);
    }
    if (!nullToAbsent || bismillahPre != null) {
      map['bismillah_pre'] = Variable<bool>(bismillahPre);
    }
    if (!nullToAbsent || translatedName != null) {
      map['translated_name'] = Variable<String>(translatedName);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuranChapterCacheCompanion toCompanion(bool nullToAbsent) {
    return QuranChapterCacheCompanion(
      chapterId: Value(chapterId),
      nameArabic: Value(nameArabic),
      nameSimple: Value(nameSimple),
      nameComplex: Value(nameComplex),
      versesCount: Value(versesCount),
      pagesJson: Value(pagesJson),
      revelationPlace: revelationPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(revelationPlace),
      revelationOrder: revelationOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(revelationOrder),
      bismillahPre: bismillahPre == null && nullToAbsent
          ? const Value.absent()
          : Value(bismillahPre),
      translatedName: translatedName == null && nullToAbsent
          ? const Value.absent()
          : Value(translatedName),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuranChapterCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranChapterCacheEntry(
      chapterId: serializer.fromJson<int>(json['chapterId']),
      nameArabic: serializer.fromJson<String>(json['nameArabic']),
      nameSimple: serializer.fromJson<String>(json['nameSimple']),
      nameComplex: serializer.fromJson<String>(json['nameComplex']),
      versesCount: serializer.fromJson<int>(json['versesCount']),
      pagesJson: serializer.fromJson<String>(json['pagesJson']),
      revelationPlace: serializer.fromJson<String?>(json['revelationPlace']),
      revelationOrder: serializer.fromJson<int?>(json['revelationOrder']),
      bismillahPre: serializer.fromJson<bool?>(json['bismillahPre']),
      translatedName: serializer.fromJson<String?>(json['translatedName']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<int>(chapterId),
      'nameArabic': serializer.toJson<String>(nameArabic),
      'nameSimple': serializer.toJson<String>(nameSimple),
      'nameComplex': serializer.toJson<String>(nameComplex),
      'versesCount': serializer.toJson<int>(versesCount),
      'pagesJson': serializer.toJson<String>(pagesJson),
      'revelationPlace': serializer.toJson<String?>(revelationPlace),
      'revelationOrder': serializer.toJson<int?>(revelationOrder),
      'bismillahPre': serializer.toJson<bool?>(bismillahPre),
      'translatedName': serializer.toJson<String?>(translatedName),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuranChapterCacheEntry copyWith({
    int? chapterId,
    String? nameArabic,
    String? nameSimple,
    String? nameComplex,
    int? versesCount,
    String? pagesJson,
    Value<String?> revelationPlace = const Value.absent(),
    Value<int?> revelationOrder = const Value.absent(),
    Value<bool?> bismillahPre = const Value.absent(),
    Value<String?> translatedName = const Value.absent(),
    DateTime? updatedAt,
  }) => QuranChapterCacheEntry(
    chapterId: chapterId ?? this.chapterId,
    nameArabic: nameArabic ?? this.nameArabic,
    nameSimple: nameSimple ?? this.nameSimple,
    nameComplex: nameComplex ?? this.nameComplex,
    versesCount: versesCount ?? this.versesCount,
    pagesJson: pagesJson ?? this.pagesJson,
    revelationPlace: revelationPlace.present
        ? revelationPlace.value
        : this.revelationPlace,
    revelationOrder: revelationOrder.present
        ? revelationOrder.value
        : this.revelationOrder,
    bismillahPre: bismillahPre.present ? bismillahPre.value : this.bismillahPre,
    translatedName: translatedName.present
        ? translatedName.value
        : this.translatedName,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuranChapterCacheEntry copyWithCompanion(QuranChapterCacheCompanion data) {
    return QuranChapterCacheEntry(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      nameArabic: data.nameArabic.present
          ? data.nameArabic.value
          : this.nameArabic,
      nameSimple: data.nameSimple.present
          ? data.nameSimple.value
          : this.nameSimple,
      nameComplex: data.nameComplex.present
          ? data.nameComplex.value
          : this.nameComplex,
      versesCount: data.versesCount.present
          ? data.versesCount.value
          : this.versesCount,
      pagesJson: data.pagesJson.present ? data.pagesJson.value : this.pagesJson,
      revelationPlace: data.revelationPlace.present
          ? data.revelationPlace.value
          : this.revelationPlace,
      revelationOrder: data.revelationOrder.present
          ? data.revelationOrder.value
          : this.revelationOrder,
      bismillahPre: data.bismillahPre.present
          ? data.bismillahPre.value
          : this.bismillahPre,
      translatedName: data.translatedName.present
          ? data.translatedName.value
          : this.translatedName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranChapterCacheEntry(')
          ..write('chapterId: $chapterId, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameSimple: $nameSimple, ')
          ..write('nameComplex: $nameComplex, ')
          ..write('versesCount: $versesCount, ')
          ..write('pagesJson: $pagesJson, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('revelationOrder: $revelationOrder, ')
          ..write('bismillahPre: $bismillahPre, ')
          ..write('translatedName: $translatedName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chapterId,
    nameArabic,
    nameSimple,
    nameComplex,
    versesCount,
    pagesJson,
    revelationPlace,
    revelationOrder,
    bismillahPre,
    translatedName,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranChapterCacheEntry &&
          other.chapterId == this.chapterId &&
          other.nameArabic == this.nameArabic &&
          other.nameSimple == this.nameSimple &&
          other.nameComplex == this.nameComplex &&
          other.versesCount == this.versesCount &&
          other.pagesJson == this.pagesJson &&
          other.revelationPlace == this.revelationPlace &&
          other.revelationOrder == this.revelationOrder &&
          other.bismillahPre == this.bismillahPre &&
          other.translatedName == this.translatedName &&
          other.updatedAt == this.updatedAt);
}

class QuranChapterCacheCompanion
    extends UpdateCompanion<QuranChapterCacheEntry> {
  final Value<int> chapterId;
  final Value<String> nameArabic;
  final Value<String> nameSimple;
  final Value<String> nameComplex;
  final Value<int> versesCount;
  final Value<String> pagesJson;
  final Value<String?> revelationPlace;
  final Value<int?> revelationOrder;
  final Value<bool?> bismillahPre;
  final Value<String?> translatedName;
  final Value<DateTime> updatedAt;
  const QuranChapterCacheCompanion({
    this.chapterId = const Value.absent(),
    this.nameArabic = const Value.absent(),
    this.nameSimple = const Value.absent(),
    this.nameComplex = const Value.absent(),
    this.versesCount = const Value.absent(),
    this.pagesJson = const Value.absent(),
    this.revelationPlace = const Value.absent(),
    this.revelationOrder = const Value.absent(),
    this.bismillahPre = const Value.absent(),
    this.translatedName = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QuranChapterCacheCompanion.insert({
    this.chapterId = const Value.absent(),
    required String nameArabic,
    required String nameSimple,
    required String nameComplex,
    required int versesCount,
    required String pagesJson,
    this.revelationPlace = const Value.absent(),
    this.revelationOrder = const Value.absent(),
    this.bismillahPre = const Value.absent(),
    this.translatedName = const Value.absent(),
    required DateTime updatedAt,
  }) : nameArabic = Value(nameArabic),
       nameSimple = Value(nameSimple),
       nameComplex = Value(nameComplex),
       versesCount = Value(versesCount),
       pagesJson = Value(pagesJson),
       updatedAt = Value(updatedAt);
  static Insertable<QuranChapterCacheEntry> custom({
    Expression<int>? chapterId,
    Expression<String>? nameArabic,
    Expression<String>? nameSimple,
    Expression<String>? nameComplex,
    Expression<int>? versesCount,
    Expression<String>? pagesJson,
    Expression<String>? revelationPlace,
    Expression<int>? revelationOrder,
    Expression<bool>? bismillahPre,
    Expression<String>? translatedName,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (nameArabic != null) 'name_arabic': nameArabic,
      if (nameSimple != null) 'name_simple': nameSimple,
      if (nameComplex != null) 'name_complex': nameComplex,
      if (versesCount != null) 'verses_count': versesCount,
      if (pagesJson != null) 'pages_json': pagesJson,
      if (revelationPlace != null) 'revelation_place': revelationPlace,
      if (revelationOrder != null) 'revelation_order': revelationOrder,
      if (bismillahPre != null) 'bismillah_pre': bismillahPre,
      if (translatedName != null) 'translated_name': translatedName,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QuranChapterCacheCompanion copyWith({
    Value<int>? chapterId,
    Value<String>? nameArabic,
    Value<String>? nameSimple,
    Value<String>? nameComplex,
    Value<int>? versesCount,
    Value<String>? pagesJson,
    Value<String?>? revelationPlace,
    Value<int?>? revelationOrder,
    Value<bool?>? bismillahPre,
    Value<String?>? translatedName,
    Value<DateTime>? updatedAt,
  }) {
    return QuranChapterCacheCompanion(
      chapterId: chapterId ?? this.chapterId,
      nameArabic: nameArabic ?? this.nameArabic,
      nameSimple: nameSimple ?? this.nameSimple,
      nameComplex: nameComplex ?? this.nameComplex,
      versesCount: versesCount ?? this.versesCount,
      pagesJson: pagesJson ?? this.pagesJson,
      revelationPlace: revelationPlace ?? this.revelationPlace,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      bismillahPre: bismillahPre ?? this.bismillahPre,
      translatedName: translatedName ?? this.translatedName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (nameArabic.present) {
      map['name_arabic'] = Variable<String>(nameArabic.value);
    }
    if (nameSimple.present) {
      map['name_simple'] = Variable<String>(nameSimple.value);
    }
    if (nameComplex.present) {
      map['name_complex'] = Variable<String>(nameComplex.value);
    }
    if (versesCount.present) {
      map['verses_count'] = Variable<int>(versesCount.value);
    }
    if (pagesJson.present) {
      map['pages_json'] = Variable<String>(pagesJson.value);
    }
    if (revelationPlace.present) {
      map['revelation_place'] = Variable<String>(revelationPlace.value);
    }
    if (revelationOrder.present) {
      map['revelation_order'] = Variable<int>(revelationOrder.value);
    }
    if (bismillahPre.present) {
      map['bismillah_pre'] = Variable<bool>(bismillahPre.value);
    }
    if (translatedName.present) {
      map['translated_name'] = Variable<String>(translatedName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranChapterCacheCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('nameArabic: $nameArabic, ')
          ..write('nameSimple: $nameSimple, ')
          ..write('nameComplex: $nameComplex, ')
          ..write('versesCount: $versesCount, ')
          ..write('pagesJson: $pagesJson, ')
          ..write('revelationPlace: $revelationPlace, ')
          ..write('revelationOrder: $revelationOrder, ')
          ..write('bismillahPre: $bismillahPre, ')
          ..write('translatedName: $translatedName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $QuranVerseCacheTable extends QuranVerseCache
    with TableInfo<$QuranVerseCacheTable, QuranVerseCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranVerseCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _verseKeyMeta = const VerificationMeta(
    'verseKey',
  );
  @override
  late final GeneratedColumn<String> verseKey = GeneratedColumn<String>(
    'verse_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quranComVerseIdMeta = const VerificationMeta(
    'quranComVerseId',
  );
  @override
  late final GeneratedColumn<int> quranComVerseId = GeneratedColumn<int>(
    'quran_com_verse_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseNumberMeta = const VerificationMeta(
    'verseNumber',
  );
  @override
  late final GeneratedColumn<int> verseNumber = GeneratedColumn<int>(
    'verse_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageNumberMeta = const VerificationMeta(
    'pageNumber',
  );
  @override
  late final GeneratedColumn<int> pageNumber = GeneratedColumn<int>(
    'page_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _juzNumberMeta = const VerificationMeta(
    'juzNumber',
  );
  @override
  late final GeneratedColumn<int> juzNumber = GeneratedColumn<int>(
    'juz_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hizbNumberMeta = const VerificationMeta(
    'hizbNumber',
  );
  @override
  late final GeneratedColumn<int> hizbNumber = GeneratedColumn<int>(
    'hizb_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rubElHizbNumberMeta = const VerificationMeta(
    'rubElHizbNumber',
  );
  @override
  late final GeneratedColumn<int> rubElHizbNumber = GeneratedColumn<int>(
    'rub_el_hizb_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sajdahNumberMeta = const VerificationMeta(
    'sajdahNumber',
  );
  @override
  late final GeneratedColumn<int> sajdahNumber = GeneratedColumn<int>(
    'sajdah_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textUthmaniMeta = const VerificationMeta(
    'textUthmani',
  );
  @override
  late final GeneratedColumn<String> textUthmani = GeneratedColumn<String>(
    'text_uthmani',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textUthmaniSimpleMeta = const VerificationMeta(
    'textUthmaniSimple',
  );
  @override
  late final GeneratedColumn<String> textUthmaniSimple =
      GeneratedColumn<String>(
        'text_uthmani_simple',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    verseKey,
    quranComVerseId,
    chapterId,
    verseNumber,
    pageNumber,
    juzNumber,
    hizbNumber,
    rubElHizbNumber,
    sajdahNumber,
    textUthmani,
    textUthmaniSimple,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_verse_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranVerseCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('verse_key')) {
      context.handle(
        _verseKeyMeta,
        verseKey.isAcceptableOrUnknown(data['verse_key']!, _verseKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_verseKeyMeta);
    }
    if (data.containsKey('quran_com_verse_id')) {
      context.handle(
        _quranComVerseIdMeta,
        quranComVerseId.isAcceptableOrUnknown(
          data['quran_com_verse_id']!,
          _quranComVerseIdMeta,
        ),
      );
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('verse_number')) {
      context.handle(
        _verseNumberMeta,
        verseNumber.isAcceptableOrUnknown(
          data['verse_number']!,
          _verseNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseNumberMeta);
    }
    if (data.containsKey('page_number')) {
      context.handle(
        _pageNumberMeta,
        pageNumber.isAcceptableOrUnknown(data['page_number']!, _pageNumberMeta),
      );
    }
    if (data.containsKey('juz_number')) {
      context.handle(
        _juzNumberMeta,
        juzNumber.isAcceptableOrUnknown(data['juz_number']!, _juzNumberMeta),
      );
    }
    if (data.containsKey('hizb_number')) {
      context.handle(
        _hizbNumberMeta,
        hizbNumber.isAcceptableOrUnknown(data['hizb_number']!, _hizbNumberMeta),
      );
    }
    if (data.containsKey('rub_el_hizb_number')) {
      context.handle(
        _rubElHizbNumberMeta,
        rubElHizbNumber.isAcceptableOrUnknown(
          data['rub_el_hizb_number']!,
          _rubElHizbNumberMeta,
        ),
      );
    }
    if (data.containsKey('sajdah_number')) {
      context.handle(
        _sajdahNumberMeta,
        sajdahNumber.isAcceptableOrUnknown(
          data['sajdah_number']!,
          _sajdahNumberMeta,
        ),
      );
    }
    if (data.containsKey('text_uthmani')) {
      context.handle(
        _textUthmaniMeta,
        textUthmani.isAcceptableOrUnknown(
          data['text_uthmani']!,
          _textUthmaniMeta,
        ),
      );
    }
    if (data.containsKey('text_uthmani_simple')) {
      context.handle(
        _textUthmaniSimpleMeta,
        textUthmaniSimple.isAcceptableOrUnknown(
          data['text_uthmani_simple']!,
          _textUthmaniSimpleMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {verseKey};
  @override
  QuranVerseCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranVerseCacheEntry(
      verseKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verse_key'],
      )!,
      quranComVerseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quran_com_verse_id'],
      ),
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      verseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_number'],
      )!,
      pageNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_number'],
      ),
      juzNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}juz_number'],
      ),
      hizbNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hizb_number'],
      ),
      rubElHizbNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rub_el_hizb_number'],
      ),
      sajdahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sajdah_number'],
      ),
      textUthmani: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_uthmani'],
      ),
      textUthmaniSimple: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_uthmani_simple'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuranVerseCacheTable createAlias(String alias) {
    return $QuranVerseCacheTable(attachedDatabase, alias);
  }
}

class QuranVerseCacheEntry extends DataClass
    implements Insertable<QuranVerseCacheEntry> {
  final String verseKey;
  final int? quranComVerseId;
  final int chapterId;
  final int verseNumber;
  final int? pageNumber;
  final int? juzNumber;
  final int? hizbNumber;
  final int? rubElHizbNumber;
  final int? sajdahNumber;
  final String? textUthmani;
  final String? textUthmaniSimple;
  final DateTime updatedAt;
  const QuranVerseCacheEntry({
    required this.verseKey,
    this.quranComVerseId,
    required this.chapterId,
    required this.verseNumber,
    this.pageNumber,
    this.juzNumber,
    this.hizbNumber,
    this.rubElHizbNumber,
    this.sajdahNumber,
    this.textUthmani,
    this.textUthmaniSimple,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['verse_key'] = Variable<String>(verseKey);
    if (!nullToAbsent || quranComVerseId != null) {
      map['quran_com_verse_id'] = Variable<int>(quranComVerseId);
    }
    map['chapter_id'] = Variable<int>(chapterId);
    map['verse_number'] = Variable<int>(verseNumber);
    if (!nullToAbsent || pageNumber != null) {
      map['page_number'] = Variable<int>(pageNumber);
    }
    if (!nullToAbsent || juzNumber != null) {
      map['juz_number'] = Variable<int>(juzNumber);
    }
    if (!nullToAbsent || hizbNumber != null) {
      map['hizb_number'] = Variable<int>(hizbNumber);
    }
    if (!nullToAbsent || rubElHizbNumber != null) {
      map['rub_el_hizb_number'] = Variable<int>(rubElHizbNumber);
    }
    if (!nullToAbsent || sajdahNumber != null) {
      map['sajdah_number'] = Variable<int>(sajdahNumber);
    }
    if (!nullToAbsent || textUthmani != null) {
      map['text_uthmani'] = Variable<String>(textUthmani);
    }
    if (!nullToAbsent || textUthmaniSimple != null) {
      map['text_uthmani_simple'] = Variable<String>(textUthmaniSimple);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuranVerseCacheCompanion toCompanion(bool nullToAbsent) {
    return QuranVerseCacheCompanion(
      verseKey: Value(verseKey),
      quranComVerseId: quranComVerseId == null && nullToAbsent
          ? const Value.absent()
          : Value(quranComVerseId),
      chapterId: Value(chapterId),
      verseNumber: Value(verseNumber),
      pageNumber: pageNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(pageNumber),
      juzNumber: juzNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(juzNumber),
      hizbNumber: hizbNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(hizbNumber),
      rubElHizbNumber: rubElHizbNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(rubElHizbNumber),
      sajdahNumber: sajdahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(sajdahNumber),
      textUthmani: textUthmani == null && nullToAbsent
          ? const Value.absent()
          : Value(textUthmani),
      textUthmaniSimple: textUthmaniSimple == null && nullToAbsent
          ? const Value.absent()
          : Value(textUthmaniSimple),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuranVerseCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranVerseCacheEntry(
      verseKey: serializer.fromJson<String>(json['verseKey']),
      quranComVerseId: serializer.fromJson<int?>(json['quranComVerseId']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      verseNumber: serializer.fromJson<int>(json['verseNumber']),
      pageNumber: serializer.fromJson<int?>(json['pageNumber']),
      juzNumber: serializer.fromJson<int?>(json['juzNumber']),
      hizbNumber: serializer.fromJson<int?>(json['hizbNumber']),
      rubElHizbNumber: serializer.fromJson<int?>(json['rubElHizbNumber']),
      sajdahNumber: serializer.fromJson<int?>(json['sajdahNumber']),
      textUthmani: serializer.fromJson<String?>(json['textUthmani']),
      textUthmaniSimple: serializer.fromJson<String?>(
        json['textUthmaniSimple'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'verseKey': serializer.toJson<String>(verseKey),
      'quranComVerseId': serializer.toJson<int?>(quranComVerseId),
      'chapterId': serializer.toJson<int>(chapterId),
      'verseNumber': serializer.toJson<int>(verseNumber),
      'pageNumber': serializer.toJson<int?>(pageNumber),
      'juzNumber': serializer.toJson<int?>(juzNumber),
      'hizbNumber': serializer.toJson<int?>(hizbNumber),
      'rubElHizbNumber': serializer.toJson<int?>(rubElHizbNumber),
      'sajdahNumber': serializer.toJson<int?>(sajdahNumber),
      'textUthmani': serializer.toJson<String?>(textUthmani),
      'textUthmaniSimple': serializer.toJson<String?>(textUthmaniSimple),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuranVerseCacheEntry copyWith({
    String? verseKey,
    Value<int?> quranComVerseId = const Value.absent(),
    int? chapterId,
    int? verseNumber,
    Value<int?> pageNumber = const Value.absent(),
    Value<int?> juzNumber = const Value.absent(),
    Value<int?> hizbNumber = const Value.absent(),
    Value<int?> rubElHizbNumber = const Value.absent(),
    Value<int?> sajdahNumber = const Value.absent(),
    Value<String?> textUthmani = const Value.absent(),
    Value<String?> textUthmaniSimple = const Value.absent(),
    DateTime? updatedAt,
  }) => QuranVerseCacheEntry(
    verseKey: verseKey ?? this.verseKey,
    quranComVerseId: quranComVerseId.present
        ? quranComVerseId.value
        : this.quranComVerseId,
    chapterId: chapterId ?? this.chapterId,
    verseNumber: verseNumber ?? this.verseNumber,
    pageNumber: pageNumber.present ? pageNumber.value : this.pageNumber,
    juzNumber: juzNumber.present ? juzNumber.value : this.juzNumber,
    hizbNumber: hizbNumber.present ? hizbNumber.value : this.hizbNumber,
    rubElHizbNumber: rubElHizbNumber.present
        ? rubElHizbNumber.value
        : this.rubElHizbNumber,
    sajdahNumber: sajdahNumber.present ? sajdahNumber.value : this.sajdahNumber,
    textUthmani: textUthmani.present ? textUthmani.value : this.textUthmani,
    textUthmaniSimple: textUthmaniSimple.present
        ? textUthmaniSimple.value
        : this.textUthmaniSimple,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuranVerseCacheEntry copyWithCompanion(QuranVerseCacheCompanion data) {
    return QuranVerseCacheEntry(
      verseKey: data.verseKey.present ? data.verseKey.value : this.verseKey,
      quranComVerseId: data.quranComVerseId.present
          ? data.quranComVerseId.value
          : this.quranComVerseId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      verseNumber: data.verseNumber.present
          ? data.verseNumber.value
          : this.verseNumber,
      pageNumber: data.pageNumber.present
          ? data.pageNumber.value
          : this.pageNumber,
      juzNumber: data.juzNumber.present ? data.juzNumber.value : this.juzNumber,
      hizbNumber: data.hizbNumber.present
          ? data.hizbNumber.value
          : this.hizbNumber,
      rubElHizbNumber: data.rubElHizbNumber.present
          ? data.rubElHizbNumber.value
          : this.rubElHizbNumber,
      sajdahNumber: data.sajdahNumber.present
          ? data.sajdahNumber.value
          : this.sajdahNumber,
      textUthmani: data.textUthmani.present
          ? data.textUthmani.value
          : this.textUthmani,
      textUthmaniSimple: data.textUthmaniSimple.present
          ? data.textUthmaniSimple.value
          : this.textUthmaniSimple,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranVerseCacheEntry(')
          ..write('verseKey: $verseKey, ')
          ..write('quranComVerseId: $quranComVerseId, ')
          ..write('chapterId: $chapterId, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('juzNumber: $juzNumber, ')
          ..write('hizbNumber: $hizbNumber, ')
          ..write('rubElHizbNumber: $rubElHizbNumber, ')
          ..write('sajdahNumber: $sajdahNumber, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('textUthmaniSimple: $textUthmaniSimple, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    verseKey,
    quranComVerseId,
    chapterId,
    verseNumber,
    pageNumber,
    juzNumber,
    hizbNumber,
    rubElHizbNumber,
    sajdahNumber,
    textUthmani,
    textUthmaniSimple,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranVerseCacheEntry &&
          other.verseKey == this.verseKey &&
          other.quranComVerseId == this.quranComVerseId &&
          other.chapterId == this.chapterId &&
          other.verseNumber == this.verseNumber &&
          other.pageNumber == this.pageNumber &&
          other.juzNumber == this.juzNumber &&
          other.hizbNumber == this.hizbNumber &&
          other.rubElHizbNumber == this.rubElHizbNumber &&
          other.sajdahNumber == this.sajdahNumber &&
          other.textUthmani == this.textUthmani &&
          other.textUthmaniSimple == this.textUthmaniSimple &&
          other.updatedAt == this.updatedAt);
}

class QuranVerseCacheCompanion extends UpdateCompanion<QuranVerseCacheEntry> {
  final Value<String> verseKey;
  final Value<int?> quranComVerseId;
  final Value<int> chapterId;
  final Value<int> verseNumber;
  final Value<int?> pageNumber;
  final Value<int?> juzNumber;
  final Value<int?> hizbNumber;
  final Value<int?> rubElHizbNumber;
  final Value<int?> sajdahNumber;
  final Value<String?> textUthmani;
  final Value<String?> textUthmaniSimple;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuranVerseCacheCompanion({
    this.verseKey = const Value.absent(),
    this.quranComVerseId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.verseNumber = const Value.absent(),
    this.pageNumber = const Value.absent(),
    this.juzNumber = const Value.absent(),
    this.hizbNumber = const Value.absent(),
    this.rubElHizbNumber = const Value.absent(),
    this.sajdahNumber = const Value.absent(),
    this.textUthmani = const Value.absent(),
    this.textUthmaniSimple = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuranVerseCacheCompanion.insert({
    required String verseKey,
    this.quranComVerseId = const Value.absent(),
    required int chapterId,
    required int verseNumber,
    this.pageNumber = const Value.absent(),
    this.juzNumber = const Value.absent(),
    this.hizbNumber = const Value.absent(),
    this.rubElHizbNumber = const Value.absent(),
    this.sajdahNumber = const Value.absent(),
    this.textUthmani = const Value.absent(),
    this.textUthmaniSimple = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : verseKey = Value(verseKey),
       chapterId = Value(chapterId),
       verseNumber = Value(verseNumber),
       updatedAt = Value(updatedAt);
  static Insertable<QuranVerseCacheEntry> custom({
    Expression<String>? verseKey,
    Expression<int>? quranComVerseId,
    Expression<int>? chapterId,
    Expression<int>? verseNumber,
    Expression<int>? pageNumber,
    Expression<int>? juzNumber,
    Expression<int>? hizbNumber,
    Expression<int>? rubElHizbNumber,
    Expression<int>? sajdahNumber,
    Expression<String>? textUthmani,
    Expression<String>? textUthmaniSimple,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (verseKey != null) 'verse_key': verseKey,
      if (quranComVerseId != null) 'quran_com_verse_id': quranComVerseId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (verseNumber != null) 'verse_number': verseNumber,
      if (pageNumber != null) 'page_number': pageNumber,
      if (juzNumber != null) 'juz_number': juzNumber,
      if (hizbNumber != null) 'hizb_number': hizbNumber,
      if (rubElHizbNumber != null) 'rub_el_hizb_number': rubElHizbNumber,
      if (sajdahNumber != null) 'sajdah_number': sajdahNumber,
      if (textUthmani != null) 'text_uthmani': textUthmani,
      if (textUthmaniSimple != null) 'text_uthmani_simple': textUthmaniSimple,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuranVerseCacheCompanion copyWith({
    Value<String>? verseKey,
    Value<int?>? quranComVerseId,
    Value<int>? chapterId,
    Value<int>? verseNumber,
    Value<int?>? pageNumber,
    Value<int?>? juzNumber,
    Value<int?>? hizbNumber,
    Value<int?>? rubElHizbNumber,
    Value<int?>? sajdahNumber,
    Value<String?>? textUthmani,
    Value<String?>? textUthmaniSimple,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuranVerseCacheCompanion(
      verseKey: verseKey ?? this.verseKey,
      quranComVerseId: quranComVerseId ?? this.quranComVerseId,
      chapterId: chapterId ?? this.chapterId,
      verseNumber: verseNumber ?? this.verseNumber,
      pageNumber: pageNumber ?? this.pageNumber,
      juzNumber: juzNumber ?? this.juzNumber,
      hizbNumber: hizbNumber ?? this.hizbNumber,
      rubElHizbNumber: rubElHizbNumber ?? this.rubElHizbNumber,
      sajdahNumber: sajdahNumber ?? this.sajdahNumber,
      textUthmani: textUthmani ?? this.textUthmani,
      textUthmaniSimple: textUthmaniSimple ?? this.textUthmaniSimple,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (verseKey.present) {
      map['verse_key'] = Variable<String>(verseKey.value);
    }
    if (quranComVerseId.present) {
      map['quran_com_verse_id'] = Variable<int>(quranComVerseId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (verseNumber.present) {
      map['verse_number'] = Variable<int>(verseNumber.value);
    }
    if (pageNumber.present) {
      map['page_number'] = Variable<int>(pageNumber.value);
    }
    if (juzNumber.present) {
      map['juz_number'] = Variable<int>(juzNumber.value);
    }
    if (hizbNumber.present) {
      map['hizb_number'] = Variable<int>(hizbNumber.value);
    }
    if (rubElHizbNumber.present) {
      map['rub_el_hizb_number'] = Variable<int>(rubElHizbNumber.value);
    }
    if (sajdahNumber.present) {
      map['sajdah_number'] = Variable<int>(sajdahNumber.value);
    }
    if (textUthmani.present) {
      map['text_uthmani'] = Variable<String>(textUthmani.value);
    }
    if (textUthmaniSimple.present) {
      map['text_uthmani_simple'] = Variable<String>(textUthmaniSimple.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranVerseCacheCompanion(')
          ..write('verseKey: $verseKey, ')
          ..write('quranComVerseId: $quranComVerseId, ')
          ..write('chapterId: $chapterId, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('pageNumber: $pageNumber, ')
          ..write('juzNumber: $juzNumber, ')
          ..write('hizbNumber: $hizbNumber, ')
          ..write('rubElHizbNumber: $rubElHizbNumber, ')
          ..write('sajdahNumber: $sajdahNumber, ')
          ..write('textUthmani: $textUthmani, ')
          ..write('textUthmaniSimple: $textUthmaniSimple, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuranRecitationCacheTable extends QuranRecitationCache
    with TableInfo<$QuranRecitationCacheTable, QuranRecitationCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranRecitationCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recitationIdMeta = const VerificationMeta(
    'recitationId',
  );
  @override
  late final GeneratedColumn<int> recitationId = GeneratedColumn<int>(
    'recitation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reciterNameMeta = const VerificationMeta(
    'reciterName',
  );
  @override
  late final GeneratedColumn<String> reciterName = GeneratedColumn<String>(
    'reciter_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _styleMeta = const VerificationMeta('style');
  @override
  late final GeneratedColumn<String> style = GeneratedColumn<String>(
    'style',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translatedNameMeta = const VerificationMeta(
    'translatedName',
  );
  @override
  late final GeneratedColumn<String> translatedName = GeneratedColumn<String>(
    'translated_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageNameMeta = const VerificationMeta(
    'languageName',
  );
  @override
  late final GeneratedColumn<String> languageName = GeneratedColumn<String>(
    'language_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    recitationId,
    languageCode,
    reciterName,
    style,
    translatedName,
    languageName,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_recitation_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranRecitationCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recitation_id')) {
      context.handle(
        _recitationIdMeta,
        recitationId.isAcceptableOrUnknown(
          data['recitation_id']!,
          _recitationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recitationIdMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('reciter_name')) {
      context.handle(
        _reciterNameMeta,
        reciterName.isAcceptableOrUnknown(
          data['reciter_name']!,
          _reciterNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reciterNameMeta);
    }
    if (data.containsKey('style')) {
      context.handle(
        _styleMeta,
        style.isAcceptableOrUnknown(data['style']!, _styleMeta),
      );
    }
    if (data.containsKey('translated_name')) {
      context.handle(
        _translatedNameMeta,
        translatedName.isAcceptableOrUnknown(
          data['translated_name']!,
          _translatedNameMeta,
        ),
      );
    }
    if (data.containsKey('language_name')) {
      context.handle(
        _languageNameMeta,
        languageName.isAcceptableOrUnknown(
          data['language_name']!,
          _languageNameMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recitationId, languageCode};
  @override
  QuranRecitationCacheEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranRecitationCacheEntry(
      recitationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recitation_id'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      reciterName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reciter_name'],
      )!,
      style: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style'],
      ),
      translatedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translated_name'],
      ),
      languageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_name'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuranRecitationCacheTable createAlias(String alias) {
    return $QuranRecitationCacheTable(attachedDatabase, alias);
  }
}

class QuranRecitationCacheEntry extends DataClass
    implements Insertable<QuranRecitationCacheEntry> {
  final int recitationId;
  final String languageCode;
  final String reciterName;
  final String? style;
  final String? translatedName;
  final String? languageName;
  final DateTime updatedAt;
  const QuranRecitationCacheEntry({
    required this.recitationId,
    required this.languageCode,
    required this.reciterName,
    this.style,
    this.translatedName,
    this.languageName,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recitation_id'] = Variable<int>(recitationId);
    map['language_code'] = Variable<String>(languageCode);
    map['reciter_name'] = Variable<String>(reciterName);
    if (!nullToAbsent || style != null) {
      map['style'] = Variable<String>(style);
    }
    if (!nullToAbsent || translatedName != null) {
      map['translated_name'] = Variable<String>(translatedName);
    }
    if (!nullToAbsent || languageName != null) {
      map['language_name'] = Variable<String>(languageName);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuranRecitationCacheCompanion toCompanion(bool nullToAbsent) {
    return QuranRecitationCacheCompanion(
      recitationId: Value(recitationId),
      languageCode: Value(languageCode),
      reciterName: Value(reciterName),
      style: style == null && nullToAbsent
          ? const Value.absent()
          : Value(style),
      translatedName: translatedName == null && nullToAbsent
          ? const Value.absent()
          : Value(translatedName),
      languageName: languageName == null && nullToAbsent
          ? const Value.absent()
          : Value(languageName),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuranRecitationCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranRecitationCacheEntry(
      recitationId: serializer.fromJson<int>(json['recitationId']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      reciterName: serializer.fromJson<String>(json['reciterName']),
      style: serializer.fromJson<String?>(json['style']),
      translatedName: serializer.fromJson<String?>(json['translatedName']),
      languageName: serializer.fromJson<String?>(json['languageName']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recitationId': serializer.toJson<int>(recitationId),
      'languageCode': serializer.toJson<String>(languageCode),
      'reciterName': serializer.toJson<String>(reciterName),
      'style': serializer.toJson<String?>(style),
      'translatedName': serializer.toJson<String?>(translatedName),
      'languageName': serializer.toJson<String?>(languageName),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuranRecitationCacheEntry copyWith({
    int? recitationId,
    String? languageCode,
    String? reciterName,
    Value<String?> style = const Value.absent(),
    Value<String?> translatedName = const Value.absent(),
    Value<String?> languageName = const Value.absent(),
    DateTime? updatedAt,
  }) => QuranRecitationCacheEntry(
    recitationId: recitationId ?? this.recitationId,
    languageCode: languageCode ?? this.languageCode,
    reciterName: reciterName ?? this.reciterName,
    style: style.present ? style.value : this.style,
    translatedName: translatedName.present
        ? translatedName.value
        : this.translatedName,
    languageName: languageName.present ? languageName.value : this.languageName,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuranRecitationCacheEntry copyWithCompanion(
    QuranRecitationCacheCompanion data,
  ) {
    return QuranRecitationCacheEntry(
      recitationId: data.recitationId.present
          ? data.recitationId.value
          : this.recitationId,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      reciterName: data.reciterName.present
          ? data.reciterName.value
          : this.reciterName,
      style: data.style.present ? data.style.value : this.style,
      translatedName: data.translatedName.present
          ? data.translatedName.value
          : this.translatedName,
      languageName: data.languageName.present
          ? data.languageName.value
          : this.languageName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranRecitationCacheEntry(')
          ..write('recitationId: $recitationId, ')
          ..write('languageCode: $languageCode, ')
          ..write('reciterName: $reciterName, ')
          ..write('style: $style, ')
          ..write('translatedName: $translatedName, ')
          ..write('languageName: $languageName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    recitationId,
    languageCode,
    reciterName,
    style,
    translatedName,
    languageName,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranRecitationCacheEntry &&
          other.recitationId == this.recitationId &&
          other.languageCode == this.languageCode &&
          other.reciterName == this.reciterName &&
          other.style == this.style &&
          other.translatedName == this.translatedName &&
          other.languageName == this.languageName &&
          other.updatedAt == this.updatedAt);
}

class QuranRecitationCacheCompanion
    extends UpdateCompanion<QuranRecitationCacheEntry> {
  final Value<int> recitationId;
  final Value<String> languageCode;
  final Value<String> reciterName;
  final Value<String?> style;
  final Value<String?> translatedName;
  final Value<String?> languageName;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuranRecitationCacheCompanion({
    this.recitationId = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.reciterName = const Value.absent(),
    this.style = const Value.absent(),
    this.translatedName = const Value.absent(),
    this.languageName = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuranRecitationCacheCompanion.insert({
    required int recitationId,
    required String languageCode,
    required String reciterName,
    this.style = const Value.absent(),
    this.translatedName = const Value.absent(),
    this.languageName = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : recitationId = Value(recitationId),
       languageCode = Value(languageCode),
       reciterName = Value(reciterName),
       updatedAt = Value(updatedAt);
  static Insertable<QuranRecitationCacheEntry> custom({
    Expression<int>? recitationId,
    Expression<String>? languageCode,
    Expression<String>? reciterName,
    Expression<String>? style,
    Expression<String>? translatedName,
    Expression<String>? languageName,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recitationId != null) 'recitation_id': recitationId,
      if (languageCode != null) 'language_code': languageCode,
      if (reciterName != null) 'reciter_name': reciterName,
      if (style != null) 'style': style,
      if (translatedName != null) 'translated_name': translatedName,
      if (languageName != null) 'language_name': languageName,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuranRecitationCacheCompanion copyWith({
    Value<int>? recitationId,
    Value<String>? languageCode,
    Value<String>? reciterName,
    Value<String?>? style,
    Value<String?>? translatedName,
    Value<String?>? languageName,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuranRecitationCacheCompanion(
      recitationId: recitationId ?? this.recitationId,
      languageCode: languageCode ?? this.languageCode,
      reciterName: reciterName ?? this.reciterName,
      style: style ?? this.style,
      translatedName: translatedName ?? this.translatedName,
      languageName: languageName ?? this.languageName,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recitationId.present) {
      map['recitation_id'] = Variable<int>(recitationId.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (reciterName.present) {
      map['reciter_name'] = Variable<String>(reciterName.value);
    }
    if (style.present) {
      map['style'] = Variable<String>(style.value);
    }
    if (translatedName.present) {
      map['translated_name'] = Variable<String>(translatedName.value);
    }
    if (languageName.present) {
      map['language_name'] = Variable<String>(languageName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranRecitationCacheCompanion(')
          ..write('recitationId: $recitationId, ')
          ..write('languageCode: $languageCode, ')
          ..write('reciterName: $reciterName, ')
          ..write('style: $style, ')
          ..write('translatedName: $translatedName, ')
          ..write('languageName: $languageName, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuranCacheMetadataTable extends QuranCacheMetadata
    with TableInfo<$QuranCacheMetadataTable, QuranCacheMetadataEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranCacheMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastFetchedAtMeta = const VerificationMeta(
    'lastFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchedAt =
      GeneratedColumn<DateTime>(
        'last_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cacheKey, lastFetchedAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_cache_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranCacheMetadataEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('last_fetched_at')) {
      context.handle(
        _lastFetchedAtMeta,
        lastFetchedAt.isAcceptableOrUnknown(
          data['last_fetched_at']!,
          _lastFetchedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cacheKey};
  @override
  QuranCacheMetadataEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranCacheMetadataEntry(
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      lastFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuranCacheMetadataTable createAlias(String alias) {
    return $QuranCacheMetadataTable(attachedDatabase, alias);
  }
}

class QuranCacheMetadataEntry extends DataClass
    implements Insertable<QuranCacheMetadataEntry> {
  final String cacheKey;
  final DateTime? lastFetchedAt;
  final DateTime updatedAt;
  const QuranCacheMetadataEntry({
    required this.cacheKey,
    this.lastFetchedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cache_key'] = Variable<String>(cacheKey);
    if (!nullToAbsent || lastFetchedAt != null) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuranCacheMetadataCompanion toCompanion(bool nullToAbsent) {
    return QuranCacheMetadataCompanion(
      cacheKey: Value(cacheKey),
      lastFetchedAt: lastFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetchedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuranCacheMetadataEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranCacheMetadataEntry(
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      lastFetchedAt: serializer.fromJson<DateTime?>(json['lastFetchedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cacheKey': serializer.toJson<String>(cacheKey),
      'lastFetchedAt': serializer.toJson<DateTime?>(lastFetchedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuranCacheMetadataEntry copyWith({
    String? cacheKey,
    Value<DateTime?> lastFetchedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => QuranCacheMetadataEntry(
    cacheKey: cacheKey ?? this.cacheKey,
    lastFetchedAt: lastFetchedAt.present
        ? lastFetchedAt.value
        : this.lastFetchedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuranCacheMetadataEntry copyWithCompanion(QuranCacheMetadataCompanion data) {
    return QuranCacheMetadataEntry(
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      lastFetchedAt: data.lastFetchedAt.present
          ? data.lastFetchedAt.value
          : this.lastFetchedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranCacheMetadataEntry(')
          ..write('cacheKey: $cacheKey, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cacheKey, lastFetchedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranCacheMetadataEntry &&
          other.cacheKey == this.cacheKey &&
          other.lastFetchedAt == this.lastFetchedAt &&
          other.updatedAt == this.updatedAt);
}

class QuranCacheMetadataCompanion
    extends UpdateCompanion<QuranCacheMetadataEntry> {
  final Value<String> cacheKey;
  final Value<DateTime?> lastFetchedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QuranCacheMetadataCompanion({
    this.cacheKey = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuranCacheMetadataCompanion.insert({
    required String cacheKey,
    this.lastFetchedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : cacheKey = Value(cacheKey),
       updatedAt = Value(updatedAt);
  static Insertable<QuranCacheMetadataEntry> custom({
    Expression<String>? cacheKey,
    Expression<DateTime>? lastFetchedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cacheKey != null) 'cache_key': cacheKey,
      if (lastFetchedAt != null) 'last_fetched_at': lastFetchedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuranCacheMetadataCompanion copyWith({
    Value<String>? cacheKey,
    Value<DateTime?>? lastFetchedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QuranCacheMetadataCompanion(
      cacheKey: cacheKey ?? this.cacheKey,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (lastFetchedAt.present) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranCacheMetadataCompanion(')
          ..write('cacheKey: $cacheKey, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdhkarProgressCacheTable extends AdhkarProgressCache
    with TableInfo<$AdhkarProgressCacheTable, AdhkarProgressCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarProgressCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedCountMeta = const VerificationMeta(
    'completedCount',
  );
  @override
  late final GeneratedColumn<int> completedCount = GeneratedColumn<int>(
    'completed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    categoryId,
    completedCount,
    isCompleted,
    lastUpdated,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_progress_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarProgressCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('completed_count')) {
      context.handle(
        _completedCountMeta,
        completedCount.isAcceptableOrUnknown(
          data['completed_count']!,
          _completedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedCountMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isCompletedMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  AdhkarProgressCacheEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarProgressCacheEntry(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      completedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_count'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      lastUpdated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_updated'],
      )!,
    );
  }

  @override
  $AdhkarProgressCacheTable createAlias(String alias) {
    return $AdhkarProgressCacheTable(attachedDatabase, alias);
  }
}

class AdhkarProgressCacheEntry extends DataClass
    implements Insertable<AdhkarProgressCacheEntry> {
  final String itemId;
  final String categoryId;
  final int completedCount;
  final bool isCompleted;
  final DateTime lastUpdated;
  const AdhkarProgressCacheEntry({
    required this.itemId,
    required this.categoryId,
    required this.completedCount,
    required this.isCompleted,
    required this.lastUpdated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['category_id'] = Variable<String>(categoryId);
    map['completed_count'] = Variable<int>(completedCount);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    return map;
  }

  AdhkarProgressCacheCompanion toCompanion(bool nullToAbsent) {
    return AdhkarProgressCacheCompanion(
      itemId: Value(itemId),
      categoryId: Value(categoryId),
      completedCount: Value(completedCount),
      isCompleted: Value(isCompleted),
      lastUpdated: Value(lastUpdated),
    );
  }

  factory AdhkarProgressCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarProgressCacheEntry(
      itemId: serializer.fromJson<String>(json['itemId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      completedCount: serializer.fromJson<int>(json['completedCount']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'categoryId': serializer.toJson<String>(categoryId),
      'completedCount': serializer.toJson<int>(completedCount),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
    };
  }

  AdhkarProgressCacheEntry copyWith({
    String? itemId,
    String? categoryId,
    int? completedCount,
    bool? isCompleted,
    DateTime? lastUpdated,
  }) => AdhkarProgressCacheEntry(
    itemId: itemId ?? this.itemId,
    categoryId: categoryId ?? this.categoryId,
    completedCount: completedCount ?? this.completedCount,
    isCompleted: isCompleted ?? this.isCompleted,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
  AdhkarProgressCacheEntry copyWithCompanion(
    AdhkarProgressCacheCompanion data,
  ) {
    return AdhkarProgressCacheEntry(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      completedCount: data.completedCount.present
          ? data.completedCount.value
          : this.completedCount,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      lastUpdated: data.lastUpdated.present
          ? data.lastUpdated.value
          : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarProgressCacheEntry(')
          ..write('itemId: $itemId, ')
          ..write('categoryId: $categoryId, ')
          ..write('completedCount: $completedCount, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(itemId, categoryId, completedCount, isCompleted, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarProgressCacheEntry &&
          other.itemId == this.itemId &&
          other.categoryId == this.categoryId &&
          other.completedCount == this.completedCount &&
          other.isCompleted == this.isCompleted &&
          other.lastUpdated == this.lastUpdated);
}

class AdhkarProgressCacheCompanion
    extends UpdateCompanion<AdhkarProgressCacheEntry> {
  final Value<String> itemId;
  final Value<String> categoryId;
  final Value<int> completedCount;
  final Value<bool> isCompleted;
  final Value<DateTime> lastUpdated;
  final Value<int> rowid;
  const AdhkarProgressCacheCompanion({
    this.itemId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.completedCount = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdhkarProgressCacheCompanion.insert({
    required String itemId,
    required String categoryId,
    required int completedCount,
    required bool isCompleted,
    required DateTime lastUpdated,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       categoryId = Value(categoryId),
       completedCount = Value(completedCount),
       isCompleted = Value(isCompleted),
       lastUpdated = Value(lastUpdated);
  static Insertable<AdhkarProgressCacheEntry> custom({
    Expression<String>? itemId,
    Expression<String>? categoryId,
    Expression<int>? completedCount,
    Expression<bool>? isCompleted,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (categoryId != null) 'category_id': categoryId,
      if (completedCount != null) 'completed_count': completedCount,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdhkarProgressCacheCompanion copyWith({
    Value<String>? itemId,
    Value<String>? categoryId,
    Value<int>? completedCount,
    Value<bool>? isCompleted,
    Value<DateTime>? lastUpdated,
    Value<int>? rowid,
  }) {
    return AdhkarProgressCacheCompanion(
      itemId: itemId ?? this.itemId,
      categoryId: categoryId ?? this.categoryId,
      completedCount: completedCount ?? this.completedCount,
      isCompleted: isCompleted ?? this.isCompleted,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (completedCount.present) {
      map['completed_count'] = Variable<int>(completedCount.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarProgressCacheCompanion(')
          ..write('itemId: $itemId, ')
          ..write('categoryId: $categoryId, ')
          ..write('completedCount: $completedCount, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdhkarFavoritesTable extends AdhkarFavorites
    with TableInfo<$AdhkarFavoritesTable, AdhkarFavoritesEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarFavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarFavoritesEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  AdhkarFavoritesEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarFavoritesEntry(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AdhkarFavoritesTable createAlias(String alias) {
    return $AdhkarFavoritesTable(attachedDatabase, alias);
  }
}

class AdhkarFavoritesEntry extends DataClass
    implements Insertable<AdhkarFavoritesEntry> {
  final String itemId;
  final DateTime createdAt;
  const AdhkarFavoritesEntry({required this.itemId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AdhkarFavoritesCompanion toCompanion(bool nullToAbsent) {
    return AdhkarFavoritesCompanion(
      itemId: Value(itemId),
      createdAt: Value(createdAt),
    );
  }

  factory AdhkarFavoritesEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarFavoritesEntry(
      itemId: serializer.fromJson<String>(json['itemId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AdhkarFavoritesEntry copyWith({String? itemId, DateTime? createdAt}) =>
      AdhkarFavoritesEntry(
        itemId: itemId ?? this.itemId,
        createdAt: createdAt ?? this.createdAt,
      );
  AdhkarFavoritesEntry copyWithCompanion(AdhkarFavoritesCompanion data) {
    return AdhkarFavoritesEntry(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarFavoritesEntry(')
          ..write('itemId: $itemId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarFavoritesEntry &&
          other.itemId == this.itemId &&
          other.createdAt == this.createdAt);
}

class AdhkarFavoritesCompanion extends UpdateCompanion<AdhkarFavoritesEntry> {
  final Value<String> itemId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AdhkarFavoritesCompanion({
    this.itemId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdhkarFavoritesCompanion.insert({
    required String itemId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       createdAt = Value(createdAt);
  static Insertable<AdhkarFavoritesEntry> custom({
    Expression<String>? itemId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdhkarFavoritesCompanion copyWith({
    Value<String>? itemId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AdhkarFavoritesCompanion(
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarFavoritesCompanion(')
          ..write('itemId: $itemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QuranChapterCacheTable quranChapterCache =
      $QuranChapterCacheTable(this);
  late final $QuranVerseCacheTable quranVerseCache = $QuranVerseCacheTable(
    this,
  );
  late final $QuranRecitationCacheTable quranRecitationCache =
      $QuranRecitationCacheTable(this);
  late final $QuranCacheMetadataTable quranCacheMetadata =
      $QuranCacheMetadataTable(this);
  late final $AdhkarProgressCacheTable adhkarProgressCache =
      $AdhkarProgressCacheTable(this);
  late final $AdhkarFavoritesTable adhkarFavorites = $AdhkarFavoritesTable(
    this,
  );
  late final Index quranChapterCacheUpdatedAt = Index(
    'quran_chapter_cache_updated_at',
    'CREATE INDEX quran_chapter_cache_updated_at ON quran_chapter_cache (updated_at)',
  );
  late final Index quranVerseCacheChapterVerse = Index(
    'quran_verse_cache_chapter_verse',
    'CREATE INDEX quran_verse_cache_chapter_verse ON quran_verse_cache (chapter_id, verse_number)',
  );
  late final Index quranVerseCachePageNumber = Index(
    'quran_verse_cache_page_number',
    'CREATE INDEX quran_verse_cache_page_number ON quran_verse_cache (page_number)',
  );
  late final Index quranVerseCacheUpdatedAt = Index(
    'quran_verse_cache_updated_at',
    'CREATE INDEX quran_verse_cache_updated_at ON quran_verse_cache (updated_at)',
  );
  late final Index quranRecitationCacheLanguage = Index(
    'quran_recitation_cache_language',
    'CREATE INDEX quran_recitation_cache_language ON quran_recitation_cache (language_code)',
  );
  late final Index quranRecitationCacheUpdatedAt = Index(
    'quran_recitation_cache_updated_at',
    'CREATE INDEX quran_recitation_cache_updated_at ON quran_recitation_cache (updated_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    quranChapterCache,
    quranVerseCache,
    quranRecitationCache,
    quranCacheMetadata,
    adhkarProgressCache,
    adhkarFavorites,
    quranChapterCacheUpdatedAt,
    quranVerseCacheChapterVerse,
    quranVerseCachePageNumber,
    quranVerseCacheUpdatedAt,
    quranRecitationCacheLanguage,
    quranRecitationCacheUpdatedAt,
  ];
}

typedef $$QuranChapterCacheTableCreateCompanionBuilder =
    QuranChapterCacheCompanion Function({
      Value<int> chapterId,
      required String nameArabic,
      required String nameSimple,
      required String nameComplex,
      required int versesCount,
      required String pagesJson,
      Value<String?> revelationPlace,
      Value<int?> revelationOrder,
      Value<bool?> bismillahPre,
      Value<String?> translatedName,
      required DateTime updatedAt,
    });
typedef $$QuranChapterCacheTableUpdateCompanionBuilder =
    QuranChapterCacheCompanion Function({
      Value<int> chapterId,
      Value<String> nameArabic,
      Value<String> nameSimple,
      Value<String> nameComplex,
      Value<int> versesCount,
      Value<String> pagesJson,
      Value<String?> revelationPlace,
      Value<int?> revelationOrder,
      Value<bool?> bismillahPre,
      Value<String?> translatedName,
      Value<DateTime> updatedAt,
    });

class $$QuranChapterCacheTableFilterComposer
    extends Composer<_$AppDatabase, $QuranChapterCacheTable> {
  $$QuranChapterCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameComplex => $composableBuilder(
    column: $table.nameComplex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pagesJson => $composableBuilder(
    column: $table.pagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranChapterCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $QuranChapterCacheTable> {
  $$QuranChapterCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameComplex => $composableBuilder(
    column: $table.nameComplex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pagesJson => $composableBuilder(
    column: $table.pagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranChapterCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuranChapterCacheTable> {
  $$QuranChapterCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get nameArabic => $composableBuilder(
    column: $table.nameArabic,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameSimple => $composableBuilder(
    column: $table.nameSimple,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nameComplex => $composableBuilder(
    column: $table.nameComplex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versesCount => $composableBuilder(
    column: $table.versesCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pagesJson =>
      $composableBuilder(column: $table.pagesJson, builder: (column) => column);

  GeneratedColumn<String> get revelationPlace => $composableBuilder(
    column: $table.revelationPlace,
    builder: (column) => column,
  );

  GeneratedColumn<int> get revelationOrder => $composableBuilder(
    column: $table.revelationOrder,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get bismillahPre => $composableBuilder(
    column: $table.bismillahPre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuranChapterCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuranChapterCacheTable,
          QuranChapterCacheEntry,
          $$QuranChapterCacheTableFilterComposer,
          $$QuranChapterCacheTableOrderingComposer,
          $$QuranChapterCacheTableAnnotationComposer,
          $$QuranChapterCacheTableCreateCompanionBuilder,
          $$QuranChapterCacheTableUpdateCompanionBuilder,
          (
            QuranChapterCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $QuranChapterCacheTable,
              QuranChapterCacheEntry
            >,
          ),
          QuranChapterCacheEntry,
          PrefetchHooks Function()
        > {
  $$QuranChapterCacheTableTableManager(
    _$AppDatabase db,
    $QuranChapterCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranChapterCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranChapterCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranChapterCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> chapterId = const Value.absent(),
                Value<String> nameArabic = const Value.absent(),
                Value<String> nameSimple = const Value.absent(),
                Value<String> nameComplex = const Value.absent(),
                Value<int> versesCount = const Value.absent(),
                Value<String> pagesJson = const Value.absent(),
                Value<String?> revelationPlace = const Value.absent(),
                Value<int?> revelationOrder = const Value.absent(),
                Value<bool?> bismillahPre = const Value.absent(),
                Value<String?> translatedName = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => QuranChapterCacheCompanion(
                chapterId: chapterId,
                nameArabic: nameArabic,
                nameSimple: nameSimple,
                nameComplex: nameComplex,
                versesCount: versesCount,
                pagesJson: pagesJson,
                revelationPlace: revelationPlace,
                revelationOrder: revelationOrder,
                bismillahPre: bismillahPre,
                translatedName: translatedName,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> chapterId = const Value.absent(),
                required String nameArabic,
                required String nameSimple,
                required String nameComplex,
                required int versesCount,
                required String pagesJson,
                Value<String?> revelationPlace = const Value.absent(),
                Value<int?> revelationOrder = const Value.absent(),
                Value<bool?> bismillahPre = const Value.absent(),
                Value<String?> translatedName = const Value.absent(),
                required DateTime updatedAt,
              }) => QuranChapterCacheCompanion.insert(
                chapterId: chapterId,
                nameArabic: nameArabic,
                nameSimple: nameSimple,
                nameComplex: nameComplex,
                versesCount: versesCount,
                pagesJson: pagesJson,
                revelationPlace: revelationPlace,
                revelationOrder: revelationOrder,
                bismillahPre: bismillahPre,
                translatedName: translatedName,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranChapterCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuranChapterCacheTable,
      QuranChapterCacheEntry,
      $$QuranChapterCacheTableFilterComposer,
      $$QuranChapterCacheTableOrderingComposer,
      $$QuranChapterCacheTableAnnotationComposer,
      $$QuranChapterCacheTableCreateCompanionBuilder,
      $$QuranChapterCacheTableUpdateCompanionBuilder,
      (
        QuranChapterCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $QuranChapterCacheTable,
          QuranChapterCacheEntry
        >,
      ),
      QuranChapterCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$QuranVerseCacheTableCreateCompanionBuilder =
    QuranVerseCacheCompanion Function({
      required String verseKey,
      Value<int?> quranComVerseId,
      required int chapterId,
      required int verseNumber,
      Value<int?> pageNumber,
      Value<int?> juzNumber,
      Value<int?> hizbNumber,
      Value<int?> rubElHizbNumber,
      Value<int?> sajdahNumber,
      Value<String?> textUthmani,
      Value<String?> textUthmaniSimple,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$QuranVerseCacheTableUpdateCompanionBuilder =
    QuranVerseCacheCompanion Function({
      Value<String> verseKey,
      Value<int?> quranComVerseId,
      Value<int> chapterId,
      Value<int> verseNumber,
      Value<int?> pageNumber,
      Value<int?> juzNumber,
      Value<int?> hizbNumber,
      Value<int?> rubElHizbNumber,
      Value<int?> sajdahNumber,
      Value<String?> textUthmani,
      Value<String?> textUthmaniSimple,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$QuranVerseCacheTableFilterComposer
    extends Composer<_$AppDatabase, $QuranVerseCacheTable> {
  $$QuranVerseCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quranComVerseId => $composableBuilder(
    column: $table.quranComVerseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get juzNumber => $composableBuilder(
    column: $table.juzNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rubElHizbNumber => $composableBuilder(
    column: $table.rubElHizbNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sajdahNumber => $composableBuilder(
    column: $table.sajdahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textUthmaniSimple => $composableBuilder(
    column: $table.textUthmaniSimple,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranVerseCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $QuranVerseCacheTable> {
  $$QuranVerseCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get verseKey => $composableBuilder(
    column: $table.verseKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quranComVerseId => $composableBuilder(
    column: $table.quranComVerseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get juzNumber => $composableBuilder(
    column: $table.juzNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rubElHizbNumber => $composableBuilder(
    column: $table.rubElHizbNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sajdahNumber => $composableBuilder(
    column: $table.sajdahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textUthmaniSimple => $composableBuilder(
    column: $table.textUthmaniSimple,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranVerseCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuranVerseCacheTable> {
  $$QuranVerseCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get verseKey =>
      $composableBuilder(column: $table.verseKey, builder: (column) => column);

  GeneratedColumn<int> get quranComVerseId => $composableBuilder(
    column: $table.quranComVerseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageNumber => $composableBuilder(
    column: $table.pageNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get juzNumber =>
      $composableBuilder(column: $table.juzNumber, builder: (column) => column);

  GeneratedColumn<int> get hizbNumber => $composableBuilder(
    column: $table.hizbNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rubElHizbNumber => $composableBuilder(
    column: $table.rubElHizbNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sajdahNumber => $composableBuilder(
    column: $table.sajdahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textUthmani => $composableBuilder(
    column: $table.textUthmani,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textUthmaniSimple => $composableBuilder(
    column: $table.textUthmaniSimple,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuranVerseCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuranVerseCacheTable,
          QuranVerseCacheEntry,
          $$QuranVerseCacheTableFilterComposer,
          $$QuranVerseCacheTableOrderingComposer,
          $$QuranVerseCacheTableAnnotationComposer,
          $$QuranVerseCacheTableCreateCompanionBuilder,
          $$QuranVerseCacheTableUpdateCompanionBuilder,
          (
            QuranVerseCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $QuranVerseCacheTable,
              QuranVerseCacheEntry
            >,
          ),
          QuranVerseCacheEntry,
          PrefetchHooks Function()
        > {
  $$QuranVerseCacheTableTableManager(
    _$AppDatabase db,
    $QuranVerseCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranVerseCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranVerseCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranVerseCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> verseKey = const Value.absent(),
                Value<int?> quranComVerseId = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<int> verseNumber = const Value.absent(),
                Value<int?> pageNumber = const Value.absent(),
                Value<int?> juzNumber = const Value.absent(),
                Value<int?> hizbNumber = const Value.absent(),
                Value<int?> rubElHizbNumber = const Value.absent(),
                Value<int?> sajdahNumber = const Value.absent(),
                Value<String?> textUthmani = const Value.absent(),
                Value<String?> textUthmaniSimple = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranVerseCacheCompanion(
                verseKey: verseKey,
                quranComVerseId: quranComVerseId,
                chapterId: chapterId,
                verseNumber: verseNumber,
                pageNumber: pageNumber,
                juzNumber: juzNumber,
                hizbNumber: hizbNumber,
                rubElHizbNumber: rubElHizbNumber,
                sajdahNumber: sajdahNumber,
                textUthmani: textUthmani,
                textUthmaniSimple: textUthmaniSimple,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String verseKey,
                Value<int?> quranComVerseId = const Value.absent(),
                required int chapterId,
                required int verseNumber,
                Value<int?> pageNumber = const Value.absent(),
                Value<int?> juzNumber = const Value.absent(),
                Value<int?> hizbNumber = const Value.absent(),
                Value<int?> rubElHizbNumber = const Value.absent(),
                Value<int?> sajdahNumber = const Value.absent(),
                Value<String?> textUthmani = const Value.absent(),
                Value<String?> textUthmaniSimple = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuranVerseCacheCompanion.insert(
                verseKey: verseKey,
                quranComVerseId: quranComVerseId,
                chapterId: chapterId,
                verseNumber: verseNumber,
                pageNumber: pageNumber,
                juzNumber: juzNumber,
                hizbNumber: hizbNumber,
                rubElHizbNumber: rubElHizbNumber,
                sajdahNumber: sajdahNumber,
                textUthmani: textUthmani,
                textUthmaniSimple: textUthmaniSimple,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranVerseCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuranVerseCacheTable,
      QuranVerseCacheEntry,
      $$QuranVerseCacheTableFilterComposer,
      $$QuranVerseCacheTableOrderingComposer,
      $$QuranVerseCacheTableAnnotationComposer,
      $$QuranVerseCacheTableCreateCompanionBuilder,
      $$QuranVerseCacheTableUpdateCompanionBuilder,
      (
        QuranVerseCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $QuranVerseCacheTable,
          QuranVerseCacheEntry
        >,
      ),
      QuranVerseCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$QuranRecitationCacheTableCreateCompanionBuilder =
    QuranRecitationCacheCompanion Function({
      required int recitationId,
      required String languageCode,
      required String reciterName,
      Value<String?> style,
      Value<String?> translatedName,
      Value<String?> languageName,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$QuranRecitationCacheTableUpdateCompanionBuilder =
    QuranRecitationCacheCompanion Function({
      Value<int> recitationId,
      Value<String> languageCode,
      Value<String> reciterName,
      Value<String?> style,
      Value<String?> translatedName,
      Value<String?> languageName,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$QuranRecitationCacheTableFilterComposer
    extends Composer<_$AppDatabase, $QuranRecitationCacheTable> {
  $$QuranRecitationCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get recitationId => $composableBuilder(
    column: $table.recitationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reciterName => $composableBuilder(
    column: $table.reciterName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranRecitationCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $QuranRecitationCacheTable> {
  $$QuranRecitationCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get recitationId => $composableBuilder(
    column: $table.recitationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reciterName => $composableBuilder(
    column: $table.reciterName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get style => $composableBuilder(
    column: $table.style,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranRecitationCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuranRecitationCacheTable> {
  $$QuranRecitationCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get recitationId => $composableBuilder(
    column: $table.recitationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reciterName => $composableBuilder(
    column: $table.reciterName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get style =>
      $composableBuilder(column: $table.style, builder: (column) => column);

  GeneratedColumn<String> get translatedName => $composableBuilder(
    column: $table.translatedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuranRecitationCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuranRecitationCacheTable,
          QuranRecitationCacheEntry,
          $$QuranRecitationCacheTableFilterComposer,
          $$QuranRecitationCacheTableOrderingComposer,
          $$QuranRecitationCacheTableAnnotationComposer,
          $$QuranRecitationCacheTableCreateCompanionBuilder,
          $$QuranRecitationCacheTableUpdateCompanionBuilder,
          (
            QuranRecitationCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $QuranRecitationCacheTable,
              QuranRecitationCacheEntry
            >,
          ),
          QuranRecitationCacheEntry,
          PrefetchHooks Function()
        > {
  $$QuranRecitationCacheTableTableManager(
    _$AppDatabase db,
    $QuranRecitationCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranRecitationCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranRecitationCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuranRecitationCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> recitationId = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> reciterName = const Value.absent(),
                Value<String?> style = const Value.absent(),
                Value<String?> translatedName = const Value.absent(),
                Value<String?> languageName = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranRecitationCacheCompanion(
                recitationId: recitationId,
                languageCode: languageCode,
                reciterName: reciterName,
                style: style,
                translatedName: translatedName,
                languageName: languageName,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int recitationId,
                required String languageCode,
                required String reciterName,
                Value<String?> style = const Value.absent(),
                Value<String?> translatedName = const Value.absent(),
                Value<String?> languageName = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuranRecitationCacheCompanion.insert(
                recitationId: recitationId,
                languageCode: languageCode,
                reciterName: reciterName,
                style: style,
                translatedName: translatedName,
                languageName: languageName,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranRecitationCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuranRecitationCacheTable,
      QuranRecitationCacheEntry,
      $$QuranRecitationCacheTableFilterComposer,
      $$QuranRecitationCacheTableOrderingComposer,
      $$QuranRecitationCacheTableAnnotationComposer,
      $$QuranRecitationCacheTableCreateCompanionBuilder,
      $$QuranRecitationCacheTableUpdateCompanionBuilder,
      (
        QuranRecitationCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $QuranRecitationCacheTable,
          QuranRecitationCacheEntry
        >,
      ),
      QuranRecitationCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$QuranCacheMetadataTableCreateCompanionBuilder =
    QuranCacheMetadataCompanion Function({
      required String cacheKey,
      Value<DateTime?> lastFetchedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$QuranCacheMetadataTableUpdateCompanionBuilder =
    QuranCacheMetadataCompanion Function({
      Value<String> cacheKey,
      Value<DateTime?> lastFetchedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$QuranCacheMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $QuranCacheMetadataTable> {
  $$QuranCacheMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranCacheMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $QuranCacheMetadataTable> {
  $$QuranCacheMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranCacheMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuranCacheMetadataTable> {
  $$QuranCacheMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuranCacheMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuranCacheMetadataTable,
          QuranCacheMetadataEntry,
          $$QuranCacheMetadataTableFilterComposer,
          $$QuranCacheMetadataTableOrderingComposer,
          $$QuranCacheMetadataTableAnnotationComposer,
          $$QuranCacheMetadataTableCreateCompanionBuilder,
          $$QuranCacheMetadataTableUpdateCompanionBuilder,
          (
            QuranCacheMetadataEntry,
            BaseReferences<
              _$AppDatabase,
              $QuranCacheMetadataTable,
              QuranCacheMetadataEntry
            >,
          ),
          QuranCacheMetadataEntry,
          PrefetchHooks Function()
        > {
  $$QuranCacheMetadataTableTableManager(
    _$AppDatabase db,
    $QuranCacheMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranCacheMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranCacheMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranCacheMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> cacheKey = const Value.absent(),
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuranCacheMetadataCompanion(
                cacheKey: cacheKey,
                lastFetchedAt: lastFetchedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cacheKey,
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuranCacheMetadataCompanion.insert(
                cacheKey: cacheKey,
                lastFetchedAt: lastFetchedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranCacheMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuranCacheMetadataTable,
      QuranCacheMetadataEntry,
      $$QuranCacheMetadataTableFilterComposer,
      $$QuranCacheMetadataTableOrderingComposer,
      $$QuranCacheMetadataTableAnnotationComposer,
      $$QuranCacheMetadataTableCreateCompanionBuilder,
      $$QuranCacheMetadataTableUpdateCompanionBuilder,
      (
        QuranCacheMetadataEntry,
        BaseReferences<
          _$AppDatabase,
          $QuranCacheMetadataTable,
          QuranCacheMetadataEntry
        >,
      ),
      QuranCacheMetadataEntry,
      PrefetchHooks Function()
    >;
typedef $$AdhkarProgressCacheTableCreateCompanionBuilder =
    AdhkarProgressCacheCompanion Function({
      required String itemId,
      required String categoryId,
      required int completedCount,
      required bool isCompleted,
      required DateTime lastUpdated,
      Value<int> rowid,
    });
typedef $$AdhkarProgressCacheTableUpdateCompanionBuilder =
    AdhkarProgressCacheCompanion Function({
      Value<String> itemId,
      Value<String> categoryId,
      Value<int> completedCount,
      Value<bool> isCompleted,
      Value<DateTime> lastUpdated,
      Value<int> rowid,
    });

class $$AdhkarProgressCacheTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarProgressCacheTable> {
  $$AdhkarProgressCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdhkarProgressCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarProgressCacheTable> {
  $$AdhkarProgressCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdhkarProgressCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarProgressCacheTable> {
  $$AdhkarProgressCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );
}

class $$AdhkarProgressCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarProgressCacheTable,
          AdhkarProgressCacheEntry,
          $$AdhkarProgressCacheTableFilterComposer,
          $$AdhkarProgressCacheTableOrderingComposer,
          $$AdhkarProgressCacheTableAnnotationComposer,
          $$AdhkarProgressCacheTableCreateCompanionBuilder,
          $$AdhkarProgressCacheTableUpdateCompanionBuilder,
          (
            AdhkarProgressCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $AdhkarProgressCacheTable,
              AdhkarProgressCacheEntry
            >,
          ),
          AdhkarProgressCacheEntry,
          PrefetchHooks Function()
        > {
  $$AdhkarProgressCacheTableTableManager(
    _$AppDatabase db,
    $AdhkarProgressCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarProgressCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarProgressCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AdhkarProgressCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> completedCount = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdhkarProgressCacheCompanion(
                itemId: itemId,
                categoryId: categoryId,
                completedCount: completedCount,
                isCompleted: isCompleted,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required String categoryId,
                required int completedCount,
                required bool isCompleted,
                required DateTime lastUpdated,
                Value<int> rowid = const Value.absent(),
              }) => AdhkarProgressCacheCompanion.insert(
                itemId: itemId,
                categoryId: categoryId,
                completedCount: completedCount,
                isCompleted: isCompleted,
                lastUpdated: lastUpdated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdhkarProgressCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarProgressCacheTable,
      AdhkarProgressCacheEntry,
      $$AdhkarProgressCacheTableFilterComposer,
      $$AdhkarProgressCacheTableOrderingComposer,
      $$AdhkarProgressCacheTableAnnotationComposer,
      $$AdhkarProgressCacheTableCreateCompanionBuilder,
      $$AdhkarProgressCacheTableUpdateCompanionBuilder,
      (
        AdhkarProgressCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $AdhkarProgressCacheTable,
          AdhkarProgressCacheEntry
        >,
      ),
      AdhkarProgressCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$AdhkarFavoritesTableCreateCompanionBuilder =
    AdhkarFavoritesCompanion Function({
      required String itemId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AdhkarFavoritesTableUpdateCompanionBuilder =
    AdhkarFavoritesCompanion Function({
      Value<String> itemId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AdhkarFavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarFavoritesTable> {
  $$AdhkarFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdhkarFavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarFavoritesTable> {
  $$AdhkarFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdhkarFavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarFavoritesTable> {
  $$AdhkarFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AdhkarFavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarFavoritesTable,
          AdhkarFavoritesEntry,
          $$AdhkarFavoritesTableFilterComposer,
          $$AdhkarFavoritesTableOrderingComposer,
          $$AdhkarFavoritesTableAnnotationComposer,
          $$AdhkarFavoritesTableCreateCompanionBuilder,
          $$AdhkarFavoritesTableUpdateCompanionBuilder,
          (
            AdhkarFavoritesEntry,
            BaseReferences<
              _$AppDatabase,
              $AdhkarFavoritesTable,
              AdhkarFavoritesEntry
            >,
          ),
          AdhkarFavoritesEntry,
          PrefetchHooks Function()
        > {
  $$AdhkarFavoritesTableTableManager(
    _$AppDatabase db,
    $AdhkarFavoritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarFavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdhkarFavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdhkarFavoritesCompanion(
                itemId: itemId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AdhkarFavoritesCompanion.insert(
                itemId: itemId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdhkarFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarFavoritesTable,
      AdhkarFavoritesEntry,
      $$AdhkarFavoritesTableFilterComposer,
      $$AdhkarFavoritesTableOrderingComposer,
      $$AdhkarFavoritesTableAnnotationComposer,
      $$AdhkarFavoritesTableCreateCompanionBuilder,
      $$AdhkarFavoritesTableUpdateCompanionBuilder,
      (
        AdhkarFavoritesEntry,
        BaseReferences<
          _$AppDatabase,
          $AdhkarFavoritesTable,
          AdhkarFavoritesEntry
        >,
      ),
      AdhkarFavoritesEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QuranChapterCacheTableTableManager get quranChapterCache =>
      $$QuranChapterCacheTableTableManager(_db, _db.quranChapterCache);
  $$QuranVerseCacheTableTableManager get quranVerseCache =>
      $$QuranVerseCacheTableTableManager(_db, _db.quranVerseCache);
  $$QuranRecitationCacheTableTableManager get quranRecitationCache =>
      $$QuranRecitationCacheTableTableManager(_db, _db.quranRecitationCache);
  $$QuranCacheMetadataTableTableManager get quranCacheMetadata =>
      $$QuranCacheMetadataTableTableManager(_db, _db.quranCacheMetadata);
  $$AdhkarProgressCacheTableTableManager get adhkarProgressCache =>
      $$AdhkarProgressCacheTableTableManager(_db, _db.adhkarProgressCache);
  $$AdhkarFavoritesTableTableManager get adhkarFavorites =>
      $$AdhkarFavoritesTableTableManager(_db, _db.adhkarFavorites);
}
