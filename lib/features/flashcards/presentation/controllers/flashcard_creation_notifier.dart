import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";
import "package:isar/isar.dart";

import "../../data/repositories_impl/ai_repository_impl.dart";
import "../../data/repositories_impl/flashcard_deck_repository_impl.dart";
import "../../data/repositories_impl/ocr_repository_impl.dart";
import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/repositories/ai_repository.dart";
import "../../domain/repositories/flashcard_deck_repository.dart";
import "../../domain/repositories/ocr_repository.dart";
import "../../domain/usecases/process_images_use_case.dart";
import "../../domain/usecases/save_flashcard_deck_use_case.dart";
import "flashcard_creation_state.dart";

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return OcrRepositoryImpl();
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  return AiRepositoryImpl.fromEnv();
});

final flashcardDeckRepositoryProvider = Provider<FlashcardDeckRepository>((
  ref,
) {
  final isar = Isar.getInstance();
  if (isar == null) {
    throw StateError("Isar is not initialized");
  }
  return FlashcardDeckRepositoryImpl(isar: isar);
});

final processImagesUseCaseProvider = Provider<ProcessImagesUseCase>((ref) {
  return ProcessImagesUseCase(
    ocrRepository: ref.read(ocrRepositoryProvider),
    aiRepository: ref.read(aiRepositoryProvider),
  );
});

final saveFlashcardDeckUseCaseProvider = Provider<SaveFlashcardDeckUseCase>((
  ref,
) {
  return SaveFlashcardDeckUseCase(
    repository: ref.read(flashcardDeckRepositoryProvider),
  );
});

final flashcardCreationNotifierProvider =
    StateNotifierProvider<FlashcardCreationNotifier, FlashcardCreationState>((
      ref,
    ) {
      return FlashcardCreationNotifier(
        processImagesUseCase: ref.read(processImagesUseCaseProvider),
        saveFlashcardDeckUseCase: ref.read(saveFlashcardDeckUseCaseProvider),
      );
    });

class FlashcardCreationNotifier extends StateNotifier<FlashcardCreationState> {
  final ProcessImagesUseCase _processImagesUseCase;
  final SaveFlashcardDeckUseCase _saveFlashcardDeckUseCase;

  FlashcardCreationNotifier({
    required ProcessImagesUseCase processImagesUseCase,
    required SaveFlashcardDeckUseCase saveFlashcardDeckUseCase,
  }) : _processImagesUseCase = processImagesUseCase,
       _saveFlashcardDeckUseCase = saveFlashcardDeckUseCase,
       super(const FlashcardCreationInitial());

  Future<void> generateFlashcards({
    required List<XFile> images,
    required int flashcardCount,
    required String title,
  }) async {
    state = const FlashcardCreationLoadingOcr();

    try {
      final flashcards = await _processImagesUseCase.execute(
        images: images,
        flashcardCount: flashcardCount,
        onOcrCompleted: (_) {
          state = const FlashcardCreationLoadingGemini();
        },
      );

      if (flashcards.isEmpty) {
        state = const FlashcardCreationError(
          "Gagal membuat flashcard. Pastikan teks hasil scan cukup jelas.",
        );
        return;
      }

      final deck = FlashcardDeckEntity(
        id: 0,
        title: title,
        coverImagePath: images.first.path,
        flashcards: flashcards,
      );
      final savedId = await _saveFlashcardDeckUseCase.execute(deck);
      final savedDeck = FlashcardDeckEntity(
        id: savedId,
        title: deck.title,
        coverImagePath: deck.coverImagePath,
        flashcards: deck.flashcards,
      );

      state = FlashcardCreationSuccess(savedDeck);
    } catch (error) {
      state = FlashcardCreationError(error.toString());
    }
  }

  Future<int> saveDeck(FlashcardDeckEntity deck) async {
    try {
      return await _saveFlashcardDeckUseCase.execute(deck);
    } catch (error) {
      state = FlashcardCreationError(error.toString());
      rethrow;
    }
  }
}
