import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

Future<void> _migrateLegacyUserName() async {
  final prefs = await SharedPreferences.getInstance();
  final legacy = prefs.getString('user_name')?.trim();
  if (legacy == null || legacy.isEmpty) return;
  final box = Hive.box('profile');
  final existing = box.get('name');
  final hasName = existing is String && existing.trim().isNotEmpty;
  if (hasName) return;
  await box.put('name', legacy);
  await prefs.remove('user_name');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open persistence boxes
  await Future.wait([
    Hive.openBox<bool>('mastered'),
    Hive.openBox<bool>('bookmarks'),
    Hive.openBox('profile'),
    Hive.openBox('settings'),
    Hive.openBox<String>('review_schedules'),
    Hive.openBox<int>('study_dates'),
  ]);

  await _migrateLegacyUserName();

  runApp(
    const ProviderScope(
      child: SysDesignFlashApp(),
    ),
  );
}
