// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_deck_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFlashcardDeckModelCollection on Isar {
  IsarCollection<FlashcardDeckModel> get flashcardDeckModels =>
      this.collection();
}

const FlashcardDeckModelSchema = CollectionSchema(
  name: r'FlashcardDeckModel',
  id: -4854476195083472704,
  properties: {
    r'title': PropertySchema(
      id: 0,
      name: r'title',
      type: IsarType.string,
    )
  },
  estimateSize: _flashcardDeckModelEstimateSize,
  serialize: _flashcardDeckModelSerialize,
  deserialize: _flashcardDeckModelDeserialize,
  deserializeProp: _flashcardDeckModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'flashcards': LinkSchema(
      id: -5302832695961801925,
      name: r'flashcards',
      target: r'FlashcardModel',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _flashcardDeckModelGetId,
  getLinks: _flashcardDeckModelGetLinks,
  attach: _flashcardDeckModelAttach,
  version: '3.1.0+1',
);

int _flashcardDeckModelEstimateSize(
  FlashcardDeckModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.title.length * 3;
  return bytesCount;
}

void _flashcardDeckModelSerialize(
  FlashcardDeckModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.title);
}

FlashcardDeckModel _flashcardDeckModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FlashcardDeckModel(
    id: id,
    title: reader.readString(offsets[0]),
  );
  return object;
}

P _flashcardDeckModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _flashcardDeckModelGetId(FlashcardDeckModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _flashcardDeckModelGetLinks(
    FlashcardDeckModel object) {
  return [object.flashcards];
}

void _flashcardDeckModelAttach(
    IsarCollection<dynamic> col, Id id, FlashcardDeckModel object) {
  object.id = id;
  object.flashcards
      .attach(col, col.isar.collection<FlashcardModel>(), r'flashcards', id);
}

extension FlashcardDeckModelQueryWhereSort
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QWhere> {
  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FlashcardDeckModelQueryWhere
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QWhereClause> {
  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension FlashcardDeckModelQueryFilter
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QFilterCondition> {
  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }
}

extension FlashcardDeckModelQueryObject
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QFilterCondition> {}

extension FlashcardDeckModelQueryLinks
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QFilterCondition> {
  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      flashcards(FilterQuery<FlashcardModel> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'flashcards');
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      flashcardsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'flashcards', length, true, length, true);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      flashcardsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'flashcards', 0, true, 0, true);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      flashcardsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'flashcards', 0, false, 999999, true);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      flashcardsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'flashcards', 0, true, length, include);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      flashcardsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'flashcards', length, include, 999999, true);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterFilterCondition>
      flashcardsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'flashcards', lower, includeLower, upper, includeUpper);
    });
  }
}

extension FlashcardDeckModelQuerySortBy
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QSortBy> {
  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterSortBy>
      sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension FlashcardDeckModelQuerySortThenBy
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QSortThenBy> {
  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterSortBy>
      thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }
}

extension FlashcardDeckModelQueryWhereDistinct
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QDistinct> {
  QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QDistinct>
      distinctByTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }
}

extension FlashcardDeckModelQueryProperty
    on QueryBuilder<FlashcardDeckModel, FlashcardDeckModel, QQueryProperty> {
  QueryBuilder<FlashcardDeckModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FlashcardDeckModel, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }
}
