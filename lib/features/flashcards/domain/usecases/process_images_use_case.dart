import "package:image_picker/image_picker.dart";

import "../entities/flashcard_entity.dart";
import "../repositories/ai_repository.dart";
import "../repositories/ocr_repository.dart";

class ProcessImagesUseCase {
  static const int maxImages = 5;
  static const int minTextLength = 40;
  final OcrRepository _ocrRepository;
  final AiRepository _aiRepository;

  ProcessImagesUseCase({
    required OcrRepository ocrRepository,
    required AiRepository aiRepository,
  }) : _ocrRepository = ocrRepository,
       _aiRepository = aiRepository;

  Future<List<FlashcardEntity>> execute({
    required List<XFile> images,
    required int flashcardCount,
    void Function(String combinedText)? onOcrCompleted,
  }) async {
    if (images.isEmpty) {
      return <FlashcardEntity>[];
    }

    final limitedImages = images.length > maxImages
        ? images.sublist(0, maxImages)
        : images;

    final ocrResults = await Future.wait(
      limitedImages.map(
        (image) => _ocrRepository.extractTextFromImage(image.path),
      ),
    );

    final combinedText = _cleanCombinedText(ocrResults);

    onOcrCompleted?.call(combinedText);

    if (combinedText.isEmpty || combinedText.length < minTextLength) {
      throw StateError(
        "Teks OCR terlalu pendek. Coba scan ulang dengan gambar yang lebih jelas.",
      );
    }

    return _aiRepository.generateFlashcards(
      extractedText: combinedText,
      flashcardCount: flashcardCount,
    );
  }

  String _cleanCombinedText(List<String> chunks) {
    final lines = chunks
        .expand((text) => text.split(RegExp("[\n\r]+")))
        .map((line) => line.replaceAll(RegExp(r"\s+"), " ").trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final seen = <String>{};
    final dedupedLines = <String>[];
    for (final line in lines) {
      final normalized = line.toLowerCase();
      if (seen.add(normalized)) {
        dedupedLines.add(line);
      }
    }

    final tokens = dedupedLines
        .join(" ")
        .split(RegExp(r"\s+"))
        .where((token) => token.isNotEmpty)
        .toList();

    final cleanedTokens = <String>[];
    String? last;
    for (final token in tokens) {
      if (token != last) {
        cleanedTokens.add(token);
        last = token;
      }
    }

    return cleanedTokens.join(" ").trim();
  }
}
