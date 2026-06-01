import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:google_generative_ai/google_generative_ai.dart";

import "../../domain/entities/flashcard_entity.dart";
import "../../domain/repositories/ai_repository.dart";

class AiRepositoryImpl implements AiRepository {
  static const String geminiModelName = "gemini-3.1-flash-lite";
  final GenerativeModel _model;

  AiRepositoryImpl({required GenerativeModel model}) : _model = model;

  factory AiRepositoryImpl.fromEnv() {
    final apiKey = dotenv.get("GEMINI_API_KEY", fallback: "");
    if (apiKey.trim().isEmpty) {
      throw StateError("GEMINI_API_KEY is missing in .env");
    }

    final model = GenerativeModel(model: geminiModelName, apiKey: apiKey);
    return AiRepositoryImpl(model: model);
  }

  @override
  Future<List<FlashcardEntity>> generateFlashcards({
    required String extractedText,
    required int flashcardCount,
  }) async {
    if (extractedText.trim().isEmpty) {
      return <FlashcardEntity>[];
    }

    final safeCount = flashcardCount.clamp(3, 15);
    final prompt = _buildPrompt(
      extractedText: extractedText,
      flashcardCount: safeCount,
    );

    try {
      final response = await _model.generateContent([Content.text(prompt)]);

      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        return <FlashcardEntity>[];
      }

      final decoded = jsonDecode(text) as List<dynamic>;
      final now = DateTime.now();

      final uniqueFlashcards = <FlashcardEntity>[];
      final seen = <String>{};

      for (final item in decoded) {
        final map = item as Map<String, dynamic>;
        final front = (map["front"] as String?)?.trim() ?? "";
        final back = (map["back"] as String?)?.trim() ?? "";

        if (front.isEmpty || back.isEmpty) {
          continue;
        }

        final key = "${front.toLowerCase()}||${back.toLowerCase()}";
        if (!seen.add(key)) {
          continue;
        }

        uniqueFlashcards.add(
          FlashcardEntity(id: 0, front: front, back: back, createdAt: now),
        );

        if (uniqueFlashcards.length == flashcardCount) {
          break;
        }
      }

      return uniqueFlashcards;
    } on FormatException catch (error) {
      debugPrint("AI JSON parse error: $error");
      return <FlashcardEntity>[];
    } catch (error) {
      debugPrint("AI request error: $error");
      return <FlashcardEntity>[];
    }
  }

  String _buildPrompt({
    required String extractedText,
    required int flashcardCount,
  }) {
    return """
You are a strict JSON generator.
Return only a valid JSON array with exactly $flashcardCount items.
No markdown, no code fences, no extra text.
Each item must follow this schema:
[{"front": "Question/Term", "back": "Answer/Explanation"}]

Source text:
$extractedText
""";
  }
}
