import "package:isar/isar.dart";

import "../../domain/entities/flashcard_entity.dart";

part "flashcard_model.g.dart";

@collection
class FlashcardModel {
  Id id = Isar.autoIncrement;
  late String front;
  late String back;
  late DateTime createdAt;

  FlashcardModel({
    this.id = Isar.autoIncrement,
    required this.front,
    required this.back,
    required this.createdAt,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json["id"] as int? ?? Isar.autoIncrement,
      front: json["front"] as String? ?? "",
      back: json["back"] as String? ?? "",
      createdAt: DateTime.parse(json["created_at"] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "front": front,
      "back": back,
      "created_at": createdAt.toIso8601String(),
    };
  }

  FlashcardEntity toEntity() {
    return FlashcardEntity(
      id: id,
      front: front,
      back: back,
      createdAt: createdAt,
    );
  }

  factory FlashcardModel.fromEntity(FlashcardEntity entity) {
    return FlashcardModel(
      id: entity.id == 0 ? Isar.autoIncrement : entity.id,
      front: entity.front,
      back: entity.back,
      createdAt: entity.createdAt,
    );
  }
}
