import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/subscription_provider.dart';

class ProGate extends ConsumerWidget {
  final Widget child;
  final String featureTitle;

  const ProGate({
    super.key,
    required this.child,
    this.featureTitle = 'Pro feature',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(subscriptionProvider);

    if (tier == SubscriptionTier.pro) return child;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: const Icon(Icons.lock_outline),
        title: Text('Unlock: $featureTitle'),
        subtitle: const Text('Start your Pro smart sessions and get smarter scheduling.'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/paywall'),
      ),
    );
  }
}

