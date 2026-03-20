import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/subscription_models.dart';
export '../domain/models/subscription_models.dart';

part 'subscription_provider.g.dart';

/// Always returns [SubscriptionTier.pro] — the app is fully free.
@riverpod
SubscriptionTier subscription(Ref ref) => SubscriptionTier.pro;
