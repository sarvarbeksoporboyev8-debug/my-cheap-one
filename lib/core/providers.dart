import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sellingapp/core/config/app_config.dart';
import 'package:sellingapp/core/network/dio_client.dart';
import 'package:sellingapp/data/datasources/api_data_source.dart';
import 'package:sellingapp/data/datasources/base_data_source.dart';
import 'package:sellingapp/data/datasources/mock_data_source.dart';
import 'package:sellingapp/data/repositories/cart_repository.dart';
import 'package:sellingapp/data/repositories/shop_repository.dart';

final dataSourceProvider = Provider<BaseDataSource>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useApiDataSource) {
    final dio = ref.watch(dioProvider);
    return ApiDataSource(dio);
  }
  return MockDataSource(ref);
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final ds = ref.watch(dataSourceProvider);
  return ShopRepository(ds);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final ds = ref.watch(dataSourceProvider);
  return CartRepository(ds);
});
