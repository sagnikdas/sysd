# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

**SysDesign Flash** — Flutter flashcard app for system design interview prep. Targets backend engineers preparing for FAANG/senior-level interviews.

## Commands

```bash
# Run app
flutter run

# Code generation (required after any @riverpod provider change or Hive model change)
dart run build_runner build --delete-conflicting-outputs

# Run all tests
flutter test

# Run a single test file
flutter test test/unit/sm2_algorithm_test.dart

# Release build
flutter build appbundle --release
```

## Architecture

### Folder layout

```
lib/
├── core/
│   ├── config/       # supabase_config.dart — isSupabaseConfigured flag
│   ├── routing/      # app_router.dart — single GoRouter instance
│   ├── theme/        # AppTheme.light() / AppTheme.dark(), AppColors
│   └── utils/        # sm2_algorithm.dart, readiness_score.dart, weakness_score.dart, haptics.dart
├── data/
│   ├── all_concepts.dart          # Aggregates all 13 category files; allConcepts list
│   ├── concepts/                  # One file per category (concepts_scalability.dart, etc.)
│   └── simulation_scenarios.dart
├── domain/
│   ├── models/       # Concept, ReviewSchedule, StudySession, SimulationSession, UserProfile, SubscriptionModels
│   └── repositories/ # ProfileRepository, ProgressRepository, SubscriptionRepository
├── providers/        # All Riverpod providers; *.g.dart files are code-generated — do not edit
├── services/         # AuthService, BillingService, SyncService, NotificationService
├── screens/          # One folder per screen; widgets/ subfolder for screen-local widgets
│   # Folders: auth/, home/, onboarding/, paywall/, progress/, settings/, simulation/, splash/, study/
└── shared/widgets/   # AppScaffold (bottom nav shell), ProGate, EmptyState
```

### Routing

`app_router.dart` defines a single `GoRouter`. The bottom-nav shell (`AppScaffold`) wraps `/home` and `/progress` via a `ShellRoute`. All Pro-only routes (`/simulation`, `/simulation/session`, `/simulation/results`) are wrapped in `ProGate` directly in the router — no separate gate needed at the screen level.

Transitions use `SharedAxisTransition` (horizontal for stack pushes, vertical for tab switches) and `FadeThroughTransition` for overlay screens. Both respect `MediaQuery.disableAnimations`.

### State management

All providers use `@riverpod` codegen. After editing any provider file, run `build_runner`. Key providers:

| Provider | Persistence | Notes |
|---|---|---|
| `masteredProvider` | Hive `Box<bool>('mastered')` | Toggle / markMastered / clearAll |
| `bookmarksProvider` | Hive | Similar pattern to mastered |
| `spacedRepetitionProvider` | Hive | `ReviewSchedule` per concept; Pro only |
| `subscriptionProvider` | SharedPrefs (cached) | Has `setTier()` debug override; `clearDebugOverride()` to reset |
| `streakProvider` | Hive/SharedPrefs | Auto-resets on missed day |
| `studySessionProvider` | In-memory | Current session state |
| `conceptsProvider` | Static | Derived from `allConcepts` |
| `authProvider` | Supabase session | Manages auth state |
| `deckFilterProvider` | In-memory | Filters concepts by category |
| `homeGridFiltersProvider` | In-memory | Filters and search on home screen |
| `readinessScoreProvider` | Derived | Computed from mastered + spaced repetition data |
| `studyDatesProvider` | Hive | Tracks study history dates |
| `userPrefsProvider` | SharedPrefs | Theme, daily goal, reminders |
| `weakAreasProvider` | Derived | Identifies weak categories from review history |

Writes always go to Hive first (optimistic). Background sync to Supabase is triggered via `SyncService` for Pro users only.

### Sync & offline

`SyncService` is Pro-only. It uses exponential backoff (starting at 1 s, capped at 30 s) with a single-flight guard. Conflict resolution is server-wins on pull. It upserts local profile + progress to Supabase, then overwrites local with cloud data.

`isSupabaseConfigured` (in `supabase_config.dart`) guards all Supabase calls — when Supabase credentials aren't set, sync silently no-ops.

### Subscription / paywall

`SubscriptionTier` is `free` or `pro`. `ProGate` widget checks `subscriptionProvider` and shows `PaywallSheet` if the user is on free. `BillingService` wraps `in_app_purchase`; `SubscriptionRepository` maps store receipts to tiers. Product IDs are defined in `SubscriptionRepository`.

### Content data

`allConcepts` in `lib/data/all_concepts.dart` is the single source of truth — it aggregates 13 category list files. Each `Concept` has: `id` (int), `category`, `color`, `icon`, `title`, `tagline`, `difficulty`, `tags` (list), `diagram` (ASCII art), `bullets` (key points list), `mnemonic`, `interviewQ`, `interviewA`. `allCategories` returns categories in canonical display order.

### Key algorithms

- **SM-2** (`core/utils/sm2_algorithm.dart`): `SM2.calculate(schedule, quality)` — quality 0-5; <3 resets repetitions; ease factor floored at 1.3. "Got It!" maps to quality 4, "Review Again" to quality 1.
- **Readiness score** (`core/utils/readiness_score.dart`): `mastered×0.4 + quality×0.4 + coverage×0.2`, returns 0–100.
- **Weakness score** (`core/utils/weakness_score.dart`): Per-category weakness for surfacing weak areas.

## Tests

```
test/
├── widget_test.dart                   # Smoke test
└── unit/
    ├── sm2_algorithm_test.dart        # SM-2 math
    └── readiness_score_test.dart      # Readiness formula
```

Unit tests do not require a device or emulator. Widget tests need `flutter test`.

## Code generation

The `.g.dart` files in `lib/providers/` are generated by `riverpod_generator` via `build_runner`. Never edit them manually. Regenerate whenever a `@riverpod`-annotated class/function changes signature.
