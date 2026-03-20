import 'package:flutter/material.dart';

/// All features are free — ProGate is a passthrough.
class ProGate extends StatelessWidget {
  final Widget child;
  final String featureTitle;
  final String featureDescription;

  const ProGate({
    super.key,
    required this.child,
    this.featureTitle = '',
    this.featureDescription = '',
  });

  @override
  Widget build(BuildContext context) => child;
}
