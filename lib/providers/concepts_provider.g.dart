// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concepts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(concepts)
final conceptsProvider = ConceptsProvider._();

final class ConceptsProvider
    extends $FunctionalProvider<List<Concept>, List<Concept>, List<Concept>>
    with $Provider<List<Concept>> {
  ConceptsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'conceptsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$conceptsHash();

  @$internal
  @override
  $ProviderElement<List<Concept>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Concept> create(Ref ref) {
    return concepts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Concept> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Concept>>(value),
    );
  }
}

String _$conceptsHash() => r'b7c8e7486a17aced295b705fc2cfae06d78e2577';

@ProviderFor(categories)
final categoriesProvider = CategoriesProvider._();

final class CategoriesProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return categories(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$categoriesHash() => r'af276614623105e881a584cfac5f9d471818a58f';

@ProviderFor(filteredConcepts)
final filteredConceptsProvider = FilteredConceptsFamily._();

final class FilteredConceptsProvider
    extends $FunctionalProvider<List<Concept>, List<Concept>, List<Concept>>
    with $Provider<List<Concept>> {
  FilteredConceptsProvider._({
    required FilteredConceptsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'filteredConceptsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredConceptsHash();

  @override
  String toString() {
    return r'filteredConceptsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Concept>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Concept> create(Ref ref) {
    final argument = this.argument as String;
    return filteredConcepts(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Concept> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Concept>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredConceptsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredConceptsHash() => r'494ee52984b6699dffdbea6d53c0d7b132f67796';

final class FilteredConceptsFamily extends $Family
    with $FunctionalFamilyOverride<List<Concept>, String> {
  FilteredConceptsFamily._()
    : super(
        retry: null,
        name: r'filteredConceptsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredConceptsProvider call(String category) =>
      FilteredConceptsProvider._(argument: category, from: this);

  @override
  String toString() => r'filteredConceptsProvider';
}
