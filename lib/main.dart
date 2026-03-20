import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/supabase_config.dart';

Future<void> _openHiveBoxes() async {
  try {
    await Future.wait([
      Hive.openBox<bool>('mastered'),
      Hive.openBox<bool>('bookmarks'),
      Hive.openBox('profile'),
      Hive.openBox('settings'),
      Hive.openBox('subscription'),
      Hive.openBox<String>('review_schedules'),
      Hive.openBox<int>('study_dates'),
    ]);
  } catch (_) {
    // One or more boxes failed to open (corrupted file, storage permission
    // denied on first launch). Delete the corrupted box and re-open fresh.
    const boxNames = [
      'mastered',
      'bookmarks',
      'profile',
      'settings',
      'subscription',
      'review_schedules',
      'study_dates',
    ];
    for (final name in boxNames) {
      if (Hive.isBoxOpen(name)) continue;
      try {
        await Hive.openBox(name);
      } catch (_) {
        await Hive.deleteBoxFromDisk(name);
        await Hive.openBox(name);
      }
    }
  }
}

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

  // Open persistence boxes — recover from corruption by deleting and re-opening.
  await _openHiveBoxes();

  await _migrateLegacyUserName();
  await initializeSupabaseIfConfigured();

  runApp(const ProviderScope(child: SysDesignFlashApp()));
}
