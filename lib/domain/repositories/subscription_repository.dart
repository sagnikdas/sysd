import 'dart:async';

import 'package:hive/hive.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/subscription_models.dart';
import '../../services/billing_service.dart';

class SubscriptionRepository {
  SubscriptionRepository({
    BillingService? billingService,
    SupabaseClient? client,
  }) : _billingService = billingService ?? BillingService(),
       _client = client;

  final BillingService _billingService;
  final SupabaseClient? _client;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  Completer<PurchaseDetails>? _purchaseCompleter;
  String? _activePurchaseSku;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;
  Box<dynamic> get _subscriptionBox => Hive.box('subscription');

  Future<void> initialize() async {
    await _billingService.initialize();
    _purchaseSub ??= _billingService.purchaseUpdates.listen(_onPurchases);
  }

  Future<List<ProductDetails>> fetchProducts() async {
    await initialize();
    final products = await _billingService.fetchProducts({
      SubscriptionPlan.monthly.sku,
      SubscriptionPlan.annual.sku,
      SubscriptionPlan.lifetime.sku,
    });
    products.sort((a, b) => a.id.compareTo(b.id));
    return products;
  }

  SubscriptionTier getCachedTier() {
    final tier = (_subscriptionBox.get('tier') as String?) ?? 'free';
    final plan = (_subscriptionBox.get('plan') as String?) ?? '';
    final expiryRaw = (_subscriptionBox.get('expiresAt') as String?) ?? '';
    final expiresAt = DateTime.tryParse(expiryRaw);

    if (tier == 'pro' &&
        plan != SubscriptionPlan.lifetime.name &&
        expiresAt != null &&
        expiresAt.isBefore(DateTime.now())) {
      _subscriptionBox.put('tier', 'free');
      return SubscriptionTier.free;
    }
    return tier == 'pro' ? SubscriptionTier.pro : SubscriptionTier.free;
  }

  DateTime? getTrialStartedAt() {
    final raw = (_subscriptionBox.get('trialStartedAt') as String?) ?? '';
    return DateTime.tryParse(raw);
  }

  Future<SubscriptionTier> getCurrentTier() async {
    final cached = getCachedTier();
    if (!isSupabaseConfigured || _supabase.auth.currentUser == null) {
      return cached;
    }

    try {
      final row = await _supabase
          .from('subscriptions')
          .select('tier, plan, expires_at')
          .eq('user_id', _supabase.auth.currentUser!.id)
          .maybeSingle();
      if (row is Map<String, dynamic>) {
        await _cacheSubscriptionRow(row);
        return getCachedTier();
      }
    } catch (_) {
      // Fall back to cached tier when network/server fetch fails.
    }
    return cached;
  }

  Future<SubscriptionTier> purchaseByPlan(SubscriptionPlan plan) async {
    await initialize();
    final products = await fetchProducts();
    final sku = plan.sku;
    ProductDetails? product;
    for (final item in products) {
      if (item.id == sku) {
        product = item;
        break;
      }
    }
    if (product == null) {
      throw Exception('Product not available on this store account.');
    }

    _activePurchaseSku = product.id;
    _purchaseCompleter = Completer<PurchaseDetails>();
    await _billingService.purchaseProduct(product);

    final purchase = await _purchaseCompleter!.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () =>
          throw TimeoutException('Purchase confirmation timed out.'),
    );

    if (purchase.status == PurchaseStatus.canceled) {
      throw Exception('Purchase cancelled.');
    }
    if (purchase.status == PurchaseStatus.error) {
      throw Exception(purchase.error?.message ?? 'Purchase failed.');
    }
    if (purchase.status != PurchaseStatus.purchased &&
        purchase.status != PurchaseStatus.restored) {
      throw Exception('Purchase did not complete.');
    }

