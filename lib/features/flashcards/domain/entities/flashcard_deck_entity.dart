import "flashcard_entity.dart";

class FlashcardDeckEntity {
  final int id;
  final String title;
  final String? coverImagePath;
  final List<FlashcardEntity> flashcards;

  const FlashcardDeckEntity({
    required this.id,
    required this.title,
    this.coverImagePath,
    required this.flashcards,
  });
}
