import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/all_concepts.dart';
import '../../domain/models/concept.dart';
import '../../providers/mastered_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/study_session_provider.dart';
import 'widgets/swipeable_card.dart';
import 'widgets/card_stack_effect.dart';
import 'widgets/session_complete_sheet.dart';

class CardScreen extends ConsumerStatefulWidget {
  final String deckId;

  const CardScreen({super.key, required this.deckId});

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen>
    with SingleTickerProviderStateMixin {
  late List<Concept> _cards;
  int _currentIndex = 0;
  int _gotItCount = 0;
  late DateTime _startedAt;
  bool _streakRecorded = false;

  late AnimationController _enterController;
  late Animation<double> _enterScale;
  late Animation<double> _enterOpacity;

  @override
  void initState() {
    super.initState();
    if (widget.deckId == 'smart') {
      // Smart sessions are built by SM-2 queue prioritization.
      final session = ref.read(studySessionProvider(maxNew: 5));
      _startedAt = session.startedAt;

      final conceptById = {for (final c in allConcepts) c.id: c};
      _cards = session.cardOrder
          .map((id) => conceptById[id])
          .whereType<Concept>()
          .toList();
    } else {
      _startedAt = DateTime.now();

      if (widget.deckId == 'all') {
        _cards = List.of(allConcepts);
      } else {
        _cards = allConcepts
            .where((c) => c.category == widget.deckId)
            .toList();
      }
    }

    _enterController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _enterScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutBack),
    );
    _enterOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOut),
    );
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  void _onSwiped(SwipeDirection direction) {
    final concept = _cards[_currentIndex];

    final isPro = ref.read(subscriptionProvider) == SubscriptionTier.pro;
    final quality = direction == SwipeDirection.right ? 4 : 1;

    if (direction == SwipeDirection.right) {
      _gotItCount++;
      ref.read(masteredProvider.notifier).markMastered(concept.id);
    }

    // SM-2 scheduling for Pro users.
    if (isPro) {
      final isLastCard = _currentIndex + 1 >= _cards.length;
      final updatedSchedule =
          ref.read(spacedRepetitionProvider.notifier).recordReview(
                concept.id,
                quality,
              );

      if (!isLastCard) {
        final nextDate =
            updatedSchedule.nextReview.toLocal().toIso8601String().split('T').first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Next review: $nextDate')),
        );
      }
    }

    // Record streak on first swipe of the session
    if (!_streakRecorded) {
      ref.read(streakProvider.notifier).recordStudy();
      _streakRecorded = true;
    }

    setState(() {
      _currentIndex++;
    });

    if (_currentIndex >= _cards.length) {
      _showSessionComplete();
    } else {
      _enterController.reset();
      _enterController.forward();
    }
  }

  void _showSessionComplete() {
    final elapsed = DateTime.now().difference(_startedAt);
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => SessionCompleteSheet(
        totalCards: _cards.length,
        gotItCount: _gotItCount,
        elapsed: elapsed,
        onDone: () {
          Navigator.of(context).pop();
          context.go('/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = _currentIndex >= _cards.length;
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      appBar: AppBar(
        title: isComplete
            ? const Text('Done!')
            : Text('${_currentIndex + 1} / ${_cards.length}'),
        actions: [
          if (!isComplete) ...[
            IconButton(
              icon: Icon(
                bookmarks.contains(_cards[_currentIndex].id)
                    ? Icons.bookmark
                    : Icons.bookmark_outline,
              ),
              onPressed: () => ref
                  .read(bookmarksProvider.notifier)
                  .toggle(_cards[_currentIndex].id),
            ),
          ],
        ],
      ),
      body: isComplete
          ? const SizedBox.shrink()
          : Column(
              children: [
                LinearProgressIndicator(
                  value: _cards.isEmpty
                      ? 0
                      : _currentIndex / _cards.length,
                  minHeight: 3,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CardStackEffect(
                      remainingCards: _cards.length - _currentIndex,
                      activeCard: ScaleTransition(
                        scale: _enterScale,
                        child: FadeTransition(
                          opacity: _enterOpacity,
                          child: SwipeableCard(
                            key: ValueKey(_cards[_currentIndex].id),
                            concept: _cards[_currentIndex],
                            onSwiped: _onSwiped,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back,
                          size: 16, color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text('Review',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline)),
                      const SizedBox(width: 24),
                      Text('Got It',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.outline)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 16, color: theme.colorScheme.outline),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
