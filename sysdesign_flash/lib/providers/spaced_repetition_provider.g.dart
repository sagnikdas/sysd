// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaced_repetition_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SpacedRepetition)
final spacedRepetitionProvider = SpacedRepetitionProvider._();

final class SpacedRepetitionProvider
    extends $NotifierProvider<SpacedRepetition, Map<int, ReviewSchedule>> {
  SpacedRepetitionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spacedRepetitionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spacedRepetitionHash();

  @$internal
  @override
  SpacedRepetition create() => SpacedRepetition();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<int, ReviewSchedule> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<int, ReviewSchedule>>(value),
    );
  }
}

String _$spacedRepetitionHash() => r'306d7164792497fe123173df3257618114277450';

abstract class _$SpacedRepetition extends $Notifier<Map<int, ReviewSchedule>> {
  Map<int, ReviewSchedule> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<int, ReviewSchedule>, Map<int, ReviewSchedule>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<int, ReviewSchedule>, Map<int, ReviewSchedule>>,
              Map<int, ReviewSchedule>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
