import "package:flutter/material.dart";

import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/entities/flashcard_entity.dart";
import "../../domain/repositories/flashcard_deck_repository.dart";
import "flashcard_viewer_screen.dart";
import "../widgets/brand_app_bar.dart";

class AllFlashcardsScreen extends StatefulWidget {
  final FlashcardDeckRepository repository;

  const AllFlashcardsScreen({super.key, required this.repository});

  @override
  State<AllFlashcardsScreen> createState() => _AllFlashcardsScreenState();
}

class _AllFlashcardsScreenState extends State<AllFlashcardsScreen> {
  late Future<List<FlashcardDeckEntity>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _decksFuture = widget.repository.fetchAllDecks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(
        title: "All Flashcards",
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: FutureBuilder<List<FlashcardDeckEntity>>(
        future: _decksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _EmptyState(
              icon: Icons.error_outline_rounded,
              title: "Gagal memuat flashcard",
              message: snapshot.error.toString(),
            );
          }

          final decks = snapshot.data ?? <FlashcardDeckEntity>[];
          final entries = _flattenFlashcards(decks);
          final totalFlashcards = entries.length;

          if (entries.isEmpty) {
            return const _EmptyState(
              icon: Icons.style_outlined,
              title: "Belum ada flashcard",
              message:
                  "Buat deck pertama dari halaman utama, lalu semua flashcard akan muncul di sini.",
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    _StatChip(label: "Decks", value: decks.length.toString()),
                    const SizedBox(width: 12),
                    _StatChip(
                      label: "Flashcards",
                      value: totalFlashcards.toString(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return _FlashcardListTile(
                      deck: entry.deck,
                      flashcard: entry.flashcard,
                      index: index + 1,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                FlashcardViewerScreen(deck: entry.deck),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_FlashcardEntry> _flattenFlashcards(List<FlashcardDeckEntity> decks) {
    final entries = <_FlashcardEntry>[];

    for (final deck in decks) {
      for (final flashcard in deck.flashcards) {
        entries.add(_FlashcardEntry(deck: deck, flashcard: flashcard));
      }
    }

    return entries;
  }
}

class _FlashcardEntry {
  final FlashcardDeckEntity deck;
  final FlashcardEntity flashcard;

  const _FlashcardEntry({required this.deck, required this.flashcard});
}

class _FlashcardListTile extends StatelessWidget {
  final FlashcardDeckEntity deck;
  final FlashcardEntity flashcard;
  final int index;
  final VoidCallback onTap;

  const _FlashcardListTile({
    required this.deck,
    required this.flashcard,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE4E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      "#$index",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    deck.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                flashcard.front,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                flashcard.back,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 34),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
