import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/theme.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmation')),
      body: Center(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CircleAvatar(radius: 40, backgroundColor: scheme.primaryContainer, child: Icon(Icons.check_circle, color: scheme.primary, size: 56)),
            const SizedBox(height: 16),
            Text('Order placed successfully', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Thank you for your order! You will receive a confirmation email shortly.'),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => context.go(AppRoutes.discover), child: const Text('Back to Discover')),
          ]),
        ),
      ),
    );
  }
}
