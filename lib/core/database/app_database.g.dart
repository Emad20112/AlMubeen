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

class $CategoryFavoritesTable extends CategoryFavorites
    with TableInfo<$CategoryFavoritesTable, CategoryFavoritesEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryFavoritesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
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
  List<GeneratedColumn> get $columns => [categoryId, type, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_favorites';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryFavoritesEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
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
  Set<GeneratedColumn> get $primaryKey => {categoryId};
  @override
  CategoryFavoritesEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryFavoritesEntry(
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategoryFavoritesTable createAlias(String alias) {
    return $CategoryFavoritesTable(attachedDatabase, alias);
  }
}

class CategoryFavoritesEntry extends DataClass
    implements Insertable<CategoryFavoritesEntry> {
  final String categoryId;
  final String type;
  final DateTime createdAt;
  const CategoryFavoritesEntry({
    required this.categoryId,
    required this.type,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['type'] = Variable<String>(type);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategoryFavoritesCompanion toCompanion(bool nullToAbsent) {
    return CategoryFavoritesCompanion(
      categoryId: Value(categoryId),
      type: Value(type),
      createdAt: Value(createdAt),
    );
  }

  factory CategoryFavoritesEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryFavoritesEntry(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      type: serializer.fromJson<String>(json['type']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'type': serializer.toJson<String>(type),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CategoryFavoritesEntry copyWith({
    String? categoryId,
    String? type,
    DateTime? createdAt,
  }) => CategoryFavoritesEntry(
    categoryId: categoryId ?? this.categoryId,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt,
  );
  CategoryFavoritesEntry copyWithCompanion(CategoryFavoritesCompanion data) {
    return CategoryFavoritesEntry(
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      type: data.type.present ? data.type.value : this.type,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryFavoritesEntry(')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, type, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryFavoritesEntry &&
          other.categoryId == this.categoryId &&
          other.type == this.type &&
          other.createdAt == this.createdAt);
}

class CategoryFavoritesCompanion
    extends UpdateCompanion<CategoryFavoritesEntry> {
  final Value<String> categoryId;
  final Value<String> type;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategoryFavoritesCompanion({
    this.categoryId = const Value.absent(),
    this.type = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryFavoritesCompanion.insert({
    required String categoryId,
    required String type,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<CategoryFavoritesEntry> custom({
    Expression<String>? categoryId,
    Expression<String>? type,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (type != null) 'type': type,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryFavoritesCompanion copyWith({
    Value<String>? categoryId,
    Value<String>? type,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategoryFavoritesCompanion(
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
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
    return (StringBuffer('CategoryFavoritesCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('type: $type, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuranReadingProgressCacheTable extends QuranReadingProgressCache
    with TableInfo<$QuranReadingProgressCacheTable, QuranReadingProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranReadingProgressCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lastPageMeta = const VerificationMeta(
    'lastPage',
  );
  @override
  late final GeneratedColumn<int> lastPage = GeneratedColumn<int>(
    'last_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSurahNumberMeta = const VerificationMeta(
    'lastSurahNumber',
  );
  @override
  late final GeneratedColumn<int> lastSurahNumber = GeneratedColumn<int>(
    'last_surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
    id,
    lastPage,
    lastSurahNumber,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_reading_progress_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranReadingProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_page')) {
      context.handle(
        _lastPageMeta,
        lastPage.isAcceptableOrUnknown(data['last_page']!, _lastPageMeta),
      );
    } else if (isInserting) {
      context.missing(_lastPageMeta);
    }
    if (data.containsKey('last_surah_number')) {
      context.handle(
        _lastSurahNumberMeta,
        lastSurahNumber.isAcceptableOrUnknown(
          data['last_surah_number']!,
          _lastSurahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSurahNumberMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuranReadingProgressEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranReadingProgressEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lastPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page'],
      )!,
      lastSurahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_surah_number'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuranReadingProgressCacheTable createAlias(String alias) {
    return $QuranReadingProgressCacheTable(attachedDatabase, alias);
  }
}

class QuranReadingProgressEntry extends DataClass
    implements Insertable<QuranReadingProgressEntry> {
  final int id;
  final int lastPage;
  final int lastSurahNumber;
  final DateTime updatedAt;
  const QuranReadingProgressEntry({
    required this.id,
    required this.lastPage,
    required this.lastSurahNumber,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['last_page'] = Variable<int>(lastPage);
    map['last_surah_number'] = Variable<int>(lastSurahNumber);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuranReadingProgressCacheCompanion toCompanion(bool nullToAbsent) {
    return QuranReadingProgressCacheCompanion(
      id: Value(id),
      lastPage: Value(lastPage),
      lastSurahNumber: Value(lastSurahNumber),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuranReadingProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranReadingProgressEntry(
      id: serializer.fromJson<int>(json['id']),
      lastPage: serializer.fromJson<int>(json['lastPage']),
      lastSurahNumber: serializer.fromJson<int>(json['lastSurahNumber']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastPage': serializer.toJson<int>(lastPage),
      'lastSurahNumber': serializer.toJson<int>(lastSurahNumber),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuranReadingProgressEntry copyWith({
    int? id,
    int? lastPage,
    int? lastSurahNumber,
    DateTime? updatedAt,
  }) => QuranReadingProgressEntry(
    id: id ?? this.id,
    lastPage: lastPage ?? this.lastPage,
    lastSurahNumber: lastSurahNumber ?? this.lastSurahNumber,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuranReadingProgressEntry copyWithCompanion(
    QuranReadingProgressCacheCompanion data,
  ) {
    return QuranReadingProgressEntry(
      id: data.id.present ? data.id.value : this.id,
      lastPage: data.lastPage.present ? data.lastPage.value : this.lastPage,
      lastSurahNumber: data.lastSurahNumber.present
          ? data.lastSurahNumber.value
          : this.lastSurahNumber,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranReadingProgressEntry(')
          ..write('id: $id, ')
          ..write('lastPage: $lastPage, ')
          ..write('lastSurahNumber: $lastSurahNumber, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastPage, lastSurahNumber, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranReadingProgressEntry &&
          other.id == this.id &&
          other.lastPage == this.lastPage &&
          other.lastSurahNumber == this.lastSurahNumber &&
          other.updatedAt == this.updatedAt);
}

class QuranReadingProgressCacheCompanion
    extends UpdateCompanion<QuranReadingProgressEntry> {
  final Value<int> id;
  final Value<int> lastPage;
  final Value<int> lastSurahNumber;
  final Value<DateTime> updatedAt;
  const QuranReadingProgressCacheCompanion({
    this.id = const Value.absent(),
    this.lastPage = const Value.absent(),
    this.lastSurahNumber = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QuranReadingProgressCacheCompanion.insert({
    this.id = const Value.absent(),
    required int lastPage,
    required int lastSurahNumber,
    required DateTime updatedAt,
  }) : lastPage = Value(lastPage),
       lastSurahNumber = Value(lastSurahNumber),
       updatedAt = Value(updatedAt);
  static Insertable<QuranReadingProgressEntry> custom({
    Expression<int>? id,
    Expression<int>? lastPage,
    Expression<int>? lastSurahNumber,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastPage != null) 'last_page': lastPage,
      if (lastSurahNumber != null) 'last_surah_number': lastSurahNumber,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QuranReadingProgressCacheCompanion copyWith({
    Value<int>? id,
    Value<int>? lastPage,
    Value<int>? lastSurahNumber,
    Value<DateTime>? updatedAt,
  }) {
    return QuranReadingProgressCacheCompanion(
      id: id ?? this.id,
      lastPage: lastPage ?? this.lastPage,
      lastSurahNumber: lastSurahNumber ?? this.lastSurahNumber,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastPage.present) {
      map['last_page'] = Variable<int>(lastPage.value);
    }
    if (lastSurahNumber.present) {
      map['last_surah_number'] = Variable<int>(lastSurahNumber.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranReadingProgressCacheCompanion(')
          ..write('id: $id, ')
          ..write('lastPage: $lastPage, ')
          ..write('lastSurahNumber: $lastSurahNumber, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $QuranBookmarksTable extends QuranBookmarks
    with TableInfo<$QuranBookmarksTable, QuranBookmarkEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuranBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _surahNumberMeta = const VerificationMeta(
    'surahNumber',
  );
  @override
  late final GeneratedColumn<int> surahNumber = GeneratedColumn<int>(
    'surah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  List<GeneratedColumn> get $columns => [
    id,
    page,
    surahNumber,
    ayahNumber,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quran_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuranBookmarkEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    } else if (isInserting) {
      context.missing(_pageMeta);
    }
    if (data.containsKey('surah_number')) {
      context.handle(
        _surahNumberMeta,
        surahNumber.isAcceptableOrUnknown(
          data['surah_number']!,
          _surahNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_surahNumberMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {page, surahNumber, ayahNumber},
  ];
  @override
  QuranBookmarkEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuranBookmarkEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      )!,
      surahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}surah_number'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $QuranBookmarksTable createAlias(String alias) {
    return $QuranBookmarksTable(attachedDatabase, alias);
  }
}

class QuranBookmarkEntry extends DataClass
    implements Insertable<QuranBookmarkEntry> {
  final int id;
  final int page;
  final int surahNumber;
  final int? ayahNumber;
  final String? label;
  final DateTime createdAt;
  const QuranBookmarkEntry({
    required this.id,
    required this.page,
    required this.surahNumber,
    this.ayahNumber,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['page'] = Variable<int>(page);
    map['surah_number'] = Variable<int>(surahNumber);
    if (!nullToAbsent || ayahNumber != null) {
      map['ayah_number'] = Variable<int>(ayahNumber);
    }
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  QuranBookmarksCompanion toCompanion(bool nullToAbsent) {
    return QuranBookmarksCompanion(
      id: Value(id),
      page: Value(page),
      surahNumber: Value(surahNumber),
      ayahNumber: ayahNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(ayahNumber),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory QuranBookmarkEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuranBookmarkEntry(
      id: serializer.fromJson<int>(json['id']),
      page: serializer.fromJson<int>(json['page']),
      surahNumber: serializer.fromJson<int>(json['surahNumber']),
      ayahNumber: serializer.fromJson<int?>(json['ayahNumber']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'page': serializer.toJson<int>(page),
      'surahNumber': serializer.toJson<int>(surahNumber),
      'ayahNumber': serializer.toJson<int?>(ayahNumber),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  QuranBookmarkEntry copyWith({
    int? id,
    int? page,
    int? surahNumber,
    Value<int?> ayahNumber = const Value.absent(),
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => QuranBookmarkEntry(
    id: id ?? this.id,
    page: page ?? this.page,
    surahNumber: surahNumber ?? this.surahNumber,
    ayahNumber: ayahNumber.present ? ayahNumber.value : this.ayahNumber,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  QuranBookmarkEntry copyWithCompanion(QuranBookmarksCompanion data) {
    return QuranBookmarkEntry(
      id: data.id.present ? data.id.value : this.id,
      page: data.page.present ? data.page.value : this.page,
      surahNumber: data.surahNumber.present
          ? data.surahNumber.value
          : this.surahNumber,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuranBookmarkEntry(')
          ..write('id: $id, ')
          ..write('page: $page, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, page, surahNumber, ayahNumber, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuranBookmarkEntry &&
          other.id == this.id &&
          other.page == this.page &&
          other.surahNumber == this.surahNumber &&
          other.ayahNumber == this.ayahNumber &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class QuranBookmarksCompanion extends UpdateCompanion<QuranBookmarkEntry> {
  final Value<int> id;
  final Value<int> page;
  final Value<int> surahNumber;
  final Value<int?> ayahNumber;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  const QuranBookmarksCompanion({
    this.id = const Value.absent(),
    this.page = const Value.absent(),
    this.surahNumber = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  QuranBookmarksCompanion.insert({
    this.id = const Value.absent(),
    required int page,
    required int surahNumber,
    this.ayahNumber = const Value.absent(),
    this.label = const Value.absent(),
    required DateTime createdAt,
  }) : page = Value(page),
       surahNumber = Value(surahNumber),
       createdAt = Value(createdAt);
  static Insertable<QuranBookmarkEntry> custom({
    Expression<int>? id,
    Expression<int>? page,
    Expression<int>? surahNumber,
    Expression<int>? ayahNumber,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (page != null) 'page': page,
      if (surahNumber != null) 'surah_number': surahNumber,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  QuranBookmarksCompanion copyWith({
    Value<int>? id,
    Value<int>? page,
    Value<int>? surahNumber,
    Value<int?>? ayahNumber,
    Value<String?>? label,
    Value<DateTime>? createdAt,
  }) {
    return QuranBookmarksCompanion(
      id: id ?? this.id,
      page: page ?? this.page,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (surahNumber.present) {
      map['surah_number'] = Variable<int>(surahNumber.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuranBookmarksCompanion(')
          ..write('id: $id, ')
          ..write('page: $page, ')
          ..write('surahNumber: $surahNumber, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WirdsTableTable extends WirdsTable
    with TableInfo<$WirdsTableTable, WirdEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WirdsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Wird'),
  );
  static const VerificationMeta _goalTypeMeta = const VerificationMeta(
    'goalType',
  );
  @override
  late final GeneratedColumn<String> goalType = GeneratedColumn<String>(
    'goal_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('legacy'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _startPageMeta = const VerificationMeta(
    'startPage',
  );
  @override
  late final GeneratedColumn<int> startPage = GeneratedColumn<int>(
    'start_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _endPageMeta = const VerificationMeta(
    'endPage',
  );
  @override
  late final GeneratedColumn<int> endPage = GeneratedColumn<int>(
    'end_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(604),
  );
  static const VerificationMeta _pagesPerDayMeta = const VerificationMeta(
    'pagesPerDay',
  );
  @override
  late final GeneratedColumn<int> pagesPerDay = GeneratedColumn<int>(
    'pages_per_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );
  static const VerificationMeta _activeWeekdaysMeta = const VerificationMeta(
    'activeWeekdays',
  );
  @override
  late final GeneratedColumn<String> activeWeekdays = GeneratedColumn<String>(
    'active_weekdays',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[1,2,3,4,5,6,7]'),
  );
  static const VerificationMeta _isFlexibleMeta = const VerificationMeta(
    'isFlexible',
  );
  @override
  late final GeneratedColumn<bool> isFlexible = GeneratedColumn<bool>(
    'is_flexible',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_flexible" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _allowCatchUpMeta = const VerificationMeta(
    'allowCatchUp',
  );
  @override
  late final GeneratedColumn<bool> allowCatchUp = GeneratedColumn<bool>(
    'allow_catch_up',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allow_catch_up" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _autoStartNextKhatmaMeta =
      const VerificationMeta('autoStartNextKhatma');
  @override
  late final GeneratedColumn<bool> autoStartNextKhatma = GeneratedColumn<bool>(
    'auto_start_next_khatma',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_start_next_khatma" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _currentCycleMeta = const VerificationMeta(
    'currentCycle',
  );
  @override
  late final GeneratedColumn<int> currentCycle = GeneratedColumn<int>(
    'current_cycle',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountTypeMeta = const VerificationMeta(
    'amountType',
  );
  @override
  late final GeneratedColumn<String> amountType = GeneratedColumn<String>(
    'amount_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMultiplierMeta = const VerificationMeta(
    'amountMultiplier',
  );
  @override
  late final GeneratedColumn<int> amountMultiplier = GeneratedColumn<int>(
    'amount_multiplier',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _durationDaysMeta = const VerificationMeta(
    'durationDays',
  );
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
    'duration_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<String> reminderTime = GeneratedColumn<String>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReadDateMeta = const VerificationMeta(
    'lastReadDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastReadDate = GeneratedColumn<DateTime>(
    'last_read_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedDaysCountMeta =
      const VerificationMeta('completedDaysCount');
  @override
  late final GeneratedColumn<int> completedDaysCount = GeneratedColumn<int>(
    'completed_days_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    goalType,
    status,
    startPage,
    endPage,
    pagesPerDay,
    startDate,
    targetDate,
    scheduleType,
    activeWeekdays,
    isFlexible,
    allowCatchUp,
    autoStartNextKhatma,
    currentCycle,
    createdAt,
    updatedAt,
    completedAt,
    amountType,
    amountMultiplier,
    durationDays,
    frequency,
    reminderTime,
    lastReadDate,
    completedDaysCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wirds_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WirdEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('goal_type')) {
      context.handle(
        _goalTypeMeta,
        goalType.isAcceptableOrUnknown(data['goal_type']!, _goalTypeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('start_page')) {
      context.handle(
        _startPageMeta,
        startPage.isAcceptableOrUnknown(data['start_page']!, _startPageMeta),
      );
    }
    if (data.containsKey('end_page')) {
      context.handle(
        _endPageMeta,
        endPage.isAcceptableOrUnknown(data['end_page']!, _endPageMeta),
      );
    }
    if (data.containsKey('pages_per_day')) {
      context.handle(
        _pagesPerDayMeta,
        pagesPerDay.isAcceptableOrUnknown(
          data['pages_per_day']!,
          _pagesPerDayMeta,
        ),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    }
    if (data.containsKey('active_weekdays')) {
      context.handle(
        _activeWeekdaysMeta,
        activeWeekdays.isAcceptableOrUnknown(
          data['active_weekdays']!,
          _activeWeekdaysMeta,
        ),
      );
    }
    if (data.containsKey('is_flexible')) {
      context.handle(
        _isFlexibleMeta,
        isFlexible.isAcceptableOrUnknown(data['is_flexible']!, _isFlexibleMeta),
      );
    }
    if (data.containsKey('allow_catch_up')) {
      context.handle(
        _allowCatchUpMeta,
        allowCatchUp.isAcceptableOrUnknown(
          data['allow_catch_up']!,
          _allowCatchUpMeta,
        ),
      );
    }
    if (data.containsKey('auto_start_next_khatma')) {
      context.handle(
        _autoStartNextKhatmaMeta,
        autoStartNextKhatma.isAcceptableOrUnknown(
          data['auto_start_next_khatma']!,
          _autoStartNextKhatmaMeta,
        ),
      );
    }
    if (data.containsKey('current_cycle')) {
      context.handle(
        _currentCycleMeta,
        currentCycle.isAcceptableOrUnknown(
          data['current_cycle']!,
          _currentCycleMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('amount_type')) {
      context.handle(
        _amountTypeMeta,
        amountType.isAcceptableOrUnknown(data['amount_type']!, _amountTypeMeta),
      );
    }
    if (data.containsKey('amount_multiplier')) {
      context.handle(
        _amountMultiplierMeta,
        amountMultiplier.isAcceptableOrUnknown(
          data['amount_multiplier']!,
          _amountMultiplierMeta,
        ),
      );
    }
    if (data.containsKey('duration_days')) {
      context.handle(
        _durationDaysMeta,
        durationDays.isAcceptableOrUnknown(
          data['duration_days']!,
          _durationDaysMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('last_read_date')) {
      context.handle(
        _lastReadDateMeta,
        lastReadDate.isAcceptableOrUnknown(
          data['last_read_date']!,
          _lastReadDateMeta,
        ),
      );
    }
    if (data.containsKey('completed_days_count')) {
      context.handle(
        _completedDaysCountMeta,
        completedDaysCount.isAcceptableOrUnknown(
          data['completed_days_count']!,
          _completedDaysCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WirdEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WirdEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      goalType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_page'],
      )!,
      endPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_page'],
      )!,
      pagesPerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_per_day'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      scheduleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_type'],
      )!,
      activeWeekdays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_weekdays'],
      )!,
      isFlexible: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_flexible'],
      )!,
      allowCatchUp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allow_catch_up'],
      )!,
      autoStartNextKhatma: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_start_next_khatma'],
      )!,
      currentCycle: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_cycle'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      amountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_type'],
      ),
      amountMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_multiplier'],
      ),
      durationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_days'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_time'],
      ),
      lastReadDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read_date'],
      ),
      completedDaysCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_days_count'],
      ),
    );
  }

  @override
  $WirdsTableTable createAlias(String alias) {
    return $WirdsTableTable(attachedDatabase, alias);
  }
}

class WirdEntry extends DataClass implements Insertable<WirdEntry> {
  final int id;
  final String name;
  final String goalType;
  final String status;
  final int startPage;
  final int endPage;
  final int? pagesPerDay;
  final DateTime startDate;
  final DateTime? targetDate;
  final String scheduleType;
  final String activeWeekdays;
  final bool isFlexible;
  final bool allowCatchUp;
  final bool autoStartNextKhatma;
  final int currentCycle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String? amountType;
  final int? amountMultiplier;
  final int? durationDays;
  final String? frequency;
  final String? reminderTime;
  final DateTime? lastReadDate;
  final int? completedDaysCount;
  const WirdEntry({
    required this.id,
    required this.name,
    required this.goalType,
    required this.status,
    required this.startPage,
    required this.endPage,
    this.pagesPerDay,
    required this.startDate,
    this.targetDate,
    required this.scheduleType,
    required this.activeWeekdays,
    required this.isFlexible,
    required this.allowCatchUp,
    required this.autoStartNextKhatma,
    required this.currentCycle,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.amountType,
    this.amountMultiplier,
    this.durationDays,
    this.frequency,
    this.reminderTime,
    this.lastReadDate,
    this.completedDaysCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['goal_type'] = Variable<String>(goalType);
    map['status'] = Variable<String>(status);
    map['start_page'] = Variable<int>(startPage);
    map['end_page'] = Variable<int>(endPage);
    if (!nullToAbsent || pagesPerDay != null) {
      map['pages_per_day'] = Variable<int>(pagesPerDay);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    map['schedule_type'] = Variable<String>(scheduleType);
    map['active_weekdays'] = Variable<String>(activeWeekdays);
    map['is_flexible'] = Variable<bool>(isFlexible);
    map['allow_catch_up'] = Variable<bool>(allowCatchUp);
    map['auto_start_next_khatma'] = Variable<bool>(autoStartNextKhatma);
    map['current_cycle'] = Variable<int>(currentCycle);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || amountType != null) {
      map['amount_type'] = Variable<String>(amountType);
    }
    if (!nullToAbsent || amountMultiplier != null) {
      map['amount_multiplier'] = Variable<int>(amountMultiplier);
    }
    if (!nullToAbsent || durationDays != null) {
      map['duration_days'] = Variable<int>(durationDays);
    }
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<String>(reminderTime);
    }
    if (!nullToAbsent || lastReadDate != null) {
      map['last_read_date'] = Variable<DateTime>(lastReadDate);
    }
    if (!nullToAbsent || completedDaysCount != null) {
      map['completed_days_count'] = Variable<int>(completedDaysCount);
    }
    return map;
  }

  WirdsTableCompanion toCompanion(bool nullToAbsent) {
    return WirdsTableCompanion(
      id: Value(id),
      name: Value(name),
      goalType: Value(goalType),
      status: Value(status),
      startPage: Value(startPage),
      endPage: Value(endPage),
      pagesPerDay: pagesPerDay == null && nullToAbsent
          ? const Value.absent()
          : Value(pagesPerDay),
      startDate: Value(startDate),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      scheduleType: Value(scheduleType),
      activeWeekdays: Value(activeWeekdays),
      isFlexible: Value(isFlexible),
      allowCatchUp: Value(allowCatchUp),
      autoStartNextKhatma: Value(autoStartNextKhatma),
      currentCycle: Value(currentCycle),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      amountType: amountType == null && nullToAbsent
          ? const Value.absent()
          : Value(amountType),
      amountMultiplier: amountMultiplier == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMultiplier),
      durationDays: durationDays == null && nullToAbsent
          ? const Value.absent()
          : Value(durationDays),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      lastReadDate: lastReadDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReadDate),
      completedDaysCount: completedDaysCount == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDaysCount),
    );
  }

  factory WirdEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WirdEntry(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      goalType: serializer.fromJson<String>(json['goalType']),
      status: serializer.fromJson<String>(json['status']),
      startPage: serializer.fromJson<int>(json['startPage']),
      endPage: serializer.fromJson<int>(json['endPage']),
      pagesPerDay: serializer.fromJson<int?>(json['pagesPerDay']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      activeWeekdays: serializer.fromJson<String>(json['activeWeekdays']),
      isFlexible: serializer.fromJson<bool>(json['isFlexible']),
      allowCatchUp: serializer.fromJson<bool>(json['allowCatchUp']),
      autoStartNextKhatma: serializer.fromJson<bool>(
        json['autoStartNextKhatma'],
      ),
      currentCycle: serializer.fromJson<int>(json['currentCycle']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      amountType: serializer.fromJson<String?>(json['amountType']),
      amountMultiplier: serializer.fromJson<int?>(json['amountMultiplier']),
      durationDays: serializer.fromJson<int?>(json['durationDays']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      reminderTime: serializer.fromJson<String?>(json['reminderTime']),
      lastReadDate: serializer.fromJson<DateTime?>(json['lastReadDate']),
      completedDaysCount: serializer.fromJson<int?>(json['completedDaysCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'goalType': serializer.toJson<String>(goalType),
      'status': serializer.toJson<String>(status),
      'startPage': serializer.toJson<int>(startPage),
      'endPage': serializer.toJson<int>(endPage),
      'pagesPerDay': serializer.toJson<int?>(pagesPerDay),
      'startDate': serializer.toJson<DateTime>(startDate),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'activeWeekdays': serializer.toJson<String>(activeWeekdays),
      'isFlexible': serializer.toJson<bool>(isFlexible),
      'allowCatchUp': serializer.toJson<bool>(allowCatchUp),
      'autoStartNextKhatma': serializer.toJson<bool>(autoStartNextKhatma),
      'currentCycle': serializer.toJson<int>(currentCycle),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'amountType': serializer.toJson<String?>(amountType),
      'amountMultiplier': serializer.toJson<int?>(amountMultiplier),
      'durationDays': serializer.toJson<int?>(durationDays),
      'frequency': serializer.toJson<String?>(frequency),
      'reminderTime': serializer.toJson<String?>(reminderTime),
      'lastReadDate': serializer.toJson<DateTime?>(lastReadDate),
      'completedDaysCount': serializer.toJson<int?>(completedDaysCount),
    };
  }

  WirdEntry copyWith({
    int? id,
    String? name,
    String? goalType,
    String? status,
    int? startPage,
    int? endPage,
    Value<int?> pagesPerDay = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> targetDate = const Value.absent(),
    String? scheduleType,
    String? activeWeekdays,
    bool? isFlexible,
    bool? allowCatchUp,
    bool? autoStartNextKhatma,
    int? currentCycle,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> amountType = const Value.absent(),
    Value<int?> amountMultiplier = const Value.absent(),
    Value<int?> durationDays = const Value.absent(),
    Value<String?> frequency = const Value.absent(),
    Value<String?> reminderTime = const Value.absent(),
    Value<DateTime?> lastReadDate = const Value.absent(),
    Value<int?> completedDaysCount = const Value.absent(),
  }) => WirdEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    goalType: goalType ?? this.goalType,
    status: status ?? this.status,
    startPage: startPage ?? this.startPage,
    endPage: endPage ?? this.endPage,
    pagesPerDay: pagesPerDay.present ? pagesPerDay.value : this.pagesPerDay,
    startDate: startDate ?? this.startDate,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    scheduleType: scheduleType ?? this.scheduleType,
    activeWeekdays: activeWeekdays ?? this.activeWeekdays,
    isFlexible: isFlexible ?? this.isFlexible,
    allowCatchUp: allowCatchUp ?? this.allowCatchUp,
    autoStartNextKhatma: autoStartNextKhatma ?? this.autoStartNextKhatma,
    currentCycle: currentCycle ?? this.currentCycle,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    amountType: amountType.present ? amountType.value : this.amountType,
    amountMultiplier: amountMultiplier.present
        ? amountMultiplier.value
        : this.amountMultiplier,
    durationDays: durationDays.present ? durationDays.value : this.durationDays,
    frequency: frequency.present ? frequency.value : this.frequency,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    lastReadDate: lastReadDate.present ? lastReadDate.value : this.lastReadDate,
    completedDaysCount: completedDaysCount.present
        ? completedDaysCount.value
        : this.completedDaysCount,
  );
  WirdEntry copyWithCompanion(WirdsTableCompanion data) {
    return WirdEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      goalType: data.goalType.present ? data.goalType.value : this.goalType,
      status: data.status.present ? data.status.value : this.status,
      startPage: data.startPage.present ? data.startPage.value : this.startPage,
      endPage: data.endPage.present ? data.endPage.value : this.endPage,
      pagesPerDay: data.pagesPerDay.present
          ? data.pagesPerDay.value
          : this.pagesPerDay,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      activeWeekdays: data.activeWeekdays.present
          ? data.activeWeekdays.value
          : this.activeWeekdays,
      isFlexible: data.isFlexible.present
          ? data.isFlexible.value
          : this.isFlexible,
      allowCatchUp: data.allowCatchUp.present
          ? data.allowCatchUp.value
          : this.allowCatchUp,
      autoStartNextKhatma: data.autoStartNextKhatma.present
          ? data.autoStartNextKhatma.value
          : this.autoStartNextKhatma,
      currentCycle: data.currentCycle.present
          ? data.currentCycle.value
          : this.currentCycle,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      amountType: data.amountType.present
          ? data.amountType.value
          : this.amountType,
      amountMultiplier: data.amountMultiplier.present
          ? data.amountMultiplier.value
          : this.amountMultiplier,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      lastReadDate: data.lastReadDate.present
          ? data.lastReadDate.value
          : this.lastReadDate,
      completedDaysCount: data.completedDaysCount.present
          ? data.completedDaysCount.value
          : this.completedDaysCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WirdEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('goalType: $goalType, ')
          ..write('status: $status, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('pagesPerDay: $pagesPerDay, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('activeWeekdays: $activeWeekdays, ')
          ..write('isFlexible: $isFlexible, ')
          ..write('allowCatchUp: $allowCatchUp, ')
          ..write('autoStartNextKhatma: $autoStartNextKhatma, ')
          ..write('currentCycle: $currentCycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('amountType: $amountType, ')
          ..write('amountMultiplier: $amountMultiplier, ')
          ..write('durationDays: $durationDays, ')
          ..write('frequency: $frequency, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('lastReadDate: $lastReadDate, ')
          ..write('completedDaysCount: $completedDaysCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    goalType,
    status,
    startPage,
    endPage,
    pagesPerDay,
    startDate,
    targetDate,
    scheduleType,
    activeWeekdays,
    isFlexible,
    allowCatchUp,
    autoStartNextKhatma,
    currentCycle,
    createdAt,
    updatedAt,
    completedAt,
    amountType,
    amountMultiplier,
    durationDays,
    frequency,
    reminderTime,
    lastReadDate,
    completedDaysCount,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WirdEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.goalType == this.goalType &&
          other.status == this.status &&
          other.startPage == this.startPage &&
          other.endPage == this.endPage &&
          other.pagesPerDay == this.pagesPerDay &&
          other.startDate == this.startDate &&
          other.targetDate == this.targetDate &&
          other.scheduleType == this.scheduleType &&
          other.activeWeekdays == this.activeWeekdays &&
          other.isFlexible == this.isFlexible &&
          other.allowCatchUp == this.allowCatchUp &&
          other.autoStartNextKhatma == this.autoStartNextKhatma &&
          other.currentCycle == this.currentCycle &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.completedAt == this.completedAt &&
          other.amountType == this.amountType &&
          other.amountMultiplier == this.amountMultiplier &&
          other.durationDays == this.durationDays &&
          other.frequency == this.frequency &&
          other.reminderTime == this.reminderTime &&
          other.lastReadDate == this.lastReadDate &&
          other.completedDaysCount == this.completedDaysCount);
}

class WirdsTableCompanion extends UpdateCompanion<WirdEntry> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> goalType;
  final Value<String> status;
  final Value<int> startPage;
  final Value<int> endPage;
  final Value<int?> pagesPerDay;
  final Value<DateTime> startDate;
  final Value<DateTime?> targetDate;
  final Value<String> scheduleType;
  final Value<String> activeWeekdays;
  final Value<bool> isFlexible;
  final Value<bool> allowCatchUp;
  final Value<bool> autoStartNextKhatma;
  final Value<int> currentCycle;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> amountType;
  final Value<int?> amountMultiplier;
  final Value<int?> durationDays;
  final Value<String?> frequency;
  final Value<String?> reminderTime;
  final Value<DateTime?> lastReadDate;
  final Value<int?> completedDaysCount;
  const WirdsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.goalType = const Value.absent(),
    this.status = const Value.absent(),
    this.startPage = const Value.absent(),
    this.endPage = const Value.absent(),
    this.pagesPerDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.activeWeekdays = const Value.absent(),
    this.isFlexible = const Value.absent(),
    this.allowCatchUp = const Value.absent(),
    this.autoStartNextKhatma = const Value.absent(),
    this.currentCycle = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.amountType = const Value.absent(),
    this.amountMultiplier = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.frequency = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.lastReadDate = const Value.absent(),
    this.completedDaysCount = const Value.absent(),
  });
  WirdsTableCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.goalType = const Value.absent(),
    this.status = const Value.absent(),
    this.startPage = const Value.absent(),
    this.endPage = const Value.absent(),
    this.pagesPerDay = const Value.absent(),
    this.startDate = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.activeWeekdays = const Value.absent(),
    this.isFlexible = const Value.absent(),
    this.allowCatchUp = const Value.absent(),
    this.autoStartNextKhatma = const Value.absent(),
    this.currentCycle = const Value.absent(),
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.amountType = const Value.absent(),
    this.amountMultiplier = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.frequency = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.lastReadDate = const Value.absent(),
    this.completedDaysCount = const Value.absent(),
  }) : createdAt = Value(createdAt);
  static Insertable<WirdEntry> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? goalType,
    Expression<String>? status,
    Expression<int>? startPage,
    Expression<int>? endPage,
    Expression<int>? pagesPerDay,
    Expression<DateTime>? startDate,
    Expression<DateTime>? targetDate,
    Expression<String>? scheduleType,
    Expression<String>? activeWeekdays,
    Expression<bool>? isFlexible,
    Expression<bool>? allowCatchUp,
    Expression<bool>? autoStartNextKhatma,
    Expression<int>? currentCycle,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? amountType,
    Expression<int>? amountMultiplier,
    Expression<int>? durationDays,
    Expression<String>? frequency,
    Expression<String>? reminderTime,
    Expression<DateTime>? lastReadDate,
    Expression<int>? completedDaysCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (goalType != null) 'goal_type': goalType,
      if (status != null) 'status': status,
      if (startPage != null) 'start_page': startPage,
      if (endPage != null) 'end_page': endPage,
      if (pagesPerDay != null) 'pages_per_day': pagesPerDay,
      if (startDate != null) 'start_date': startDate,
      if (targetDate != null) 'target_date': targetDate,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (activeWeekdays != null) 'active_weekdays': activeWeekdays,
      if (isFlexible != null) 'is_flexible': isFlexible,
      if (allowCatchUp != null) 'allow_catch_up': allowCatchUp,
      if (autoStartNextKhatma != null)
        'auto_start_next_khatma': autoStartNextKhatma,
      if (currentCycle != null) 'current_cycle': currentCycle,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (amountType != null) 'amount_type': amountType,
      if (amountMultiplier != null) 'amount_multiplier': amountMultiplier,
      if (durationDays != null) 'duration_days': durationDays,
      if (frequency != null) 'frequency': frequency,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (lastReadDate != null) 'last_read_date': lastReadDate,
      if (completedDaysCount != null)
        'completed_days_count': completedDaysCount,
    });
  }

  WirdsTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? goalType,
    Value<String>? status,
    Value<int>? startPage,
    Value<int>? endPage,
    Value<int?>? pagesPerDay,
    Value<DateTime>? startDate,
    Value<DateTime?>? targetDate,
    Value<String>? scheduleType,
    Value<String>? activeWeekdays,
    Value<bool>? isFlexible,
    Value<bool>? allowCatchUp,
    Value<bool>? autoStartNextKhatma,
    Value<int>? currentCycle,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? amountType,
    Value<int?>? amountMultiplier,
    Value<int?>? durationDays,
    Value<String?>? frequency,
    Value<String?>? reminderTime,
    Value<DateTime?>? lastReadDate,
    Value<int?>? completedDaysCount,
  }) {
    return WirdsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      goalType: goalType ?? this.goalType,
      status: status ?? this.status,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      pagesPerDay: pagesPerDay ?? this.pagesPerDay,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      scheduleType: scheduleType ?? this.scheduleType,
      activeWeekdays: activeWeekdays ?? this.activeWeekdays,
      isFlexible: isFlexible ?? this.isFlexible,
      allowCatchUp: allowCatchUp ?? this.allowCatchUp,
      autoStartNextKhatma: autoStartNextKhatma ?? this.autoStartNextKhatma,
      currentCycle: currentCycle ?? this.currentCycle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      amountType: amountType ?? this.amountType,
      amountMultiplier: amountMultiplier ?? this.amountMultiplier,
      durationDays: durationDays ?? this.durationDays,
      frequency: frequency ?? this.frequency,
      reminderTime: reminderTime ?? this.reminderTime,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      completedDaysCount: completedDaysCount ?? this.completedDaysCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (goalType.present) {
      map['goal_type'] = Variable<String>(goalType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startPage.present) {
      map['start_page'] = Variable<int>(startPage.value);
    }
    if (endPage.present) {
      map['end_page'] = Variable<int>(endPage.value);
    }
    if (pagesPerDay.present) {
      map['pages_per_day'] = Variable<int>(pagesPerDay.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (activeWeekdays.present) {
      map['active_weekdays'] = Variable<String>(activeWeekdays.value);
    }
    if (isFlexible.present) {
      map['is_flexible'] = Variable<bool>(isFlexible.value);
    }
    if (allowCatchUp.present) {
      map['allow_catch_up'] = Variable<bool>(allowCatchUp.value);
    }
    if (autoStartNextKhatma.present) {
      map['auto_start_next_khatma'] = Variable<bool>(autoStartNextKhatma.value);
    }
    if (currentCycle.present) {
      map['current_cycle'] = Variable<int>(currentCycle.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (amountType.present) {
      map['amount_type'] = Variable<String>(amountType.value);
    }
    if (amountMultiplier.present) {
      map['amount_multiplier'] = Variable<int>(amountMultiplier.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<String>(reminderTime.value);
    }
    if (lastReadDate.present) {
      map['last_read_date'] = Variable<DateTime>(lastReadDate.value);
    }
    if (completedDaysCount.present) {
      map['completed_days_count'] = Variable<int>(completedDaysCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WirdsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('goalType: $goalType, ')
          ..write('status: $status, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('pagesPerDay: $pagesPerDay, ')
          ..write('startDate: $startDate, ')
          ..write('targetDate: $targetDate, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('activeWeekdays: $activeWeekdays, ')
          ..write('isFlexible: $isFlexible, ')
          ..write('allowCatchUp: $allowCatchUp, ')
          ..write('autoStartNextKhatma: $autoStartNextKhatma, ')
          ..write('currentCycle: $currentCycle, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('amountType: $amountType, ')
          ..write('amountMultiplier: $amountMultiplier, ')
          ..write('durationDays: $durationDays, ')
          ..write('frequency: $frequency, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('lastReadDate: $lastReadDate, ')
          ..write('completedDaysCount: $completedDaysCount')
          ..write(')'))
        .toString();
  }
}

class $WirdDailyProgressTableTable extends WirdDailyProgressTable
    with TableInfo<$WirdDailyProgressTableTable, WirdDailyProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WirdDailyProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wirdIdMeta = const VerificationMeta('wirdId');
  @override
  late final GeneratedColumn<int> wirdId = GeneratedColumn<int>(
    'wird_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wirds_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateKeyMeta = const VerificationMeta(
    'dateKey',
  );
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
    'date_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedStartPageMeta = const VerificationMeta(
    'plannedStartPage',
  );
  @override
  late final GeneratedColumn<int> plannedStartPage = GeneratedColumn<int>(
    'planned_start_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedEndPageMeta = const VerificationMeta(
    'plannedEndPage',
  );
  @override
  late final GeneratedColumn<int> plannedEndPage = GeneratedColumn<int>(
    'planned_end_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualStartPageMeta = const VerificationMeta(
    'actualStartPage',
  );
  @override
  late final GeneratedColumn<int> actualStartPage = GeneratedColumn<int>(
    'actual_start_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualEndPageMeta = const VerificationMeta(
    'actualEndPage',
  );
  @override
  late final GeneratedColumn<int> actualEndPage = GeneratedColumn<int>(
    'actual_end_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetPagesMeta = const VerificationMeta(
    'targetPages',
  );
  @override
  late final GeneratedColumn<int> targetPages = GeneratedColumn<int>(
    'target_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedPagesMeta = const VerificationMeta(
    'completedPages',
  );
  @override
  late final GeneratedColumn<int> completedPages = GeneratedColumn<int>(
    'completed_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    id,
    wirdId,
    dateKey,
    plannedStartPage,
    plannedEndPage,
    actualStartPage,
    actualEndPage,
    targetPages,
    completedPages,
    status,
    completedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wird_daily_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WirdDailyProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wird_id')) {
      context.handle(
        _wirdIdMeta,
        wirdId.isAcceptableOrUnknown(data['wird_id']!, _wirdIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wirdIdMeta);
    }
    if (data.containsKey('date_key')) {
      context.handle(
        _dateKeyMeta,
        dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('planned_start_page')) {
      context.handle(
        _plannedStartPageMeta,
        plannedStartPage.isAcceptableOrUnknown(
          data['planned_start_page']!,
          _plannedStartPageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedStartPageMeta);
    }
    if (data.containsKey('planned_end_page')) {
      context.handle(
        _plannedEndPageMeta,
        plannedEndPage.isAcceptableOrUnknown(
          data['planned_end_page']!,
          _plannedEndPageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedEndPageMeta);
    }
    if (data.containsKey('actual_start_page')) {
      context.handle(
        _actualStartPageMeta,
        actualStartPage.isAcceptableOrUnknown(
          data['actual_start_page']!,
          _actualStartPageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualStartPageMeta);
    }
    if (data.containsKey('actual_end_page')) {
      context.handle(
        _actualEndPageMeta,
        actualEndPage.isAcceptableOrUnknown(
          data['actual_end_page']!,
          _actualEndPageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualEndPageMeta);
    }
    if (data.containsKey('target_pages')) {
      context.handle(
        _targetPagesMeta,
        targetPages.isAcceptableOrUnknown(
          data['target_pages']!,
          _targetPagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetPagesMeta);
    }
    if (data.containsKey('completed_pages')) {
      context.handle(
        _completedPagesMeta,
        completedPages.isAcceptableOrUnknown(
          data['completed_pages']!,
          _completedPagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedPagesMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {wirdId, dateKey},
  ];
  @override
  WirdDailyProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WirdDailyProgressEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wirdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wird_id'],
      )!,
      dateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_key'],
      )!,
      plannedStartPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_start_page'],
      )!,
      plannedEndPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_end_page'],
      )!,
      actualStartPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_start_page'],
      )!,
      actualEndPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_end_page'],
      )!,
      targetPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_pages'],
      )!,
      completedPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_pages'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WirdDailyProgressTableTable createAlias(String alias) {
    return $WirdDailyProgressTableTable(attachedDatabase, alias);
  }
}

class WirdDailyProgressEntry extends DataClass
    implements Insertable<WirdDailyProgressEntry> {
  final int id;
  final int wirdId;
  final String dateKey;
  final int plannedStartPage;
  final int plannedEndPage;
  final int actualStartPage;
  final int actualEndPage;
  final int targetPages;
  final int completedPages;
  final String status;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WirdDailyProgressEntry({
    required this.id,
    required this.wirdId,
    required this.dateKey,
    required this.plannedStartPage,
    required this.plannedEndPage,
    required this.actualStartPage,
    required this.actualEndPage,
    required this.targetPages,
    required this.completedPages,
    required this.status,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wird_id'] = Variable<int>(wirdId);
    map['date_key'] = Variable<String>(dateKey);
    map['planned_start_page'] = Variable<int>(plannedStartPage);
    map['planned_end_page'] = Variable<int>(plannedEndPage);
    map['actual_start_page'] = Variable<int>(actualStartPage);
    map['actual_end_page'] = Variable<int>(actualEndPage);
    map['target_pages'] = Variable<int>(targetPages);
    map['completed_pages'] = Variable<int>(completedPages);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WirdDailyProgressTableCompanion toCompanion(bool nullToAbsent) {
    return WirdDailyProgressTableCompanion(
      id: Value(id),
      wirdId: Value(wirdId),
      dateKey: Value(dateKey),
      plannedStartPage: Value(plannedStartPage),
      plannedEndPage: Value(plannedEndPage),
      actualStartPage: Value(actualStartPage),
      actualEndPage: Value(actualEndPage),
      targetPages: Value(targetPages),
      completedPages: Value(completedPages),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WirdDailyProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WirdDailyProgressEntry(
      id: serializer.fromJson<int>(json['id']),
      wirdId: serializer.fromJson<int>(json['wirdId']),
      dateKey: serializer.fromJson<String>(json['dateKey']),
      plannedStartPage: serializer.fromJson<int>(json['plannedStartPage']),
      plannedEndPage: serializer.fromJson<int>(json['plannedEndPage']),
      actualStartPage: serializer.fromJson<int>(json['actualStartPage']),
      actualEndPage: serializer.fromJson<int>(json['actualEndPage']),
      targetPages: serializer.fromJson<int>(json['targetPages']),
      completedPages: serializer.fromJson<int>(json['completedPages']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wirdId': serializer.toJson<int>(wirdId),
      'dateKey': serializer.toJson<String>(dateKey),
      'plannedStartPage': serializer.toJson<int>(plannedStartPage),
      'plannedEndPage': serializer.toJson<int>(plannedEndPage),
      'actualStartPage': serializer.toJson<int>(actualStartPage),
      'actualEndPage': serializer.toJson<int>(actualEndPage),
      'targetPages': serializer.toJson<int>(targetPages),
      'completedPages': serializer.toJson<int>(completedPages),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WirdDailyProgressEntry copyWith({
    int? id,
    int? wirdId,
    String? dateKey,
    int? plannedStartPage,
    int? plannedEndPage,
    int? actualStartPage,
    int? actualEndPage,
    int? targetPages,
    int? completedPages,
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WirdDailyProgressEntry(
    id: id ?? this.id,
    wirdId: wirdId ?? this.wirdId,
    dateKey: dateKey ?? this.dateKey,
    plannedStartPage: plannedStartPage ?? this.plannedStartPage,
    plannedEndPage: plannedEndPage ?? this.plannedEndPage,
    actualStartPage: actualStartPage ?? this.actualStartPage,
    actualEndPage: actualEndPage ?? this.actualEndPage,
    targetPages: targetPages ?? this.targetPages,
    completedPages: completedPages ?? this.completedPages,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WirdDailyProgressEntry copyWithCompanion(
    WirdDailyProgressTableCompanion data,
  ) {
    return WirdDailyProgressEntry(
      id: data.id.present ? data.id.value : this.id,
      wirdId: data.wirdId.present ? data.wirdId.value : this.wirdId,
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      plannedStartPage: data.plannedStartPage.present
          ? data.plannedStartPage.value
          : this.plannedStartPage,
      plannedEndPage: data.plannedEndPage.present
          ? data.plannedEndPage.value
          : this.plannedEndPage,
      actualStartPage: data.actualStartPage.present
          ? data.actualStartPage.value
          : this.actualStartPage,
      actualEndPage: data.actualEndPage.present
          ? data.actualEndPage.value
          : this.actualEndPage,
      targetPages: data.targetPages.present
          ? data.targetPages.value
          : this.targetPages,
      completedPages: data.completedPages.present
          ? data.completedPages.value
          : this.completedPages,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WirdDailyProgressEntry(')
          ..write('id: $id, ')
          ..write('wirdId: $wirdId, ')
          ..write('dateKey: $dateKey, ')
          ..write('plannedStartPage: $plannedStartPage, ')
          ..write('plannedEndPage: $plannedEndPage, ')
          ..write('actualStartPage: $actualStartPage, ')
          ..write('actualEndPage: $actualEndPage, ')
          ..write('targetPages: $targetPages, ')
          ..write('completedPages: $completedPages, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wirdId,
    dateKey,
    plannedStartPage,
    plannedEndPage,
    actualStartPage,
    actualEndPage,
    targetPages,
    completedPages,
    status,
    completedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WirdDailyProgressEntry &&
          other.id == this.id &&
          other.wirdId == this.wirdId &&
          other.dateKey == this.dateKey &&
          other.plannedStartPage == this.plannedStartPage &&
          other.plannedEndPage == this.plannedEndPage &&
          other.actualStartPage == this.actualStartPage &&
          other.actualEndPage == this.actualEndPage &&
          other.targetPages == this.targetPages &&
          other.completedPages == this.completedPages &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WirdDailyProgressTableCompanion
    extends UpdateCompanion<WirdDailyProgressEntry> {
  final Value<int> id;
  final Value<int> wirdId;
  final Value<String> dateKey;
  final Value<int> plannedStartPage;
  final Value<int> plannedEndPage;
  final Value<int> actualStartPage;
  final Value<int> actualEndPage;
  final Value<int> targetPages;
  final Value<int> completedPages;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const WirdDailyProgressTableCompanion({
    this.id = const Value.absent(),
    this.wirdId = const Value.absent(),
    this.dateKey = const Value.absent(),
    this.plannedStartPage = const Value.absent(),
    this.plannedEndPage = const Value.absent(),
    this.actualStartPage = const Value.absent(),
    this.actualEndPage = const Value.absent(),
    this.targetPages = const Value.absent(),
    this.completedPages = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WirdDailyProgressTableCompanion.insert({
    this.id = const Value.absent(),
    required int wirdId,
    required String dateKey,
    required int plannedStartPage,
    required int plannedEndPage,
    required int actualStartPage,
    required int actualEndPage,
    required int targetPages,
    required int completedPages,
    required String status,
    this.completedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : wirdId = Value(wirdId),
       dateKey = Value(dateKey),
       plannedStartPage = Value(plannedStartPage),
       plannedEndPage = Value(plannedEndPage),
       actualStartPage = Value(actualStartPage),
       actualEndPage = Value(actualEndPage),
       targetPages = Value(targetPages),
       completedPages = Value(completedPages),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<WirdDailyProgressEntry> custom({
    Expression<int>? id,
    Expression<int>? wirdId,
    Expression<String>? dateKey,
    Expression<int>? plannedStartPage,
    Expression<int>? plannedEndPage,
    Expression<int>? actualStartPage,
    Expression<int>? actualEndPage,
    Expression<int>? targetPages,
    Expression<int>? completedPages,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wirdId != null) 'wird_id': wirdId,
      if (dateKey != null) 'date_key': dateKey,
      if (plannedStartPage != null) 'planned_start_page': plannedStartPage,
      if (plannedEndPage != null) 'planned_end_page': plannedEndPage,
      if (actualStartPage != null) 'actual_start_page': actualStartPage,
      if (actualEndPage != null) 'actual_end_page': actualEndPage,
      if (targetPages != null) 'target_pages': targetPages,
      if (completedPages != null) 'completed_pages': completedPages,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WirdDailyProgressTableCompanion copyWith({
    Value<int>? id,
    Value<int>? wirdId,
    Value<String>? dateKey,
    Value<int>? plannedStartPage,
    Value<int>? plannedEndPage,
    Value<int>? actualStartPage,
    Value<int>? actualEndPage,
    Value<int>? targetPages,
    Value<int>? completedPages,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return WirdDailyProgressTableCompanion(
      id: id ?? this.id,
      wirdId: wirdId ?? this.wirdId,
      dateKey: dateKey ?? this.dateKey,
      plannedStartPage: plannedStartPage ?? this.plannedStartPage,
      plannedEndPage: plannedEndPage ?? this.plannedEndPage,
      actualStartPage: actualStartPage ?? this.actualStartPage,
      actualEndPage: actualEndPage ?? this.actualEndPage,
      targetPages: targetPages ?? this.targetPages,
      completedPages: completedPages ?? this.completedPages,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wirdId.present) {
      map['wird_id'] = Variable<int>(wirdId.value);
    }
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (plannedStartPage.present) {
      map['planned_start_page'] = Variable<int>(plannedStartPage.value);
    }
    if (plannedEndPage.present) {
      map['planned_end_page'] = Variable<int>(plannedEndPage.value);
    }
    if (actualStartPage.present) {
      map['actual_start_page'] = Variable<int>(actualStartPage.value);
    }
    if (actualEndPage.present) {
      map['actual_end_page'] = Variable<int>(actualEndPage.value);
    }
    if (targetPages.present) {
      map['target_pages'] = Variable<int>(targetPages.value);
    }
    if (completedPages.present) {
      map['completed_pages'] = Variable<int>(completedPages.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WirdDailyProgressTableCompanion(')
          ..write('id: $id, ')
          ..write('wirdId: $wirdId, ')
          ..write('dateKey: $dateKey, ')
          ..write('plannedStartPage: $plannedStartPage, ')
          ..write('plannedEndPage: $plannedEndPage, ')
          ..write('actualStartPage: $actualStartPage, ')
          ..write('actualEndPage: $actualEndPage, ')
          ..write('targetPages: $targetPages, ')
          ..write('completedPages: $completedPages, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WirdCycleHistoryTableTable extends WirdCycleHistoryTable
    with TableInfo<$WirdCycleHistoryTableTable, WirdCycleHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WirdCycleHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _wirdIdMeta = const VerificationMeta('wirdId');
  @override
  late final GeneratedColumn<int> wirdId = GeneratedColumn<int>(
    'wird_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wirds_table (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cycleNumberMeta = const VerificationMeta(
    'cycleNumber',
  );
  @override
  late final GeneratedColumn<int> cycleNumber = GeneratedColumn<int>(
    'cycle_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedDateMeta = const VerificationMeta(
    'completedDate',
  );
  @override
  late final GeneratedColumn<DateTime> completedDate =
      GeneratedColumn<DateTime>(
        'completed_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _startPageMeta = const VerificationMeta(
    'startPage',
  );
  @override
  late final GeneratedColumn<int> startPage = GeneratedColumn<int>(
    'start_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endPageMeta = const VerificationMeta(
    'endPage',
  );
  @override
  late final GeneratedColumn<int> endPage = GeneratedColumn<int>(
    'end_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualCompletedPagesMeta =
      const VerificationMeta('actualCompletedPages');
  @override
  late final GeneratedColumn<int> actualCompletedPages = GeneratedColumn<int>(
    'actual_completed_pages',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  List<GeneratedColumn> get $columns => [
    id,
    wirdId,
    cycleNumber,
    startDate,
    completedDate,
    startPage,
    endPage,
    actualCompletedPages,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wird_cycle_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WirdCycleHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('wird_id')) {
      context.handle(
        _wirdIdMeta,
        wirdId.isAcceptableOrUnknown(data['wird_id']!, _wirdIdMeta),
      );
    } else if (isInserting) {
      context.missing(_wirdIdMeta);
    }
    if (data.containsKey('cycle_number')) {
      context.handle(
        _cycleNumberMeta,
        cycleNumber.isAcceptableOrUnknown(
          data['cycle_number']!,
          _cycleNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cycleNumberMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('completed_date')) {
      context.handle(
        _completedDateMeta,
        completedDate.isAcceptableOrUnknown(
          data['completed_date']!,
          _completedDateMeta,
        ),
      );
    }
    if (data.containsKey('start_page')) {
      context.handle(
        _startPageMeta,
        startPage.isAcceptableOrUnknown(data['start_page']!, _startPageMeta),
      );
    } else if (isInserting) {
      context.missing(_startPageMeta);
    }
    if (data.containsKey('end_page')) {
      context.handle(
        _endPageMeta,
        endPage.isAcceptableOrUnknown(data['end_page']!, _endPageMeta),
      );
    } else if (isInserting) {
      context.missing(_endPageMeta);
    }
    if (data.containsKey('actual_completed_pages')) {
      context.handle(
        _actualCompletedPagesMeta,
        actualCompletedPages.isAcceptableOrUnknown(
          data['actual_completed_pages']!,
          _actualCompletedPagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualCompletedPagesMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WirdCycleHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WirdCycleHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      wirdId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wird_id'],
      )!,
      cycleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_number'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      completedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_date'],
      ),
      startPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_page'],
      )!,
      endPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_page'],
      )!,
      actualCompletedPages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_completed_pages'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WirdCycleHistoryTableTable createAlias(String alias) {
    return $WirdCycleHistoryTableTable(attachedDatabase, alias);
  }
}

class WirdCycleHistoryEntry extends DataClass
    implements Insertable<WirdCycleHistoryEntry> {
  final int id;
  final int wirdId;
  final int cycleNumber;
  final DateTime startDate;
  final DateTime? completedDate;
  final int startPage;
  final int endPage;
  final int actualCompletedPages;
  final DateTime createdAt;
  const WirdCycleHistoryEntry({
    required this.id,
    required this.wirdId,
    required this.cycleNumber,
    required this.startDate,
    this.completedDate,
    required this.startPage,
    required this.endPage,
    required this.actualCompletedPages,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['wird_id'] = Variable<int>(wirdId);
    map['cycle_number'] = Variable<int>(cycleNumber);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || completedDate != null) {
      map['completed_date'] = Variable<DateTime>(completedDate);
    }
    map['start_page'] = Variable<int>(startPage);
    map['end_page'] = Variable<int>(endPage);
    map['actual_completed_pages'] = Variable<int>(actualCompletedPages);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WirdCycleHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return WirdCycleHistoryTableCompanion(
      id: Value(id),
      wirdId: Value(wirdId),
      cycleNumber: Value(cycleNumber),
      startDate: Value(startDate),
      completedDate: completedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(completedDate),
      startPage: Value(startPage),
      endPage: Value(endPage),
      actualCompletedPages: Value(actualCompletedPages),
      createdAt: Value(createdAt),
    );
  }

  factory WirdCycleHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WirdCycleHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      wirdId: serializer.fromJson<int>(json['wirdId']),
      cycleNumber: serializer.fromJson<int>(json['cycleNumber']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      completedDate: serializer.fromJson<DateTime?>(json['completedDate']),
      startPage: serializer.fromJson<int>(json['startPage']),
      endPage: serializer.fromJson<int>(json['endPage']),
      actualCompletedPages: serializer.fromJson<int>(
        json['actualCompletedPages'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'wirdId': serializer.toJson<int>(wirdId),
      'cycleNumber': serializer.toJson<int>(cycleNumber),
      'startDate': serializer.toJson<DateTime>(startDate),
      'completedDate': serializer.toJson<DateTime?>(completedDate),
      'startPage': serializer.toJson<int>(startPage),
      'endPage': serializer.toJson<int>(endPage),
      'actualCompletedPages': serializer.toJson<int>(actualCompletedPages),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WirdCycleHistoryEntry copyWith({
    int? id,
    int? wirdId,
    int? cycleNumber,
    DateTime? startDate,
    Value<DateTime?> completedDate = const Value.absent(),
    int? startPage,
    int? endPage,
    int? actualCompletedPages,
    DateTime? createdAt,
  }) => WirdCycleHistoryEntry(
    id: id ?? this.id,
    wirdId: wirdId ?? this.wirdId,
    cycleNumber: cycleNumber ?? this.cycleNumber,
    startDate: startDate ?? this.startDate,
    completedDate: completedDate.present
        ? completedDate.value
        : this.completedDate,
    startPage: startPage ?? this.startPage,
    endPage: endPage ?? this.endPage,
    actualCompletedPages: actualCompletedPages ?? this.actualCompletedPages,
    createdAt: createdAt ?? this.createdAt,
  );
  WirdCycleHistoryEntry copyWithCompanion(WirdCycleHistoryTableCompanion data) {
    return WirdCycleHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      wirdId: data.wirdId.present ? data.wirdId.value : this.wirdId,
      cycleNumber: data.cycleNumber.present
          ? data.cycleNumber.value
          : this.cycleNumber,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      completedDate: data.completedDate.present
          ? data.completedDate.value
          : this.completedDate,
      startPage: data.startPage.present ? data.startPage.value : this.startPage,
      endPage: data.endPage.present ? data.endPage.value : this.endPage,
      actualCompletedPages: data.actualCompletedPages.present
          ? data.actualCompletedPages.value
          : this.actualCompletedPages,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WirdCycleHistoryEntry(')
          ..write('id: $id, ')
          ..write('wirdId: $wirdId, ')
          ..write('cycleNumber: $cycleNumber, ')
          ..write('startDate: $startDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('actualCompletedPages: $actualCompletedPages, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    wirdId,
    cycleNumber,
    startDate,
    completedDate,
    startPage,
    endPage,
    actualCompletedPages,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WirdCycleHistoryEntry &&
          other.id == this.id &&
          other.wirdId == this.wirdId &&
          other.cycleNumber == this.cycleNumber &&
          other.startDate == this.startDate &&
          other.completedDate == this.completedDate &&
          other.startPage == this.startPage &&
          other.endPage == this.endPage &&
          other.actualCompletedPages == this.actualCompletedPages &&
          other.createdAt == this.createdAt);
}

class WirdCycleHistoryTableCompanion
    extends UpdateCompanion<WirdCycleHistoryEntry> {
  final Value<int> id;
  final Value<int> wirdId;
  final Value<int> cycleNumber;
  final Value<DateTime> startDate;
  final Value<DateTime?> completedDate;
  final Value<int> startPage;
  final Value<int> endPage;
  final Value<int> actualCompletedPages;
  final Value<DateTime> createdAt;
  const WirdCycleHistoryTableCompanion({
    this.id = const Value.absent(),
    this.wirdId = const Value.absent(),
    this.cycleNumber = const Value.absent(),
    this.startDate = const Value.absent(),
    this.completedDate = const Value.absent(),
    this.startPage = const Value.absent(),
    this.endPage = const Value.absent(),
    this.actualCompletedPages = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WirdCycleHistoryTableCompanion.insert({
    this.id = const Value.absent(),
    required int wirdId,
    required int cycleNumber,
    required DateTime startDate,
    this.completedDate = const Value.absent(),
    required int startPage,
    required int endPage,
    required int actualCompletedPages,
    required DateTime createdAt,
  }) : wirdId = Value(wirdId),
       cycleNumber = Value(cycleNumber),
       startDate = Value(startDate),
       startPage = Value(startPage),
       endPage = Value(endPage),
       actualCompletedPages = Value(actualCompletedPages),
       createdAt = Value(createdAt);
  static Insertable<WirdCycleHistoryEntry> custom({
    Expression<int>? id,
    Expression<int>? wirdId,
    Expression<int>? cycleNumber,
    Expression<DateTime>? startDate,
    Expression<DateTime>? completedDate,
    Expression<int>? startPage,
    Expression<int>? endPage,
    Expression<int>? actualCompletedPages,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (wirdId != null) 'wird_id': wirdId,
      if (cycleNumber != null) 'cycle_number': cycleNumber,
      if (startDate != null) 'start_date': startDate,
      if (completedDate != null) 'completed_date': completedDate,
      if (startPage != null) 'start_page': startPage,
      if (endPage != null) 'end_page': endPage,
      if (actualCompletedPages != null)
        'actual_completed_pages': actualCompletedPages,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WirdCycleHistoryTableCompanion copyWith({
    Value<int>? id,
    Value<int>? wirdId,
    Value<int>? cycleNumber,
    Value<DateTime>? startDate,
    Value<DateTime?>? completedDate,
    Value<int>? startPage,
    Value<int>? endPage,
    Value<int>? actualCompletedPages,
    Value<DateTime>? createdAt,
  }) {
    return WirdCycleHistoryTableCompanion(
      id: id ?? this.id,
      wirdId: wirdId ?? this.wirdId,
      cycleNumber: cycleNumber ?? this.cycleNumber,
      startDate: startDate ?? this.startDate,
      completedDate: completedDate ?? this.completedDate,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      actualCompletedPages: actualCompletedPages ?? this.actualCompletedPages,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (wirdId.present) {
      map['wird_id'] = Variable<int>(wirdId.value);
    }
    if (cycleNumber.present) {
      map['cycle_number'] = Variable<int>(cycleNumber.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (completedDate.present) {
      map['completed_date'] = Variable<DateTime>(completedDate.value);
    }
    if (startPage.present) {
      map['start_page'] = Variable<int>(startPage.value);
    }
    if (endPage.present) {
      map['end_page'] = Variable<int>(endPage.value);
    }
    if (actualCompletedPages.present) {
      map['actual_completed_pages'] = Variable<int>(actualCompletedPages.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WirdCycleHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('wirdId: $wirdId, ')
          ..write('cycleNumber: $cycleNumber, ')
          ..write('startDate: $startDate, ')
          ..write('completedDate: $completedDate, ')
          ..write('startPage: $startPage, ')
          ..write('endPage: $endPage, ')
          ..write('actualCompletedPages: $actualCompletedPages, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WirdAchievementsTableTable extends WirdAchievementsTable
    with TableInfo<$WirdAchievementsTableTable, WirdAchievementEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WirdAchievementsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thresholdMeta = const VerificationMeta(
    'threshold',
  );
  @override
  late final GeneratedColumn<int> threshold = GeneratedColumn<int>(
    'threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedMeta = const VerificationMeta(
    'unlocked',
  );
  @override
  late final GeneratedColumn<bool> unlocked = GeneratedColumn<bool>(
    'unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    threshold,
    unlocked,
    unlockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wird_achievements_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<WirdAchievementEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('threshold')) {
      context.handle(
        _thresholdMeta,
        threshold.isAcceptableOrUnknown(data['threshold']!, _thresholdMeta),
      );
    } else if (isInserting) {
      context.missing(_thresholdMeta);
    }
    if (data.containsKey('unlocked')) {
      context.handle(
        _unlockedMeta,
        unlocked.isAcceptableOrUnknown(data['unlocked']!, _unlockedMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WirdAchievementEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WirdAchievementEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      threshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}threshold'],
      )!,
      unlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}unlocked'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
    );
  }

  @override
  $WirdAchievementsTableTable createAlias(String alias) {
    return $WirdAchievementsTableTable(attachedDatabase, alias);
  }
}

class WirdAchievementEntry extends DataClass
    implements Insertable<WirdAchievementEntry> {
  final String id;
  final String type;
  final int threshold;
  final bool unlocked;
  final DateTime? unlockedAt;
  const WirdAchievementEntry({
    required this.id,
    required this.type,
    required this.threshold,
    required this.unlocked,
    this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['threshold'] = Variable<int>(threshold);
    map['unlocked'] = Variable<bool>(unlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  WirdAchievementsTableCompanion toCompanion(bool nullToAbsent) {
    return WirdAchievementsTableCompanion(
      id: Value(id),
      type: Value(type),
      threshold: Value(threshold),
      unlocked: Value(unlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory WirdAchievementEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WirdAchievementEntry(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      threshold: serializer.fromJson<int>(json['threshold']),
      unlocked: serializer.fromJson<bool>(json['unlocked']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'threshold': serializer.toJson<int>(threshold),
      'unlocked': serializer.toJson<bool>(unlocked),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  WirdAchievementEntry copyWith({
    String? id,
    String? type,
    int? threshold,
    bool? unlocked,
    Value<DateTime?> unlockedAt = const Value.absent(),
  }) => WirdAchievementEntry(
    id: id ?? this.id,
    type: type ?? this.type,
    threshold: threshold ?? this.threshold,
    unlocked: unlocked ?? this.unlocked,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
  );
  WirdAchievementEntry copyWithCompanion(WirdAchievementsTableCompanion data) {
    return WirdAchievementEntry(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      threshold: data.threshold.present ? data.threshold.value : this.threshold,
      unlocked: data.unlocked.present ? data.unlocked.value : this.unlocked,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WirdAchievementEntry(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('threshold: $threshold, ')
          ..write('unlocked: $unlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, threshold, unlocked, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WirdAchievementEntry &&
          other.id == this.id &&
          other.type == this.type &&
          other.threshold == this.threshold &&
          other.unlocked == this.unlocked &&
          other.unlockedAt == this.unlockedAt);
}

class WirdAchievementsTableCompanion
    extends UpdateCompanion<WirdAchievementEntry> {
  final Value<String> id;
  final Value<String> type;
  final Value<int> threshold;
  final Value<bool> unlocked;
  final Value<DateTime?> unlockedAt;
  final Value<int> rowid;
  const WirdAchievementsTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.threshold = const Value.absent(),
    this.unlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WirdAchievementsTableCompanion.insert({
    required String id,
    required String type,
    required int threshold,
    this.unlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       threshold = Value(threshold);
  static Insertable<WirdAchievementEntry> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? threshold,
    Expression<bool>? unlocked,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (threshold != null) 'threshold': threshold,
      if (unlocked != null) 'unlocked': unlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WirdAchievementsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<int>? threshold,
    Value<bool>? unlocked,
    Value<DateTime?>? unlockedAt,
    Value<int>? rowid,
  }) {
    return WirdAchievementsTableCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      threshold: threshold ?? this.threshold,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (threshold.present) {
      map['threshold'] = Variable<int>(threshold.value);
    }
    if (unlocked.present) {
      map['unlocked'] = Variable<bool>(unlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WirdAchievementsTableCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('threshold: $threshold, ')
          ..write('unlocked: $unlocked, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DownloadedTafsirsTable extends DownloadedTafsirs
    with TableInfo<$DownloadedTafsirsTable, DownloadedTafsirEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedTafsirsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
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
  static const VerificationMeta _resourceNameMeta = const VerificationMeta(
    'resourceName',
  );
  @override
  late final GeneratedColumn<String> resourceName = GeneratedColumn<String>(
    'resource_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    resourceId,
    name,
    authorName,
    slug,
    languageName,
    resourceName,
    downloadedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_tafsirs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedTafsirEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
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
    if (data.containsKey('resource_name')) {
      context.handle(
        _resourceNameMeta,
        resourceName.isAcceptableOrUnknown(
          data['resource_name']!,
          _resourceNameMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {resourceId};
  @override
  DownloadedTafsirEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedTafsirEntry(
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      ),
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      ),
      languageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_name'],
      ),
      resourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_name'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadedTafsirsTable createAlias(String alias) {
    return $DownloadedTafsirsTable(attachedDatabase, alias);
  }
}

class DownloadedTafsirEntry extends DataClass
    implements Insertable<DownloadedTafsirEntry> {
  final int resourceId;
  final String name;
  final String? authorName;
  final String? slug;
  final String? languageName;
  final String? resourceName;
  final DateTime downloadedAt;
  final DateTime updatedAt;
  const DownloadedTafsirEntry({
    required this.resourceId,
    required this.name,
    this.authorName,
    this.slug,
    this.languageName,
    this.resourceName,
    required this.downloadedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_id'] = Variable<int>(resourceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || authorName != null) {
      map['author_name'] = Variable<String>(authorName);
    }
    if (!nullToAbsent || slug != null) {
      map['slug'] = Variable<String>(slug);
    }
    if (!nullToAbsent || languageName != null) {
      map['language_name'] = Variable<String>(languageName);
    }
    if (!nullToAbsent || resourceName != null) {
      map['resource_name'] = Variable<String>(resourceName);
    }
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadedTafsirsCompanion toCompanion(bool nullToAbsent) {
    return DownloadedTafsirsCompanion(
      resourceId: Value(resourceId),
      name: Value(name),
      authorName: authorName == null && nullToAbsent
          ? const Value.absent()
          : Value(authorName),
      slug: slug == null && nullToAbsent ? const Value.absent() : Value(slug),
      languageName: languageName == null && nullToAbsent
          ? const Value.absent()
          : Value(languageName),
      resourceName: resourceName == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceName),
      downloadedAt: Value(downloadedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadedTafsirEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedTafsirEntry(
      resourceId: serializer.fromJson<int>(json['resourceId']),
      name: serializer.fromJson<String>(json['name']),
      authorName: serializer.fromJson<String?>(json['authorName']),
      slug: serializer.fromJson<String?>(json['slug']),
      languageName: serializer.fromJson<String?>(json['languageName']),
      resourceName: serializer.fromJson<String?>(json['resourceName']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceId': serializer.toJson<int>(resourceId),
      'name': serializer.toJson<String>(name),
      'authorName': serializer.toJson<String?>(authorName),
      'slug': serializer.toJson<String?>(slug),
      'languageName': serializer.toJson<String?>(languageName),
      'resourceName': serializer.toJson<String?>(resourceName),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadedTafsirEntry copyWith({
    int? resourceId,
    String? name,
    Value<String?> authorName = const Value.absent(),
    Value<String?> slug = const Value.absent(),
    Value<String?> languageName = const Value.absent(),
    Value<String?> resourceName = const Value.absent(),
    DateTime? downloadedAt,
    DateTime? updatedAt,
  }) => DownloadedTafsirEntry(
    resourceId: resourceId ?? this.resourceId,
    name: name ?? this.name,
    authorName: authorName.present ? authorName.value : this.authorName,
    slug: slug.present ? slug.value : this.slug,
    languageName: languageName.present ? languageName.value : this.languageName,
    resourceName: resourceName.present ? resourceName.value : this.resourceName,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadedTafsirEntry copyWithCompanion(DownloadedTafsirsCompanion data) {
    return DownloadedTafsirEntry(
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      name: data.name.present ? data.name.value : this.name,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      slug: data.slug.present ? data.slug.value : this.slug,
      languageName: data.languageName.present
          ? data.languageName.value
          : this.languageName,
      resourceName: data.resourceName.present
          ? data.resourceName.value
          : this.resourceName,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTafsirEntry(')
          ..write('resourceId: $resourceId, ')
          ..write('name: $name, ')
          ..write('authorName: $authorName, ')
          ..write('slug: $slug, ')
          ..write('languageName: $languageName, ')
          ..write('resourceName: $resourceName, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resourceId,
    name,
    authorName,
    slug,
    languageName,
    resourceName,
    downloadedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedTafsirEntry &&
          other.resourceId == this.resourceId &&
          other.name == this.name &&
          other.authorName == this.authorName &&
          other.slug == this.slug &&
          other.languageName == this.languageName &&
          other.resourceName == this.resourceName &&
          other.downloadedAt == this.downloadedAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadedTafsirsCompanion
    extends UpdateCompanion<DownloadedTafsirEntry> {
  final Value<int> resourceId;
  final Value<String> name;
  final Value<String?> authorName;
  final Value<String?> slug;
  final Value<String?> languageName;
  final Value<String?> resourceName;
  final Value<DateTime> downloadedAt;
  final Value<DateTime> updatedAt;
  const DownloadedTafsirsCompanion({
    this.resourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.authorName = const Value.absent(),
    this.slug = const Value.absent(),
    this.languageName = const Value.absent(),
    this.resourceName = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DownloadedTafsirsCompanion.insert({
    this.resourceId = const Value.absent(),
    required String name,
    this.authorName = const Value.absent(),
    this.slug = const Value.absent(),
    this.languageName = const Value.absent(),
    this.resourceName = const Value.absent(),
    required DateTime downloadedAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       downloadedAt = Value(downloadedAt),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadedTafsirEntry> custom({
    Expression<int>? resourceId,
    Expression<String>? name,
    Expression<String>? authorName,
    Expression<String>? slug,
    Expression<String>? languageName,
    Expression<String>? resourceName,
    Expression<DateTime>? downloadedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (resourceId != null) 'resource_id': resourceId,
      if (name != null) 'name': name,
      if (authorName != null) 'author_name': authorName,
      if (slug != null) 'slug': slug,
      if (languageName != null) 'language_name': languageName,
      if (resourceName != null) 'resource_name': resourceName,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DownloadedTafsirsCompanion copyWith({
    Value<int>? resourceId,
    Value<String>? name,
    Value<String?>? authorName,
    Value<String?>? slug,
    Value<String?>? languageName,
    Value<String?>? resourceName,
    Value<DateTime>? downloadedAt,
    Value<DateTime>? updatedAt,
  }) {
    return DownloadedTafsirsCompanion(
      resourceId: resourceId ?? this.resourceId,
      name: name ?? this.name,
      authorName: authorName ?? this.authorName,
      slug: slug ?? this.slug,
      languageName: languageName ?? this.languageName,
      resourceName: resourceName ?? this.resourceName,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (languageName.present) {
      map['language_name'] = Variable<String>(languageName.value);
    }
    if (resourceName.present) {
      map['resource_name'] = Variable<String>(resourceName.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTafsirsCompanion(')
          ..write('resourceId: $resourceId, ')
          ..write('name: $name, ')
          ..write('authorName: $authorName, ')
          ..write('slug: $slug, ')
          ..write('languageName: $languageName, ')
          ..write('resourceName: $resourceName, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadedTranslationsTable extends DownloadedTranslations
    with TableInfo<$DownloadedTranslationsTable, DownloadedTranslationEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadedTranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
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
  static const VerificationMeta _resourceNameMeta = const VerificationMeta(
    'resourceName',
  );
  @override
  late final GeneratedColumn<String> resourceName = GeneratedColumn<String>(
    'resource_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
    resourceId,
    name,
    authorName,
    slug,
    languageName,
    resourceName,
    downloadedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'downloaded_translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadedTranslationEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
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
    if (data.containsKey('resource_name')) {
      context.handle(
        _resourceNameMeta,
        resourceName.isAcceptableOrUnknown(
          data['resource_name']!,
          _resourceNameMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_downloadedAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {resourceId};
  @override
  DownloadedTranslationEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadedTranslationEntry(
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      ),
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      ),
      languageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_name'],
      ),
      resourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_name'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadedTranslationsTable createAlias(String alias) {
    return $DownloadedTranslationsTable(attachedDatabase, alias);
  }
}

class DownloadedTranslationEntry extends DataClass
    implements Insertable<DownloadedTranslationEntry> {
  final int resourceId;
  final String name;
  final String? authorName;
  final String? slug;
  final String? languageName;
  final String? resourceName;
  final DateTime downloadedAt;
  final DateTime updatedAt;
  const DownloadedTranslationEntry({
    required this.resourceId,
    required this.name,
    this.authorName,
    this.slug,
    this.languageName,
    this.resourceName,
    required this.downloadedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_id'] = Variable<int>(resourceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || authorName != null) {
      map['author_name'] = Variable<String>(authorName);
    }
    if (!nullToAbsent || slug != null) {
      map['slug'] = Variable<String>(slug);
    }
    if (!nullToAbsent || languageName != null) {
      map['language_name'] = Variable<String>(languageName);
    }
    if (!nullToAbsent || resourceName != null) {
      map['resource_name'] = Variable<String>(resourceName);
    }
    map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadedTranslationsCompanion toCompanion(bool nullToAbsent) {
    return DownloadedTranslationsCompanion(
      resourceId: Value(resourceId),
      name: Value(name),
      authorName: authorName == null && nullToAbsent
          ? const Value.absent()
          : Value(authorName),
      slug: slug == null && nullToAbsent ? const Value.absent() : Value(slug),
      languageName: languageName == null && nullToAbsent
          ? const Value.absent()
          : Value(languageName),
      resourceName: resourceName == null && nullToAbsent
          ? const Value.absent()
          : Value(resourceName),
      downloadedAt: Value(downloadedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadedTranslationEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadedTranslationEntry(
      resourceId: serializer.fromJson<int>(json['resourceId']),
      name: serializer.fromJson<String>(json['name']),
      authorName: serializer.fromJson<String?>(json['authorName']),
      slug: serializer.fromJson<String?>(json['slug']),
      languageName: serializer.fromJson<String?>(json['languageName']),
      resourceName: serializer.fromJson<String?>(json['resourceName']),
      downloadedAt: serializer.fromJson<DateTime>(json['downloadedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceId': serializer.toJson<int>(resourceId),
      'name': serializer.toJson<String>(name),
      'authorName': serializer.toJson<String?>(authorName),
      'slug': serializer.toJson<String?>(slug),
      'languageName': serializer.toJson<String?>(languageName),
      'resourceName': serializer.toJson<String?>(resourceName),
      'downloadedAt': serializer.toJson<DateTime>(downloadedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadedTranslationEntry copyWith({
    int? resourceId,
    String? name,
    Value<String?> authorName = const Value.absent(),
    Value<String?> slug = const Value.absent(),
    Value<String?> languageName = const Value.absent(),
    Value<String?> resourceName = const Value.absent(),
    DateTime? downloadedAt,
    DateTime? updatedAt,
  }) => DownloadedTranslationEntry(
    resourceId: resourceId ?? this.resourceId,
    name: name ?? this.name,
    authorName: authorName.present ? authorName.value : this.authorName,
    slug: slug.present ? slug.value : this.slug,
    languageName: languageName.present ? languageName.value : this.languageName,
    resourceName: resourceName.present ? resourceName.value : this.resourceName,
    downloadedAt: downloadedAt ?? this.downloadedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadedTranslationEntry copyWithCompanion(
    DownloadedTranslationsCompanion data,
  ) {
    return DownloadedTranslationEntry(
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      name: data.name.present ? data.name.value : this.name,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      slug: data.slug.present ? data.slug.value : this.slug,
      languageName: data.languageName.present
          ? data.languageName.value
          : this.languageName,
      resourceName: data.resourceName.present
          ? data.resourceName.value
          : this.resourceName,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTranslationEntry(')
          ..write('resourceId: $resourceId, ')
          ..write('name: $name, ')
          ..write('authorName: $authorName, ')
          ..write('slug: $slug, ')
          ..write('languageName: $languageName, ')
          ..write('resourceName: $resourceName, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resourceId,
    name,
    authorName,
    slug,
    languageName,
    resourceName,
    downloadedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadedTranslationEntry &&
          other.resourceId == this.resourceId &&
          other.name == this.name &&
          other.authorName == this.authorName &&
          other.slug == this.slug &&
          other.languageName == this.languageName &&
          other.resourceName == this.resourceName &&
          other.downloadedAt == this.downloadedAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadedTranslationsCompanion
    extends UpdateCompanion<DownloadedTranslationEntry> {
  final Value<int> resourceId;
  final Value<String> name;
  final Value<String?> authorName;
  final Value<String?> slug;
  final Value<String?> languageName;
  final Value<String?> resourceName;
  final Value<DateTime> downloadedAt;
  final Value<DateTime> updatedAt;
  const DownloadedTranslationsCompanion({
    this.resourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.authorName = const Value.absent(),
    this.slug = const Value.absent(),
    this.languageName = const Value.absent(),
    this.resourceName = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DownloadedTranslationsCompanion.insert({
    this.resourceId = const Value.absent(),
    required String name,
    this.authorName = const Value.absent(),
    this.slug = const Value.absent(),
    this.languageName = const Value.absent(),
    this.resourceName = const Value.absent(),
    required DateTime downloadedAt,
    required DateTime updatedAt,
  }) : name = Value(name),
       downloadedAt = Value(downloadedAt),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadedTranslationEntry> custom({
    Expression<int>? resourceId,
    Expression<String>? name,
    Expression<String>? authorName,
    Expression<String>? slug,
    Expression<String>? languageName,
    Expression<String>? resourceName,
    Expression<DateTime>? downloadedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (resourceId != null) 'resource_id': resourceId,
      if (name != null) 'name': name,
      if (authorName != null) 'author_name': authorName,
      if (slug != null) 'slug': slug,
      if (languageName != null) 'language_name': languageName,
      if (resourceName != null) 'resource_name': resourceName,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DownloadedTranslationsCompanion copyWith({
    Value<int>? resourceId,
    Value<String>? name,
    Value<String?>? authorName,
    Value<String?>? slug,
    Value<String?>? languageName,
    Value<String?>? resourceName,
    Value<DateTime>? downloadedAt,
    Value<DateTime>? updatedAt,
  }) {
    return DownloadedTranslationsCompanion(
      resourceId: resourceId ?? this.resourceId,
      name: name ?? this.name,
      authorName: authorName ?? this.authorName,
      slug: slug ?? this.slug,
      languageName: languageName ?? this.languageName,
      resourceName: resourceName ?? this.resourceName,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (languageName.present) {
      map['language_name'] = Variable<String>(languageName.value);
    }
    if (resourceName.present) {
      map['resource_name'] = Variable<String>(resourceName.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadedTranslationsCompanion(')
          ..write('resourceId: $resourceId, ')
          ..write('name: $name, ')
          ..write('authorName: $authorName, ')
          ..write('slug: $slug, ')
          ..write('languageName: $languageName, ')
          ..write('resourceName: $resourceName, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TafsirTextCacheTable extends TafsirTextCache
    with TableInfo<$TafsirTextCacheTable, TafsirTextCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TafsirTextCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tafsirTextMeta = const VerificationMeta(
    'tafsirText',
  );
  @override
  late final GeneratedColumn<String> tafsirText = GeneratedColumn<String>(
    'tafsir_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceNameMeta = const VerificationMeta(
    'resourceName',
  );
  @override
  late final GeneratedColumn<String> resourceName = GeneratedColumn<String>(
    'resource_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    resourceId,
    chapterId,
    ayahNumber,
    tafsirText,
    resourceName,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tafsir_text_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TafsirTextCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('tafsir_text')) {
      context.handle(
        _tafsirTextMeta,
        tafsirText.isAcceptableOrUnknown(data['tafsir_text']!, _tafsirTextMeta),
      );
    } else if (isInserting) {
      context.missing(_tafsirTextMeta);
    }
    if (data.containsKey('resource_name')) {
      context.handle(
        _resourceNameMeta,
        resourceName.isAcceptableOrUnknown(
          data['resource_name']!,
          _resourceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceNameMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resourceId, chapterId, ayahNumber};
  @override
  TafsirTextCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TafsirTextCacheEntry(
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      tafsirText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tafsir_text'],
      )!,
      resourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_name'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $TafsirTextCacheTable createAlias(String alias) {
    return $TafsirTextCacheTable(attachedDatabase, alias);
  }
}

class TafsirTextCacheEntry extends DataClass
    implements Insertable<TafsirTextCacheEntry> {
  final int resourceId;
  final int chapterId;
  final int ayahNumber;
  final String tafsirText;
  final String resourceName;
  final DateTime cachedAt;
  const TafsirTextCacheEntry({
    required this.resourceId,
    required this.chapterId,
    required this.ayahNumber,
    required this.tafsirText,
    required this.resourceName,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_id'] = Variable<int>(resourceId);
    map['chapter_id'] = Variable<int>(chapterId);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['tafsir_text'] = Variable<String>(tafsirText);
    map['resource_name'] = Variable<String>(resourceName);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  TafsirTextCacheCompanion toCompanion(bool nullToAbsent) {
    return TafsirTextCacheCompanion(
      resourceId: Value(resourceId),
      chapterId: Value(chapterId),
      ayahNumber: Value(ayahNumber),
      tafsirText: Value(tafsirText),
      resourceName: Value(resourceName),
      cachedAt: Value(cachedAt),
    );
  }

  factory TafsirTextCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TafsirTextCacheEntry(
      resourceId: serializer.fromJson<int>(json['resourceId']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      tafsirText: serializer.fromJson<String>(json['tafsirText']),
      resourceName: serializer.fromJson<String>(json['resourceName']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceId': serializer.toJson<int>(resourceId),
      'chapterId': serializer.toJson<int>(chapterId),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'tafsirText': serializer.toJson<String>(tafsirText),
      'resourceName': serializer.toJson<String>(resourceName),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  TafsirTextCacheEntry copyWith({
    int? resourceId,
    int? chapterId,
    int? ayahNumber,
    String? tafsirText,
    String? resourceName,
    DateTime? cachedAt,
  }) => TafsirTextCacheEntry(
    resourceId: resourceId ?? this.resourceId,
    chapterId: chapterId ?? this.chapterId,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    tafsirText: tafsirText ?? this.tafsirText,
    resourceName: resourceName ?? this.resourceName,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  TafsirTextCacheEntry copyWithCompanion(TafsirTextCacheCompanion data) {
    return TafsirTextCacheEntry(
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      tafsirText: data.tafsirText.present
          ? data.tafsirText.value
          : this.tafsirText,
      resourceName: data.resourceName.present
          ? data.resourceName.value
          : this.resourceName,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TafsirTextCacheEntry(')
          ..write('resourceId: $resourceId, ')
          ..write('chapterId: $chapterId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('tafsirText: $tafsirText, ')
          ..write('resourceName: $resourceName, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resourceId,
    chapterId,
    ayahNumber,
    tafsirText,
    resourceName,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TafsirTextCacheEntry &&
          other.resourceId == this.resourceId &&
          other.chapterId == this.chapterId &&
          other.ayahNumber == this.ayahNumber &&
          other.tafsirText == this.tafsirText &&
          other.resourceName == this.resourceName &&
          other.cachedAt == this.cachedAt);
}

class TafsirTextCacheCompanion extends UpdateCompanion<TafsirTextCacheEntry> {
  final Value<int> resourceId;
  final Value<int> chapterId;
  final Value<int> ayahNumber;
  final Value<String> tafsirText;
  final Value<String> resourceName;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const TafsirTextCacheCompanion({
    this.resourceId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.tafsirText = const Value.absent(),
    this.resourceName = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TafsirTextCacheCompanion.insert({
    required int resourceId,
    required int chapterId,
    required int ayahNumber,
    required String tafsirText,
    required String resourceName,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : resourceId = Value(resourceId),
       chapterId = Value(chapterId),
       ayahNumber = Value(ayahNumber),
       tafsirText = Value(tafsirText),
       resourceName = Value(resourceName),
       cachedAt = Value(cachedAt);
  static Insertable<TafsirTextCacheEntry> custom({
    Expression<int>? resourceId,
    Expression<int>? chapterId,
    Expression<int>? ayahNumber,
    Expression<String>? tafsirText,
    Expression<String>? resourceName,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resourceId != null) 'resource_id': resourceId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (tafsirText != null) 'tafsir_text': tafsirText,
      if (resourceName != null) 'resource_name': resourceName,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TafsirTextCacheCompanion copyWith({
    Value<int>? resourceId,
    Value<int>? chapterId,
    Value<int>? ayahNumber,
    Value<String>? tafsirText,
    Value<String>? resourceName,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return TafsirTextCacheCompanion(
      resourceId: resourceId ?? this.resourceId,
      chapterId: chapterId ?? this.chapterId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      tafsirText: tafsirText ?? this.tafsirText,
      resourceName: resourceName ?? this.resourceName,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (tafsirText.present) {
      map['tafsir_text'] = Variable<String>(tafsirText.value);
    }
    if (resourceName.present) {
      map['resource_name'] = Variable<String>(resourceName.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TafsirTextCacheCompanion(')
          ..write('resourceId: $resourceId, ')
          ..write('chapterId: $chapterId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('tafsirText: $tafsirText, ')
          ..write('resourceName: $resourceName, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranslationTextCacheTable extends TranslationTextCache
    with TableInfo<$TranslationTextCacheTable, TranslationTextCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranslationTextCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceIdMeta = const VerificationMeta(
    'resourceId',
  );
  @override
  late final GeneratedColumn<int> resourceId = GeneratedColumn<int>(
    'resource_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _ayahNumberMeta = const VerificationMeta(
    'ayahNumber',
  );
  @override
  late final GeneratedColumn<int> ayahNumber = GeneratedColumn<int>(
    'ayah_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _translationTextMeta = const VerificationMeta(
    'translationText',
  );
  @override
  late final GeneratedColumn<String> translationText = GeneratedColumn<String>(
    'translation_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resourceNameMeta = const VerificationMeta(
    'resourceName',
  );
  @override
  late final GeneratedColumn<String> resourceName = GeneratedColumn<String>(
    'resource_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    resourceId,
    chapterId,
    ayahNumber,
    translationText,
    resourceName,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'translation_text_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranslationTextCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_id')) {
      context.handle(
        _resourceIdMeta,
        resourceId.isAcceptableOrUnknown(data['resource_id']!, _resourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_resourceIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('ayah_number')) {
      context.handle(
        _ayahNumberMeta,
        ayahNumber.isAcceptableOrUnknown(data['ayah_number']!, _ayahNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_ayahNumberMeta);
    }
    if (data.containsKey('translation_text')) {
      context.handle(
        _translationTextMeta,
        translationText.isAcceptableOrUnknown(
          data['translation_text']!,
          _translationTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_translationTextMeta);
    }
    if (data.containsKey('resource_name')) {
      context.handle(
        _resourceNameMeta,
        resourceName.isAcceptableOrUnknown(
          data['resource_name']!,
          _resourceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceNameMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resourceId, chapterId, ayahNumber};
  @override
  TranslationTextCacheEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranslationTextCacheEntry(
      resourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resource_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      )!,
      ayahNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ayah_number'],
      )!,
      translationText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation_text'],
      )!,
      resourceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_name'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $TranslationTextCacheTable createAlias(String alias) {
    return $TranslationTextCacheTable(attachedDatabase, alias);
  }
}

class TranslationTextCacheEntry extends DataClass
    implements Insertable<TranslationTextCacheEntry> {
  final int resourceId;
  final int chapterId;
  final int ayahNumber;
  final String translationText;
  final String resourceName;
  final DateTime cachedAt;
  const TranslationTextCacheEntry({
    required this.resourceId,
    required this.chapterId,
    required this.ayahNumber,
    required this.translationText,
    required this.resourceName,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_id'] = Variable<int>(resourceId);
    map['chapter_id'] = Variable<int>(chapterId);
    map['ayah_number'] = Variable<int>(ayahNumber);
    map['translation_text'] = Variable<String>(translationText);
    map['resource_name'] = Variable<String>(resourceName);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  TranslationTextCacheCompanion toCompanion(bool nullToAbsent) {
    return TranslationTextCacheCompanion(
      resourceId: Value(resourceId),
      chapterId: Value(chapterId),
      ayahNumber: Value(ayahNumber),
      translationText: Value(translationText),
      resourceName: Value(resourceName),
      cachedAt: Value(cachedAt),
    );
  }

  factory TranslationTextCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranslationTextCacheEntry(
      resourceId: serializer.fromJson<int>(json['resourceId']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      ayahNumber: serializer.fromJson<int>(json['ayahNumber']),
      translationText: serializer.fromJson<String>(json['translationText']),
      resourceName: serializer.fromJson<String>(json['resourceName']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceId': serializer.toJson<int>(resourceId),
      'chapterId': serializer.toJson<int>(chapterId),
      'ayahNumber': serializer.toJson<int>(ayahNumber),
      'translationText': serializer.toJson<String>(translationText),
      'resourceName': serializer.toJson<String>(resourceName),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  TranslationTextCacheEntry copyWith({
    int? resourceId,
    int? chapterId,
    int? ayahNumber,
    String? translationText,
    String? resourceName,
    DateTime? cachedAt,
  }) => TranslationTextCacheEntry(
    resourceId: resourceId ?? this.resourceId,
    chapterId: chapterId ?? this.chapterId,
    ayahNumber: ayahNumber ?? this.ayahNumber,
    translationText: translationText ?? this.translationText,
    resourceName: resourceName ?? this.resourceName,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  TranslationTextCacheEntry copyWithCompanion(
    TranslationTextCacheCompanion data,
  ) {
    return TranslationTextCacheEntry(
      resourceId: data.resourceId.present
          ? data.resourceId.value
          : this.resourceId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      ayahNumber: data.ayahNumber.present
          ? data.ayahNumber.value
          : this.ayahNumber,
      translationText: data.translationText.present
          ? data.translationText.value
          : this.translationText,
      resourceName: data.resourceName.present
          ? data.resourceName.value
          : this.resourceName,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranslationTextCacheEntry(')
          ..write('resourceId: $resourceId, ')
          ..write('chapterId: $chapterId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('translationText: $translationText, ')
          ..write('resourceName: $resourceName, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resourceId,
    chapterId,
    ayahNumber,
    translationText,
    resourceName,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranslationTextCacheEntry &&
          other.resourceId == this.resourceId &&
          other.chapterId == this.chapterId &&
          other.ayahNumber == this.ayahNumber &&
          other.translationText == this.translationText &&
          other.resourceName == this.resourceName &&
          other.cachedAt == this.cachedAt);
}

class TranslationTextCacheCompanion
    extends UpdateCompanion<TranslationTextCacheEntry> {
  final Value<int> resourceId;
  final Value<int> chapterId;
  final Value<int> ayahNumber;
  final Value<String> translationText;
  final Value<String> resourceName;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const TranslationTextCacheCompanion({
    this.resourceId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.ayahNumber = const Value.absent(),
    this.translationText = const Value.absent(),
    this.resourceName = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranslationTextCacheCompanion.insert({
    required int resourceId,
    required int chapterId,
    required int ayahNumber,
    required String translationText,
    required String resourceName,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : resourceId = Value(resourceId),
       chapterId = Value(chapterId),
       ayahNumber = Value(ayahNumber),
       translationText = Value(translationText),
       resourceName = Value(resourceName),
       cachedAt = Value(cachedAt);
  static Insertable<TranslationTextCacheEntry> custom({
    Expression<int>? resourceId,
    Expression<int>? chapterId,
    Expression<int>? ayahNumber,
    Expression<String>? translationText,
    Expression<String>? resourceName,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resourceId != null) 'resource_id': resourceId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (ayahNumber != null) 'ayah_number': ayahNumber,
      if (translationText != null) 'translation_text': translationText,
      if (resourceName != null) 'resource_name': resourceName,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranslationTextCacheCompanion copyWith({
    Value<int>? resourceId,
    Value<int>? chapterId,
    Value<int>? ayahNumber,
    Value<String>? translationText,
    Value<String>? resourceName,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return TranslationTextCacheCompanion(
      resourceId: resourceId ?? this.resourceId,
      chapterId: chapterId ?? this.chapterId,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      translationText: translationText ?? this.translationText,
      resourceName: resourceName ?? this.resourceName,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceId.present) {
      map['resource_id'] = Variable<int>(resourceId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (ayahNumber.present) {
      map['ayah_number'] = Variable<int>(ayahNumber.value);
    }
    if (translationText.present) {
      map['translation_text'] = Variable<String>(translationText.value);
    }
    if (resourceName.present) {
      map['resource_name'] = Variable<String>(resourceName.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranslationTextCacheCompanion(')
          ..write('resourceId: $resourceId, ')
          ..write('chapterId: $chapterId, ')
          ..write('ayahNumber: $ayahNumber, ')
          ..write('translationText: $translationText, ')
          ..write('resourceName: $resourceName, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HisnContentCacheTable extends HisnContentCache
    with TableInfo<$HisnContentCacheTable, HisnContentCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HisnContentCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arabicTitleMeta = const VerificationMeta(
    'arabicTitle',
  );
  @override
  late final GeneratedColumn<String> arabicTitle = GeneratedColumn<String>(
    'arabic_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(99),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    subtitle,
    iconKey,
    count,
    arabicTitle,
    priority,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hisn_content_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<HisnContentCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    if (data.containsKey('arabic_title')) {
      context.handle(
        _arabicTitleMeta,
        arabicTitle.isAcceptableOrUnknown(
          data['arabic_title']!,
          _arabicTitleMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HisnContentCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HisnContentCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
      arabicTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}arabic_title'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $HisnContentCacheTable createAlias(String alias) {
    return $HisnContentCacheTable(attachedDatabase, alias);
  }
}

class HisnContentCacheEntry extends DataClass
    implements Insertable<HisnContentCacheEntry> {
  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final int count;
  final String? arabicTitle;
  final int priority;
  final String type;
  const HisnContentCacheEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.count,
    this.arabicTitle,
    required this.priority,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['icon_key'] = Variable<String>(iconKey);
    map['count'] = Variable<int>(count);
    if (!nullToAbsent || arabicTitle != null) {
      map['arabic_title'] = Variable<String>(arabicTitle);
    }
    map['priority'] = Variable<int>(priority);
    map['type'] = Variable<String>(type);
    return map;
  }

  HisnContentCacheCompanion toCompanion(bool nullToAbsent) {
    return HisnContentCacheCompanion(
      id: Value(id),
      title: Value(title),
      subtitle: Value(subtitle),
      iconKey: Value(iconKey),
      count: Value(count),
      arabicTitle: arabicTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(arabicTitle),
      priority: Value(priority),
      type: Value(type),
    );
  }

  factory HisnContentCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HisnContentCacheEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      count: serializer.fromJson<int>(json['count']),
      arabicTitle: serializer.fromJson<String?>(json['arabicTitle']),
      priority: serializer.fromJson<int>(json['priority']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'iconKey': serializer.toJson<String>(iconKey),
      'count': serializer.toJson<int>(count),
      'arabicTitle': serializer.toJson<String?>(arabicTitle),
      'priority': serializer.toJson<int>(priority),
      'type': serializer.toJson<String>(type),
    };
  }

  HisnContentCacheEntry copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? iconKey,
    int? count,
    Value<String?> arabicTitle = const Value.absent(),
    int? priority,
    String? type,
  }) => HisnContentCacheEntry(
    id: id ?? this.id,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    iconKey: iconKey ?? this.iconKey,
    count: count ?? this.count,
    arabicTitle: arabicTitle.present ? arabicTitle.value : this.arabicTitle,
    priority: priority ?? this.priority,
    type: type ?? this.type,
  );
  HisnContentCacheEntry copyWithCompanion(HisnContentCacheCompanion data) {
    return HisnContentCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      count: data.count.present ? data.count.value : this.count,
      arabicTitle: data.arabicTitle.present
          ? data.arabicTitle.value
          : this.arabicTitle,
      priority: data.priority.present ? data.priority.value : this.priority,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HisnContentCacheEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('iconKey: $iconKey, ')
          ..write('count: $count, ')
          ..write('arabicTitle: $arabicTitle, ')
          ..write('priority: $priority, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    subtitle,
    iconKey,
    count,
    arabicTitle,
    priority,
    type,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HisnContentCacheEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.iconKey == this.iconKey &&
          other.count == this.count &&
          other.arabicTitle == this.arabicTitle &&
          other.priority == this.priority &&
          other.type == this.type);
}

class HisnContentCacheCompanion extends UpdateCompanion<HisnContentCacheEntry> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> iconKey;
  final Value<int> count;
  final Value<String?> arabicTitle;
  final Value<int> priority;
  final Value<String> type;
  final Value<int> rowid;
  const HisnContentCacheCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.count = const Value.absent(),
    this.arabicTitle = const Value.absent(),
    this.priority = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HisnContentCacheCompanion.insert({
    required String id,
    required String title,
    required String subtitle,
    required String iconKey,
    required int count,
    this.arabicTitle = const Value.absent(),
    this.priority = const Value.absent(),
    required String type,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       subtitle = Value(subtitle),
       iconKey = Value(iconKey),
       count = Value(count),
       type = Value(type);
  static Insertable<HisnContentCacheEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? iconKey,
    Expression<int>? count,
    Expression<String>? arabicTitle,
    Expression<int>? priority,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (iconKey != null) 'icon_key': iconKey,
      if (count != null) 'count': count,
      if (arabicTitle != null) 'arabic_title': arabicTitle,
      if (priority != null) 'priority': priority,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HisnContentCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? subtitle,
    Value<String>? iconKey,
    Value<int>? count,
    Value<String?>? arabicTitle,
    Value<int>? priority,
    Value<String>? type,
    Value<int>? rowid,
  }) {
    return HisnContentCacheCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconKey: iconKey ?? this.iconKey,
      count: count ?? this.count,
      arabicTitle: arabicTitle ?? this.arabicTitle,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (arabicTitle.present) {
      map['arabic_title'] = Variable<String>(arabicTitle.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HisnContentCacheCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('iconKey: $iconKey, ')
          ..write('count: $count, ')
          ..write('arabicTitle: $arabicTitle, ')
          ..write('priority: $priority, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HisnContentItemCacheTable extends HisnContentItemCache
    with TableInfo<$HisnContentItemCacheTable, HisnContentItemCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HisnContentItemCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _contentTextMeta = const VerificationMeta(
    'contentText',
  );
  @override
  late final GeneratedColumn<String> contentText = GeneratedColumn<String>(
    'content_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatCountMeta = const VerificationMeta(
    'repeatCount',
  );
  @override
  late final GeneratedColumn<int> repeatCount = GeneratedColumn<int>(
    'repeat_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _fadlMeta = const VerificationMeta('fadl');
  @override
  late final GeneratedColumn<String> fadl = GeneratedColumn<String>(
    'fadl',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  @override
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    contentText,
    source,
    repeatCount,
    fadl,
    reference,
    translation,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hisn_content_item_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<HisnContentItemCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('content_text')) {
      context.handle(
        _contentTextMeta,
        contentText.isAcceptableOrUnknown(
          data['content_text']!,
          _contentTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentTextMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('repeat_count')) {
      context.handle(
        _repeatCountMeta,
        repeatCount.isAcceptableOrUnknown(
          data['repeat_count']!,
          _repeatCountMeta,
        ),
      );
    }
    if (data.containsKey('fadl')) {
      context.handle(
        _fadlMeta,
        fadl.isAcceptableOrUnknown(data['fadl']!, _fadlMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HisnContentItemCacheEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HisnContentItemCacheEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      contentText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_text'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      repeatCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_count'],
      )!,
      fadl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fadl'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $HisnContentItemCacheTable createAlias(String alias) {
    return $HisnContentItemCacheTable(attachedDatabase, alias);
  }
}

class HisnContentItemCacheEntry extends DataClass
    implements Insertable<HisnContentItemCacheEntry> {
  final String id;
  final String categoryId;
  final String contentText;
  final String source;
  final int repeatCount;
  final String? fadl;
  final String? reference;
  final String? translation;
  final String type;
  const HisnContentItemCacheEntry({
    required this.id,
    required this.categoryId,
    required this.contentText,
    required this.source,
    required this.repeatCount,
    this.fadl,
    this.reference,
    this.translation,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['content_text'] = Variable<String>(contentText);
    map['source'] = Variable<String>(source);
    map['repeat_count'] = Variable<int>(repeatCount);
    if (!nullToAbsent || fadl != null) {
      map['fadl'] = Variable<String>(fadl);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || translation != null) {
      map['translation'] = Variable<String>(translation);
    }
    map['type'] = Variable<String>(type);
    return map;
  }

  HisnContentItemCacheCompanion toCompanion(bool nullToAbsent) {
    return HisnContentItemCacheCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      contentText: Value(contentText),
      source: Value(source),
      repeatCount: Value(repeatCount),
      fadl: fadl == null && nullToAbsent ? const Value.absent() : Value(fadl),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      translation: translation == null && nullToAbsent
          ? const Value.absent()
          : Value(translation),
      type: Value(type),
    );
  }

  factory HisnContentItemCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HisnContentItemCacheEntry(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      contentText: serializer.fromJson<String>(json['contentText']),
      source: serializer.fromJson<String>(json['source']),
      repeatCount: serializer.fromJson<int>(json['repeatCount']),
      fadl: serializer.fromJson<String?>(json['fadl']),
      reference: serializer.fromJson<String?>(json['reference']),
      translation: serializer.fromJson<String?>(json['translation']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'contentText': serializer.toJson<String>(contentText),
      'source': serializer.toJson<String>(source),
      'repeatCount': serializer.toJson<int>(repeatCount),
      'fadl': serializer.toJson<String?>(fadl),
      'reference': serializer.toJson<String?>(reference),
      'translation': serializer.toJson<String?>(translation),
      'type': serializer.toJson<String>(type),
    };
  }

  HisnContentItemCacheEntry copyWith({
    String? id,
    String? categoryId,
    String? contentText,
    String? source,
    int? repeatCount,
    Value<String?> fadl = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    Value<String?> translation = const Value.absent(),
    String? type,
  }) => HisnContentItemCacheEntry(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    contentText: contentText ?? this.contentText,
    source: source ?? this.source,
    repeatCount: repeatCount ?? this.repeatCount,
    fadl: fadl.present ? fadl.value : this.fadl,
    reference: reference.present ? reference.value : this.reference,
    translation: translation.present ? translation.value : this.translation,
    type: type ?? this.type,
  );
  HisnContentItemCacheEntry copyWithCompanion(
    HisnContentItemCacheCompanion data,
  ) {
    return HisnContentItemCacheEntry(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      contentText: data.contentText.present
          ? data.contentText.value
          : this.contentText,
      source: data.source.present ? data.source.value : this.source,
      repeatCount: data.repeatCount.present
          ? data.repeatCount.value
          : this.repeatCount,
      fadl: data.fadl.present ? data.fadl.value : this.fadl,
      reference: data.reference.present ? data.reference.value : this.reference,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HisnContentItemCacheEntry(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('contentText: $contentText, ')
          ..write('source: $source, ')
          ..write('repeatCount: $repeatCount, ')
          ..write('fadl: $fadl, ')
          ..write('reference: $reference, ')
          ..write('translation: $translation, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    contentText,
    source,
    repeatCount,
    fadl,
    reference,
    translation,
    type,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HisnContentItemCacheEntry &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.contentText == this.contentText &&
          other.source == this.source &&
          other.repeatCount == this.repeatCount &&
          other.fadl == this.fadl &&
          other.reference == this.reference &&
          other.translation == this.translation &&
          other.type == this.type);
}

class HisnContentItemCacheCompanion
    extends UpdateCompanion<HisnContentItemCacheEntry> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> contentText;
  final Value<String> source;
  final Value<int> repeatCount;
  final Value<String?> fadl;
  final Value<String?> reference;
  final Value<String?> translation;
  final Value<String> type;
  final Value<int> rowid;
  const HisnContentItemCacheCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.contentText = const Value.absent(),
    this.source = const Value.absent(),
    this.repeatCount = const Value.absent(),
    this.fadl = const Value.absent(),
    this.reference = const Value.absent(),
    this.translation = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HisnContentItemCacheCompanion.insert({
    required String id,
    required String categoryId,
    required String contentText,
    required String source,
    this.repeatCount = const Value.absent(),
    this.fadl = const Value.absent(),
    this.reference = const Value.absent(),
    this.translation = const Value.absent(),
    required String type,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       contentText = Value(contentText),
       source = Value(source),
       type = Value(type);
  static Insertable<HisnContentItemCacheEntry> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? contentText,
    Expression<String>? source,
    Expression<int>? repeatCount,
    Expression<String>? fadl,
    Expression<String>? reference,
    Expression<String>? translation,
    Expression<String>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (contentText != null) 'content_text': contentText,
      if (source != null) 'source': source,
      if (repeatCount != null) 'repeat_count': repeatCount,
      if (fadl != null) 'fadl': fadl,
      if (reference != null) 'reference': reference,
      if (translation != null) 'translation': translation,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HisnContentItemCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<String>? contentText,
    Value<String>? source,
    Value<int>? repeatCount,
    Value<String?>? fadl,
    Value<String?>? reference,
    Value<String?>? translation,
    Value<String>? type,
    Value<int>? rowid,
  }) {
    return HisnContentItemCacheCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      contentText: contentText ?? this.contentText,
      source: source ?? this.source,
      repeatCount: repeatCount ?? this.repeatCount,
      fadl: fadl ?? this.fadl,
      reference: reference ?? this.reference,
      translation: translation ?? this.translation,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (contentText.present) {
      map['content_text'] = Variable<String>(contentText.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (repeatCount.present) {
      map['repeat_count'] = Variable<int>(repeatCount.value);
    }
    if (fadl.present) {
      map['fadl'] = Variable<String>(fadl.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HisnContentItemCacheCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('contentText: $contentText, ')
          ..write('source: $source, ')
          ..write('repeatCount: $repeatCount, ')
          ..write('fadl: $fadl, ')
          ..write('reference: $reference, ')
          ..write('translation: $translation, ')
          ..write('type: $type, ')
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
  late final $CategoryFavoritesTable categoryFavorites =
      $CategoryFavoritesTable(this);
  late final $QuranReadingProgressCacheTable quranReadingProgressCache =
      $QuranReadingProgressCacheTable(this);
  late final $QuranBookmarksTable quranBookmarks = $QuranBookmarksTable(this);
  late final $WirdsTableTable wirdsTable = $WirdsTableTable(this);
  late final $WirdDailyProgressTableTable wirdDailyProgressTable =
      $WirdDailyProgressTableTable(this);
  late final $WirdCycleHistoryTableTable wirdCycleHistoryTable =
      $WirdCycleHistoryTableTable(this);
  late final $WirdAchievementsTableTable wirdAchievementsTable =
      $WirdAchievementsTableTable(this);
  late final $DownloadedTafsirsTable downloadedTafsirs =
      $DownloadedTafsirsTable(this);
  late final $DownloadedTranslationsTable downloadedTranslations =
      $DownloadedTranslationsTable(this);
  late final $TafsirTextCacheTable tafsirTextCache = $TafsirTextCacheTable(
    this,
  );
  late final $TranslationTextCacheTable translationTextCache =
      $TranslationTextCacheTable(this);
  late final $HisnContentCacheTable hisnContentCache = $HisnContentCacheTable(
    this,
  );
  late final $HisnContentItemCacheTable hisnContentItemCache =
      $HisnContentItemCacheTable(this);
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
  late final Index downloadedTafsirsResourceId = Index(
    'downloaded_tafsirs_resource_id',
    'CREATE INDEX downloaded_tafsirs_resource_id ON downloaded_tafsirs (resource_id)',
  );
  late final Index downloadedTafsirsUpdatedAt = Index(
    'downloaded_tafsirs_updated_at',
    'CREATE INDEX downloaded_tafsirs_updated_at ON downloaded_tafsirs (updated_at)',
  );
  late final Index downloadedTranslationsResourceId = Index(
    'downloaded_translations_resource_id',
    'CREATE INDEX downloaded_translations_resource_id ON downloaded_translations (resource_id)',
  );
  late final Index downloadedTranslationsUpdatedAt = Index(
    'downloaded_translations_updated_at',
    'CREATE INDEX downloaded_translations_updated_at ON downloaded_translations (updated_at)',
  );
  late final Index tafsirTextCacheResourceChapterAyah = Index(
    'tafsir_text_cache_resource_chapter_ayah',
    'CREATE INDEX tafsir_text_cache_resource_chapter_ayah ON tafsir_text_cache (resource_id, chapter_id, ayah_number)',
  );
  late final Index tafsirTextCacheUpdatedAt = Index(
    'tafsir_text_cache_updated_at',
    'CREATE INDEX tafsir_text_cache_updated_at ON tafsir_text_cache (cached_at)',
  );
  late final Index translationTextCacheResourceChapterAyah = Index(
    'translation_text_cache_resource_chapter_ayah',
    'CREATE INDEX translation_text_cache_resource_chapter_ayah ON translation_text_cache (resource_id, chapter_id, ayah_number)',
  );
  late final Index translationTextCacheUpdatedAt = Index(
    'translation_text_cache_updated_at',
    'CREATE INDEX translation_text_cache_updated_at ON translation_text_cache (cached_at)',
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
    categoryFavorites,
    quranReadingProgressCache,
    quranBookmarks,
    wirdsTable,
    wirdDailyProgressTable,
    wirdCycleHistoryTable,
    wirdAchievementsTable,
    downloadedTafsirs,
    downloadedTranslations,
    tafsirTextCache,
    translationTextCache,
    hisnContentCache,
    hisnContentItemCache,
    quranChapterCacheUpdatedAt,
    quranVerseCacheChapterVerse,
    quranVerseCachePageNumber,
    quranVerseCacheUpdatedAt,
    quranRecitationCacheLanguage,
    quranRecitationCacheUpdatedAt,
    downloadedTafsirsResourceId,
    downloadedTafsirsUpdatedAt,
    downloadedTranslationsResourceId,
    downloadedTranslationsUpdatedAt,
    tafsirTextCacheResourceChapterAyah,
    tafsirTextCacheUpdatedAt,
    translationTextCacheResourceChapterAyah,
    translationTextCacheUpdatedAt,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wirds_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('wird_daily_progress_table', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wirds_table',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('wird_cycle_history_table', kind: UpdateKind.delete),
      ],
    ),
  ]);
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
typedef $$CategoryFavoritesTableCreateCompanionBuilder =
    CategoryFavoritesCompanion Function({
      required String categoryId,
      required String type,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CategoryFavoritesTableUpdateCompanionBuilder =
    CategoryFavoritesCompanion Function({
      Value<String> categoryId,
      Value<String> type,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CategoryFavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryFavoritesTable> {
  $$CategoryFavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoryFavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryFavoritesTable> {
  $$CategoryFavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoryFavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryFavoritesTable> {
  $$CategoryFavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategoryFavoritesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryFavoritesTable,
          CategoryFavoritesEntry,
          $$CategoryFavoritesTableFilterComposer,
          $$CategoryFavoritesTableOrderingComposer,
          $$CategoryFavoritesTableAnnotationComposer,
          $$CategoryFavoritesTableCreateCompanionBuilder,
          $$CategoryFavoritesTableUpdateCompanionBuilder,
          (
            CategoryFavoritesEntry,
            BaseReferences<
              _$AppDatabase,
              $CategoryFavoritesTable,
              CategoryFavoritesEntry
            >,
          ),
          CategoryFavoritesEntry,
          PrefetchHooks Function()
        > {
  $$CategoryFavoritesTableTableManager(
    _$AppDatabase db,
    $CategoryFavoritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryFavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryFavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryFavoritesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> categoryId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoryFavoritesCompanion(
                categoryId: categoryId,
                type: type,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String categoryId,
                required String type,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategoryFavoritesCompanion.insert(
                categoryId: categoryId,
                type: type,
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

typedef $$CategoryFavoritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryFavoritesTable,
      CategoryFavoritesEntry,
      $$CategoryFavoritesTableFilterComposer,
      $$CategoryFavoritesTableOrderingComposer,
      $$CategoryFavoritesTableAnnotationComposer,
      $$CategoryFavoritesTableCreateCompanionBuilder,
      $$CategoryFavoritesTableUpdateCompanionBuilder,
      (
        CategoryFavoritesEntry,
        BaseReferences<
          _$AppDatabase,
          $CategoryFavoritesTable,
          CategoryFavoritesEntry
        >,
      ),
      CategoryFavoritesEntry,
      PrefetchHooks Function()
    >;
typedef $$QuranReadingProgressCacheTableCreateCompanionBuilder =
    QuranReadingProgressCacheCompanion Function({
      Value<int> id,
      required int lastPage,
      required int lastSurahNumber,
      required DateTime updatedAt,
    });
typedef $$QuranReadingProgressCacheTableUpdateCompanionBuilder =
    QuranReadingProgressCacheCompanion Function({
      Value<int> id,
      Value<int> lastPage,
      Value<int> lastSurahNumber,
      Value<DateTime> updatedAt,
    });

class $$QuranReadingProgressCacheTableFilterComposer
    extends Composer<_$AppDatabase, $QuranReadingProgressCacheTable> {
  $$QuranReadingProgressCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSurahNumber => $composableBuilder(
    column: $table.lastSurahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranReadingProgressCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $QuranReadingProgressCacheTable> {
  $$QuranReadingProgressCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPage => $composableBuilder(
    column: $table.lastPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSurahNumber => $composableBuilder(
    column: $table.lastSurahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranReadingProgressCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuranReadingProgressCacheTable> {
  $$QuranReadingProgressCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get lastPage =>
      $composableBuilder(column: $table.lastPage, builder: (column) => column);

  GeneratedColumn<int> get lastSurahNumber => $composableBuilder(
    column: $table.lastSurahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuranReadingProgressCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuranReadingProgressCacheTable,
          QuranReadingProgressEntry,
          $$QuranReadingProgressCacheTableFilterComposer,
          $$QuranReadingProgressCacheTableOrderingComposer,
          $$QuranReadingProgressCacheTableAnnotationComposer,
          $$QuranReadingProgressCacheTableCreateCompanionBuilder,
          $$QuranReadingProgressCacheTableUpdateCompanionBuilder,
          (
            QuranReadingProgressEntry,
            BaseReferences<
              _$AppDatabase,
              $QuranReadingProgressCacheTable,
              QuranReadingProgressEntry
            >,
          ),
          QuranReadingProgressEntry,
          PrefetchHooks Function()
        > {
  $$QuranReadingProgressCacheTableTableManager(
    _$AppDatabase db,
    $QuranReadingProgressCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranReadingProgressCacheTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$QuranReadingProgressCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuranReadingProgressCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> lastPage = const Value.absent(),
                Value<int> lastSurahNumber = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => QuranReadingProgressCacheCompanion(
                id: id,
                lastPage: lastPage,
                lastSurahNumber: lastSurahNumber,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int lastPage,
                required int lastSurahNumber,
                required DateTime updatedAt,
              }) => QuranReadingProgressCacheCompanion.insert(
                id: id,
                lastPage: lastPage,
                lastSurahNumber: lastSurahNumber,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranReadingProgressCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuranReadingProgressCacheTable,
      QuranReadingProgressEntry,
      $$QuranReadingProgressCacheTableFilterComposer,
      $$QuranReadingProgressCacheTableOrderingComposer,
      $$QuranReadingProgressCacheTableAnnotationComposer,
      $$QuranReadingProgressCacheTableCreateCompanionBuilder,
      $$QuranReadingProgressCacheTableUpdateCompanionBuilder,
      (
        QuranReadingProgressEntry,
        BaseReferences<
          _$AppDatabase,
          $QuranReadingProgressCacheTable,
          QuranReadingProgressEntry
        >,
      ),
      QuranReadingProgressEntry,
      PrefetchHooks Function()
    >;
typedef $$QuranBookmarksTableCreateCompanionBuilder =
    QuranBookmarksCompanion Function({
      Value<int> id,
      required int page,
      required int surahNumber,
      Value<int?> ayahNumber,
      Value<String?> label,
      required DateTime createdAt,
    });
typedef $$QuranBookmarksTableUpdateCompanionBuilder =
    QuranBookmarksCompanion Function({
      Value<int> id,
      Value<int> page,
      Value<int> surahNumber,
      Value<int?> ayahNumber,
      Value<String?> label,
      Value<DateTime> createdAt,
    });

class $$QuranBookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $QuranBookmarksTable> {
  $$QuranBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuranBookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $QuranBookmarksTable> {
  $$QuranBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuranBookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuranBookmarksTable> {
  $$QuranBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<int> get surahNumber => $composableBuilder(
    column: $table.surahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$QuranBookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuranBookmarksTable,
          QuranBookmarkEntry,
          $$QuranBookmarksTableFilterComposer,
          $$QuranBookmarksTableOrderingComposer,
          $$QuranBookmarksTableAnnotationComposer,
          $$QuranBookmarksTableCreateCompanionBuilder,
          $$QuranBookmarksTableUpdateCompanionBuilder,
          (
            QuranBookmarkEntry,
            BaseReferences<
              _$AppDatabase,
              $QuranBookmarksTable,
              QuranBookmarkEntry
            >,
          ),
          QuranBookmarkEntry,
          PrefetchHooks Function()
        > {
  $$QuranBookmarksTableTableManager(
    _$AppDatabase db,
    $QuranBookmarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuranBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuranBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuranBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> page = const Value.absent(),
                Value<int> surahNumber = const Value.absent(),
                Value<int?> ayahNumber = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => QuranBookmarksCompanion(
                id: id,
                page: page,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                label: label,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int page,
                required int surahNumber,
                Value<int?> ayahNumber = const Value.absent(),
                Value<String?> label = const Value.absent(),
                required DateTime createdAt,
              }) => QuranBookmarksCompanion.insert(
                id: id,
                page: page,
                surahNumber: surahNumber,
                ayahNumber: ayahNumber,
                label: label,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuranBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuranBookmarksTable,
      QuranBookmarkEntry,
      $$QuranBookmarksTableFilterComposer,
      $$QuranBookmarksTableOrderingComposer,
      $$QuranBookmarksTableAnnotationComposer,
      $$QuranBookmarksTableCreateCompanionBuilder,
      $$QuranBookmarksTableUpdateCompanionBuilder,
      (
        QuranBookmarkEntry,
        BaseReferences<_$AppDatabase, $QuranBookmarksTable, QuranBookmarkEntry>,
      ),
      QuranBookmarkEntry,
      PrefetchHooks Function()
    >;
typedef $$WirdsTableTableCreateCompanionBuilder =
    WirdsTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> goalType,
      Value<String> status,
      Value<int> startPage,
      Value<int> endPage,
      Value<int?> pagesPerDay,
      Value<DateTime> startDate,
      Value<DateTime?> targetDate,
      Value<String> scheduleType,
      Value<String> activeWeekdays,
      Value<bool> isFlexible,
      Value<bool> allowCatchUp,
      Value<bool> autoStartNextKhatma,
      Value<int> currentCycle,
      required DateTime createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<String?> amountType,
      Value<int?> amountMultiplier,
      Value<int?> durationDays,
      Value<String?> frequency,
      Value<String?> reminderTime,
      Value<DateTime?> lastReadDate,
      Value<int?> completedDaysCount,
    });
typedef $$WirdsTableTableUpdateCompanionBuilder =
    WirdsTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> goalType,
      Value<String> status,
      Value<int> startPage,
      Value<int> endPage,
      Value<int?> pagesPerDay,
      Value<DateTime> startDate,
      Value<DateTime?> targetDate,
      Value<String> scheduleType,
      Value<String> activeWeekdays,
      Value<bool> isFlexible,
      Value<bool> allowCatchUp,
      Value<bool> autoStartNextKhatma,
      Value<int> currentCycle,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> completedAt,
      Value<String?> amountType,
      Value<int?> amountMultiplier,
      Value<int?> durationDays,
      Value<String?> frequency,
      Value<String?> reminderTime,
      Value<DateTime?> lastReadDate,
      Value<int?> completedDaysCount,
    });

final class $$WirdsTableTableReferences
    extends BaseReferences<_$AppDatabase, $WirdsTableTable, WirdEntry> {
  $$WirdsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $WirdDailyProgressTableTable,
    List<WirdDailyProgressEntry>
  >
  _wirdDailyProgressTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.wirdDailyProgressTable,
        aliasName: 'wirds_table__id__wird_daily_progress_table__wird_id',
      );

  $$WirdDailyProgressTableTableProcessedTableManager
  get wirdDailyProgressTableRefs {
    final manager = $$WirdDailyProgressTableTableTableManager(
      $_db,
      $_db.wirdDailyProgressTable,
    ).filter((f) => f.wirdId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _wirdDailyProgressTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WirdCycleHistoryTableTable,
    List<WirdCycleHistoryEntry>
  >
  _wirdCycleHistoryTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.wirdCycleHistoryTable,
        aliasName: 'wirds_table__id__wird_cycle_history_table__wird_id',
      );

  $$WirdCycleHistoryTableTableProcessedTableManager
  get wirdCycleHistoryTableRefs {
    final manager = $$WirdCycleHistoryTableTableTableManager(
      $_db,
      $_db.wirdCycleHistoryTable,
    ).filter((f) => f.wirdId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _wirdCycleHistoryTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WirdsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WirdsTableTable> {
  $$WirdsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pagesPerDay => $composableBuilder(
    column: $table.pagesPerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeWeekdays => $composableBuilder(
    column: $table.activeWeekdays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFlexible => $composableBuilder(
    column: $table.isFlexible,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowCatchUp => $composableBuilder(
    column: $table.allowCatchUp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoStartNextKhatma => $composableBuilder(
    column: $table.autoStartNextKhatma,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentCycle => $composableBuilder(
    column: $table.currentCycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountType => $composableBuilder(
    column: $table.amountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMultiplier => $composableBuilder(
    column: $table.amountMultiplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedDaysCount => $composableBuilder(
    column: $table.completedDaysCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> wirdDailyProgressTableRefs(
    Expression<bool> Function($$WirdDailyProgressTableTableFilterComposer f) f,
  ) {
    final $$WirdDailyProgressTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.wirdDailyProgressTable,
          getReferencedColumn: (t) => t.wirdId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WirdDailyProgressTableTableFilterComposer(
                $db: $db,
                $table: $db.wirdDailyProgressTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> wirdCycleHistoryTableRefs(
    Expression<bool> Function($$WirdCycleHistoryTableTableFilterComposer f) f,
  ) {
    final $$WirdCycleHistoryTableTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.wirdCycleHistoryTable,
          getReferencedColumn: (t) => t.wirdId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WirdCycleHistoryTableTableFilterComposer(
                $db: $db,
                $table: $db.wirdCycleHistoryTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WirdsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WirdsTableTable> {
  $$WirdsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goalType => $composableBuilder(
    column: $table.goalType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesPerDay => $composableBuilder(
    column: $table.pagesPerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeWeekdays => $composableBuilder(
    column: $table.activeWeekdays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFlexible => $composableBuilder(
    column: $table.isFlexible,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowCatchUp => $composableBuilder(
    column: $table.allowCatchUp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoStartNextKhatma => $composableBuilder(
    column: $table.autoStartNextKhatma,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentCycle => $composableBuilder(
    column: $table.currentCycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountType => $composableBuilder(
    column: $table.amountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMultiplier => $composableBuilder(
    column: $table.amountMultiplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedDaysCount => $composableBuilder(
    column: $table.completedDaysCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WirdsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WirdsTableTable> {
  $$WirdsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get goalType =>
      $composableBuilder(column: $table.goalType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get startPage =>
      $composableBuilder(column: $table.startPage, builder: (column) => column);

  GeneratedColumn<int> get endPage =>
      $composableBuilder(column: $table.endPage, builder: (column) => column);

  GeneratedColumn<int> get pagesPerDay => $composableBuilder(
    column: $table.pagesPerDay,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeWeekdays => $composableBuilder(
    column: $table.activeWeekdays,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFlexible => $composableBuilder(
    column: $table.isFlexible,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowCatchUp => $composableBuilder(
    column: $table.allowCatchUp,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoStartNextKhatma => $composableBuilder(
    column: $table.autoStartNextKhatma,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentCycle => $composableBuilder(
    column: $table.currentCycle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amountType => $composableBuilder(
    column: $table.amountType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMultiplier => $composableBuilder(
    column: $table.amountMultiplier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastReadDate => $composableBuilder(
    column: $table.lastReadDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedDaysCount => $composableBuilder(
    column: $table.completedDaysCount,
    builder: (column) => column,
  );

  Expression<T> wirdDailyProgressTableRefs<T extends Object>(
    Expression<T> Function($$WirdDailyProgressTableTableAnnotationComposer a) f,
  ) {
    final $$WirdDailyProgressTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.wirdDailyProgressTable,
          getReferencedColumn: (t) => t.wirdId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WirdDailyProgressTableTableAnnotationComposer(
                $db: $db,
                $table: $db.wirdDailyProgressTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> wirdCycleHistoryTableRefs<T extends Object>(
    Expression<T> Function($$WirdCycleHistoryTableTableAnnotationComposer a) f,
  ) {
    final $$WirdCycleHistoryTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.wirdCycleHistoryTable,
          getReferencedColumn: (t) => t.wirdId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WirdCycleHistoryTableTableAnnotationComposer(
                $db: $db,
                $table: $db.wirdCycleHistoryTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WirdsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WirdsTableTable,
          WirdEntry,
          $$WirdsTableTableFilterComposer,
          $$WirdsTableTableOrderingComposer,
          $$WirdsTableTableAnnotationComposer,
          $$WirdsTableTableCreateCompanionBuilder,
          $$WirdsTableTableUpdateCompanionBuilder,
          (WirdEntry, $$WirdsTableTableReferences),
          WirdEntry,
          PrefetchHooks Function({
            bool wirdDailyProgressTableRefs,
            bool wirdCycleHistoryTableRefs,
          })
        > {
  $$WirdsTableTableTableManager(_$AppDatabase db, $WirdsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WirdsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WirdsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WirdsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> goalType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startPage = const Value.absent(),
                Value<int> endPage = const Value.absent(),
                Value<int?> pagesPerDay = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<String> activeWeekdays = const Value.absent(),
                Value<bool> isFlexible = const Value.absent(),
                Value<bool> allowCatchUp = const Value.absent(),
                Value<bool> autoStartNextKhatma = const Value.absent(),
                Value<int> currentCycle = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> amountType = const Value.absent(),
                Value<int?> amountMultiplier = const Value.absent(),
                Value<int?> durationDays = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<DateTime?> lastReadDate = const Value.absent(),
                Value<int?> completedDaysCount = const Value.absent(),
              }) => WirdsTableCompanion(
                id: id,
                name: name,
                goalType: goalType,
                status: status,
                startPage: startPage,
                endPage: endPage,
                pagesPerDay: pagesPerDay,
                startDate: startDate,
                targetDate: targetDate,
                scheduleType: scheduleType,
                activeWeekdays: activeWeekdays,
                isFlexible: isFlexible,
                allowCatchUp: allowCatchUp,
                autoStartNextKhatma: autoStartNextKhatma,
                currentCycle: currentCycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                amountType: amountType,
                amountMultiplier: amountMultiplier,
                durationDays: durationDays,
                frequency: frequency,
                reminderTime: reminderTime,
                lastReadDate: lastReadDate,
                completedDaysCount: completedDaysCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> goalType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> startPage = const Value.absent(),
                Value<int> endPage = const Value.absent(),
                Value<int?> pagesPerDay = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String> scheduleType = const Value.absent(),
                Value<String> activeWeekdays = const Value.absent(),
                Value<bool> isFlexible = const Value.absent(),
                Value<bool> allowCatchUp = const Value.absent(),
                Value<bool> autoStartNextKhatma = const Value.absent(),
                Value<int> currentCycle = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> amountType = const Value.absent(),
                Value<int?> amountMultiplier = const Value.absent(),
                Value<int?> durationDays = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<String?> reminderTime = const Value.absent(),
                Value<DateTime?> lastReadDate = const Value.absent(),
                Value<int?> completedDaysCount = const Value.absent(),
              }) => WirdsTableCompanion.insert(
                id: id,
                name: name,
                goalType: goalType,
                status: status,
                startPage: startPage,
                endPage: endPage,
                pagesPerDay: pagesPerDay,
                startDate: startDate,
                targetDate: targetDate,
                scheduleType: scheduleType,
                activeWeekdays: activeWeekdays,
                isFlexible: isFlexible,
                allowCatchUp: allowCatchUp,
                autoStartNextKhatma: autoStartNextKhatma,
                currentCycle: currentCycle,
                createdAt: createdAt,
                updatedAt: updatedAt,
                completedAt: completedAt,
                amountType: amountType,
                amountMultiplier: amountMultiplier,
                durationDays: durationDays,
                frequency: frequency,
                reminderTime: reminderTime,
                lastReadDate: lastReadDate,
                completedDaysCount: completedDaysCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WirdsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                wirdDailyProgressTableRefs = false,
                wirdCycleHistoryTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (wirdDailyProgressTableRefs) db.wirdDailyProgressTable,
                    if (wirdCycleHistoryTableRefs) db.wirdCycleHistoryTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (wirdDailyProgressTableRefs)
                        await $_getPrefetchedData<
                          WirdEntry,
                          $WirdsTableTable,
                          WirdDailyProgressEntry
                        >(
                          currentTable: table,
                          referencedTable: $$WirdsTableTableReferences
                              ._wirdDailyProgressTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WirdsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).wirdDailyProgressTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wirdId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (wirdCycleHistoryTableRefs)
                        await $_getPrefetchedData<
                          WirdEntry,
                          $WirdsTableTable,
                          WirdCycleHistoryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$WirdsTableTableReferences
                              ._wirdCycleHistoryTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WirdsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).wirdCycleHistoryTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.wirdId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WirdsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WirdsTableTable,
      WirdEntry,
      $$WirdsTableTableFilterComposer,
      $$WirdsTableTableOrderingComposer,
      $$WirdsTableTableAnnotationComposer,
      $$WirdsTableTableCreateCompanionBuilder,
      $$WirdsTableTableUpdateCompanionBuilder,
      (WirdEntry, $$WirdsTableTableReferences),
      WirdEntry,
      PrefetchHooks Function({
        bool wirdDailyProgressTableRefs,
        bool wirdCycleHistoryTableRefs,
      })
    >;
typedef $$WirdDailyProgressTableTableCreateCompanionBuilder =
    WirdDailyProgressTableCompanion Function({
      Value<int> id,
      required int wirdId,
      required String dateKey,
      required int plannedStartPage,
      required int plannedEndPage,
      required int actualStartPage,
      required int actualEndPage,
      required int targetPages,
      required int completedPages,
      required String status,
      Value<DateTime?> completedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$WirdDailyProgressTableTableUpdateCompanionBuilder =
    WirdDailyProgressTableCompanion Function({
      Value<int> id,
      Value<int> wirdId,
      Value<String> dateKey,
      Value<int> plannedStartPage,
      Value<int> plannedEndPage,
      Value<int> actualStartPage,
      Value<int> actualEndPage,
      Value<int> targetPages,
      Value<int> completedPages,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$WirdDailyProgressTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WirdDailyProgressTableTable,
          WirdDailyProgressEntry
        > {
  $$WirdDailyProgressTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WirdsTableTable _wirdIdTable(_$AppDatabase db) => db.wirdsTable
      .createAlias('wird_daily_progress_table__wird_id__wirds_table__id');

  $$WirdsTableTableProcessedTableManager get wirdId {
    final $_column = $_itemColumn<int>('wird_id')!;

    final manager = $$WirdsTableTableTableManager(
      $_db,
      $_db.wirdsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wirdIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WirdDailyProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $WirdDailyProgressTableTable> {
  $$WirdDailyProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedStartPage => $composableBuilder(
    column: $table.plannedStartPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedEndPage => $composableBuilder(
    column: $table.plannedEndPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualStartPage => $composableBuilder(
    column: $table.actualStartPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualEndPage => $composableBuilder(
    column: $table.actualEndPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetPages => $composableBuilder(
    column: $table.targetPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedPages => $composableBuilder(
    column: $table.completedPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WirdsTableTableFilterComposer get wirdId {
    final $$WirdsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wirdId,
      referencedTable: $db.wirdsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WirdsTableTableFilterComposer(
            $db: $db,
            $table: $db.wirdsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WirdDailyProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WirdDailyProgressTableTable> {
  $$WirdDailyProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateKey => $composableBuilder(
    column: $table.dateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedStartPage => $composableBuilder(
    column: $table.plannedStartPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedEndPage => $composableBuilder(
    column: $table.plannedEndPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualStartPage => $composableBuilder(
    column: $table.actualStartPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualEndPage => $composableBuilder(
    column: $table.actualEndPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetPages => $composableBuilder(
    column: $table.targetPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedPages => $composableBuilder(
    column: $table.completedPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WirdsTableTableOrderingComposer get wirdId {
    final $$WirdsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wirdId,
      referencedTable: $db.wirdsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WirdsTableTableOrderingComposer(
            $db: $db,
            $table: $db.wirdsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WirdDailyProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WirdDailyProgressTableTable> {
  $$WirdDailyProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<int> get plannedStartPage => $composableBuilder(
    column: $table.plannedStartPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedEndPage => $composableBuilder(
    column: $table.plannedEndPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualStartPage => $composableBuilder(
    column: $table.actualStartPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualEndPage => $composableBuilder(
    column: $table.actualEndPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetPages => $composableBuilder(
    column: $table.targetPages,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedPages => $composableBuilder(
    column: $table.completedPages,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$WirdsTableTableAnnotationComposer get wirdId {
    final $$WirdsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wirdId,
      referencedTable: $db.wirdsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WirdsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.wirdsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WirdDailyProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WirdDailyProgressTableTable,
          WirdDailyProgressEntry,
          $$WirdDailyProgressTableTableFilterComposer,
          $$WirdDailyProgressTableTableOrderingComposer,
          $$WirdDailyProgressTableTableAnnotationComposer,
          $$WirdDailyProgressTableTableCreateCompanionBuilder,
          $$WirdDailyProgressTableTableUpdateCompanionBuilder,
          (WirdDailyProgressEntry, $$WirdDailyProgressTableTableReferences),
          WirdDailyProgressEntry,
          PrefetchHooks Function({bool wirdId})
        > {
  $$WirdDailyProgressTableTableTableManager(
    _$AppDatabase db,
    $WirdDailyProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WirdDailyProgressTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WirdDailyProgressTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WirdDailyProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wirdId = const Value.absent(),
                Value<String> dateKey = const Value.absent(),
                Value<int> plannedStartPage = const Value.absent(),
                Value<int> plannedEndPage = const Value.absent(),
                Value<int> actualStartPage = const Value.absent(),
                Value<int> actualEndPage = const Value.absent(),
                Value<int> targetPages = const Value.absent(),
                Value<int> completedPages = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WirdDailyProgressTableCompanion(
                id: id,
                wirdId: wirdId,
                dateKey: dateKey,
                plannedStartPage: plannedStartPage,
                plannedEndPage: plannedEndPage,
                actualStartPage: actualStartPage,
                actualEndPage: actualEndPage,
                targetPages: targetPages,
                completedPages: completedPages,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wirdId,
                required String dateKey,
                required int plannedStartPage,
                required int plannedEndPage,
                required int actualStartPage,
                required int actualEndPage,
                required int targetPages,
                required int completedPages,
                required String status,
                Value<DateTime?> completedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => WirdDailyProgressTableCompanion.insert(
                id: id,
                wirdId: wirdId,
                dateKey: dateKey,
                plannedStartPage: plannedStartPage,
                plannedEndPage: plannedEndPage,
                actualStartPage: actualStartPage,
                actualEndPage: actualEndPage,
                targetPages: targetPages,
                completedPages: completedPages,
                status: status,
                completedAt: completedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WirdDailyProgressTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wirdId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wirdId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wirdId,
                                referencedTable:
                                    $$WirdDailyProgressTableTableReferences
                                        ._wirdIdTable(db),
                                referencedColumn:
                                    $$WirdDailyProgressTableTableReferences
                                        ._wirdIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WirdDailyProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WirdDailyProgressTableTable,
      WirdDailyProgressEntry,
      $$WirdDailyProgressTableTableFilterComposer,
      $$WirdDailyProgressTableTableOrderingComposer,
      $$WirdDailyProgressTableTableAnnotationComposer,
      $$WirdDailyProgressTableTableCreateCompanionBuilder,
      $$WirdDailyProgressTableTableUpdateCompanionBuilder,
      (WirdDailyProgressEntry, $$WirdDailyProgressTableTableReferences),
      WirdDailyProgressEntry,
      PrefetchHooks Function({bool wirdId})
    >;
typedef $$WirdCycleHistoryTableTableCreateCompanionBuilder =
    WirdCycleHistoryTableCompanion Function({
      Value<int> id,
      required int wirdId,
      required int cycleNumber,
      required DateTime startDate,
      Value<DateTime?> completedDate,
      required int startPage,
      required int endPage,
      required int actualCompletedPages,
      required DateTime createdAt,
    });
typedef $$WirdCycleHistoryTableTableUpdateCompanionBuilder =
    WirdCycleHistoryTableCompanion Function({
      Value<int> id,
      Value<int> wirdId,
      Value<int> cycleNumber,
      Value<DateTime> startDate,
      Value<DateTime?> completedDate,
      Value<int> startPage,
      Value<int> endPage,
      Value<int> actualCompletedPages,
      Value<DateTime> createdAt,
    });

final class $$WirdCycleHistoryTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WirdCycleHistoryTableTable,
          WirdCycleHistoryEntry
        > {
  $$WirdCycleHistoryTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WirdsTableTable _wirdIdTable(_$AppDatabase db) => db.wirdsTable
      .createAlias('wird_cycle_history_table__wird_id__wirds_table__id');

  $$WirdsTableTableProcessedTableManager get wirdId {
    final $_column = $_itemColumn<int>('wird_id')!;

    final manager = $$WirdsTableTableTableManager(
      $_db,
      $_db.wirdsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wirdIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WirdCycleHistoryTableTableFilterComposer
    extends Composer<_$AppDatabase, $WirdCycleHistoryTableTable> {
  $$WirdCycleHistoryTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycleNumber => $composableBuilder(
    column: $table.cycleNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualCompletedPages => $composableBuilder(
    column: $table.actualCompletedPages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WirdsTableTableFilterComposer get wirdId {
    final $$WirdsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wirdId,
      referencedTable: $db.wirdsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WirdsTableTableFilterComposer(
            $db: $db,
            $table: $db.wirdsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WirdCycleHistoryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WirdCycleHistoryTableTable> {
  $$WirdCycleHistoryTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycleNumber => $composableBuilder(
    column: $table.cycleNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startPage => $composableBuilder(
    column: $table.startPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endPage => $composableBuilder(
    column: $table.endPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualCompletedPages => $composableBuilder(
    column: $table.actualCompletedPages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WirdsTableTableOrderingComposer get wirdId {
    final $$WirdsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wirdId,
      referencedTable: $db.wirdsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WirdsTableTableOrderingComposer(
            $db: $db,
            $table: $db.wirdsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WirdCycleHistoryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WirdCycleHistoryTableTable> {
  $$WirdCycleHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cycleNumber => $composableBuilder(
    column: $table.cycleNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get completedDate => $composableBuilder(
    column: $table.completedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startPage =>
      $composableBuilder(column: $table.startPage, builder: (column) => column);

  GeneratedColumn<int> get endPage =>
      $composableBuilder(column: $table.endPage, builder: (column) => column);

  GeneratedColumn<int> get actualCompletedPages => $composableBuilder(
    column: $table.actualCompletedPages,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$WirdsTableTableAnnotationComposer get wirdId {
    final $$WirdsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wirdId,
      referencedTable: $db.wirdsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WirdsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.wirdsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WirdCycleHistoryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WirdCycleHistoryTableTable,
          WirdCycleHistoryEntry,
          $$WirdCycleHistoryTableTableFilterComposer,
          $$WirdCycleHistoryTableTableOrderingComposer,
          $$WirdCycleHistoryTableTableAnnotationComposer,
          $$WirdCycleHistoryTableTableCreateCompanionBuilder,
          $$WirdCycleHistoryTableTableUpdateCompanionBuilder,
          (WirdCycleHistoryEntry, $$WirdCycleHistoryTableTableReferences),
          WirdCycleHistoryEntry,
          PrefetchHooks Function({bool wirdId})
        > {
  $$WirdCycleHistoryTableTableTableManager(
    _$AppDatabase db,
    $WirdCycleHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WirdCycleHistoryTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WirdCycleHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WirdCycleHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> wirdId = const Value.absent(),
                Value<int> cycleNumber = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> completedDate = const Value.absent(),
                Value<int> startPage = const Value.absent(),
                Value<int> endPage = const Value.absent(),
                Value<int> actualCompletedPages = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => WirdCycleHistoryTableCompanion(
                id: id,
                wirdId: wirdId,
                cycleNumber: cycleNumber,
                startDate: startDate,
                completedDate: completedDate,
                startPage: startPage,
                endPage: endPage,
                actualCompletedPages: actualCompletedPages,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int wirdId,
                required int cycleNumber,
                required DateTime startDate,
                Value<DateTime?> completedDate = const Value.absent(),
                required int startPage,
                required int endPage,
                required int actualCompletedPages,
                required DateTime createdAt,
              }) => WirdCycleHistoryTableCompanion.insert(
                id: id,
                wirdId: wirdId,
                cycleNumber: cycleNumber,
                startDate: startDate,
                completedDate: completedDate,
                startPage: startPage,
                endPage: endPage,
                actualCompletedPages: actualCompletedPages,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WirdCycleHistoryTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({wirdId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (wirdId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.wirdId,
                                referencedTable:
                                    $$WirdCycleHistoryTableTableReferences
                                        ._wirdIdTable(db),
                                referencedColumn:
                                    $$WirdCycleHistoryTableTableReferences
                                        ._wirdIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WirdCycleHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WirdCycleHistoryTableTable,
      WirdCycleHistoryEntry,
      $$WirdCycleHistoryTableTableFilterComposer,
      $$WirdCycleHistoryTableTableOrderingComposer,
      $$WirdCycleHistoryTableTableAnnotationComposer,
      $$WirdCycleHistoryTableTableCreateCompanionBuilder,
      $$WirdCycleHistoryTableTableUpdateCompanionBuilder,
      (WirdCycleHistoryEntry, $$WirdCycleHistoryTableTableReferences),
      WirdCycleHistoryEntry,
      PrefetchHooks Function({bool wirdId})
    >;
typedef $$WirdAchievementsTableTableCreateCompanionBuilder =
    WirdAchievementsTableCompanion Function({
      required String id,
      required String type,
      required int threshold,
      Value<bool> unlocked,
      Value<DateTime?> unlockedAt,
      Value<int> rowid,
    });
typedef $$WirdAchievementsTableTableUpdateCompanionBuilder =
    WirdAchievementsTableCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<int> threshold,
      Value<bool> unlocked,
      Value<DateTime?> unlockedAt,
      Value<int> rowid,
    });

class $$WirdAchievementsTableTableFilterComposer
    extends Composer<_$AppDatabase, $WirdAchievementsTableTable> {
  $$WirdAchievementsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get unlocked => $composableBuilder(
    column: $table.unlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WirdAchievementsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WirdAchievementsTableTable> {
  $$WirdAchievementsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get threshold => $composableBuilder(
    column: $table.threshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get unlocked => $composableBuilder(
    column: $table.unlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WirdAchievementsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WirdAchievementsTableTable> {
  $$WirdAchievementsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get threshold =>
      $composableBuilder(column: $table.threshold, builder: (column) => column);

  GeneratedColumn<bool> get unlocked =>
      $composableBuilder(column: $table.unlocked, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$WirdAchievementsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WirdAchievementsTableTable,
          WirdAchievementEntry,
          $$WirdAchievementsTableTableFilterComposer,
          $$WirdAchievementsTableTableOrderingComposer,
          $$WirdAchievementsTableTableAnnotationComposer,
          $$WirdAchievementsTableTableCreateCompanionBuilder,
          $$WirdAchievementsTableTableUpdateCompanionBuilder,
          (
            WirdAchievementEntry,
            BaseReferences<
              _$AppDatabase,
              $WirdAchievementsTableTable,
              WirdAchievementEntry
            >,
          ),
          WirdAchievementEntry,
          PrefetchHooks Function()
        > {
  $$WirdAchievementsTableTableTableManager(
    _$AppDatabase db,
    $WirdAchievementsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WirdAchievementsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WirdAchievementsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WirdAchievementsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> threshold = const Value.absent(),
                Value<bool> unlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WirdAchievementsTableCompanion(
                id: id,
                type: type,
                threshold: threshold,
                unlocked: unlocked,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required int threshold,
                Value<bool> unlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WirdAchievementsTableCompanion.insert(
                id: id,
                type: type,
                threshold: threshold,
                unlocked: unlocked,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WirdAchievementsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WirdAchievementsTableTable,
      WirdAchievementEntry,
      $$WirdAchievementsTableTableFilterComposer,
      $$WirdAchievementsTableTableOrderingComposer,
      $$WirdAchievementsTableTableAnnotationComposer,
      $$WirdAchievementsTableTableCreateCompanionBuilder,
      $$WirdAchievementsTableTableUpdateCompanionBuilder,
      (
        WirdAchievementEntry,
        BaseReferences<
          _$AppDatabase,
          $WirdAchievementsTableTable,
          WirdAchievementEntry
        >,
      ),
      WirdAchievementEntry,
      PrefetchHooks Function()
    >;
typedef $$DownloadedTafsirsTableCreateCompanionBuilder =
    DownloadedTafsirsCompanion Function({
      Value<int> resourceId,
      required String name,
      Value<String?> authorName,
      Value<String?> slug,
      Value<String?> languageName,
      Value<String?> resourceName,
      required DateTime downloadedAt,
      required DateTime updatedAt,
    });
typedef $$DownloadedTafsirsTableUpdateCompanionBuilder =
    DownloadedTafsirsCompanion Function({
      Value<int> resourceId,
      Value<String> name,
      Value<String?> authorName,
      Value<String?> slug,
      Value<String?> languageName,
      Value<String?> resourceName,
      Value<DateTime> downloadedAt,
      Value<DateTime> updatedAt,
    });

class $$DownloadedTafsirsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedTafsirsTable> {
  $$DownloadedTafsirsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedTafsirsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedTafsirsTable> {
  $$DownloadedTafsirsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedTafsirsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedTafsirsTable> {
  $$DownloadedTafsirsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadedTafsirsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedTafsirsTable,
          DownloadedTafsirEntry,
          $$DownloadedTafsirsTableFilterComposer,
          $$DownloadedTafsirsTableOrderingComposer,
          $$DownloadedTafsirsTableAnnotationComposer,
          $$DownloadedTafsirsTableCreateCompanionBuilder,
          $$DownloadedTafsirsTableUpdateCompanionBuilder,
          (
            DownloadedTafsirEntry,
            BaseReferences<
              _$AppDatabase,
              $DownloadedTafsirsTable,
              DownloadedTafsirEntry
            >,
          ),
          DownloadedTafsirEntry,
          PrefetchHooks Function()
        > {
  $$DownloadedTafsirsTableTableManager(
    _$AppDatabase db,
    $DownloadedTafsirsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedTafsirsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadedTafsirsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadedTafsirsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> resourceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<String?> slug = const Value.absent(),
                Value<String?> languageName = const Value.absent(),
                Value<String?> resourceName = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DownloadedTafsirsCompanion(
                resourceId: resourceId,
                name: name,
                authorName: authorName,
                slug: slug,
                languageName: languageName,
                resourceName: resourceName,
                downloadedAt: downloadedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> resourceId = const Value.absent(),
                required String name,
                Value<String?> authorName = const Value.absent(),
                Value<String?> slug = const Value.absent(),
                Value<String?> languageName = const Value.absent(),
                Value<String?> resourceName = const Value.absent(),
                required DateTime downloadedAt,
                required DateTime updatedAt,
              }) => DownloadedTafsirsCompanion.insert(
                resourceId: resourceId,
                name: name,
                authorName: authorName,
                slug: slug,
                languageName: languageName,
                resourceName: resourceName,
                downloadedAt: downloadedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedTafsirsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedTafsirsTable,
      DownloadedTafsirEntry,
      $$DownloadedTafsirsTableFilterComposer,
      $$DownloadedTafsirsTableOrderingComposer,
      $$DownloadedTafsirsTableAnnotationComposer,
      $$DownloadedTafsirsTableCreateCompanionBuilder,
      $$DownloadedTafsirsTableUpdateCompanionBuilder,
      (
        DownloadedTafsirEntry,
        BaseReferences<
          _$AppDatabase,
          $DownloadedTafsirsTable,
          DownloadedTafsirEntry
        >,
      ),
      DownloadedTafsirEntry,
      PrefetchHooks Function()
    >;
typedef $$DownloadedTranslationsTableCreateCompanionBuilder =
    DownloadedTranslationsCompanion Function({
      Value<int> resourceId,
      required String name,
      Value<String?> authorName,
      Value<String?> slug,
      Value<String?> languageName,
      Value<String?> resourceName,
      required DateTime downloadedAt,
      required DateTime updatedAt,
    });
typedef $$DownloadedTranslationsTableUpdateCompanionBuilder =
    DownloadedTranslationsCompanion Function({
      Value<int> resourceId,
      Value<String> name,
      Value<String?> authorName,
      Value<String?> slug,
      Value<String?> languageName,
      Value<String?> resourceName,
      Value<DateTime> downloadedAt,
      Value<DateTime> updatedAt,
    });

class $$DownloadedTranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadedTranslationsTable> {
  $$DownloadedTranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadedTranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadedTranslationsTable> {
  $$DownloadedTranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadedTranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadedTranslationsTable> {
  $$DownloadedTranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get languageName => $composableBuilder(
    column: $table.languageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DownloadedTranslationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadedTranslationsTable,
          DownloadedTranslationEntry,
          $$DownloadedTranslationsTableFilterComposer,
          $$DownloadedTranslationsTableOrderingComposer,
          $$DownloadedTranslationsTableAnnotationComposer,
          $$DownloadedTranslationsTableCreateCompanionBuilder,
          $$DownloadedTranslationsTableUpdateCompanionBuilder,
          (
            DownloadedTranslationEntry,
            BaseReferences<
              _$AppDatabase,
              $DownloadedTranslationsTable,
              DownloadedTranslationEntry
            >,
          ),
          DownloadedTranslationEntry,
          PrefetchHooks Function()
        > {
  $$DownloadedTranslationsTableTableManager(
    _$AppDatabase db,
    $DownloadedTranslationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadedTranslationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DownloadedTranslationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DownloadedTranslationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> resourceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<String?> slug = const Value.absent(),
                Value<String?> languageName = const Value.absent(),
                Value<String?> resourceName = const Value.absent(),
                Value<DateTime> downloadedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DownloadedTranslationsCompanion(
                resourceId: resourceId,
                name: name,
                authorName: authorName,
                slug: slug,
                languageName: languageName,
                resourceName: resourceName,
                downloadedAt: downloadedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> resourceId = const Value.absent(),
                required String name,
                Value<String?> authorName = const Value.absent(),
                Value<String?> slug = const Value.absent(),
                Value<String?> languageName = const Value.absent(),
                Value<String?> resourceName = const Value.absent(),
                required DateTime downloadedAt,
                required DateTime updatedAt,
              }) => DownloadedTranslationsCompanion.insert(
                resourceId: resourceId,
                name: name,
                authorName: authorName,
                slug: slug,
                languageName: languageName,
                resourceName: resourceName,
                downloadedAt: downloadedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadedTranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadedTranslationsTable,
      DownloadedTranslationEntry,
      $$DownloadedTranslationsTableFilterComposer,
      $$DownloadedTranslationsTableOrderingComposer,
      $$DownloadedTranslationsTableAnnotationComposer,
      $$DownloadedTranslationsTableCreateCompanionBuilder,
      $$DownloadedTranslationsTableUpdateCompanionBuilder,
      (
        DownloadedTranslationEntry,
        BaseReferences<
          _$AppDatabase,
          $DownloadedTranslationsTable,
          DownloadedTranslationEntry
        >,
      ),
      DownloadedTranslationEntry,
      PrefetchHooks Function()
    >;
typedef $$TafsirTextCacheTableCreateCompanionBuilder =
    TafsirTextCacheCompanion Function({
      required int resourceId,
      required int chapterId,
      required int ayahNumber,
      required String tafsirText,
      required String resourceName,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$TafsirTextCacheTableUpdateCompanionBuilder =
    TafsirTextCacheCompanion Function({
      Value<int> resourceId,
      Value<int> chapterId,
      Value<int> ayahNumber,
      Value<String> tafsirText,
      Value<String> resourceName,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$TafsirTextCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TafsirTextCacheTable> {
  $$TafsirTextCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tafsirText => $composableBuilder(
    column: $table.tafsirText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TafsirTextCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TafsirTextCacheTable> {
  $$TafsirTextCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tafsirText => $composableBuilder(
    column: $table.tafsirText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TafsirTextCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TafsirTextCacheTable> {
  $$TafsirTextCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tafsirText => $composableBuilder(
    column: $table.tafsirText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$TafsirTextCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TafsirTextCacheTable,
          TafsirTextCacheEntry,
          $$TafsirTextCacheTableFilterComposer,
          $$TafsirTextCacheTableOrderingComposer,
          $$TafsirTextCacheTableAnnotationComposer,
          $$TafsirTextCacheTableCreateCompanionBuilder,
          $$TafsirTextCacheTableUpdateCompanionBuilder,
          (
            TafsirTextCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $TafsirTextCacheTable,
              TafsirTextCacheEntry
            >,
          ),
          TafsirTextCacheEntry,
          PrefetchHooks Function()
        > {
  $$TafsirTextCacheTableTableManager(
    _$AppDatabase db,
    $TafsirTextCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TafsirTextCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TafsirTextCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TafsirTextCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> resourceId = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<String> tafsirText = const Value.absent(),
                Value<String> resourceName = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TafsirTextCacheCompanion(
                resourceId: resourceId,
                chapterId: chapterId,
                ayahNumber: ayahNumber,
                tafsirText: tafsirText,
                resourceName: resourceName,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int resourceId,
                required int chapterId,
                required int ayahNumber,
                required String tafsirText,
                required String resourceName,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => TafsirTextCacheCompanion.insert(
                resourceId: resourceId,
                chapterId: chapterId,
                ayahNumber: ayahNumber,
                tafsirText: tafsirText,
                resourceName: resourceName,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TafsirTextCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TafsirTextCacheTable,
      TafsirTextCacheEntry,
      $$TafsirTextCacheTableFilterComposer,
      $$TafsirTextCacheTableOrderingComposer,
      $$TafsirTextCacheTableAnnotationComposer,
      $$TafsirTextCacheTableCreateCompanionBuilder,
      $$TafsirTextCacheTableUpdateCompanionBuilder,
      (
        TafsirTextCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $TafsirTextCacheTable,
          TafsirTextCacheEntry
        >,
      ),
      TafsirTextCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$TranslationTextCacheTableCreateCompanionBuilder =
    TranslationTextCacheCompanion Function({
      required int resourceId,
      required int chapterId,
      required int ayahNumber,
      required String translationText,
      required String resourceName,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$TranslationTextCacheTableUpdateCompanionBuilder =
    TranslationTextCacheCompanion Function({
      Value<int> resourceId,
      Value<int> chapterId,
      Value<int> ayahNumber,
      Value<String> translationText,
      Value<String> resourceName,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$TranslationTextCacheTableFilterComposer
    extends Composer<_$AppDatabase, $TranslationTextCacheTable> {
  $$TranslationTextCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translationText => $composableBuilder(
    column: $table.translationText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranslationTextCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $TranslationTextCacheTable> {
  $$TranslationTextCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translationText => $composableBuilder(
    column: $table.translationText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranslationTextCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $TranslationTextCacheTable> {
  $$TranslationTextCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get resourceId => $composableBuilder(
    column: $table.resourceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<int> get ayahNumber => $composableBuilder(
    column: $table.ayahNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get translationText => $composableBuilder(
    column: $table.translationText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resourceName => $composableBuilder(
    column: $table.resourceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$TranslationTextCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TranslationTextCacheTable,
          TranslationTextCacheEntry,
          $$TranslationTextCacheTableFilterComposer,
          $$TranslationTextCacheTableOrderingComposer,
          $$TranslationTextCacheTableAnnotationComposer,
          $$TranslationTextCacheTableCreateCompanionBuilder,
          $$TranslationTextCacheTableUpdateCompanionBuilder,
          (
            TranslationTextCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $TranslationTextCacheTable,
              TranslationTextCacheEntry
            >,
          ),
          TranslationTextCacheEntry,
          PrefetchHooks Function()
        > {
  $$TranslationTextCacheTableTableManager(
    _$AppDatabase db,
    $TranslationTextCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranslationTextCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TranslationTextCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TranslationTextCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> resourceId = const Value.absent(),
                Value<int> chapterId = const Value.absent(),
                Value<int> ayahNumber = const Value.absent(),
                Value<String> translationText = const Value.absent(),
                Value<String> resourceName = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranslationTextCacheCompanion(
                resourceId: resourceId,
                chapterId: chapterId,
                ayahNumber: ayahNumber,
                translationText: translationText,
                resourceName: resourceName,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int resourceId,
                required int chapterId,
                required int ayahNumber,
                required String translationText,
                required String resourceName,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => TranslationTextCacheCompanion.insert(
                resourceId: resourceId,
                chapterId: chapterId,
                ayahNumber: ayahNumber,
                translationText: translationText,
                resourceName: resourceName,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranslationTextCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TranslationTextCacheTable,
      TranslationTextCacheEntry,
      $$TranslationTextCacheTableFilterComposer,
      $$TranslationTextCacheTableOrderingComposer,
      $$TranslationTextCacheTableAnnotationComposer,
      $$TranslationTextCacheTableCreateCompanionBuilder,
      $$TranslationTextCacheTableUpdateCompanionBuilder,
      (
        TranslationTextCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $TranslationTextCacheTable,
          TranslationTextCacheEntry
        >,
      ),
      TranslationTextCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$HisnContentCacheTableCreateCompanionBuilder =
    HisnContentCacheCompanion Function({
      required String id,
      required String title,
      required String subtitle,
      required String iconKey,
      required int count,
      Value<String?> arabicTitle,
      Value<int> priority,
      required String type,
      Value<int> rowid,
    });
typedef $$HisnContentCacheTableUpdateCompanionBuilder =
    HisnContentCacheCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> subtitle,
      Value<String> iconKey,
      Value<int> count,
      Value<String?> arabicTitle,
      Value<int> priority,
      Value<String> type,
      Value<int> rowid,
    });

class $$HisnContentCacheTableFilterComposer
    extends Composer<_$AppDatabase, $HisnContentCacheTable> {
  $$HisnContentCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get arabicTitle => $composableBuilder(
    column: $table.arabicTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HisnContentCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $HisnContentCacheTable> {
  $$HisnContentCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get arabicTitle => $composableBuilder(
    column: $table.arabicTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HisnContentCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $HisnContentCacheTable> {
  $$HisnContentCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<String> get arabicTitle => $composableBuilder(
    column: $table.arabicTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$HisnContentCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HisnContentCacheTable,
          HisnContentCacheEntry,
          $$HisnContentCacheTableFilterComposer,
          $$HisnContentCacheTableOrderingComposer,
          $$HisnContentCacheTableAnnotationComposer,
          $$HisnContentCacheTableCreateCompanionBuilder,
          $$HisnContentCacheTableUpdateCompanionBuilder,
          (
            HisnContentCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $HisnContentCacheTable,
              HisnContentCacheEntry
            >,
          ),
          HisnContentCacheEntry,
          PrefetchHooks Function()
        > {
  $$HisnContentCacheTableTableManager(
    _$AppDatabase db,
    $HisnContentCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HisnContentCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HisnContentCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HisnContentCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<String?> arabicTitle = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HisnContentCacheCompanion(
                id: id,
                title: title,
                subtitle: subtitle,
                iconKey: iconKey,
                count: count,
                arabicTitle: arabicTitle,
                priority: priority,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String subtitle,
                required String iconKey,
                required int count,
                Value<String?> arabicTitle = const Value.absent(),
                Value<int> priority = const Value.absent(),
                required String type,
                Value<int> rowid = const Value.absent(),
              }) => HisnContentCacheCompanion.insert(
                id: id,
                title: title,
                subtitle: subtitle,
                iconKey: iconKey,
                count: count,
                arabicTitle: arabicTitle,
                priority: priority,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HisnContentCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HisnContentCacheTable,
      HisnContentCacheEntry,
      $$HisnContentCacheTableFilterComposer,
      $$HisnContentCacheTableOrderingComposer,
      $$HisnContentCacheTableAnnotationComposer,
      $$HisnContentCacheTableCreateCompanionBuilder,
      $$HisnContentCacheTableUpdateCompanionBuilder,
      (
        HisnContentCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $HisnContentCacheTable,
          HisnContentCacheEntry
        >,
      ),
      HisnContentCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$HisnContentItemCacheTableCreateCompanionBuilder =
    HisnContentItemCacheCompanion Function({
      required String id,
      required String categoryId,
      required String contentText,
      required String source,
      Value<int> repeatCount,
      Value<String?> fadl,
      Value<String?> reference,
      Value<String?> translation,
      required String type,
      Value<int> rowid,
    });
typedef $$HisnContentItemCacheTableUpdateCompanionBuilder =
    HisnContentItemCacheCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<String> contentText,
      Value<String> source,
      Value<int> repeatCount,
      Value<String?> fadl,
      Value<String?> reference,
      Value<String?> translation,
      Value<String> type,
      Value<int> rowid,
    });

class $$HisnContentItemCacheTableFilterComposer
    extends Composer<_$AppDatabase, $HisnContentItemCacheTable> {
  $$HisnContentItemCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fadl => $composableBuilder(
    column: $table.fadl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HisnContentItemCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $HisnContentItemCacheTable> {
  $$HisnContentItemCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fadl => $composableBuilder(
    column: $table.fadl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HisnContentItemCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $HisnContentItemCacheTable> {
  $$HisnContentItemCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentText => $composableBuilder(
    column: $table.contentText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get repeatCount => $composableBuilder(
    column: $table.repeatCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fadl =>
      $composableBuilder(column: $table.fadl, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$HisnContentItemCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HisnContentItemCacheTable,
          HisnContentItemCacheEntry,
          $$HisnContentItemCacheTableFilterComposer,
          $$HisnContentItemCacheTableOrderingComposer,
          $$HisnContentItemCacheTableAnnotationComposer,
          $$HisnContentItemCacheTableCreateCompanionBuilder,
          $$HisnContentItemCacheTableUpdateCompanionBuilder,
          (
            HisnContentItemCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $HisnContentItemCacheTable,
              HisnContentItemCacheEntry
            >,
          ),
          HisnContentItemCacheEntry,
          PrefetchHooks Function()
        > {
  $$HisnContentItemCacheTableTableManager(
    _$AppDatabase db,
    $HisnContentItemCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HisnContentItemCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HisnContentItemCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$HisnContentItemCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> contentText = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> repeatCount = const Value.absent(),
                Value<String?> fadl = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HisnContentItemCacheCompanion(
                id: id,
                categoryId: categoryId,
                contentText: contentText,
                source: source,
                repeatCount: repeatCount,
                fadl: fadl,
                reference: reference,
                translation: translation,
                type: type,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required String contentText,
                required String source,
                Value<int> repeatCount = const Value.absent(),
                Value<String?> fadl = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                required String type,
                Value<int> rowid = const Value.absent(),
              }) => HisnContentItemCacheCompanion.insert(
                id: id,
                categoryId: categoryId,
                contentText: contentText,
                source: source,
                repeatCount: repeatCount,
                fadl: fadl,
                reference: reference,
                translation: translation,
                type: type,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HisnContentItemCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HisnContentItemCacheTable,
      HisnContentItemCacheEntry,
      $$HisnContentItemCacheTableFilterComposer,
      $$HisnContentItemCacheTableOrderingComposer,
      $$HisnContentItemCacheTableAnnotationComposer,
      $$HisnContentItemCacheTableCreateCompanionBuilder,
      $$HisnContentItemCacheTableUpdateCompanionBuilder,
      (
        HisnContentItemCacheEntry,
        BaseReferences<
          _$AppDatabase,
          $HisnContentItemCacheTable,
          HisnContentItemCacheEntry
        >,
      ),
      HisnContentItemCacheEntry,
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
  $$CategoryFavoritesTableTableManager get categoryFavorites =>
      $$CategoryFavoritesTableTableManager(_db, _db.categoryFavorites);
  $$QuranReadingProgressCacheTableTableManager get quranReadingProgressCache =>
      $$QuranReadingProgressCacheTableTableManager(
        _db,
        _db.quranReadingProgressCache,
      );
  $$QuranBookmarksTableTableManager get quranBookmarks =>
      $$QuranBookmarksTableTableManager(_db, _db.quranBookmarks);
  $$WirdsTableTableTableManager get wirdsTable =>
      $$WirdsTableTableTableManager(_db, _db.wirdsTable);
  $$WirdDailyProgressTableTableTableManager get wirdDailyProgressTable =>
      $$WirdDailyProgressTableTableTableManager(
        _db,
        _db.wirdDailyProgressTable,
      );
  $$WirdCycleHistoryTableTableTableManager get wirdCycleHistoryTable =>
      $$WirdCycleHistoryTableTableTableManager(_db, _db.wirdCycleHistoryTable);
  $$WirdAchievementsTableTableTableManager get wirdAchievementsTable =>
      $$WirdAchievementsTableTableTableManager(_db, _db.wirdAchievementsTable);
  $$DownloadedTafsirsTableTableManager get downloadedTafsirs =>
      $$DownloadedTafsirsTableTableManager(_db, _db.downloadedTafsirs);
  $$DownloadedTranslationsTableTableManager get downloadedTranslations =>
      $$DownloadedTranslationsTableTableManager(
        _db,
        _db.downloadedTranslations,
      );
  $$TafsirTextCacheTableTableManager get tafsirTextCache =>
      $$TafsirTextCacheTableTableManager(_db, _db.tafsirTextCache);
  $$TranslationTextCacheTableTableManager get translationTextCache =>
      $$TranslationTextCacheTableTableManager(_db, _db.translationTextCache);
  $$HisnContentCacheTableTableManager get hisnContentCache =>
      $$HisnContentCacheTableTableManager(_db, _db.hisnContentCache);
  $$HisnContentItemCacheTableTableManager get hisnContentItemCache =>
      $$HisnContentItemCacheTableTableManager(_db, _db.hisnContentItemCache);
}
