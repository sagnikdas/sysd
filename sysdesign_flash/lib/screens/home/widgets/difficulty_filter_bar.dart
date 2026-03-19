import 'package:flutter/material.dart';

class DifficultyFilterBar extends StatelessWidget {
  static const labels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  final String selected;
  final ValueChanged<String> onSelected;

  const DifficultyFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = labels[index];
          final isSelected = label == selected;
          return FilterChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => onSelected(label),
            showCheckmark: false,
          );
        },
      ),
    );
  }
}
