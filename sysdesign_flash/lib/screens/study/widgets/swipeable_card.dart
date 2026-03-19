import 'package:flutter/material.dart';
import '../../../core/utils/haptics.dart';
import '../../../domain/models/concept.dart';
import 'card_header.dart';
import 'diagram_tab.dart';
import 'bullets_tab.dart';
import 'interview_tab.dart';
import 'swipe_label_overlay.dart';

enum SwipeDirection { left, right }

class SwipeableCard extends StatefulWidget {
  final Concept concept;
  final ValueChanged<SwipeDirection> onSwiped;

  const SwipeableCard({
    super.key,
    required this.concept,
    required this.onSwiped,
  });

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  double _dragY = 0;
  bool _isDragging = false;
  int _selectedTab = 0;

  late AnimationController _exitController;
  Offset? _exitDirection;

  static const _swipeThreshold = 100.0;
  static const _maxRotation = 0.35; // radians

  @override
  void initState() {
    super.initState();
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(SwipeableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.concept.id != widget.concept.id) {
      _dragX = 0;
      _dragY = 0;
      _isDragging = false;
      _selectedTab = 0;
      _exitController.reset();
      _exitDirection = null;
    }
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  double get _dragFraction => (_dragX / _swipeThreshold).clamp(-1.0, 1.0);

  void _onPanStart(DragStartDetails _) {
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragX += details.delta.dx;
      _dragY += details.delta.dy * 0.4; // dampen vertical
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final flung = velocity.abs() > 800;

    if (_dragX.abs() >= _swipeThreshold || flung) {
      final direction = _dragX > 0 ? SwipeDirection.right : SwipeDirection.left;
      Haptics.swipeCommit();
      _animateExit(direction);
    } else {
      _snapBack();
    }
  }

  void _animateExit(SwipeDirection direction) {
    _exitDirection = direction == SwipeDirection.right
        ? const Offset(1.5, 0)
        : const Offset(-1.5, 0);

    _exitController.forward().then((_) {
      widget.onSwiped(direction);
    });
  }

  void _snapBack() {
    // Simple spring-back animation via setState
    setState(() {
      _dragX = 0;
      _dragY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _exitController,
      builder: (context, child) {
        double translateX = _dragX;
        double translateY = _dragY;

        if (_exitDirection != null && _exitController.isAnimating) {
          translateX = _dragX +
              _exitDirection!.dx * screenWidth * _exitController.value;
          translateY = _dragY +
              _exitDirection!.dy * 100 * _exitController.value;
        }

        final rotation =
            (translateX / screenWidth) * _maxRotation;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..translateByDouble(translateX, translateY, 0.0, 1.0)
            ..rotateZ(rotation),
          child: child,
        );
      },
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedContainer(
          duration: _isDragging
              ? Duration.zero
              : const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: CardHeader(concept: widget.concept),
                    ),
                    // Tab switcher
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(
                            value: 0,
                            label: Text('Diagram'),
                            icon: Icon(Icons.schema_outlined, size: 18),
                          ),
                          ButtonSegment(
                            value: 1,
                            label: Text('Points'),
                            icon: Icon(Icons.list, size: 18),
                          ),
                          ButtonSegment(
                            value: 2,
                            label: Text('Q&A'),
                            icon: Icon(Icons.mic, size: 18),
                          ),
                        ],
                        selected: {_selectedTab},
                        onSelectionChanged: (selected) {
                          Haptics.tabSwitch();
                          setState(() => _selectedTab = selected.first);
                        },
                        showSelectedIcon: false,
                      ),
                    ),
                    // Tab content
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: switch (_selectedTab) {
                          0 => DiagramTab(
                              key: const ValueKey('diagram'),
                              diagram: widget.concept.diagram,
                              mnemonic: widget.concept.mnemonic,
                            ),
                          1 => BulletsTab(
                              key: const ValueKey('bullets'),
                              bullets: widget.concept.bullets,
                            ),
                          _ => InterviewTab(
                              key: const ValueKey('interview'),
                              question: widget.concept.interviewQ,
                              answer: widget.concept.interviewA,
                            ),
                        },
                      ),
                    ),
                  ],
                ),
                // Swipe labels
                SwipeLabelOverlay(dragFraction: _dragFraction),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
