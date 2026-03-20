import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../data/all_concepts.dart';
import '../../domain/models/concept.dart';
import '../../providers/mastered_provider.dart';
import '../../providers/bookmarks_provider.dart';
import '../../providers/streak_provider.dart';
import '../../providers/study_dates_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/spaced_repetition_provider.dart';
import '../../providers/study_session_provider.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'widgets/swipeable_card.dart';
import 'widgets/card_stack_effect.dart';
import 'widgets/session_complete_sheet.dart';
import 'widgets/streak_milestone_sheet.dart';

class CardScreen extends ConsumerStatefulWidget {
  final String deckId;
  final List<int>? conceptIds;

  const CardScreen({super.key, required this.deckId, this.conceptIds});

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
  int? _pendingStreakMilestone; // avoid overlapping modals on final card.

  late AnimationController _enterController;
  late Animation<double> _enterScale;
  late Animation<double> _enterOpacity;

  @override
  void initState() {
    super.initState();
    if (widget.conceptIds != null) {
      _startedAt = DateTime.now();
      final conceptById = {for (final c in allConcepts) c.id: c};
      _cards = widget.conceptIds!
          .map((id) => conceptById[id])
          .whereType<Concept>()
          .toList(growable: false);
    } else if (widget.deckId == 'smart') {
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
        _cards = allConcepts.where((c) => c.category == widget.deckId).toList();
      }
    }

    _enterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _enterScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeOutBack),
    );
    _enterOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOut));
    _enterController.forward();
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  void _reviewAndAdvance({required int quality, required bool markMastered}) {
    final concept = _cards[_currentIndex];
    final isPro = ref.read(subscriptionProvider) == SubscriptionTier.pro;
    final willCompleteSession = _currentIndex + 1 >= _cards.length;

    // Track activity for heatmap analytics.
    ref.read(studyDatesProvider.notifier).recordCardReview();

    if (markMastered) {
      _gotItCount++;
      ref.read(masteredProvider.notifier).markMastered(concept.id);
    }

    // SM-2 scheduling for Pro users.
    if (isPro) {
      ref
          .read(spacedRepetitionProvider.notifier)
          .recordReview(concept.id, quality);
    }

    // Cloud sync is queued in background only for authenticated Pro users.
    ref
        .read(syncServiceProvider)
        .queueProgressSync(tier: ref.read(subscriptionProvider));

    // Record streak on first swipe of the session
    if (!_streakRecorded) {
      final newCount = ref.read(streakProvider.notifier).recordStudy();
      _streakRecorded = true;
      if (newCount != null && (newCount == 7 || newCount == 30)) {
        if (willCompleteSession) {
          _pendingStreakMilestone = newCount;
        } else {
          _showStreakMilestone(newCount);
        }
      }
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

  void _showStreakMilestone(int streakCount) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => StreakMilestoneSheet(streakCount: streakCount),
    );
  }

  void _onSwiped(SwipeDirection direction) {
    _reviewAndAdvance(
      quality: direction == SwipeDirection.right ? 4 : 1,
      markMastered: direction == SwipeDirection.right,
    );
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
          final completedSessions = _incrementCompletedSessionsCount();
          final isPro = ref.read(subscriptionProvider) == SubscriptionTier.pro;
          final pending = _pendingStreakMilestone;
          _pendingStreakMilestone = null;
          if (pending != null) {
            showModalBottomSheet(
              context: context,
              isDismissible: false,
              enableDrag: false,
              builder: (_) => StreakMilestoneSheet(streakCount: pending),
            ).whenComplete(() {
              if (!mounted) return;
              _completeSessionNavigation(
                completedSessions: completedSessions,
                isPro: isPro,
              );
            });
          } else {
            _completeSessionNavigation(
              completedSessions: completedSessions,
              isPro: isPro,
            );
          }
        },
      ),
    );
  }

  int _incrementCompletedSessionsCount() {
    final settingsBox = Hive.box('settings');
    final current = settingsBox.get(
      'completed_sessions_count',
      defaultValue: 0,
    );
    final count = current is int ? current + 1 : 1;
    settingsBox.put('completed_sessions_count', count);
    return count;
  }

  void _completeSessionNavigation({
    required int completedSessions,
    required bool isPro,
  }) {
    if (!mounted) return;

    final shouldShowNudge = !isPro && completedSessions % 5 == 0;
    if (shouldShowNudge) {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => _SessionEndProNudge(
          onTryPro: () {
            Navigator.of(context).pop();
            context.go('/paywall');
          },
          onContinueFree: () {
            Navigator.of(context).pop();
            context.go('/home');
          },
        ),
      );
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final isComplete = _currentIndex >= _cards.length;
    final subscriptionTier = ref.watch(subscriptionProvider);
    final bookmarks = ref.watch(bookmarksProvider);
    final mastered = ref.watch(masteredProvider);
    final isSmartDeck = widget.deckId == 'smart' && widget.conceptIds == null;

    return Scaffold(
      appBar: AppBar(
        title: isComplete
            ? const Text('Done!')
            : Text('${_currentIndex + 1} / ${_cards.length}'),
        actions: [
          if (!isComplete) ...[
            if (kDebugMode && subscriptionTier == SubscriptionTier.pro) ...[
              IconButton(
                tooltip: 'Quality 0 (Fail)',
                icon: const Icon(Icons.broken_image_outlined),
                onPressed: () =>
                    _reviewAndAdvance(quality: 0, markMastered: false),
              ),
            ],
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
          : _cards.isEmpty && isSmartDeck
          ? const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'All caught up!',
              subtitle:
                  'No cards are due today. Come back later for your next review.',
            )
          : Column(
              children: [
                LinearProgressIndicator(
                  value: _cards.isEmpty ? 0 : _currentIndex / _cards.length,
                  minHeight: 3,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: RepaintBoundary(
                      child: CardStackEffect(
                        remainingCards: _cards.length - _currentIndex,
                        activeCard: ScaleTransition(
                          scale: reduceMotion
                              ? const AlwaysStoppedAnimation<double>(1)
                              : _enterScale,
                          child: FadeTransition(
                            opacity: reduceMotion
                                ? const AlwaysStoppedAnimation<double>(1)
                                : _enterOpacity,
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
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
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
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SessionEndProNudge extends StatelessWidget {
  final VoidCallback onTryPro;
  final VoidCallback onContinueFree;

  const _SessionEndProNudge({
    required this.onTryPro,
    required this.onContinueFree,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are on a roll',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pro users master concepts 3x faster with smart queues and targeted reviews.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onTryPro,
                child: const Text('Try Pro free for 7 days'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onContinueFree,
                child: const Text('Continue without Pro'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
