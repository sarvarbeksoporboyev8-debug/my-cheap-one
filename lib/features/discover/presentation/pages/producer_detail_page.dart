import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/models/product.dart';
import 'package:sellingapp/theme.dart';

final _producerProvider = rp.FutureProvider.family<Enterprise, String>((ref, id) async => ref.read(shopRepositoryProvider).getShopfront(id));
final _producerProductsProvider = rp.FutureProvider.family<List<Product>, String>((ref, id) async {
  final repo = ref.read(shopRepositoryProvider);
  final oc = (await repo.getCurrentOrderCycle())?.id ?? 'oc1';
  // Attempt to load products for this id as hub; if fails in mock dataset, return empty
  try {
    final products = await repo.listProducts(orderCycleId: oc, hubId: id, page: 1, perPage: 50);
    return products;
  } catch (_) {
    return <Product>[];
  }
});

class ProducerDetailPage extends rp.ConsumerWidget {
  final String id;
  const ProducerDetailPage({super.key, required this.id});
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final async = ref.watch(_producerProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Producer')),
      body: async.when(
        data: (p) => SingleChildScrollView(
          padding: AppSpacing.paddingMd,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Icon(Icons.landscape, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            const SizedBox(height: 12),
            Text(p.name, style: Theme.of(context).textTheme.titleLarge),
            if (p.shortDescription != null) Text(p.shortDescription!),
            const SizedBox(height: 12),
            Text('About', style: Theme.of(context).textTheme.titleMedium),
            Text(p.longDescription ?? 'No description available.'),
            const SizedBox(height: 16),
            Text('Contact', style: Theme.of(context).textTheme.titleMedium),
            Wrap(spacing: 8, children: [
              OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.call), label: const Text('Call')),
              OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.email), label: const Text('Email')),
              OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.link), label: const Text('Website')),
            ]),
            const SizedBox(height: 16),
            Text('Products from this producer', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            rp.Consumer(builder: (context, ref2, _) {
              final productsAsync = ref2.watch(_producerProductsProvider(id));
              return productsAsync.when(
                data: (list) => list.isEmpty
                    ? const Padding(padding: EdgeInsets.all(8), child: Text('No products to show.'))
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (_, i) {
                          final pr = list[i];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.fastfood),
                              title: Text(pr.name),
                              subtitle: Text(pr.supplierName ?? ''),
                              trailing: Text('\$${pr.minPrice.toStringAsFixed(2)}'),
                              onTap: () => context.push('/products/${pr.id}'),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemCount: list.length,
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error loading products: $e')),
              );
            })
          ]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
