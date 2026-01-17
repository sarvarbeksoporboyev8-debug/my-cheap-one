import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/models/order_cycle.dart';
import 'package:sellingapp/models/product.dart';
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/theme.dart';
import 'package:sellingapp/features/products/presentation/widgets/filter_bottom_sheet.dart';

final _shopfrontProvider = rp.FutureProvider.family<Enterprise, String>((ref, id) async => ref.read(shopRepositoryProvider).getShopfront(id));
final _orderCyclesProvider = rp.FutureProvider.family<List<OrderCycle>, String>((ref, id) async => ref.read(shopRepositoryProvider).listOrderCycles(id));
final selectedOrderCycleIdProvider = rp.NotifierProvider<_SelectedOcNotifier, String?>(() => _SelectedOcNotifier());

class _SelectedOcNotifier extends rp.Notifier<String?> {
  @override
  String? build() => null;
}

final _productsProvider = rp.FutureProvider.family<List<Product>, (String enterpriseId, String? orderCycleId)>((ref, tuple) async {
  final (enterpriseId, ocId) = tuple;
  final repo = ref.read(shopRepositoryProvider);
  final currentOc = ocId ?? (await repo.getCurrentOrderCycle())?.id ?? 'oc1';
  // Using enterpriseId as hubId for mock
  return repo.listProducts(orderCycleId: currentOc, hubId: enterpriseId, page: 1, perPage: 20);
});

final _producersProvider = rp.FutureProvider.family<List<Enterprise>, String>((ref, enterpriseId) async {
  final repo = ref.read(shopRepositoryProvider);
  // If the data source supports filtering by shop/hub, implement here.
  // Fallback: show all producers.
  return repo.listProducers();
});

class ShopfrontPage extends rp.ConsumerWidget {
  final String enterpriseId;
  const ShopfrontPage({super.key, required this.enterpriseId});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final shopAsync = ref.watch(_shopfrontProvider(enterpriseId));
    final cyclesAsync = ref.watch(_orderCyclesProvider(enterpriseId));
    final selectedOcId = ref.watch(selectedOrderCycleIdProvider);

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Shopfront')),
      body: shopAsync.when(
        data: (shop) {
          return DefaultTabController(
            length: 3,
            child: Column(children: [
              _HeroHeader(shop: shop),
              Padding(
                padding: AppSpacing.horizontalMd.add(AppSpacing.verticalSm),
                child: Row(children: [
                  Icon(Icons.event_available, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: cyclesAsync.when(
                      data: (cycles) => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Order Cycle'),
                        value: selectedOcId ?? (cycles.isNotEmpty ? cycles.first.id : null),
                        items: cycles.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                        onChanged: (v) => ref.read(selectedOrderCycleIdProvider.notifier).state = v,
                      ),
                      loading: () => const LinearProgressIndicator(minHeight: 2),
                      error: (e, _) => Text('Order cycles error: $e'),
                    ),
                  )
                ]),
              ),
              const TabBar(tabs: [Tab(text: 'Products'), Tab(text: 'About'), Tab(text: 'Producers')]),
              Expanded(
                child: TabBarView(children: [
                  _ProductsTab(enterpriseId: enterpriseId),
                  _AboutTab(shop: shop),
                  _ProducersTab(shopName: shop.name),
                ]),
              )
            ]),
          );
        },
        loading: () => const _ShopfrontSkeleton(),
        error: (e, st) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Error: $e'),
          const SizedBox(height: 8),
          FilledButton(onPressed: () => ref.invalidate(_shopfrontProvider(enterpriseId)), child: const Text('Retry')),
        ])),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final Enterprise shop;
  const _HeroHeader({required this.shop});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Banner placeholder
      SizedBox(
        height: 140,
        width: double.infinity,
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(child: Icon(Icons.storefront, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      ),
      Padding(
        padding: AppSpacing.paddingMd,
        child: Row(children: [
          CircleAvatar(radius: 28, child: Text(shop.name.isNotEmpty ? shop.name[0] : '?')),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(shop.name, style: Theme.of(context).textTheme.titleLarge),
            if (shop.shortDescription != null) Text(shop.shortDescription!, style: Theme.of(context).textTheme.bodyMedium),
          ])),
        ]),
      ),
      Padding(
        padding: AppSpacing.horizontalMd,
        child: Wrap(spacing: 8, children: [
          if (shop.pickupAvailable) Chip(label: const Text('Pickup'), avatar: Icon(Icons.store_mall_directory, color: Theme.of(context).colorScheme.primary)),
          if (shop.deliveryAvailable) Chip(label: const Text('Delivery'), avatar: Icon(Icons.local_shipping, color: Theme.of(context).colorScheme.primary)),
        ]),
      )
    ]);
  }
}

