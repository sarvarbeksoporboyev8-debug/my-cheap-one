import 'package:sellingapp/models/cart.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/models/filters.dart';
import 'package:sellingapp/models/order_cycle.dart';
import 'package:sellingapp/models/product.dart';

abstract class BaseDataSource {
  // Discovery
  Future<List<Enterprise>> listShops({String? query});
  Future<List<Enterprise>> listProducers({String? query});

  // Shopfront
  Future<Enterprise> getShopfront(String enterpriseId);
  Future<List<OrderCycle>> listOrderCycles(String enterpriseId);
  Future<void> selectOrderCycle(String orderCycleId);
  Future<OrderCycle?> getCurrentOrderCycle();

  // Products
  Future<List<Product>> listProducts({required String orderCycleId, required String hubId, int page = 1, int perPage = 20, String? search, List<String>? taxonIds, List<String>? propertyIds});
  Future<List<Taxon>> listTaxons({required String orderCycleId, required String hubId});
  Future<List<PropertyTag>> listProperties({required String orderCycleId, required String hubId});
  Future<Product> getProduct(String productId);

  // Cart
  Future<void> cartPopulate(Map<String, Map<String, int>> variantsQuantities);
  Future<Cart> getCart();
  Future<void> emptyCart();
}
