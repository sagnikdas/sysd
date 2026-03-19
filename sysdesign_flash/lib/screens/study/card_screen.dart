import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/all_concepts.dart';
import '../../domain/models/concept.dart';
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

  // Card enter animation
  late AnimationController _enterController;
  late Animation<double> _enterScale;
  late Animation<double> _enterOpacity;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();

    // Build card list based on deckId
    if (widget.deckId == 'all') {
      _cards = List.of(allConcepts);
    } else {
      _cards = allConcepts
          .where((c) => c.category == widget.deckId)
          .toList();
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
    if (direction == SwipeDirection.right) {
      _gotItCount++;
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
          Navigator.of(context).pop(); // close sheet
          context.go('/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = _currentIndex >= _cards.length;

    return Scaffold(
      appBar: AppBar(
        title: isComplete
            ? const Text('Done!')
            : Text('${_currentIndex + 1} / ${_cards.length}'),
        actions: [
          if (!isComplete)
            IconButton(
              icon: const Icon(Icons.bookmark_outline),
              onPressed: () {},
            ),
        ],
      ),
      body: isComplete
          ? const SizedBox.shrink()
          : Column(
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: _cards.isEmpty
                      ? 0
                      : _currentIndex / _cards.length,
                  minHeight: 3,
                ),
                // Card area
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
                // Bottom hint
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back,
                          size: 16,
                          color: theme.colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        'Review',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Text(
                        'Got It',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward,
                          size: 16,
                          color: theme.colorScheme.outline),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
