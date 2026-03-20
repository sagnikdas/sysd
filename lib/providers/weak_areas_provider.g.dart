// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weak_areas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WeakAreas)
final weakAreasProvider = WeakAreasProvider._();

final class WeakAreasProvider
    extends $NotifierProvider<WeakAreas, List<WeakArea>> {
  WeakAreasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weakAreasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weakAreasHash();

  @$internal
  @override
  WeakAreas create() => WeakAreas();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<WeakArea> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<WeakArea>>(value),
    );
  }
}

String _$weakAreasHash() => r'0c22f4a670c076e2407d48a165d36cdf7e8cc7a4';

abstract class _$WeakAreas extends $Notifier<List<WeakArea>> {
  List<WeakArea> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<WeakArea>, List<WeakArea>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<WeakArea>, List<WeakArea>>,
              List<WeakArea>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