    final tier = await verifyWithServer(purchase, fallbackPlan: plan);
    await _billingService.completePurchase(purchase);
    return tier;
  }

  Future<SubscriptionTier> verifyWithServer(
    PurchaseDetails purchase, {
    SubscriptionPlan? fallbackPlan,
  }) async {
    final plan =
        fallbackPlan ?? SubscriptionPlanSku.fromSku(purchase.productID);
    final token =
        purchase.verificationData.serverVerificationData.trim().isNotEmpty
        ? purchase.verificationData.serverVerificationData
        : purchase.purchaseID;

    if (isSupabaseConfigured && _supabase.auth.currentUser != null) {
      try {
        final response = await _supabase.functions.invoke(
          'verify-purchase',
          body: <String, dynamic>{
            'productId': purchase.productID,
            'plan': plan.name,
            'purchaseToken': token,
            'transactionDate': purchase.transactionDate,
          },
        );
        final data = response.data;
        if (data is Map<String, dynamic>) {
          await _cacheVerificationResponse(data, fallbackPlan: plan);
          return getCachedTier();
        }
      } catch (_) {
        // Continue to local fallback to avoid locking users out on transient errors.
      }
    }

    await _cacheLocalPurchase(plan: plan, token: token);
    return getCachedTier();
  }

  Future<SubscriptionTier> restorePurchases() async {
    await initialize();
    final previousTier = getCachedTier();
    await _billingService.restorePurchases();
    await Future<void>.delayed(const Duration(seconds: 2));
    final refreshedTier = await getCurrentTier();
    return refreshedTier == SubscriptionTier.free
        ? previousTier
        : refreshedTier;
  }

  Future<void> _cacheVerificationResponse(
    Map<String, dynamic> data, {
    required SubscriptionPlan fallbackPlan,
  }) async {
    final tier = (data['tier'] ?? 'pro').toString();
    final plan = (data['plan'] ?? fallbackPlan.name).toString();
    final expiresAt = (data['expiresAt'] ?? data['expires_at'])?.toString();
    await _subscriptionBox.put('tier', tier);
    await _subscriptionBox.put('plan', plan);
    if (expiresAt != null && expiresAt.isNotEmpty) {
      await _subscriptionBox.put('expiresAt', expiresAt);
    } else if (plan == SubscriptionPlan.lifetime.name) {
      await _subscriptionBox.put(
        'expiresAt',
        DateTime(2100, 1, 1).toIso8601String(),
      );
    }
    if (plan == SubscriptionPlan.lifetime.name) {
      await _subscriptionBox.delete('trialStartedAt');
    } else if (_subscriptionBox.get('trialStartedAt') == null) {
      await _subscriptionBox.put(
        'trialStartedAt',
        DateTime.now().toIso8601String(),
      );
    }
    await _subscriptionBox.put('updatedAt', DateTime.now().toIso8601String());
  }

  Future<void> _cacheLocalPurchase({
    required SubscriptionPlan plan,
    String? token,
  }) async {
    await _subscriptionBox.put('tier', 'pro');
    await _subscriptionBox.put('plan', plan.name);
    if (plan == SubscriptionPlan.lifetime) {
      await _subscriptionBox.put(
        'expiresAt',
        DateTime(2100, 1, 1).toIso8601String(),
      );
      await _subscriptionBox.delete('trialStartedAt');
    } else {
      final days = plan == SubscriptionPlan.annual ? 365 : 30;
      await _subscriptionBox.put(
        'expiresAt',
        DateTime.now().add(Duration(days: days)).toIso8601String(),
      );
      if (_subscriptionBox.get('trialStartedAt') == null) {
        await _subscriptionBox.put(
          'trialStartedAt',
          DateTime.now().toIso8601String(),
        );
      }
    }
    if (token != null && token.isNotEmpty) {
      await _subscriptionBox.put('purchaseToken', token);
    }
    await _subscriptionBox.put('updatedAt', DateTime.now().toIso8601String());
  }

  Future<void> _cacheSubscriptionRow(Map<String, dynamic> row) async {
    final tier = (row['tier'] ?? 'free').toString();
    final plan = (row['plan'] ?? '').toString();
    final expiresAt = row['expires_at']?.toString();
    await _subscriptionBox.put('tier', tier);
    await _subscriptionBox.put('plan', plan);
    if (expiresAt != null && expiresAt.isNotEmpty) {
      await _subscriptionBox.put('expiresAt', expiresAt);
    }
    await _subscriptionBox.put('updatedAt', DateTime.now().toIso8601String());
  }

  void _onPurchases(List<PurchaseDetails> purchases) {
    final completer = _purchaseCompleter;
    final sku = _activePurchaseSku;
    if (completer == null || sku == null || completer.isCompleted) return;
    for (final purchase in purchases) {
      if (purchase.productID == sku) {
        completer.complete(purchase);
        _activePurchaseSku = null;
        break;
      }
    }
  }
}
