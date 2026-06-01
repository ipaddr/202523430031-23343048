import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:isar/isar.dart";
import "package:path_provider/path_provider.dart";

import "core/theme/app_theme.dart";
import "features/flashcards/data/models/flashcard_deck_model.dart";
import "features/flashcards/data/models/flashcard_model.dart";
import "features/flashcards/data/repositories_impl/ai_repository_impl.dart";
import "features/flashcards/data/repositories_impl/flashcard_deck_repository_impl.dart";
import "features/flashcards/domain/repositories/ai_repository.dart";
import "features/flashcards/domain/repositories/flashcard_deck_repository.dart";
import "features/flashcards/presentation/views/home_screen.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (error) {
    debugPrint(".env asset not found, trying local file: $error");
    try {
      final file = File(".env");
      if (await file.exists()) {
        final content = await file.readAsString();
        dotenv.testLoad(fileInput: content);
      } else {
        dotenv.testLoad(fileInput: "");
      }
    } catch (fallbackError) {
      debugPrint("Failed to load local .env: $fallbackError");
      dotenv.testLoad(fileInput: "");
    }
  }

  final directory = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    FlashcardModelSchema,
    FlashcardDeckModelSchema,
  ], directory: directory.path);

  final deckRepository = FlashcardDeckRepositoryImpl(isar: isar);
  final aiRepository = AiRepositoryImpl.fromEnv();

  runApp(
    ProviderScope(
      child: _AppBootstrap(
        isar: isar,
        deckRepository: deckRepository,
        aiRepository: aiRepository,
      ),
    ),
  );
}

class _AppBootstrap extends StatefulWidget {
  final Isar isar;
  final FlashcardDeckRepository deckRepository;
  final AiRepository aiRepository;

  const _AppBootstrap({
    required this.isar,
    required this.deckRepository,
    required this.aiRepository,
  });

  @override
  State<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<_AppBootstrap> {
  @override
  void dispose() {
    widget.isar.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(
      deckRepository: widget.deckRepository,
      aiRepository: widget.aiRepository,
    );
  }
}

class MyApp extends StatelessWidget {
  final FlashcardDeckRepository deckRepository;
  final AiRepository aiRepository;

  const MyApp({
    super.key,
    required this.deckRepository,
    required this.aiRepository,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: "Flashcard Studio",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: HomeScreen(repository: deckRepository),
      ),
    );
  }
}
