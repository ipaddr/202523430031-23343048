import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/flashcard_deck_entity.dart';

class FlashMindLogo extends StatelessWidget {
  final double size;

  const FlashMindLogo({this.size = 20, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.bolt, size: size * 0.6, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          'FlashMind',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class DashedUploadCard extends StatelessWidget {
  final VoidCallback? onLive;
  final VoidCallback? onGallery;

  const DashedUploadCard({this.onLive, this.onGallery, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    const borderColor = Color(0xFFC5CEE4);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: CustomPaint(
          painter: _DashedBorderPainter(color: borderColor),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FB),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: primary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Scan or Upload',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Scan textbook pages or upload\nstudy notes.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.68),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: onLive,
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text(
                            'Live\nScan',
                            textAlign: TextAlign.center,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: onGallery,
                          icon: const Icon(
                            Icons.upload_file_outlined,
                            size: 18,
                          ),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE3E6EB),
                            foregroundColor: Colors.black87,
                            shadowColor: Colors.transparent,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(rect.deflate(0.8), const Radius.circular(18)),
      );

    const dashWidth = 7.0;
    const dashSpace = 5.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class DeckGridCard extends StatelessWidget {
  final FlashcardDeckEntity deck;
  final VoidCallback onTap;

  const DeckGridCard({required this.deck, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final coverImagePath = deck.coverImagePath;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (coverImagePath == null || coverImagePath.isEmpty)
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF173B66), Color(0xFF5B84B7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      )
                    else
                      Image.file(
                        File(coverImagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF173B66), Color(0xFF5B84B7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          );
                        },
                      ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.18),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'SCIENCE',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        deck.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.layers_rounded,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.55),
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${deck.flashcards.length} cards',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.64),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizOptionWidget extends StatelessWidget {
  final String optionLetter;
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const QuizOptionWidget({
    required this.optionLetter,
    required this.text,
    this.selected = false,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final box = Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? primary : Colors.transparent,
        border: Border.all(
          color: selected ? primary : Colors.grey.shade300,
          width: 1.6,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        optionLetter,
        style: TextStyle(
          color: selected ? Colors.white : Colors.grey.shade800,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? primary.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primary.withOpacity(0.12) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            box,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? primary.darken() : Colors.black87,
                ),
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class StatsRow extends StatelessWidget {
  final int totalCards;
  final String lastSession;
  final double mastery;

  const StatsRow({
    required this.totalCards,
    required this.lastSession,
    required this.mastery,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Cards',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalCards',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Session',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Text(
                  lastSession,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mastery',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: mastery,
                  color: Colors.green,
                  backgroundColor: Colors.green.withOpacity(0.15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
