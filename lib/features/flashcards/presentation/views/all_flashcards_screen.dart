import "package:flutter/material.dart";

import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/repositories/flashcard_deck_repository.dart";
import "flashcard_viewer_screen.dart";
import "../widgets/brand_app_bar.dart";
import "../widgets/ui_components.dart";

class AllFlashcardsScreen extends StatefulWidget {
  final FlashcardDeckRepository repository;

  const AllFlashcardsScreen({super.key, required this.repository});

  @override
  State<AllFlashcardsScreen> createState() => _AllFlashcardsScreenState();
}

class _AllFlashcardsScreenState extends State<AllFlashcardsScreen> {
  late Future<List<FlashcardDeckEntity>> _decksFuture;
  bool _changed = false;
  _SortOption _sort = _SortOption.dateDesc;

  @override
  void initState() {
    super.initState();
    _decksFuture = widget.repository.fetchAllDecks();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_changed);
        return false;
      },
      child: Scaffold(
        appBar: BrandAppBar(
          title: "All Flashcards",
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(_changed),
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

            var decks = snapshot.data ?? <FlashcardDeckEntity>[];
            final totalFlashcards = decks.fold<int>(
              0,
              (prev, deck) => prev + deck.flashcards.length,
            );

            if (decks.isEmpty) {
              return const _EmptyState(
                icon: Icons.style_outlined,
                title: "Belum ada flashcard",
                message:
                    "Buat deck pertama dari halaman utama, lalu semua flashcard akan muncul di sini.",
              );
            }

            // Apply sorting based on selected option
            decks = List.of(decks);
            switch (_sort) {
              case _SortOption.titleAsc:
                decks.sort((a, b) => a.title.compareTo(b.title));
                break;
              case _SortOption.titleDesc:
                decks.sort((a, b) => b.title.compareTo(a.title));
                break;
              case _SortOption.dateAsc:
                decks.sort((a, b) => a.id.compareTo(b.id));
                break;
              case _SortOption.dateDesc:
                decks.sort((a, b) => b.id.compareTo(a.id));
                break;
            }

            final size = MediaQuery.sizeOf(context);
            final crossAxisCount = size.width >= 900 ? 3 : 1;

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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Row(
                    children: [
                      const Text('Sort by:'),
                      const SizedBox(width: 12),
                      DropdownButton<_SortOption>(
                        value: _sort,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _sort = v);
                        },
                        items: const [
                          DropdownMenuItem(
                            value: _SortOption.dateDesc,
                            child: Text('Date: Newest'),
                          ),
                          DropdownMenuItem(
                            value: _SortOption.dateAsc,
                            child: Text('Date: Oldest'),
                          ),
                          DropdownMenuItem(
                            value: _SortOption.titleAsc,
                            child: Text('Title: A → Z'),
                          ),
                          DropdownMenuItem(
                            value: _SortOption.titleDesc,
                            child: Text('Title: Z → A'),
                          ),
                        ],
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: GridView.builder(
                      itemCount: decks.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 220,
                      ),
                      itemBuilder: (context, index) {
                        final deck = decks[index];
                        return DeckGridCard(
                          deck: deck,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    FlashcardViewerScreen(deck: deck),
                              ),
                            );
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus deck'),
                                content: const Text(
                                  'Apakah Anda yakin ingin menghapus deck ini? Tindakan ini tidak dapat dibatalkan.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true) return;

                            try {
                              await widget.repository.deleteDeck(deck.id);
                              _changed = true;
                              setState(() {
                                _decksFuture = widget.repository
                                    .fetchAllDecks();
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                          onTitleChanged: (newTitle) async {
                            try {
                              await widget.repository.updateDeckTitle(
                                deck.id,
                                newTitle,
                              );
                              _changed = true;
                              setState(() {
                                _decksFuture = widget.repository
                                    .fetchAllDecks();
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
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

enum _SortOption { titleAsc, titleDesc, dateAsc, dateDesc }
