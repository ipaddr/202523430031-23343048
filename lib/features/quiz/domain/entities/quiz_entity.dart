class QuizEntity {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String? selectedAnswer;
  final bool isCorrect;

  const QuizEntity({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.isCorrect,
  });
}
