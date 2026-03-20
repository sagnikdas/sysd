// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Streak)
final streakProvider = StreakProvider._();

final class StreakProvider extends $NotifierProvider<Streak, StreakState> {
  StreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakHash();

  @$internal
  @override
  Streak create() => Streak();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreakState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreakState>(value),
    );
  }
}

String _$streakHash() => r'd159e1f272812f294dfeb3f31b6b5276386dcfe1';

abstract class _$Streak extends $Notifier<StreakState> {
  StreakState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<StreakState, StreakState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StreakState, StreakState>,
              StreakState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
