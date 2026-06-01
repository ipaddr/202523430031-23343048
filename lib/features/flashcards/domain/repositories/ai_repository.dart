import "../entities/flashcard_entity.dart";

abstract class AiRepository {
  Future<List<FlashcardEntity>> generateFlashcards({
    required String extractedText,
    required int flashcardCount,
  });
}
