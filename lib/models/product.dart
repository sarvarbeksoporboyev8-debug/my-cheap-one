import 'variant.dart';

class Product {
  final String id;
  final String name;
  final String? supplierName;
  final String? description;
  final List<String> images;
  final double minPrice;
  final List<Variant> variants;
  final List<String> taxonIds;
  final List<String> propertyIds;

  const Product({required this.id, required this.name, this.supplierName, this.description, this.images = const [], this.minPrice = 0.0, this.variants = const [], this.taxonIds = const [], this.propertyIds = const []});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        supplierName: json['supplier_name'] as String?,
        description: json['description'] as String?,
        images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        minPrice: (json['min_price'] is int) ? (json['min_price'] as int).toDouble() : (json['min_price'] as num?)?.toDouble() ?? 0.0,
        variants: (json['variants'] as List?)?.map((e) => Variant.fromJson(e as Map<String, dynamic>)).toList() ?? const [],
        taxonIds: (json['taxon_ids'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        propertyIds: (json['property_ids'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'supplier_name': supplierName,
        'description': description,
        'images': images,
        'min_price': minPrice,
        'variants': variants.map((e) => e.toJson()).toList(),
        'taxon_ids': taxonIds,
        'property_ids': propertyIds,
      };
}
