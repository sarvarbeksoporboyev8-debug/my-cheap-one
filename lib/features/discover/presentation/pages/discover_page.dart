import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/theme.dart';
import 'package:sellingapp/core/favorites.dart';
import 'package:sellingapp/widgets/enterprise_list_item.dart';
import 'dart:async';

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

class _DiscoverPageState extends rp.ConsumerState<DiscoverPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Timer? _debounce;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Search bar - Google style pill
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
                hintText: 'Search shops and producers',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: scheme.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(discoverQueryProvider.notifier).state = '';
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (v) {
                setState(() {});
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 350),
                  () => ref.read(discoverQueryProvider.notifier).state = v,
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Tab bar - segmented style
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.all(4),
            dividerColor: Colors.transparent,
            labelColor: scheme.onPrimaryContainer,
            unselectedLabelColor: scheme.onSurfaceVariant,
            labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            unselectedLabelStyle: textTheme.labelLarge,
            splashFactory: InkSparkle.splashFactory,
            overlayColor: WidgetStateProperty.all(scheme.primary.withOpacity(0.08)),
            tabs: const [
              Tab(text: 'Shops'),
              Tab(text: 'Producers'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _EnterpriseList(isProducers: false),
              _EnterpriseList(isProducers: true),
            ],
          ),
        ),
      ],
    );
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return async.when(
      data: (items) {
        return favsAsync.when(
          data: (favs) {
            final filtered = favOnly
                ? items.where((e) => favs.shopIds.contains(e.id)).toList()
                : items;

            if (filtered.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          favOnly ? Icons.favorite_border_rounded : Icons.search_off_rounded,
                          size: 40,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        favOnly ? 'No favorites yet' : 'No results found',
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        favOnly
                            ? 'Tap the heart icon to save favorites'
                            : 'Try adjusting your search',
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final e = filtered[index];
                return EnterpriseListItem(
                  e: e,
                  onTap: () => context.push(
                    isProducers ? '/producers/${e.id}' : '/shops/${e.id}',
                  ),
                );
              },
            );
          },
          loading: () => _buildSkeleton(scheme),
          error: (_, __) => _buildError(context, ref, scheme, textTheme),
        );
      },
      loading: () => _buildSkeleton(scheme),
      error: (_, __) => _buildError(context, ref, scheme, textTheme),
    );
  }

  Widget _buildSkeleton(ColorScheme scheme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => Container(
        height: 220,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, rp.WidgetRef ref, ColorScheme scheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: scheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text('Something went wrong', style: textTheme.titleMedium),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(isProducers ? producersProvider : shopsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
