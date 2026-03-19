class StudySession {
  final List<int> cardOrder;
  final int currentIndex;
  final int gotItCount;
  final DateTime startedAt;

  const StudySession({
    required this.cardOrder,
    this.currentIndex = 0,
    this.gotItCount = 0,
    required this.startedAt,
  });

  bool get isComplete => currentIndex >= cardOrder.length;
  int get totalCards => cardOrder.length;
  int get reviewedCount => currentIndex;
  int? get currentCardId =>
      isComplete ? null : cardOrder[currentIndex];

  StudySession copyWith({
    List<int>? cardOrder,
    int? currentIndex,
    int? gotItCount,
    DateTime? startedAt,
  }) {
    return StudySession(
      cardOrder: cardOrder ?? this.cardOrder,
      currentIndex: currentIndex ?? this.currentIndex,
      gotItCount: gotItCount ?? this.gotItCount,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
