import "dart:math";

import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/entities/quiz_entity.dart";

class QuizController {
  final Random _random = Random();
  final FlashcardDeckEntity _deck;
  static const String skippedAnswer = '__SKIPPED__';
  List<QuizEntity> _quizzes = [];

  QuizController({required FlashcardDeckEntity deck}) : _deck = deck {
    _quizzes = _buildQuiz();
  }

  List<QuizEntity> get quizzes => _quizzes;

  int get totalQuestions => _quizzes.length;

  int get correctCount =>
      _quizzes.where((quiz) => quiz.isCorrect == true).length;

  bool get isCompleted =>
      _quizzes.isNotEmpty &&
      _quizzes.every((quiz) => quiz.selectedAnswer != null);

  void reset() {
    _quizzes = _buildQuiz();
  }

  void selectAnswer(int index, String answer) {
    if (index < 0 || index >= _quizzes.length) {
      return;
    }

    final quiz = _quizzes[index];
    if (quiz.selectedAnswer != null) {
      return;
    }

    _quizzes[index] = quiz.copyWith(
      selectedAnswer: answer,
      isCorrect: answer == quiz.correctAnswer,
    );
  }

  void skipAnswer(int index) {
    if (index < 0 || index >= _quizzes.length) {
      return;
    }

    final quiz = _quizzes[index];
    if (quiz.selectedAnswer != null) {
      return;
    }

    _quizzes[index] = quiz.copyWith(
      selectedAnswer: skippedAnswer,
      isCorrect: false,
    );
  }

  List<QuizEntity> _buildQuiz() {
    if (_deck.flashcards.isEmpty) {
      return <QuizEntity>[];
    }

    final answers = _deck.flashcards.map((card) => card.back).toList();

    return _deck.flashcards.map((card) {
      final options = _buildOptions(correct: card.back, pool: answers);
      return QuizEntity(
        question: card.front,
        options: options,
        correctAnswer: card.back,
        selectedAnswer: null,
        isCorrect: false,
      );
    }).toList();
  }

  List<String> _buildOptions({
    required String correct,
    required List<String> pool,
  }) {
    final wrongOptions = pool.where((option) => option != correct).toList();
    wrongOptions.shuffle(_random);

    final options = <String>[correct];
    options.addAll(wrongOptions.take(3));

    while (options.length < 4) {
      options.add(correct);
    }

    options.shuffle(_random);
    return options;
  }
}
