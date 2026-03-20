import 'dart:async';

import '../core/config/supabase_config.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/repositories/progress_repository.dart';
import 'auth_service.dart';

class SyncService {
  SyncService({
    required AuthService authService,
    required ProfileRepository profileRepository,
    required ProgressRepository progressRepository,
  }) : _authService = authService,
       _profileRepository = profileRepository,
       _progressRepository = progressRepository;

  final AuthService _authService;
  final ProfileRepository _profileRepository;
  final ProgressRepository _progressRepository;

  bool _syncInFlight = false;

  Future<void> syncOnSignIn() async {
    await _syncWithBackoff();
  }

  Future<void> syncOnAppOpen() async {
    await _syncWithBackoff();
  }

  Future<void> queueProgressSync() async {
    unawaited(_syncWithBackoff());
  }

  Future<void> _syncWithBackoff() async {
    if (!isSupabaseConfigured || _syncInFlight) return;
    final user = _authService.currentUser;
    if (user == null) return;

    _syncInFlight = true;
    var delay = const Duration(seconds: 1);
    while (true) {
      try {
        await _syncNow(user.id);
        break;
      } catch (_) {
        await Future<void>.delayed(delay);
        final nextMs = (delay.inMilliseconds * 2).clamp(1000, 30000);
        delay = Duration(milliseconds: nextMs);
      }
    }
    _syncInFlight = false;
  }

  Future<void> _syncNow(String userId) async {
    final localProfile = _profileRepository.readLocal();
    await _profileRepository.upsertCloudProfile(
      userId: userId,
      profile: localProfile,
    );

    final localRows = _progressRepository.readLocalProgressRows(userId);
    await _progressRepository.upsertCloudProgress(localRows);

    final cloudProfile = await _profileRepository.fetchCloudProfile(userId);
    if (cloudProfile != null) {
      await _profileRepository.writeLocalFromCloud(cloudProfile);
    }
    final cloudProgress = await _progressRepository.fetchCloudProgress(userId);
    await _progressRepository.writeLocalFromCloud(
      cloudProgress,
      serverWins: true,
    );
  }
}
