import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:image_picker/image_picker.dart";

import "../controllers/flashcard_creation_notifier.dart";
import "../controllers/flashcard_creation_state.dart";
import "../../domain/entities/flashcard_deck_entity.dart";
import "../../domain/repositories/flashcard_deck_repository.dart";
import "all_flashcards_screen.dart";
import "flashcard_viewer_screen.dart";
import "../widgets/brand_app_bar.dart";
import "../widgets/ui_components.dart";

class HomeScreen extends ConsumerStatefulWidget {
  final FlashcardDeckRepository repository;

  const HomeScreen({super.key, required this.repository});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _images = [];
  late Future<List<FlashcardDeckEntity>> _decksFuture;
  final TextEditingController _titleController = TextEditingController(
    text: 'Deck baru',
  );
  int _flashcardCount = 5;
  bool _isDialogVisible = false;
  bool _initialActionsTriggered = false;
  final ValueNotifier<_LoadingStage> _loadingStage = ValueNotifier(
    _LoadingStage.none,
  );

  @override
  void initState() {
    super.initState();
    _decksFuture = widget.repository.fetchAllDecks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialActionsTriggered) {
        return;
      }

      _initialActionsTriggered = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _loadingStage.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final initialCount = _images.length;
    final picks = await _imagePicker.pickMultiImage();
    if (!mounted || picks.isEmpty) {
      return;
    }

    setState(() {
      final remaining = 5 - _images.length;
      if (remaining <= 0) {
        return;
      }

      _images.addAll(picks.take(remaining));
    });

