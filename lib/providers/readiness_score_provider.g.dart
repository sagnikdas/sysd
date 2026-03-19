// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readiness_score_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReadinessScore)
final readinessScoreProvider = ReadinessScoreProvider._();

final class ReadinessScoreProvider
    extends $NotifierProvider<ReadinessScore, ReadinessScoreState> {
  ReadinessScoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readinessScoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readinessScoreHash();

  @$internal
  @override
  ReadinessScore create() => ReadinessScore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadinessScoreState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadinessScoreState>(value),
    );
  }
}

String _$readinessScoreHash() => r'd0f66d10454a49b8972296e2e1afb1ec939303f6';

abstract class _$ReadinessScore extends $Notifier<ReadinessScoreState> {
  ReadinessScoreState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReadinessScoreState, ReadinessScoreState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReadinessScoreState, ReadinessScoreState>,
              ReadinessScoreState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
