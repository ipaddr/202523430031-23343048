import "../entities/flashcard_deck_entity.dart";

abstract class FlashcardDeckRepository {
  Future<List<FlashcardDeckEntity>> fetchAllDecks();
  Future<int> saveDeck(FlashcardDeckEntity deck);
  Future<void> deleteDeck(int id);
  Future<void> updateDeckTitle(int id, String title);
}