    if (picks.length > 5 - initialCount) {
      _showSnack('Maksimal 5 gambar. Sisanya diabaikan.');
    }
  }

  Future<void> _captureImage() async {
    final captured = await _imagePicker.pickImage(source: ImageSource.camera);
    if (!mounted || captured == null) {
      return;
    }

    setState(() {
      if (_images.length < 5) {
        _images.add(captured);
      }
    });

    if (_images.length >= 5) {
      _showSnack('Maksimal 5 gambar.');
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _generateFlashcards() async {
    if (_images.isEmpty) {
      _showSnack('Pilih minimal 1 gambar terlebih dahulu.');
      return;
    }

    final title = _titleController.text.trim().isEmpty
        ? 'Deck baru'
        : _titleController.text.trim();

    await ref
        .read(flashcardCreationNotifierProvider.notifier)
        .generateFlashcards(
          images: _images,
          flashcardCount: _flashcardCount,
          title: title,
        );
  }

  void _showLoadingDialog(_LoadingStage stage) {
    _loadingStage.value = stage;
    if (_isDialogVisible) {
      return;
    }

    _isDialogVisible = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return ValueListenableBuilder<_LoadingStage>(
          valueListenable: _loadingStage,
          builder: (context, value, child) {
            return _LoadingDialog(stage: value);
          },
        );
      },
    );
  }

  void _dismissLoadingDialog() {
    if (!_isDialogVisible) {
      return;
    }

    Navigator.of(context).pop();
    _isDialogVisible = false;
    _loadingStage.value = _LoadingStage.none;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FlashcardCreationState>(flashcardCreationNotifierProvider, (
      previous,
      next,
    ) {
      if (!mounted) {
        return;
      }

      if (next is FlashcardCreationLoadingOcr) {
        _showLoadingDialog(_LoadingStage.ocr);
        return;
      }

      if (next is FlashcardCreationLoadingGemini) {
        _showLoadingDialog(_LoadingStage.gemini);
        return;
      }

      if (next is FlashcardCreationSuccess) {
        _dismissLoadingDialog();
        setState(() {
          _decksFuture = widget.repository.fetchAllDecks();
          _images.clear();
        });
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FlashcardViewerScreen(deck: next.deck),
          ),
        );
        return;
      }

      if (next is FlashcardCreationError) {
        _dismissLoadingDialog();
        _showSnack(next.message);
      }
    });

    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final crossAxisCount = size.width >= 900 ? 3 : 1;
    final hasImages = _images.isNotEmpty;
    final isInitialState = !hasImages;

    return Scaffold(
      appBar: const BrandAppBar(),
      body: Stack(
        children: [
          const _HomeBackground(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              children: [
                if (isInitialState) ...[
                  Text(
                    'Generate New Deck',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Transform any content into optimized study material.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.72),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                DashedUploadCard(onLive: _captureImage, onGallery: _pickImages),
                if (hasImages) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return _ImagePreview(
                          image: _images[index],
                          onRemove: () => _removeImage(index),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FlashcardCountPicker(
                    value: _flashcardCount,
                    onChanged: (value) {
                      setState(() => _flashcardCount = value);
                    },
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Deck',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (isInitialState) const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _generateFlashcards,
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Generate Flashcards'),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FutureBuilder<List<FlashcardDeckEntity>>(
                  future: _decksFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox.shrink();
                    }

                    final decks = snapshot.data ?? [];
                    if (decks.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Show only the two most recent decks in "Recently Generated".
                    final recentDecks = [...decks];
                    recentDecks.sort((a, b) => b.id.compareTo(a.id));
                    final displayedDecks = recentDecks.take(2).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Recently Generated',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () async {
                                final changed = await Navigator.of(context)
                                    .push<bool>(
                                      MaterialPageRoute(
                                        builder: (_) => AllFlashcardsScreen(
                                          repository: widget.repository,
                                        ),
                                      ),
                                    );
                                if (changed == true) {
                                  setState(() {
                                    _decksFuture = widget.repository
                                        .fetchAllDecks();
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'View All',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          // Use only the latest two decks for the preview.
                          itemCount: displayedDecks.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                mainAxisExtent: 220,
                              ),
                          itemBuilder: (context, index) {
                            final deck = displayedDecks[index];
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
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F6FF), Color(0xFFEDEBFF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -40,
            child: _GlowCircle(size: 200, color: Color(0xFF7BE3C3)),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: _GlowCircle(size: 180, color: Color(0xFFF9B177)),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.5), color.withOpacity(0.0)],
        ),
      ),
    );
  }
}

class _DeckCard extends StatelessWidget {
  final FlashcardDeckEntity deck;
  final VoidCallback onTap;

  const _DeckCard({required this.deck, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        deck.coverImagePath != null &&
        deck.coverImagePath!.isNotEmpty &&
        File(deck.coverImagePath!).existsSync();
    final createdAt = DateTime.now().subtract(Duration(days: deck.id * 3));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF6F2FF)],
            ),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.12),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(deck.coverImagePath!),
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.layers_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.layers_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${deck.flashcards.length} kartu",
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                deck.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                "Dibuat ${_formatDate(createdAt)}",
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _LoadingStage { none, ocr, gemini }

class _LoadingDialog extends StatelessWidget {
  final _LoadingStage stage;

  const _LoadingDialog({required this.stage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = stage == _LoadingStage.ocr
        ? 'Membaca teks dengan OCR...'
        : 'Membuat flashcard dengan Gemini...';

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardCountPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _FlashcardCountPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jumlah Flashcard',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih antara 3 sampai 15 kartu.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.65),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: 3,
                  max: 15,
                  divisions: 12,
                  label: value.toString(),
                  onChanged: (newValue) => onChanged(newValue.round()),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyPreview extends StatelessWidget {
  final ThemeData theme;

  const _EmptyPreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.photo_camera_rounded,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Preview gambar akan tampil di sini.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _ImagePreview({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(image.path),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul",
    "Agu",
    "Sep",
    "Okt",
    "Nov",
    "Des",
  ];

  final month = months[date.month - 1];
  return "${date.day} $month ${date.year}";
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final bool isTransparent;
  final bool showElevated;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.onRetry,
    this.isTransparent = false,
    this.showElevated = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: isTransparent ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: showElevated
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_rounded,
              size: 44,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Muat ulang"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
