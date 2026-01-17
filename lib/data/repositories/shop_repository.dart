import 'package:sellingapp/data/datasources/base_data_source.dart';
import 'package:sellingapp/models/enterprise.dart';
import 'package:sellingapp/models/filters.dart';
import 'package:sellingapp/models/order_cycle.dart';
import 'package:sellingapp/models/product.dart';

class ShopRepository {
  final BaseDataSource _ds;
  ShopRepository(this._ds);

  Future<List<Enterprise>> listShops({String? query}) => _ds.listShops(query: query);
  Future<List<Enterprise>> listProducers({String? query}) => _ds.listProducers(query: query);
  Future<Enterprise> getShopfront(String id) => _ds.getShopfront(id);
  Future<List<OrderCycle>> listOrderCycles(String enterpriseId) => _ds.listOrderCycles(enterpriseId);
  Future<void> selectOrderCycle(String id) => _ds.selectOrderCycle(id);
  Future<OrderCycle?> getCurrentOrderCycle() => _ds.getCurrentOrderCycle();
  Future<List<Product>> listProducts({required String orderCycleId, required String hubId, int page = 1, int perPage = 20, String? search, List<String>? taxonIds, List<String>? propertyIds}) => _ds.listProducts(orderCycleId: orderCycleId, hubId: hubId, page: page, perPage: perPage, search: search, taxonIds: taxonIds, propertyIds: propertyIds);
  Future<List<Taxon>> listTaxons({required String orderCycleId, required String hubId}) => _ds.listTaxons(orderCycleId: orderCycleId, hubId: hubId);
  Future<List<PropertyTag>> listProperties({required String orderCycleId, required String hubId}) => _ds.listProperties(orderCycleId: orderCycleId, hubId: hubId);
  Future<Product> getProduct(String id) => _ds.getProduct(id);
}
