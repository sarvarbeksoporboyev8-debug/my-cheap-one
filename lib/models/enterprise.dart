class Enterprise {
  final String id;
  final String name;
  final String? logoUrl;
  final String? bannerUrl;
  final String? shortDescription;
  final String? longDescription;
  final bool pickupAvailable;
  final bool deliveryAvailable;
  final DateTime? ordersCloseAt;
  final double? lat;
  final double? lng;
  final double? rating;
  final int? reviewCount;

  const Enterprise({
    required this.id,
    required this.name,
    this.logoUrl,
    this.bannerUrl,
    this.shortDescription,
    this.longDescription,
    this.pickupAvailable = false,
    this.deliveryAvailable = false,
    this.ordersCloseAt,
    this.lat,
    this.lng,
    this.rating,
    this.reviewCount,
  });

  factory Enterprise.fromJson(Map<String, dynamic> json) {
    double? parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return Enterprise(
      id: json['id'].toString(),
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      shortDescription: json['short_description'] as String?,
      longDescription: json['long_description'] as String?,
      pickupAvailable: (json['pickup'] as bool?) ?? false,
      deliveryAvailable: (json['delivery'] as bool?) ?? false,
      ordersCloseAt: json['orders_close_at'] != null
          ? DateTime.tryParse(json['orders_close_at'] as String)
          : null,
      lat: parseNum(json['lat'] ?? json['latitude']),
      lng: parseNum(json['lng'] ?? json['lon'] ?? json['longitude']),
      rating: parseNum(json['rating']),
      reviewCount: parseInt(json['review_count']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logo_url': logoUrl,
    'banner_url': bannerUrl,
    'short_description': shortDescription,
    'long_description': longDescription,
    'pickup': pickupAvailable,
    'delivery': deliveryAvailable,
    'orders_close_at': ordersCloseAt?.toIso8601String(),
    'lat': lat,
    'lng': lng,
    'rating': rating,
    'review_count': reviewCount,
  };
}
