import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/theme.dart';
import 'package:sellingapp/core/favorites.dart';
import 'dart:async';
// Content-only page rendered inside NavShell

final discoverQueryProvider = rp.NotifierProvider<_QueryNotifier, String>(() => _QueryNotifier());

class _QueryNotifier extends rp.Notifier<String> {
  @override
  String build() => '';
}

final shopsProvider = rp.FutureProvider<List<Enterprise>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  final q = ref.watch(discoverQueryProvider);
  return repo.listShops(query: q);
});

final producersProvider = rp.FutureProvider<List<Enterprise>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  final q = ref.watch(discoverQueryProvider);
  return repo.listProducers(query: q);
});

class DiscoverPage extends rp.ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  rp.ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends rp.ConsumerState<DiscoverPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Timer? _debounce;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(children: [
      Padding(
        padding: AppSpacing.horizontalMd.add(AppSpacing.verticalSm),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(prefixIcon: Icon(Icons.search, color: scheme.primary), hintText: 'Search shops and producers'),
          onChanged: (v) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 350), () => ref.read(discoverQueryProvider.notifier).state = v);
          },
        ),
      ),
      TabBar(
        controller: _tabController,
        tabs: const [Tab(text: 'Shops'), Tab(text: 'Producers')],
      ),
      Expanded(
        child: TabBarView(controller: _tabController, children: [
          _EnterpriseList(isProducers: false),
          _EnterpriseList(isProducers: true),
        ]),
      )
    ]);
  }
}

class _EnterpriseList extends rp.ConsumerWidget {
  final bool isProducers;
  const _EnterpriseList({required this.isProducers});

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final async = ref.watch(isProducers ? producersProvider : shopsProvider);
    final favsAsync = ref.watch(favoritesProvider);
    final favOnly = ref.watch(discoverFavoritesOnlyProvider);
    return async.when(
      data: (items) {
        return favsAsync.when(
          data: (favs) {
            final filtered = favOnly
                ? items.where((e) => favs.shopIds.contains(e.id)).toList()
                : items;
            if (filtered.isEmpty) {
              return _EmptyState(
                title: favOnly ? 'No favorites yet' : 'No results',
                actionLabel: favOnly ? 'Browse all' : null,
                onAction: favOnly ? () => ref.read(discoverFavoritesOnlyProvider.notifier).toggle() : null,
              );
            }
            return LayoutBuilder(builder: (context, constraints) {
              final isGrid = constraints.maxWidth > 700;
              final crossAxisCount = constraints.maxWidth > 1100 ? 3 : 2;
              if (!isGrid) {
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) => _EnterpriseCard(e: filtered[index], isProducer: isProducers),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 3.3),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _EnterpriseCard(e: filtered[index], isProducer: isProducers),
              );
            });
          },
          loading: () => const _ListSkeleton(),
          error: (e, _) => _ErrorState(message: 'Failed to load favorites', onRetry: () => ref.invalidate(favoritesProvider)),
        );
      },
      loading: () => const _ListSkeleton(),
      error: (e, st) => _ErrorState(message: 'Error: $e', onRetry: () => ref.invalidate(isProducers ? producersProvider : shopsProvider)),
    );
  }
}

class _EnterpriseCard extends rp.ConsumerWidget {
  final Enterprise e;
  final bool isProducer;
  const _EnterpriseCard({required this.e, required this.isProducer});
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final favs = ref.watch(favoritesProvider).asData?.value;
    final isFav = favs?.shopIds.contains(e.id) ?? false;
    final isOpen = e.ordersCloseAt == null || e.ordersCloseAt!.isAfter(DateTime.now());
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: () => context.push(isProducer ? '/producers/${e.id}' : '/shops/${e.id}'),
        child: Padding(
          padding: AppSpacing.paddingSm,
          child: Row(children: [
            CircleAvatar(child: Text(e.name.isNotEmpty ? e.name[0] : '?')),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(e.shortDescription ?? 'Fresh local produce', maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Wrap(spacing: 6, children: [
                  Chip(visualDensity: VisualDensity.compact, label: Text(isOpen ? 'Open' : 'Closed'), backgroundColor: isOpen ? scheme.primaryContainer : scheme.errorContainer),
                  if (e.pickupAvailable) Chip(visualDensity: VisualDensity.compact, label: const Text('Pickup'), avatar: Icon(Icons.store_mall_directory, color: scheme.primary)),
                  if (e.deliveryAvailable) Chip(visualDensity: VisualDensity.compact, label: const Text('Delivery'), avatar: Icon(Icons.local_shipping, color: scheme.primary)),
                ])
              ]),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: isFav ? 'Remove from favorites' : 'Add to favorites',
              child: IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? scheme.primary : scheme.onSurfaceVariant),
                onPressed: () => ref.read(favoritesProvider.notifier).toggleShop(e.id),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (_, __) => Card(
        child: SizedBox(height: 72, child: Container(color: Theme.of(context).colorScheme.surfaceContainerHighest)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh, color: Colors.white), label: const Text('Retry')),
        ]),
      );
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const _EmptyState({required this.title, this.actionLabel, this.onAction});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title),
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ]
        ]),
      );
}
