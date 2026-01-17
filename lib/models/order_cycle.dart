class OrderCycle {
  final String id;
  final String name;
  final DateTime? closesAt;

  const OrderCycle({required this.id, required this.name, this.closesAt});

  factory OrderCycle.fromJson(Map<String, dynamic> json) => OrderCycle(
        id: json['id'].toString(),
        name: json['name'] as String? ?? '',
        closesAt: json['closes_at'] != null ? DateTime.tryParse(json['closes_at'] as String) : null,
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'closes_at': closesAt?.toIso8601String()};
}
