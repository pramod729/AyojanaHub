import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String userId;
  final String userName;
  final String eventType;
  final String eventName;
  final DateTime eventDate;
  final String location;
  final String description;
  final int guestCount;
  final double? budget;
  final String status;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.eventType,
    required this.eventName,
    required this.eventDate,
    required this.location,
    required this.description,
    required this.guestCount,
    this.budget,
    required this.status,
    required this.createdAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      eventType: map['eventType'] ?? '',
      eventName: map['eventName'] ?? '',
      eventDate: (map['eventDate'] as Timestamp).toDate(),
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      guestCount: map['guestCount'] ?? 0,
      budget: map['budget']?.toDouble(),
      status: map['status'] ?? 'planning',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'eventType': eventType,
      'eventName': eventName,
      'eventDate': Timestamp.fromDate(eventDate),
      'location': location,
      'description': description,
      'guestCount': guestCount,
      'budget': budget,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}