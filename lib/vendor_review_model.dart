import 'package:cloud_firestore/cloud_firestore.dart';

class VendorReviewModel {
  final String id;
  final String vendorId;
  final String bookingId;
  final String customerId;
  final String customerName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  VendorReviewModel({
    required this.id,
    required this.vendorId,
    required this.bookingId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory VendorReviewModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return VendorReviewModel(
      id: id,
      vendorId: map['vendorId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: parseDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vendorId': vendorId,
      'bookingId': bookingId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