class _ProductsTab extends rp.ConsumerStatefulWidget {
  final String enterpriseId;
  const _ProductsTab({required this.enterpriseId});
  @override
  rp.ConsumerState<_ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends rp.ConsumerState<_ProductsTab> {
  String search = '';
  String sort = 'az';
  Set<String> selectedTaxons = {};
  Set<String> selectedProps = {};

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final enterpriseId = widget.enterpriseId;
    final ocId = ref.watch(selectedOrderCycleIdProvider);
    final async = ref.watch(_productsProvider((enterpriseId, ocId)));
    final scheme = Theme.of(context).colorScheme;

    return async.when(
        data: (items) {
          // Client-side search/filter/sort for mock data
          var list = items.where((p) => p.name.toLowerCase().contains(search.toLowerCase())).toList();
          if (selectedTaxons.isNotEmpty) list = list.where((p) => p.taxonIds.any(selectedTaxons.contains)).toList();
          if (selectedProps.isNotEmpty) list = list.where((p) => p.propertyIds.any(selectedProps.contains)).toList();
          switch (sort) {
            case 'price_asc':
              list.sort((a, b) => a.minPrice.compareTo(b.minPrice));
              break;
            case 'price_desc':
              list.sort((a, b) => b.minPrice.compareTo(a.minPrice));
              break;
            default:
              list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          }

          return Column(children: [
            Padding(
              padding: AppSpacing.horizontalMd.add(AppSpacing.verticalSm),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products'),
                    onChanged: (v) => setState(() => search = v),
                  ),
                ),
                const SizedBox(width: 8),
                MenuAnchor(
                  builder: (context, controller, child) => OutlinedButton.icon(
                    onPressed: () => controller.open(),
                    icon: const Icon(Icons.sort),
                    label: Text(switch (sort) { 'price_asc' => 'Price ↑', 'price_desc' => 'Price ↓', _ => 'A → Z' }),
                  ),
                  menuChildren: [
                    MenuItemButton(onPressed: () => setState(() => sort = 'az'), child: const Text('A → Z')),
                    MenuItemButton(onPressed: () => setState(() => sort = 'price_asc'), child: const Text('Price low → high')),
                    MenuItemButton(onPressed: () => setState(() => sort = 'price_desc'), child: const Text('Price high → low')),
                  ],
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () async {
                    // Load taxons/properties for this shop & OC
                    final repo = ref.read(shopRepositoryProvider);
                    final currentOc = ocId ?? (await repo.getCurrentOrderCycle())?.id ?? 'oc1';
                    final taxons = await repo.listTaxons(orderCycleId: currentOc, hubId: enterpriseId);
                    final props = await repo.listProperties(orderCycleId: currentOc, hubId: enterpriseId);
                    if (!context.mounted) return;
                    showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      builder: (_) => FilterModalBottomSheet(
                        taxons: taxons,
                        properties: props,
                        selectedTaxons: {...selectedTaxons},
                        selectedProperties: {...selectedProps},
                        onApply: (t, p) {
                          setState(() {
                            selectedTaxons = t;
                            selectedProps = p;
                          });
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  label: Text('Filters${(selectedTaxons.length + selectedProps.length) > 0 ? ' (${selectedTaxons.length + selectedProps.length})' : ''}'),
                ),
              ]),
            ),
            // Active filter chips
            if (selectedTaxons.isNotEmpty || selectedProps.isNotEmpty)
              Padding(
                padding: AppSpacing.horizontalMd,
                child: Wrap(spacing: 8, children: [
                  ...selectedTaxons.map((id) => InputChip(
                        label: Text('Cat $id'),
                        onDeleted: () => setState(() => selectedTaxons = {...selectedTaxons}..remove(id)),
                      )),
                  ...selectedProps.map((id) => InputChip(
                        label: Text('Prop $id'),
                        onDeleted: () => setState(() => selectedProps = {...selectedProps}..remove(id)),
                      )),
                ]),
              ),
            Expanded(
              child: list.isEmpty
                  ? const Center(child: Text('No products match your filters'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, i) {
                        final p = list[i];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.fastfood, color: scheme.tertiary),
                            title: Text(p.name),
                            subtitle: Text(p.supplierName ?? ''),
                            trailing: Text('\$${p.minPrice.toStringAsFixed(2)}'),
                            onTap: () => context.push('/products/${p.id}'),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: list.length,
                    ),
            ),
          ]);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Error: $e'),
          const SizedBox(height: 8),
          FilledButton(onPressed: () => ref.invalidate(_productsProvider((enterpriseId, ocId))), child: const Text('Retry')),
        ])),
      );
  }
}

class _AboutTab extends StatelessWidget {
  final Enterprise shop;
  const _AboutTab({required this.shop});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(shop.longDescription ?? 'No description provided.'),
        const SizedBox(height: 16),
        Text('Address', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
          child: const Text('Address not available'),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 8, children: [
          if (shop.pickupAvailable) Chip(label: const Text('Pickup available'), avatar: Icon(Icons.store, color: scheme.primary)),
          if (shop.deliveryAvailable) Chip(label: const Text('Delivery available'), avatar: Icon(Icons.local_shipping, color: scheme.primary)),
        ]),
        const SizedBox(height: 16),
        Text('Contact', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.call), label: const Text('Call')),
          OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.email), label: const Text('Email')),
          OutlinedButton.icon(onPressed: null, icon: const Icon(Icons.link), label: const Text('Website')),
        ])
      ]),
    );
  }
}

class _ProducersTab extends rp.ConsumerWidget {
  final String shopName;
  const _ProducersTab({required this.shopName});
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final async = ref.watch(_producersProvider(shopName));
    return async.when(
      data: (items) => ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final e = items[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(child: Text(e.name.isNotEmpty ? e.name[0] : '?')),
              title: Text(e.name),
              subtitle: Text(e.shortDescription ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/producers/${e.id}'),
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}

class _ShopfrontSkeleton extends StatelessWidget {
  const _ShopfrontSkeleton();
  @override
  Widget build(BuildContext context) => Column(children: [
        Container(height: 180, color: Theme.of(context).colorScheme.surfaceContainerHighest),
        const SizedBox(height: 8),
        const LinearProgressIndicator(minHeight: 2),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, __) => Card(child: SizedBox(height: 72)),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: 6,
          ),
        )
      ]);
}
