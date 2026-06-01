class QuizEntity {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? selectedAnswer;
  final bool? isCorrect;

  const QuizEntity({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.isCorrect,
  });

  QuizEntity copyWith({
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? selectedAnswer,
    bool? isCorrect,
  }) {
    return QuizEntity(
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
