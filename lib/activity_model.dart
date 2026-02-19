import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityLog {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String userRole;
  final String activityType; // login, logout, create_event, create_booking, etc.
  final String activityTitle;
  final String description;
  final String? relatedId; // event_id, booking_id, vendor_id, etc.
  final String? relatedType; // event, booking, vendor, user
  final Map<String, dynamic>? metadata; // Additional data
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  ActivityLog({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRole,
    required this.activityType,
    required this.activityTitle,
    required this.description,
    this.relatedId,
    this.relatedType,
    this.metadata,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> map, String id) {
    return ActivityLog(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userRole: map['userRole'] ?? '',
      activityType: map['activityType'] ?? '',
      activityTitle: map['activityTitle'] ?? '',
      description: map['description'] ?? '',
      relatedId: map['relatedId'],
      relatedType: map['relatedType'],
      metadata: map['metadata'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      ipAddress: map['ipAddress'],
      userAgent: map['userAgent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userRole': userRole,
      'activityType': activityType,
      'activityTitle': activityTitle,
      'description': description,
      'relatedId': relatedId,
      'relatedType': relatedType,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }
}
