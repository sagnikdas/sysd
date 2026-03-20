import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/repositories/progress_repository.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';

class AuthUiState {
  const AuthUiState({
    required this.isConfigured,
    required this.user,
    required this.isAnonymousMode,
    this.errorMessage,
  });

  final bool isConfigured;
  final User? user;
  final bool isAnonymousMode;
  final String? errorMessage;

  AuthUiState copyWith({
    bool? isConfigured,
    User? user,
    bool? isAnonymousMode,
    String? errorMessage,
  }) {
    return AuthUiState(
      isConfigured: isConfigured ?? this.isConfigured,
      user: user ?? this.user,
      isAnonymousMode: isAnonymousMode ?? this.isAnonymousMode,
      errorMessage: errorMessage,
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    authService: ref.read(authServiceProvider),
    profileRepository: ProfileRepository(),
    progressRepository: ProgressRepository(),
  ),
);

final authControllerProvider = NotifierProvider<AuthController, AuthUiState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthUiState> {
  StreamSubscription<AuthState>? _sub;

  @override
  AuthUiState build() {
    if (isSupabaseConfigured) {
      _sub = ref.read(authServiceProvider).authStateChanges.listen((event) {
        state = state.copyWith(user: event.session?.user, errorMessage: null);
        unawaited(ref.read(syncServiceProvider).syncOnAppOpen());
      });
      ref.onDispose(() => _sub?.cancel());
    }
    return AuthUiState(
      isConfigured: isSupabaseConfigured,
      user: isSupabaseConfigured ? Supabase.instance.client.auth.currentUser : null,
      isAnonymousMode: true,
    );
  }

  Future<void> continueWithoutAccount() async {
    state = state.copyWith(isAnonymousMode: true, errorMessage: null);
  }

  Future<void> signInWithGoogle() async {
    try {
      final ok = await ref.read(authServiceProvider).signInWithGoogle();
      if (!ok) {
        state = state.copyWith(errorMessage: 'Google sign-in was not completed.');
        return;
      }
      await ref.read(syncServiceProvider).syncOnSignIn();
      state = state.copyWith(isAnonymousMode: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      await ref.read(authServiceProvider).signInWithEmail(email, password);
      await ref.read(syncServiceProvider).syncOnSignIn();
      state = state.copyWith(isAnonymousMode: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      await ref.read(authServiceProvider).signUp(
        email: email,
        password: password,
        name: name,
      );
      await ref.read(syncServiceProvider).syncOnSignIn();
      state = state.copyWith(isAnonymousMode: false, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await ref.read(authServiceProvider).signOut();
      state = state.copyWith(isAnonymousMode: true, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
