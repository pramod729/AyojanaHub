class PackageModel {
  final String id;
  final String vendorId;
  final String name;
  final String description;
  final double price;
  final List<String> features;
  final String duration;

  PackageModel({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    required this.duration,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map, String id) {
    return PackageModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      features: List<String>.from(map['features'] ?? []),
      duration: map['duration'] ?? '',
    );
  }
}
