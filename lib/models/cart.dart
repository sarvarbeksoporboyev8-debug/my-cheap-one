class LineItem {
  final String productId;
  final String variantId;
  final String name;
  final int quantity;
  final double price;
  const LineItem({required this.productId, required this.variantId, required this.name, required this.quantity, required this.price});
  double get total => price * quantity;
  factory LineItem.fromJson(Map<String, dynamic> json) => LineItem(
        productId: json['product_id'].toString(),
        variantId: json['variant_id'].toString(),
        name: json['name'] as String? ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        price: (json['price'] is int) ? (json['price'] as int).toDouble() : (json['price'] as num?)?.toDouble() ?? 0.0,
      );
  Map<String, dynamic> toJson() => {'product_id': productId, 'variant_id': variantId, 'name': name, 'quantity': quantity, 'price': price};
}

class Cart {
  final List<LineItem> items;
  const Cart({this.items = const []});
  double get subtotal => items.fold(0.0, (sum, e) => sum + e.total);
  factory Cart.fromJson(Map<String, dynamic> json) => Cart(items: (json['items'] as List?)?.map((e) => LineItem.fromJson(e as Map<String, dynamic>)).toList() ?? const []);
  Map<String, dynamic> toJson() => {'items': items.map((e) => e.toJson()).toList()};
}
