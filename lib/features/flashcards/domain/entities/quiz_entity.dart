class QuizEntity {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? selectedAnswer;
  final bool? isCorrect;
  final bool submitted;

  const QuizEntity({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.isCorrect,
    this.submitted = false,
  });

  QuizEntity copyWith({
    String? question,
    List<String>? options,
    String? correctAnswer,
    String? selectedAnswer,
    bool? isCorrect,
    bool? submitted,
  }) {
    return QuizEntity(
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      submitted: submitted ?? this.submitted,
    );
  }
}
