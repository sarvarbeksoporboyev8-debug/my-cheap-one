import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/favorites.dart';
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/product.dart';
import 'package:sellingapp/models/enterprise.dart';

class FavoritesPage extends rp.ConsumerWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final favsAsync = ref.watch(favoritesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favsAsync.when(
        data: (favs) => ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text('Shops', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (favs.shopIds.isEmpty) const Text('No favorite shops.')
            else ...favs.shopIds.map((id) => Card(child: ListTile(title: Text('Shop $id'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/shops/$id')))),
            const SizedBox(height: 16),
            Text('Products', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (favs.productIds.isEmpty) const Text('No favorite products.')
            else ...favs.productIds.map((id) => Card(child: ListTile(title: Text('Product $id'), trailing: const Icon(Icons.chevron_right), onTap: () => context.push('/products/$id')))),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
