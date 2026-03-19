// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeckFilter)
final deckFilterProvider = DeckFilterProvider._();

final class DeckFilterProvider extends $NotifierProvider<DeckFilter, String> {
  DeckFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deckFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deckFilterHash();

  @$internal
  @override
  DeckFilter create() => DeckFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$deckFilterHash() => r'de03049669d23644e49be17ef201d6e0bfc2442c';

abstract class _$DeckFilter extends $Notifier<String> {
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
