import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const seed = Color(0xFF2563EB); // Blue-600
  static const accent = Color(0xFFFF6B35); // Orange accent

  // Category colours
  static const scalability = Color(0xFFFF6B35);
  static const distributedSystems = Color(0xFF8B5CF6);
  static const databases = Color(0xFF10B981);
  static const messaging = Color(0xFFF59E0B);
  static const apiDesign = Color(0xFF3B82F6);
  static const reliability = Color(0xFFEF4444);
  static const rateLimiting = Color(0xFF6366F1);
  static const microservices = Color(0xFF14B8A6);
  static const security = Color(0xFFEC4899);
  static const observability = Color(0xFF8B5CF6);
  static const networking = Color(0xFF06B6D4);
  static const dataEngineering = Color(0xFF84CC16);
  static const interviewSystems = Color(0xFFF97316);

  static Color categoryColor(String category) {
    return switch (category) {
      'Scalability' => scalability,
      'Distributed Systems' => distributedSystems,
      'Databases' => databases,
      'Messaging' => messaging,
      'API Design' => apiDesign,
      'Reliability' => reliability,
      'Rate Limiting' => rateLimiting,
      'Microservices' => microservices,
      'Security' => security,
      'Observability' => observability,
      'Networking' => networking,
      'Data Engineering' => dataEngineering,
      'Interview Systems' => interviewSystems,
      _ => seed,
    };
  }
}
