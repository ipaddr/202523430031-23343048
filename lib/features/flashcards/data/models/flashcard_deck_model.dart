import "package:isar/isar.dart";

import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/entities/flashcard_entity.dart";
import "flashcard_model.dart";

part "flashcard_deck_model.g.dart";

@collection
class FlashcardDeckModel {
  Id id = Isar.autoIncrement;
  late String title;
  String? coverImagePath;
  final IsarLinks<FlashcardModel> flashcards = IsarLinks<FlashcardModel>();

  FlashcardDeckModel({
    this.id = Isar.autoIncrement,
    required this.title,
    this.coverImagePath,
  });

  FlashcardDeckEntity toEntity({List<FlashcardModel>? loadedFlashcards}) {
    final models = _dedupeFlashcardModels(
      loadedFlashcards ?? flashcards.toList(),
    );
    return FlashcardDeckEntity(
      id: id,
      title: title,
      coverImagePath: coverImagePath,
      flashcards: models.map(_mapModelToEntity).toList(),
    );
  }

  FlashcardModel _mapEntityToModel(FlashcardEntity entity) {
    return FlashcardModel.fromEntity(entity);
  }

  FlashcardEntity _mapModelToEntity(FlashcardModel model) {
    return model.toEntity();
  }

  List<FlashcardModel> mapEntitiesToModels(List<FlashcardEntity> entities) {
    return entities.map(_mapEntityToModel).toList();
  }

  List<FlashcardModel> _dedupeFlashcardModels(List<FlashcardModel> models) {
    final deduped = <FlashcardModel>[];
    final seen = <String>{};

    for (final model in models) {
      final key =
          "${model.front.trim().toLowerCase()}||${model.back.trim().toLowerCase()}";
      if (seen.add(key)) {
        deduped.add(model);
      }
    }

    return deduped;
  }

  factory FlashcardDeckModel.fromEntity(FlashcardDeckEntity entity) {
    return FlashcardDeckModel(
      id: entity.id == 0 ? Isar.autoIncrement : entity.id,
      title: entity.title,
      coverImagePath: entity.coverImagePath,
    );
  }
}
