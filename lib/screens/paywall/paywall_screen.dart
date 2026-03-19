import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/subscription_provider.dart';

enum _PaywallPlan { annual, monthly, lifetime }

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  _PaywallPlan _selectedPlan = _PaywallPlan.annual;
  bool _isPurchasing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(billingProductsProvider);
    final products = productsAsync.asData?.value ?? const <ProductDetails>[];
    final selectedSku = _mapPlanToSubscriptionPlan(_selectedPlan).sku;
    final selectedProduct = products.where((p) => p.id == selectedSku).toList();
    final selectedPrice = selectedProduct.isNotEmpty
        ? selectedProduct.first.price
        : switch (_selectedPlan) {
            _PaywallPlan.annual => r'$35.99/yr',
            _PaywallPlan.monthly => r'$5.99/mo',
            _PaywallPlan.lifetime => r'$79.99 one-time',
          };

    return Scaffold(
      appBar: AppBar(title: const Text('SysDesign Flash Pro')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build confidence faster with Pro',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const _BenefitItem(
                      icon: Icons.auto_awesome_outlined,
                      text: 'SM-2 smart queue and weak area targeting',
                    ),
                    const _BenefitItem(
                      icon: Icons.quiz_outlined,
                      text: 'Timed interview simulation mode',
                    ),
                    const _BenefitItem(
                      icon: Icons.analytics_outlined,
                      text:
                          'Readiness score, heatmap, and confidence analytics',
                    ),
                    const _BenefitItem(
                      icon: Icons.cloud_sync_outlined,
                      text: 'Cloud sync support when backend is enabled',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SegmentedButton<_PaywallPlan>(
                      segments: const [
                        ButtonSegment(
                          value: _PaywallPlan.annual,
                          label: Text('Annual'),
                        ),
                        ButtonSegment(
                          value: _PaywallPlan.monthly,
                          label: Text('Monthly'),
                        ),
                        ButtonSegment(
                          value: _PaywallPlan.lifetime,
                          label: Text('Lifetime'),
                        ),
                      ],
                      selected: {_selectedPlan},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedPlan = selection.first);
                      },
                    ),
                    const SizedBox(height: 12),
                    _PlanTile(
                      selected: _selectedPlan == _PaywallPlan.annual,
                      title: 'Annual',
                      subtitle: _planSubtitle(
                        products,
                        SubscriptionPlan.annual,
                        fallback: r'$35.99 / year (best value)',
                      ),
                    ),
                    _PlanTile(
                      selected: _selectedPlan == _PaywallPlan.monthly,
                      title: 'Monthly',
                      subtitle: _planSubtitle(
                        products,
                        SubscriptionPlan.monthly,
                        fallback: r'$5.99 / month',
                      ),
                    ),
                    _PlanTile(
                      selected: _selectedPlan == _PaywallPlan.lifetime,
                      title: 'Lifetime',
                      subtitle: _planSubtitle(
                        products,
                        SubscriptionPlan.lifetime,
                        fallback: r'$79.99 one-time',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isPurchasing ? null : _startPurchase,
                child: _isPurchasing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _selectedPlan == _PaywallPlan.lifetime
                            ? 'Buy Lifetime Access — $selectedPrice'
                            : 'Start 7-day Free Trial — $selectedPrice',
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '"The smartest way to retain system design concepts before interviews."',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton(
                  onPressed: _launchCancelSubscription,
                  child: const Text('Cancel anytime'),
                ),
                TextButton(
                  onPressed: _isPurchasing ? null : _restorePurchases,
                  child: const Text('Restore'),
                ),
                TextButton(
                  onPressed: _launchPrivacyPolicy,
                  child: const Text('Privacy'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPurchase() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isPurchasing = true);
    try {
      await ref
          .read(subscriptionProvider.notifier)
          .purchasePlan(_mapPlanToSubscriptionPlan(_selectedPlan));
      if (!mounted) return;
      router.go('/upgrade-success');
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isPurchasing = true);
    try {
      final tier = await ref
          .read(subscriptionProvider.notifier)
          .restorePurchases();
      if (!mounted) return;
      if (tier == SubscriptionTier.pro) {
        router.go('/upgrade-success');
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('No active Pro purchase found.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse('https://sysdesignflash.dev/privacy');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchCancelSubscription() async {
    // iOS: deep-link to App Store subscriptions; Android: Google Play.
    final iosUri = Uri.parse('https://apps.apple.com/account/subscriptions');
    final androidUri = Uri.parse(
      'https://play.google.com/store/account/subscriptions',
    );
    final uri =
        Theme.of(context).platform == TargetPlatform.iOS ? iosUri : androidUri;
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  SubscriptionPlan _mapPlanToSubscriptionPlan(_PaywallPlan plan) {
    return switch (plan) {
      _PaywallPlan.annual => SubscriptionPlan.annual,
      _PaywallPlan.monthly => SubscriptionPlan.monthly,
      _PaywallPlan.lifetime => SubscriptionPlan.lifetime,
    };
  }

  String _planSubtitle(
    List<ProductDetails> products,
    SubscriptionPlan plan, {
    required String fallback,
  }) {
    for (final product in products) {
      if (product.id == plan.sku) {
        if (plan == SubscriptionPlan.lifetime) {
          return '${product.price} one-time';
        }
        if (plan == SubscriptionPlan.annual) {
          return '${product.price} / year (best value)';
        }
        return '${product.price} / month';
      }
    }
    return fallback;
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;

  const _PlanTile({
    required this.selected,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? theme.colorScheme.primary : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            selected ? Icons.check_circle : Icons.circle_outlined,
            size: 18,
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title - $subtitle',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
