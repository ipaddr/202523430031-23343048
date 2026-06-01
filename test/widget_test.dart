// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import "package:flutter_test/flutter_test.dart";

import "package:flashcard/main.dart";
import "package:flashcard/features/flashcards/domain/entities/flashcard_deck_entity.dart";
import "package:flashcard/features/flashcards/domain/entities/flashcard_entity.dart";
import "package:flashcard/features/flashcards/domain/repositories/ai_repository.dart";
import "package:flashcard/features/flashcards/domain/repositories/flashcard_deck_repository.dart";

void main() {
  testWidgets("Home screen renders", (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        deckRepository: _FakeDeckRepository(),
        aiRepository: _FakeAiRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("FlashMind"), findsOneWidget);
    expect(find.text("Generate New Deck"), findsOneWidget);
    expect(find.text("Live\nScan"), findsOneWidget);
  });
}

class _FakeDeckRepository implements FlashcardDeckRepository {
  @override
  Future<List<FlashcardDeckEntity>> fetchAllDecks() async {
    return <FlashcardDeckEntity>[];
  }

  @override
  Future<int> saveDeck(FlashcardDeckEntity deck) async {
    return 0;
  }
}

class _FakeAiRepository implements AiRepository {
  @override
  Future<List<FlashcardEntity>> generateFlashcards({
    required String extractedText,
    required int flashcardCount,
  }) async {
    return <FlashcardEntity>[];
  }
}
