import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/cart.dart';
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/theme.dart';
import 'package:sellingapp/features/cart/presentation/controllers/cart_controller.dart';

final cartProvider = rp.FutureProvider<Cart>((ref) async => ref.read(cartRepositoryProvider).getCart());

class CartPage extends rp.ConsumerWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final cartState = ref.watch(cartControllerProvider);
    final controller = ref.read(cartControllerProvider.notifier);
    if (cartState.items.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Your cart is empty'),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: () => context.go('/'), icon: const Icon(Icons.explore, color: Colors.white), label: const Text('Continue shopping')),
        ]),
      );
    }
    return LayoutBuilder(builder: (context, constraints) {
      final wide = constraints.maxWidth > 900;
      final list = ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, i) {
          final it = cartState.items[i];
          return Card(
            child: Padding(
              padding: AppSpacing.paddingSm,
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(it.name, style: Theme.of(context).textTheme.titleSmall),
                    Text('Variant ${it.variantId}', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                ),
                IconButton(
                  tooltip: 'Remove',
                  icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Remove item?'),
                        content: Text('Remove ${it.name} from cart?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
                        ],
                      ),
                    );
                    if (confirm == true) controller.removeAt(i);
                  },
                ),
                const SizedBox(width: 4),
                Text('\$' + it.total.toStringAsFixed(2)),
                const SizedBox(width: 8),
                IconButton(icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.primary), onPressed: () => controller.decrement(i)),
                Text(it.quantity.toString()),
                IconButton(icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary), onPressed: () => controller.increment(i)),
              ]),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemCount: cartState.items.length,
      );

      final summary = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('Subtotal: ' + ('\$' + cartState.subtotal.toStringAsFixed(2)), textAlign: TextAlign.right, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: 'Proceed to checkout',
          child: FilledButton(onPressed: () => context.push(AppRoutes.checkout), child: const Text('Checkout')),
        ),
        TextButton(onPressed: controller.clear, child: const Text('Empty cart')),
      ]);

      if (wide) {
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: list),
          SizedBox(width: 360, child: Padding(padding: AppSpacing.paddingMd, child: Card(child: Padding(padding: AppSpacing.paddingMd, child: summary)))),
        ]);
      }

      return Scaffold(
        body: list,
        bottomNavigationBar: SafeArea(
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            padding: AppSpacing.paddingMd,
            child: summary,
          ),
        ),
      );
    });
  }
}
