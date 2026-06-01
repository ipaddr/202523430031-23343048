import "../../domain/entities/flashcard_deck_entity.dart";

abstract class FlashcardCreationState {
  const FlashcardCreationState();
}

class FlashcardCreationInitial extends FlashcardCreationState {
  const FlashcardCreationInitial();
}

class FlashcardCreationLoadingOcr extends FlashcardCreationState {
  const FlashcardCreationLoadingOcr();
}

class FlashcardCreationLoadingGemini extends FlashcardCreationState {
  const FlashcardCreationLoadingGemini();
}

class FlashcardCreationSuccess extends FlashcardCreationState {
  final FlashcardDeckEntity deck;

  const FlashcardCreationSuccess(this.deck);
}

class FlashcardCreationError extends FlashcardCreationState {
  final String message;

  const FlashcardCreationError(this.message);
}
