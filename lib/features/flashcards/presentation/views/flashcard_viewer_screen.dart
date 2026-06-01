import "dart:math";

import "package:flutter/material.dart";

import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/entities/flashcard_entity.dart";
import "../widgets/brand_app_bar.dart";
import "quiz_screen.dart";

class FlashcardViewerScreen extends StatefulWidget {
  final FlashcardDeckEntity deck;

  const FlashcardViewerScreen({super.key, required this.deck});

  @override
  State<FlashcardViewerScreen> createState() => _FlashcardViewerScreenState();
}

class _FlashcardViewerScreenState extends State<FlashcardViewerScreen> {
  int _currentIndex = 0;

  void _goPrevious() {
    if (_currentIndex <= 0) {
      return;
    }

    setState(() => _currentIndex -= 1);
  }

  void _goNext() {
    if (_currentIndex >= widget.deck.flashcards.length - 1) {
      return;
    }

    setState(() => _currentIndex += 1);
  }

  void _openQuiz() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => QuizScreen(deck: widget.deck)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.deck.flashcards.length;
    final hasPrevious = _currentIndex > 0;
    final isLastCard = _currentIndex >= total - 1;

    return Scaffold(
      appBar: BrandAppBar(
        title: widget.deck.title,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: total == 0
                    ? const Text('Belum ada flashcard.')
                    : SizedBox(
                        height: 380,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: _FlipCard(
                            key: ValueKey<int>(_currentIndex),
                            card: widget.deck.flashcards[_currentIndex],
                          ),
                        ),
                      ),
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: 16),
              Text(
                '${_currentIndex + 1} of $total',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.62),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: hasPrevious ? _goPrevious : null,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Previous'),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.35),
                        ),
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.center,
                          fit: StackFit.loose,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: isLastCard
                          ? SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                key: const ValueKey<String>('quiz-button'),
                                onPressed: _openQuiz,
                                icon: const Icon(Icons.quiz_rounded),
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('Quiz'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                key: const ValueKey<String>('next-button'),
                                onPressed: _goNext,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  child: Text('Next'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: theme
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.35),
                                  disabledForegroundColor: Colors.white
                                      .withOpacity(0.85),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _FlipCard extends StatefulWidget {
  final FlashcardEntity card;

  const _FlipCard({required this.card, super.key});

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isDismissed) {
      _controller.forward();
    } else if (_controller.isCompleted) {
      _controller.reverse();
    } else if (_controller.value >= 0.5) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * pi;
          final isFront = _controller.value < 0.5;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF6F2FF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                ),
              ),
              child: isFront
                  ? _CardContent(
                      title: 'Pertanyaan',
                      text: widget.card.front,
                      hint: 'Tap untuk lihat jawaban',
                    )
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(pi),
                      child: _CardContent(
                        title: 'Jawaban',
                        text: widget.card.back,
                        hint: 'Tap untuk kembali',
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _CardContent extends StatelessWidget {
  final String title;
  final String text;
  final String hint;

  const _CardContent({
    required this.title,
    required this.text,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Text(
          hint,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}
