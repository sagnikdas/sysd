import 'package:flutter/material.dart';

enum Difficulty { beginner, intermediate, advanced }

class Concept {
  final int id;
  final String category;
  final Color color;
  final String icon;
  final String title;
  final String tagline;
  final String diagram;
  final List<String> bullets;
  final String mnemonic;
  final String interviewQ;
  final String interviewA;
  final Difficulty difficulty;
  final List<String> tags;

  const Concept({
    required this.id,
    required this.category,
    required this.color,
    required this.icon,
    required this.title,
    required this.tagline,
    required this.diagram,
    required this.bullets,
    required this.mnemonic,
    required this.interviewQ,
    required this.interviewA,
    required this.difficulty,
    required this.tags,
  });

  Concept copyWith({
    int? id,
    String? category,
    Color? color,
    String? icon,
    String? title,
    String? tagline,
    String? diagram,
    List<String>? bullets,
    String? mnemonic,
    String? interviewQ,
    String? interviewA,
    Difficulty? difficulty,
    List<String>? tags,
  }) {
    return Concept(
      id: id ?? this.id,
      category: category ?? this.category,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      title: title ?? this.title,
      tagline: tagline ?? this.tagline,
      diagram: diagram ?? this.diagram,
      bullets: bullets ?? this.bullets,
      mnemonic: mnemonic ?? this.mnemonic,
      interviewQ: interviewQ ?? this.interviewQ,
      interviewA: interviewA ?? this.interviewA,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
    );
  }
}
