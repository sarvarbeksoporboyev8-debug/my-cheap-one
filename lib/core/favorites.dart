import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds persisted favorites for shops and products
class FavoritesState {
  final Set<String> shopIds;
  final Set<String> productIds;
  const FavoritesState({required this.shopIds, required this.productIds});

  FavoritesState copyWith({Set<String>? shopIds, Set<String>? productIds}) => FavoritesState(
        shopIds: shopIds ?? this.shopIds,
        productIds: productIds ?? this.productIds,
      );
}

class FavoritesNotifier extends AsyncNotifier<FavoritesState> {
  static const _kShops = 'fav_shops';
  static const _kProducts = 'fav_products';

  @override
  Future<FavoritesState> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final shops = prefs.getStringList(_kShops) ?? const [];
      final products = prefs.getStringList(_kProducts) ?? const [];
      return FavoritesState(shopIds: shops.toSet(), productIds: products.toSet());
    } catch (e) {
      debugPrint('Favorites load failed: $e');
      return const FavoritesState(shopIds: {}, productIds: {});
    }
  }

  Future<void> _persist(FavoritesState s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kShops, s.shopIds.toList());
      await prefs.setStringList(_kProducts, s.productIds.toList());
    } catch (e) {
      debugPrint('Favorites persist failed: $e');
    }
  }

  Future<void> toggleShop(String id) async {
    final current = state.value ?? const FavoritesState(shopIds: {}, productIds: {});
    final next = current.shopIds.contains(id)
        ? current.copyWith(shopIds: {...current.shopIds}..remove(id))
        : current.copyWith(shopIds: {...current.shopIds, id});
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> toggleProduct(String id) async {
    final current = state.value ?? const FavoritesState(shopIds: {}, productIds: {});
    final next = current.productIds.contains(id)
        ? current.copyWith(productIds: {...current.productIds}..remove(id))
        : current.copyWith(productIds: {...current.productIds, id});
    state = AsyncData(next);
    await _persist(next);
  }

  bool isShopFav(String id) => state.value?.shopIds.contains(id) ?? false;
  bool isProductFav(String id) => state.value?.productIds.contains(id) ?? false;
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, FavoritesState>(() => FavoritesNotifier());

/// Controls whether Discover shows only favorites
class DiscoverFavoritesFilter extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final discoverFavoritesOnlyProvider = NotifierProvider<DiscoverFavoritesFilter, bool>(() => DiscoverFavoritesFilter());
