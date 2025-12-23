class VendorModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final String phone;
  final String email;
  final String location;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final String? profileImage;
  final List<String> portfolioImages;

  VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.phone,
    required this.email,
    required this.location,
    required this.services,
    required this.rating,
    required this.reviewCount,
    this.profileImage,
    required this.portfolioImages,
  });

  factory VendorModel.fromMap(Map<String, dynamic> map, String id) {
    return VendorModel(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      location: map['location'] ?? '',
      services: List<String>.from(map['services'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      profileImage: map['profileImage'],
      portfolioImages: List<String>.from(map['portfolioImages'] ?? []),
    );
  }
}