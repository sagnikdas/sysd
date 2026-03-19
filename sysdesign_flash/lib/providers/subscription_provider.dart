import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_provider.g.dart';

enum SubscriptionTier { free, pro }

@riverpod
class Subscription extends _$Subscription {
  @override
  SubscriptionTier build() {
    // Development default: Pro.
    // Release builds default to Free (so SM-2 is gated).
    if (kDebugMode) return SubscriptionTier.pro;
    return SubscriptionTier.free;
  }

  void setTier(SubscriptionTier tier) {
    state = tier;
  }
}

