import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sellingapp/data/datasources/base_data_source.dart';
import 'package:sellingapp/models/cart.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/models/filters.dart';
import 'package:sellingapp/models/order_cycle.dart';
import 'package:sellingapp/models/product.dart';

class MockDataSource implements BaseDataSource {
  final Ref ref;
  Cart _cart = const Cart(items: []);
  OrderCycle? _current;
  MockDataSource(this.ref);

  Future<Map<String, dynamic>> _loadJson(String path) async {
    final str = await rootBundle.loadString(path);
    return json.decode(str) as Map<String, dynamic>;
  }

  @override
  Future<List<Enterprise>> listShops({String? query}) async {
    final data = await _loadJson('assets/mock/shops.json');
    final items = (data['shops'] as List).map((e) => Enterprise.fromJson(e as Map<String, dynamic>)).toList();
    if (query == null || query.isEmpty) return items;
    return items.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<Enterprise>> listProducers({String? query}) async {
    final data = await _loadJson('assets/mock/producers.json');
    final items = (data['producers'] as List).map((e) => Enterprise.fromJson(e as Map<String, dynamic>)).toList();
    if (query == null || query.isEmpty) return items;
    return items.where((e) => e.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<Enterprise> getShopfront(String enterpriseId) async {
    final data = await _loadJson('assets/mock/shop_${enterpriseId}.json');
    return Enterprise.fromJson(data['shop'] as Map<String, dynamic>);
  }

  @override
  Future<List<OrderCycle>> listOrderCycles(String enterpriseId) async {
    final data = await _loadJson('assets/mock/order_cycles_${enterpriseId}.json');
    final items = (data['order_cycles'] as List).map((e) => OrderCycle.fromJson(e as Map<String, dynamic>)).toList();
    return items;
  }

  @override
  Future<void> selectOrderCycle(String orderCycleId) async {
    _current = OrderCycle(id: orderCycleId, name: 'Selected');
  }

  @override
  Future<OrderCycle?> getCurrentOrderCycle() async => _current;

  @override
  Future<List<Product>> listProducts({required String orderCycleId, required String hubId, int page = 1, int perPage = 20, String? search, List<String>? taxonIds, List<String>? propertyIds}) async {
    final data = await _loadJson('assets/mock/products_${hubId}_${orderCycleId}.json');
    var items = (data['products'] as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    if (search != null && search.isNotEmpty) {
      items = items.where((p) => p.name.toLowerCase().contains(search.toLowerCase())).toList();
    }
    if (taxonIds != null && taxonIds.isNotEmpty) {
      items = items.where((p) => p.taxonIds.any(taxonIds.contains)).toList();
    }
    if (propertyIds != null && propertyIds.isNotEmpty) {
      items = items.where((p) => p.propertyIds.any(propertyIds.contains)).toList();
    }
    final start = (page - 1) * perPage;
    final end = (start + perPage) > items.length ? items.length : start + perPage;
    if (start >= items.length) return [];
    return items.sublist(start, end);
  }

  @override
  Future<List<Taxon>> listTaxons({required String orderCycleId, required String hubId}) async {
    final data = await _loadJson('assets/mock/taxons_${hubId}_${orderCycleId}.json');
    return (data['taxons'] as List).map((e) => Taxon.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PropertyTag>> listProperties({required String orderCycleId, required String hubId}) async {
    final data = await _loadJson('assets/mock/properties_${hubId}_${orderCycleId}.json');
    return (data['properties'] as List).map((e) => PropertyTag.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Product> getProduct(String productId) async {
    final data = await _loadJson('assets/mock/product_$productId.json');
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  @override
  Future<void> cartPopulate(Map<String, Map<String, int>> variantsQuantities) async {
    final newItems = <LineItem>[];
    for (final entry in variantsQuantities.entries) {
      for (final vEntry in entry.value.entries) {
        newItems.add(LineItem(productId: entry.key, variantId: vEntry.key, name: 'Item ${entry.key}-${vEntry.key}', quantity: vEntry.value, price: 5.0));
      }
    }
    _cart = Cart(items: [..._cart.items, ...newItems]);
  }

  @override
  Future<Cart> getCart() async => _cart;

  @override
  Future<void> emptyCart() async {
    _cart = const Cart(items: []);
  }
}
