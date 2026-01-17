import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/core/favorites.dart';

/// NavShell hosts the three primary tabs using a single Scaffold with
/// AppBar + NavigationBar. It renders the active branch content provided
/// by StatefulNavigationShell.
class NavShell extends rp.ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const NavShell({super.key, required this.navigationShell});

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Discover';
      case 1:
        return 'Map';
      case 2:
        return 'Cart';
      case 3:
        return 'Account';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final canPop = GoRouter.of(context).canPop();
    final favOnly = ref.watch(discoverFavoritesOnlyProvider);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: canPop ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()) : null,
        title: Text(_titleForIndex(navigationShell.currentIndex)),
        actions: [
          if (navigationShell.currentIndex == 0)
            Semantics(
              button: true,
              label: favOnly ? 'Show all' : 'Show favorites only',
              child: IconButton(
                tooltip: favOnly ? 'Favorites filter on' : 'Favorites filter off',
                icon: Icon(favOnly ? Icons.favorite : Icons.favorite_border, color: favOnly ? scheme.primary : scheme.onSurfaceVariant),
                onPressed: () => ref.read(discoverFavoritesOnlyProvider.notifier).toggle(),
              ),
            ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
        indicatorColor: scheme.primaryContainer,
      ),
    );
  }
}
