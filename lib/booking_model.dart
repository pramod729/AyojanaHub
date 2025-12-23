import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String eventId;
  final String eventName;
  final String customerId;
  final String customerName;
  final String vendorId;
  final String vendorName;
  final String packageId;
  final String packageName;
  final double price;
  final DateTime bookingDate;
  final DateTime eventDate;
  final String status;
  final String? notes;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.vendorName,
    required this.packageId,
    required this.packageName,
    required this.price,
    required this.bookingDate,
    required this.eventDate,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      eventId: map['eventId'] ?? '',
      eventName: map['eventName'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      packageId: map['packageId'] ?? '',
      packageName: map['packageName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      notes: map['notes'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'customerId': customerId,
      'customerName': customerName,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'packageId': packageId,
      'packageName': packageName,
      'price': price,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'eventDate': Timestamp.fromDate(eventDate),
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
