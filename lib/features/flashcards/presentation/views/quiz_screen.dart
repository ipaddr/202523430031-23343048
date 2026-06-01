import "package:flutter/material.dart";

import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/entities/quiz_entity.dart";
import "../controllers/quiz_controller.dart";
import "../widgets/custom_button.dart";
import "../widgets/ui_components.dart";
import "../widgets/brand_app_bar.dart";

class QuizScreen extends StatefulWidget {
  final FlashcardDeckEntity deck;

  const QuizScreen({super.key, required this.deck});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late QuizController _controller;
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = QuizController(deck: widget.deck);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _restartQuiz() {
    setState(() {
      _controller.reset();
      _pageIndex = 0;
    });
    _pageController.jumpToPage(0);
  }

  void _selectAnswer(int index, String answer) {
    setState(() {
      _controller.selectAnswer(index, answer);
    });
  }

  void _skipQuestion() {
    if (_controller.isCompleted) {
      return;
    }

    setState(() {
      _controller.skipAnswer(_pageIndex);
    });

    if (_pageIndex < _controller.totalQuestions - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  void _submitAnswer() {
    final currentQuiz = _controller.quizzes[_pageIndex];
    if (currentQuiz.selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jawaban dulu sebelum submit.')),
      );
      return;
    }

    if (_pageIndex < _controller.totalQuestions - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quizzes = _controller.quizzes;

    return Scaffold(
      appBar: BrandAppBar(
        title: 'Quiz',
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
      body: quizzes.isEmpty
          ? _EmptyQuiz(theme: theme)
          : _controller.isCompleted
          ? _QuizSummary(
              theme: theme,
              quizzes: quizzes,
              correct: _controller.correctCount,
              total: _controller.totalQuestions,
              onRestart: _restartQuiz,
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'Question ${_pageIndex + 1} of ${quizzes.length}',
                        style: theme.textTheme.labelLarge,
                      ),
                      const Spacer(),
                      Text(
                        '${((_pageIndex + 1) / quizzes.length * 100).round()}% Complete',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_pageIndex + 1) / quizzes.length,
                      minHeight: 6,
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.12,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: quizzes.length,
                    onPageChanged: (index) {
                      setState(() => _pageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return _QuizCard(
                        quiz: quiz,
                        onOptionSelected: (answer) {
                          _selectAnswer(index, answer);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _skipQuestion,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Skip'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitAnswer,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Submit Answer'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizEntity quiz;
  final ValueChanged<String> onOptionSelected;

  const _QuizCard({required this.quiz, required this.onOptionSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.08,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Biology',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.info_outline, color: Colors.grey.shade400),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        quiz.question,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Choose the most accurate description from the options below.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          ...quiz.options.map((option) {
            final isSelected = quiz.selectedAnswer == option;
            final letter = String.fromCharCode(
              65 + quiz.options.indexOf(option),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: QuizOptionWidget(
                optionLetter: letter,
                text: option,
                selected: isSelected,
                onTap: quiz.selectedAnswer == null
                    ? () => onOptionSelected(option)
                    : null,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _QuizSummary extends StatelessWidget {
  final ThemeData theme;
  final List<QuizEntity> quizzes;
  final int correct;
  final int total;
  final VoidCallback onRestart;

  const _QuizSummary({
    required this.theme,
    required this.quizzes,
    required this.correct,
    required this.total,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : correct / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Column(
        children: [
          Text(
            "Selesai!",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Kamu telah menyelesaikan kuis.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  width: 140,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.12,
                        ),
                        color: theme.colorScheme.secondary,
                      ),
                      Center(
                        child: Text(
                          "$correct/$total",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Skor kamu",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Ringkasan Jawaban",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: quizzes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _QuizSummaryItem(
                  theme: theme,
                  index: index,
                  quiz: quizzes[index],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: "Ulangi Kuis",
            icon: Icons.replay_rounded,
            onPressed: onRestart,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _QuizSummaryItem extends StatelessWidget {
  final ThemeData theme;
  final int index;
  final QuizEntity quiz;

  const _QuizSummaryItem({
    required this.theme,
    required this.index,
    required this.quiz,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = quiz.selectedAnswer != null && quiz.isCorrect == true;
    final wasSkipped = quiz.selectedAnswer == QuizController.skippedAnswer;
    final selectedAnswer = wasSkipped ? 'Dilewati' : quiz.selectedAnswer;
    final showCorrectAnswer = !isCorrect;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (isCorrect)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Jawaban benar',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            quiz.question,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryLine(
            label: 'Jawaban pengguna',
            value: selectedAnswer ?? 'Belum dijawab',
            valueColor: isCorrect
                ? Colors.green.shade700
                : theme.colorScheme.onSurface,
          ),
          if (showCorrectAnswer)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _SummaryLine(
                label: 'Jawaban benar',
                value: quiz.correctAnswer,
                valueColor: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _SummaryLine({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.68),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyQuiz extends StatelessWidget {
  final ThemeData theme;

  const _EmptyQuiz({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Deck belum memiliki flashcard.",
        style: theme.textTheme.titleMedium,
      ),
    );
  }
}
