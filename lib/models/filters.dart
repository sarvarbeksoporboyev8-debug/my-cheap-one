class Taxon {
  final String id;
  final String name;
  const Taxon({required this.id, required this.name});
  factory Taxon.fromJson(Map<String, dynamic> json) => Taxon(id: json['id'].toString(), name: json['name'] as String? ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class PropertyTag {
  final String id;
  final String name;
  const PropertyTag({required this.id, required this.name});
  factory PropertyTag.fromJson(Map<String, dynamic> json) => PropertyTag(id: json['id'].toString(), name: json['name'] as String? ?? '');
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
