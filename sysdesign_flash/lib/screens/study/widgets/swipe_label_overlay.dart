import 'package:flutter/material.dart';

class SwipeLabelOverlay extends StatelessWidget {
  final double dragFraction; // -1.0 to 1.0

  const SwipeLabelOverlay({super.key, required this.dragFraction});

  @override
  Widget build(BuildContext context) {
    final gotItOpacity = (dragFraction).clamp(0.0, 1.0);
    final reviewOpacity = (-dragFraction).clamp(0.0, 1.0);

    return IgnorePointer(
      child: Stack(
        children: [
          // GOT IT! — right swipe
          Positioned(
            top: 40,
            left: 24,
            child: Opacity(
              opacity: gotItOpacity,
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'GOT IT!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // REVIEW — left swipe
          Positioned(
            top: 40,
            right: 24,
            child: Opacity(
              opacity: reviewOpacity,
              child: Transform.rotate(
                angle: 0.3,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'REVIEW',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
