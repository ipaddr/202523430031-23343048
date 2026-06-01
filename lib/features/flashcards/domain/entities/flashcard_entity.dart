class FlashcardEntity {
  final int id;
  final String front;
  final String back;
  final DateTime createdAt;

  const FlashcardEntity({
    required this.id,
    required this.front,
    required this.back,
    required this.createdAt,
  });
}
