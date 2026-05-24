import 'package:cloud_firestore/cloud_firestore.dart';

class ProposalModel {
  final String id;
  final String eventId;
  final String eventName;
  final String eventType;
  final String userId;
  final String vendorId;
  final String vendorName;
  final String vendorCategory;
  final double proposedPrice;
  final String description;
  final List<String> servicesIncluded;
  final String deliveryTime;
  final String status;
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? userNotes;
  final String? vendorReply;
  final String? userMessage;
  ProposalModel({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.eventType,
    required this.userId,
    required this.vendorId,
    required this.vendorName,
    required this.vendorCategory,
    required this.proposedPrice,
    required this.description,
    required this.servicesIncluded,
    required this.deliveryTime,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    this.userNotes,
    this.vendorReply,
    this.userMessage,
  });

  factory ProposalModel.fromMap(Map<String, dynamic> map, String id) {
    return ProposalModel(
      id: id,
      eventId: map['eventId'] ?? '',
      eventName: map['eventName'] ?? '',
      eventType: map['eventType'] ?? '',
      userId: map['userId'] ?? '',
      vendorId: map['vendorId'] ?? '',
      vendorName: map['vendorName'] ?? '',
      vendorCategory: map['vendorCategory'] ?? '',
      proposedPrice: (map['proposedPrice'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      servicesIncluded: List<String>.from(map['servicesIncluded'] ?? []),
      deliveryTime: map['deliveryTime'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      respondedAt: map['respondedAt'] != null 
          ? (map['respondedAt'] as Timestamp).toDate() 
          : null,
      userNotes: map['userNotes'],
      vendorReply: map['vendorReply'],
      userMessage: map['userMessage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'eventType': eventType,
      'userId': userId,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'vendorCategory': vendorCategory,
      'proposedPrice': proposedPrice,
      'description': description,
      'servicesIncluded': servicesIncluded,
      'deliveryTime': deliveryTime,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null 
          ? Timestamp.fromDate(respondedAt!) 
          : null,
      'userNotes': userNotes,
      'vendorReply': vendorReply,
      'userMessage': userMessage,
    };
  }

  ProposalModel copyWith({
    String? status,
    DateTime? respondedAt,
    String? userNotes,
    String? vendorReply,
    String? userMessage,
  }) {
    return ProposalModel(
      id: id,
      eventId: eventId,
      eventName: eventName,
      eventType: eventType,
      userId: userId,
      vendorId: vendorId,
      vendorName: vendorName,
      vendorCategory: vendorCategory,
      proposedPrice: proposedPrice,
      description: description,
      servicesIncluded: servicesIncluded,
      deliveryTime: deliveryTime,
      status: status ?? this.status,
      createdAt: createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      userNotes: userNotes ?? this.userNotes,
      vendorReply: vendorReply ?? this.vendorReply,
      userMessage: userMessage ?? this.userMessage,
    );
  }
}
