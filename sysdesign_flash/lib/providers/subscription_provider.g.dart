// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Subscription)
final subscriptionProvider = SubscriptionProvider._();

final class SubscriptionProvider
    extends $NotifierProvider<Subscription, SubscriptionTier> {
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
  Subscription create() => Subscription();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscriptionTier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscriptionTier>(value),
    );
  }
}

String _$subscriptionHash() => r'a600f065800ac367b8bce0062a95a19caa56c0f0';

abstract class _$Subscription extends $Notifier<SubscriptionTier> {
  SubscriptionTier build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SubscriptionTier, SubscriptionTier>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SubscriptionTier, SubscriptionTier>,
              SubscriptionTier,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
