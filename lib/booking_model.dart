import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String eventId;
  final String eventName;
  final String customerId;
  final String customerName;
  final String vendorId;
  final String vendorName;
  final String proposalId;
  final int guestCount;
  final String eventType;
  final String vendorCategory;
  final double price;
  final DateTime bookingDate;
  final DateTime eventDate;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final String paymentStatus;
  final String? orderId;
  final String? transactionId;
  final String paymentMethod;
  final DateTime? paymentDate;
  final String? paymentError;

  BookingModel({
    required this.id,
    this.eventId = '',
    this.eventName = '',
    required this.customerId,
    required this.customerName,
    required this.vendorId,
    required this.vendorName,
    this.proposalId = '',
    this.guestCount = 0,
    this.eventType = '',
    required this.vendorCategory,
    required this.price,
    required this.bookingDate,
    required this.eventDate,
    required this.status,
    this.notes,
    required this.createdAt,
    this.paymentStatus = 'pending',
    this.orderId,
    this.transactionId,
    this.paymentMethod = 'razorpay',
    this.paymentDate,
    this.paymentError,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    double parseDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    DateTime? parseNullableDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return BookingModel(
      id: id,
      eventId: map['eventId'] ?? '',
      eventName: map['eventName'] ?? '',
      customerId: map['customerId'] ?? '',
      customerName: map['customerName'] ?? '',
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      proposalId: map['proposalId'] ?? '',
      guestCount: parseInt(map['guestCount']),
      eventType: map['eventType'] ?? '',
      vendorCategory: map['vendorCategory'] ?? '',
      price: parseDouble(map['price']),
      bookingDate: parseDateTime(map['bookingDate']),
      eventDate: parseDateTime(map['eventDate']),
      status: map['status'] ?? 'confirmed',
      notes: map['notes'],
      createdAt: parseDateTime(map['createdAt']),
      paymentStatus: map['paymentStatus'] ?? 'pending',
      orderId: map['orderId'],
      transactionId: map['transactionId'],
      paymentMethod: map['paymentMethod'] ?? 'razorpay',
      paymentDate: parseNullableDateTime(map['paymentDate']),
      paymentError: map['paymentError'],
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
      'proposalId': proposalId,
      'guestCount': guestCount,
      'eventType': eventType,
      'vendorCategory': vendorCategory,
      'price': price,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'eventDate': Timestamp.fromDate(eventDate),
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'paymentStatus': paymentStatus,
      'orderId': orderId,
      'transactionId': transactionId,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate != null ? Timestamp.fromDate(paymentDate!) : null,
      'paymentError': paymentError,
    };
  }
}
