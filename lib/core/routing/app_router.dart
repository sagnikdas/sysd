import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/progress/progress_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/study/card_screen.dart';
import '../../screens/auth/auth_screen.dart';
import '../../screens/simulation/simulation_results_screen.dart';
import '../../screens/simulation/simulation_session_screen.dart';
import '../../screens/simulation/simulation_setup_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../domain/models/simulation_session.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _sharedAxisPage({
  required GoRouterState state,
  required Widget child,
  required SharedAxisTransitionType type,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) return child;
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: type,
        child: child,
      );
    },
  );
}

CustomTransitionPage<void> _fadeThroughPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final reduceMotion =
          MediaQuery.maybeOf(context)?.disableAnimations ?? false;
      if (reduceMotion) return child;
      return FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    },
  );
}

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppScaffold(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _sharedAxisPage(
            state: state,
            type: SharedAxisTransitionType.horizontal,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/progress',
          pageBuilder: (context, state) => _sharedAxisPage(
            state: state,
            type: SharedAxisTransitionType.vertical,
            child: const ProgressScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) =>
          _fadeThroughPage(state: state, child: const SettingsScreen()),
    ),
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) =>
          _fadeThroughPage(state: state, child: const AuthScreen()),
    ),
    GoRoute(
      path: '/study/concepts',
      pageBuilder: (context, state) {
        final extra = state.extra;
        final ids = extra is List<int>
            ? extra
            : (extra is List ? extra.cast<int>() : const <int>[]);
        return _sharedAxisPage(
          state: state,
          type: SharedAxisTransitionType.horizontal,
          child: CardScreen(deckId: 'concepts', conceptIds: ids),
        );
      },
    ),
    GoRoute(
      path: '/study/:deckId',
      pageBuilder: (context, state) {
        final deckId = state.pathParameters['deckId'] ?? 'all';
        return _sharedAxisPage(
          state: state,
          type: SharedAxisTransitionType.horizontal,
          child: CardScreen(deckId: deckId),
        );
      },
    ),
    GoRoute(
      path: '/simulation',
      builder: (context, state) => const SimulationSetupScreen(),
    ),
    GoRoute(
      path: '/simulation/session',
      builder: (context, state) {
        final extra = state.extra;
        final session = extra is SimulationSession ? extra : null;
        return session == null
            ? const Scaffold(
                body: Center(child: Text('Simulation session unavailable')),
              )
            : SimulationSessionScreen(session: session);
      },
    ),
    GoRoute(
      path: '/simulation/results',
      builder: (context, state) {
        final extra = state.extra;
        final session = extra is SimulationSession ? extra : null;
        return session == null
            ? const Scaffold(
                body: Center(child: Text('Simulation results unavailable')),
              )
            : SimulationResultsScreen(session: session);
      },
    ),
  ],
);
