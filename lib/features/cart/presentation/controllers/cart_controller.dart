import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:sellingapp/core/providers.dart';
import 'package:sellingapp/models/cart.dart';

class CartState {
  final List<LineItem> items;
  const CartState({this.items = const []});
  double get subtotal => items.fold(0.0, (s, e) => s + e.total);
  CartState copyWith({List<LineItem>? items}) => CartState(items: items ?? this.items);
}

final cartControllerProvider = rp.NotifierProvider<CartController, CartState>(() => CartController());

class CartController extends rp.Notifier<CartState> {
  @override
  CartState build() {
    // Initialize from repository, but don't block UI
    _init();
    return const CartState();
  }

  Future<void> _init() async {
    try {
      final cart = await ref.read(cartRepositoryProvider).getCart();
      state = CartState(items: List.of(cart.items));
    } catch (e) {
      debugPrint('Failed to load cart: $e');
    }
  }

  void increment(int index) {
    final list = List<LineItem>.of(state.items);
    final it = list[index];
    list[index] = LineItem(productId: it.productId, variantId: it.variantId, name: it.name, quantity: it.quantity + 1, price: it.price);
    state = state.copyWith(items: list);
  }

  void decrement(int index) {
    final list = List<LineItem>.of(state.items);
    final it = list[index];
    final nextQty = (it.quantity - 1).clamp(0, 9999);
    if (nextQty == 0) {
      list.removeAt(index);
    } else {
      list[index] = LineItem(productId: it.productId, variantId: it.variantId, name: it.name, quantity: nextQty, price: it.price);
    }
    state = state.copyWith(items: list);
  }

  void clear() => state = const CartState(items: []);

  void removeAt(int index) {
    final list = List<LineItem>.of(state.items);
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      state = state.copyWith(items: list);
    }
  }

  /// Add multiple variant quantities for a single product. Merges with existing items.
  void addItems({required String productId, required Map<String, (String name, int qty, double price)> variants}) {
    final list = List<LineItem>.of(state.items);
    for (final entry in variants.entries) {
      final variantId = entry.key;
      final (name, qty, price) = entry.value;
      if (qty <= 0) continue;
      final idx = list.indexWhere((e) => e.productId == productId && e.variantId == variantId);
      if (idx >= 0) {
        final it = list[idx];
        list[idx] = LineItem(productId: it.productId, variantId: it.variantId, name: it.name, quantity: it.quantity + qty, price: it.price);
      } else {
        list.add(LineItem(productId: productId, variantId: variantId, name: name, quantity: qty, price: price));
      }
    }
    state = state.copyWith(items: list);
  }
}
