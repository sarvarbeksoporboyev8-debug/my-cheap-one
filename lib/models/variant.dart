class Variant {
  final String id;
  final String displayName;
  final String? unitToDisplay;
  final double priceWithFees;
  final int? stockOnHand;
  final bool onDemand;

  const Variant({required this.id, required this.displayName, this.unitToDisplay, required this.priceWithFees, this.stockOnHand, this.onDemand = false});

  factory Variant.fromJson(Map<String, dynamic> json) => Variant(
        id: json['id'].toString(),
        displayName: json['display_name'] as String? ?? '',
        unitToDisplay: json['unit_to_display'] as String?,
        priceWithFees: (json['price_with_fees'] is int) ? (json['price_with_fees'] as int).toDouble() : (json['price_with_fees'] as num?)?.toDouble() ?? 0.0,
        stockOnHand: json['stock_on_hand'] as int?,
        onDemand: (json['on_demand'] as bool?) ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'unit_to_display': unitToDisplay,
        'price_with_fees': priceWithFees,
        'stock_on_hand': stockOnHand,
        'on_demand': onDemand,
      };
}
