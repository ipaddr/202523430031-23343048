import "../entities/flashcard_deck_entity.dart";
import "../repositories/flashcard_deck_repository.dart";

class SaveFlashcardDeckUseCase {
  final FlashcardDeckRepository _repository;

  SaveFlashcardDeckUseCase({required FlashcardDeckRepository repository})
    : _repository = repository;

  Future<int> execute(FlashcardDeckEntity deck) {
    return _repository.saveDeck(deck);
  }
}
