// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mastered_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Mastered)
final masteredProvider = MasteredProvider._();

final class MasteredProvider extends $NotifierProvider<Mastered, Set<int>> {
  MasteredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'masteredProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$masteredHash();

  @$internal
  @override
  Mastered create() => Mastered();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$masteredHash() => r'c59897c3375a907d1e1926ca364bd7cdc92cc358';

abstract class _$Mastered extends $Notifier<Set<int>> {
  Set<int> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<int>, Set<int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<int>, Set<int>>,
              Set<int>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
