import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:sellingapp/data/datasources/base_data_source.dart';
import 'package:sellingapp/models/cart.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/models/filters.dart';
import 'package:sellingapp/models/order_cycle.dart';
import 'package:sellingapp/models/product.dart';

class ApiDataSource implements BaseDataSource {
  final Dio _dio;
  ApiDataSource(this._dio);

  @override
  Future<List<Enterprise>> listProducers({String? query}) async {
    // No direct endpoint; reuse shops and filter by type in future
    return listShops(query: query);
  }

  @override
  Future<List<Enterprise>> listShops({String? query}) async {
    // Placeholder: In a real backend, implement discover endpoint or composite search
    // For now, return empty and let UI show empty state
    return [];
  }

  @override
  Future<Enterprise> getShopfront(String enterpriseId) async {
    final res = await _dio.get('/api/v0/shops/$enterpriseId.json');
    return Enterprise.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<OrderCycle>> listOrderCycles(String enterpriseId) async {
    // Not specified: order cycles list endpoint by enterprise is usually embedded in shopfront
    // For now return empty, UI will handle gracefully
    return [];
  }

  @override
  Future<void> selectOrderCycle(String orderCycleId) async {
    await _dio.post('/shop/order_cycle.json', data: {'order_cycle_id': orderCycleId});
  }

  @override
  Future<OrderCycle?> getCurrentOrderCycle() async {
    final res = await _dio.get('/shop/order_cycle.json');
    if (res.data == null) return null;
    return OrderCycle.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<List<Product>> listProducts({required String orderCycleId, required String hubId, int page = 1, int perPage = 20, String? search, List<String>? taxonIds, List<String>? propertyIds}) async {
    final query = <String, dynamic>{
      'distributor': hubId,
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search.isNotEmpty) {
      query['q[name_or_meta_keywords_or_variants_display_as_or_variants_display_name_or_supplier_name_cont]'] = search;
    }
    for (final t in taxonIds ?? const []) {
      query['q[primary_taxon_id_in_any][]'] = t;
    }
    for (final p in propertyIds ?? const []) {
      query['q[with_properties][]'] = p;
    }
    final res = await _dio.get('/api/v0/order_cycles/$orderCycleId/products.json', queryParameters: query);
    final list = (res.data as List).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    return list;
  }

  @override
  Future<List<Taxon>> listTaxons({required String orderCycleId, required String hubId}) async {
    final res = await _dio.get('/api/v0/order_cycles/$orderCycleId/taxons.json', queryParameters: {'distributor': hubId});
    final list = (res.data as List).map((e) => Taxon.fromJson(e as Map<String, dynamic>)).toList();
    return list;
  }

  @override
  Future<List<PropertyTag>> listProperties({required String orderCycleId, required String hubId}) async {
    final res = await _dio.get('/api/v0/order_cycles/$orderCycleId/properties.json', queryParameters: {'distributor': hubId});
    final list = (res.data as List).map((e) => PropertyTag.fromJson(e as Map<String, dynamic>)).toList();
    return list;
  }

  @override
  Future<Product> getProduct(String productId) async {
    // Not specified explicitly; typically /products/:id
    final res = await _dio.get('/api/v0/products/$productId.json');
    return Product.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> cartPopulate(Map<String, Map<String, int>> variantsQuantities) async {
    await _dio.post('/cart/populate', data: {'variants': variantsQuantities});
  }

  @override
  Future<Cart> getCart() async {
    final res = await _dio.get('/cart.json');
    return Cart.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> emptyCart() async {
    await _dio.put('/cart/empty');
  }
}
