// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_prefs_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserPrefs)
final userPrefsProvider = UserPrefsProvider._();

final class UserPrefsProvider
    extends $NotifierProvider<UserPrefs, UserPrefsState> {
  UserPrefsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userPrefsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userPrefsHash();

  @$internal
  @override
  UserPrefs create() => UserPrefs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserPrefsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserPrefsState>(value),
    );
  }
}

String _$userPrefsHash() => r'defb728069a659ae88e0bc9f11664ad9173fe100';

abstract class _$UserPrefs extends $Notifier<UserPrefsState> {
  UserPrefsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserPrefsState, UserPrefsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserPrefsState, UserPrefsState>,
              UserPrefsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
