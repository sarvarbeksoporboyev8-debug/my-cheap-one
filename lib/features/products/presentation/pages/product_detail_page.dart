import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/product.dart';
import 'package:sellingapp/models/variant.dart';
import 'package:sellingapp/theme.dart';
import 'package:sellingapp/features/cart/presentation/controllers/cart_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/favorites.dart';

final productProvider = rp.FutureProvider.family<Product, String>((ref, id) async => ref.read(shopRepositoryProvider).getProduct(id));

class ProductDetailPage extends rp.ConsumerStatefulWidget {
  final String productId;
  const ProductDetailPage({super.key, required this.productId});

  @override
  rp.ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends rp.ConsumerState<ProductDetailPage> {
  final Map<String, int> _quantities = {};
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productProvider(widget.productId));
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: async.when(
        data: (p) => SingleChildScrollView(
          padding: AppSpacing.paddingMd,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: (p.images.isNotEmpty ? p.images.length : 3),
                controller: PageController(viewportFraction: 0.92),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Center(
                          child: Icon(Icons.image, size: 72, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: Text(p.name, style: Theme.of(context).textTheme.titleLarge)),
              rp.Consumer(builder: (context, ref2, _) {
                final favs = ref2.watch(favoritesProvider).asData?.value;
                final isFav = favs?.productIds.contains(p.id) ?? false;
                return IconButton(
                  tooltip: isFav ? 'Unfavorite' : 'Favorite',
                  icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
                  onPressed: () => ref2.read(favoritesProvider.notifier).toggleProduct(p.id),
                );
              })
            ]),
            if (p.description != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(p.description!)),
            const SizedBox(height: 12),
            // Supplier card
            if (p.supplierName != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.apartment),
                  title: Text(p.supplierName!),
                  subtitle: const Text('Supplier'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    // Try to find a producer by name and navigate
                    try {
                      final repo = ref.read(shopRepositoryProvider);
                      final list = await repo.listProducers(query: p.supplierName);
                      final match = list.firstWhere((e) => e.name.toLowerCase() == p.supplierName!.toLowerCase(), orElse: () => list.isNotEmpty ? list.first : throw Exception('notfound'));
                      if (context.mounted) context.push('/producers/${match.id}');
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Producer page not available for ${p.supplierName}')));
                      }
                    }
                  },
                ),
              ),
            ExpansionTile(title: const Text('Details'), initiallyExpanded: true, children: [
              if (p.description != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(p.description!)),
              Text('Properties', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              if (p.propertyIds.isEmpty)
                const Text('No properties listed.')
              else
                Column(children: p.propertyIds.map((id) => ListTile(leading: const Icon(Icons.label_outline), title: Text('Property $id'))).toList()),
            ]),
            const SizedBox(height: 12),
            Text('Variants', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...p.variants.map((v) => _VariantRow(variant: v, onChanged: (qty) => setState(() => _quantities[v.id] = qty))),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              label: 'Add selected variants to cart',
              child: FilledButton.icon(
              onPressed: _quantities.isEmpty
                  ? null
                  : () async {
                      final variants = <String, (String name, int qty, double price)>{};
                      for (final v in p.variants) {
                        final q = _quantities[v.id] ?? 0;
                        if (q > 0) {
                          variants[v.id] = ('${p.name} • ${v.displayName}', q, v.priceWithFees);
                        }
                      }
                      ref.read(cartControllerProvider.notifier).addItems(productId: p.id, variants: variants);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to cart')));
                      }
                    },
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text('Add to cart'),
              ),
            )
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _VariantRow extends StatefulWidget {
  final Variant variant;
  final ValueChanged<int> onChanged;
  const _VariantRow({required this.variant, required this.onChanged});
  @override
  State<_VariantRow> createState() => _VariantRowState();
}

class _VariantRowState extends State<_VariantRow> {
  int qty = 0;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingSm,
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.variant.displayName, style: Theme.of(context).textTheme.titleSmall),
              Text(widget.variant.unitToDisplay ?? ''),
            ]),
          ),
          Text('\$${widget.variant.priceWithFees.toStringAsFixed(2)}'),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Decrease quantity',
            child: IconButton(
              icon: Icon(Icons.remove_circle_outline, color: Theme.of(context).colorScheme.primary),
              onPressed: qty <= 0
                  ? null
                  : () {
                      setState(() => qty = qty - 1);
                      widget.onChanged(qty);
                    },
            ),
          ),
          Text(qty.toString()),
          Semantics(
            button: true,
            label: 'Increase quantity',
            child: IconButton(
              icon: Icon(Icons.add_circle_outline, color: Theme.of(context).colorScheme.primary),
              onPressed: (widget.variant.stockOnHand != null && qty >= (widget.variant.stockOnHand ?? 0))
                  ? null
                  : () {
                      setState(() => qty = qty + 1);
                      widget.onChanged(qty);
                    },
            ),
          ),
        ]),
      ),
    );
  }
}
