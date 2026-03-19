import 'package:flutter/material.dart';

class CardStackEffect extends StatelessWidget {
  final Widget activeCard;
  final int remainingCards;

  const CardStackEffect({
    super.key,
    required this.activeCard,
    required this.remainingCards,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ghostColor = theme.colorScheme.surfaceContainerHigh;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Ghost 2 — furthest back
        if (remainingCards >= 3)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translateByDouble(0.0, 14.0, 0.0, 1.0)
              ..rotateZ(0.03),
            child: _GhostCard(color: ghostColor, opacity: 0.25),
          ),
        // Ghost 1
        if (remainingCards >= 2)
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..translateByDouble(0.0, 7.0, 0.0, 1.0)
              ..rotateZ(0.015),
            child: _GhostCard(color: ghostColor, opacity: 0.45),
          ),
        // Active card
        activeCard,
      ],
    );
  }
}

class _GhostCard extends StatelessWidget {
  final Color color;
  final double opacity;

  const _GhostCard({required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
