import "package:isar/isar.dart";

import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/entities/flashcard_entity.dart";
import "../../domain/repositories/flashcard_deck_repository.dart";
import "../models/flashcard_deck_model.dart";
import "../models/flashcard_model.dart";

class FlashcardDeckRepositoryImpl implements FlashcardDeckRepository {
  final Isar _isar;

  FlashcardDeckRepositoryImpl({required Isar isar}) : _isar = isar;

  @override
  Future<List<FlashcardDeckEntity>> fetchAllDecks() async {
    final decks = await _isar.flashcardDeckModels.where().findAll();

    final entities = <FlashcardDeckEntity>[];
    for (final deck in decks) {
      await deck.flashcards.load();
      entities.add(deck.toEntity(loadedFlashcards: deck.flashcards.toList()));
    }

    return entities;
  }

  @override
  Future<int> saveDeck(FlashcardDeckEntity deck) async {
    final deckModel = FlashcardDeckModel.fromEntity(deck);
    final flashcardModels = deckModel.mapEntitiesToModels(
      _dedupeFlashcards(deck.flashcards),
    );

    return _isar.writeTxn(() async {
      final deckId = await _isar.flashcardDeckModels.put(deckModel);
      await _isar.flashcardModels.putAll(flashcardModels);

      deckModel.flashcards.clear();
      deckModel.flashcards.addAll(flashcardModels);
      await deckModel.flashcards.save();

      return deckId;
    });
  }

  List<FlashcardEntity> _dedupeFlashcards(List<FlashcardEntity> flashcards) {
    final deduped = <FlashcardEntity>[];
    final seen = <String>{};

    for (final flashcard in flashcards) {
      final key =
          "${flashcard.front.trim().toLowerCase()}||${flashcard.back.trim().toLowerCase()}";
      if (seen.add(key)) {
        deduped.add(flashcard);
      }
    }

    return deduped;
  }
}
