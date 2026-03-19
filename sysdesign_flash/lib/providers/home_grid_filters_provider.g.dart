// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_grid_filters_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DifficultyDeckFilter)
final difficultyDeckFilterProvider = DifficultyDeckFilterProvider._();

final class DifficultyDeckFilterProvider
    extends $NotifierProvider<DifficultyDeckFilter, String> {
  DifficultyDeckFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'difficultyDeckFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$difficultyDeckFilterHash();

  @$internal
  @override
  DifficultyDeckFilter create() => DifficultyDeckFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$difficultyDeckFilterHash() =>
    r'8f2241256bd2f753b94128e3ae6837126162e3b7';

abstract class _$DifficultyDeckFilter extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(HomeSearchQuery)
final homeSearchQueryProvider = HomeSearchQueryProvider._();

final class HomeSearchQueryProvider
    extends $NotifierProvider<HomeSearchQuery, String> {
  HomeSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeSearchQueryHash();

  @$internal
  @override
  HomeSearchQuery create() => HomeSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$homeSearchQueryHash() => r'81a78af82e7d8885e919e8ab75e5ce74a42c52fa';

abstract class _$HomeSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(HomeSearchExpanded)
final homeSearchExpandedProvider = HomeSearchExpandedProvider._();

final class HomeSearchExpandedProvider
    extends $NotifierProvider<HomeSearchExpanded, bool> {
  HomeSearchExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeSearchExpandedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeSearchExpandedHash();

  @$internal
  @override
  HomeSearchExpanded create() => HomeSearchExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$homeSearchExpandedHash() =>
    r'21716214c6e5316c9304e2a016dbf758de3fcfb7';

abstract class _$HomeSearchExpanded extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
