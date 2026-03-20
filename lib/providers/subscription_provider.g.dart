// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Always returns [SubscriptionTier.pro] — the app is fully free.

@ProviderFor(subscription)
final subscriptionProvider = SubscriptionProvider._();

/// Always returns [SubscriptionTier.pro] — the app is fully free.

final class SubscriptionProvider
    extends
        $FunctionalProvider<
          SubscriptionTier,
          SubscriptionTier,
          SubscriptionTier
        >
    with $Provider<SubscriptionTier> {
  /// Always returns [SubscriptionTier.pro] — the app is fully free.
  SubscriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionHash();

  @$internal
  @override
  $ProviderElement<SubscriptionTier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SubscriptionTier create(Ref ref) {
    return subscription(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionTier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionTier>(value),
    );
  }
}

String _$subscriptionHash() => r'795ecdde6aef4ad83f0d440e9afe47949ee542d6';
