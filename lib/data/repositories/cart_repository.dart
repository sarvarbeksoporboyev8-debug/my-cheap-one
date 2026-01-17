import 'package:sellingapp/data/datasources/base_data_source.dart';
import 'package:sellingapp/models/cart.dart';

class CartRepository {
  final BaseDataSource _ds;
  CartRepository(this._ds);

  Future<void> cartPopulate(Map<String, Map<String, int>> variantsQuantities) => _ds.cartPopulate(variantsQuantities);
  Future<Cart> getCart() => _ds.getCart();
  Future<void> emptyCart() => _ds.emptyCart();
}
