import 'package:ayojana_hub/usermodels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory ActivityService() {
    return _instance;
  }

  ActivityService._internal();

  /// Log a user activity
  Future<void> logActivity({
    required String userId,
    required String userName,
    required String userEmail,
    required String userRole,
    required String activityType,
    required String activityTitle,
    required String description,
    String? relatedId,
    String? relatedType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('activityLogs').add({
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
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error logging activity: $e');
    }
  }

  /// Log authentication events
  Future<void> logAuthActivity(
    UserModel user, {
    required String action, // login, logout, register, password_reset
    String? description,
  }) async {
    final descriptions = {
      'login': 'User logged in',
      'logout': 'User logged out',
      'register': 'New user registered',
      'password_reset': 'User reset password',
      'profile_update': 'User updated profile',
      'photo_upload': 'User uploaded profile photo',
    };

    await logActivity(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
      activityType: 'authentication',
      activityTitle: 'Auth: ${action.replaceAll('_', ' ').toUpperCase()}',
      description: description ?? descriptions[action] ?? 'Authentication event',
      metadata: {
        'email': user.email,
        'role': user.role,
      },
    );
  }

  /// Log event-related activities
  Future<void> logEventActivity(
    UserModel user, {
    required String action, // create, update, delete, view
    required String eventId,
    required String eventName,
    String? description,
    Map<String, dynamic>? eventData,
  }) async {
    final actions = {
      'create': 'Created new event',
      'update': 'Updated event',
      'delete': 'Deleted event',
      'view': 'Viewed event',
      'publish': 'Published event',
      'archive': 'Archived event',
    };

    await logActivity(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
      activityType: 'event',
      activityTitle: 'Event: ${action.replaceAll('_', ' ').toUpperCase()}',
      description: description ?? '${actions[action] ?? 'Event action'}: $eventName',
      relatedId: eventId,
      relatedType: 'event',
      metadata: {
        'eventName': eventName,
        'eventId': eventId,
        ...?eventData,
      },
    );
  }

  /// Log booking-related activities
  Future<void> logBookingActivity(
    UserModel user, {
    required String action, // create, update, confirm, cancel, complete
    required String bookingId,
    required String bookingName,
    required String vendorName,
    String? description,
    Map<String, dynamic>? bookingData,
  }) async {
    final actions = {
      'create': 'Created booking',
      'update': 'Updated booking',
      'confirm': 'Confirmed booking',
      'cancel': 'Cancelled booking',
      'complete': 'Completed booking',
      'payment': 'Paid for booking',
    };

    await logActivity(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
      activityType: 'booking',
      activityTitle: 'Booking: ${action.replaceAll('_', ' ').toUpperCase()}',
      description: description ??
          '${actions[action] ?? 'Booking action'}: $bookingName with $vendorName',
      relatedId: bookingId,
      relatedType: 'booking',
      metadata: {
        'bookingName': bookingName,
        'bookingId': bookingId,
        'vendorName': vendorName,
        ...?bookingData,
      },
    );
  }

  /// Log vendor-related activities
  Future<void> logVendorActivity(
    UserModel user, {
    required String action, // create_proposal, update_profile, submit_quote
    required String vendorId,
    required String vendorName,
    String? description,
    Map<String, dynamic>? vendorData,
  }) async {
    final actions = {
      'profile_update': 'Updated vendor profile',
      'submit_proposal': 'Submitted proposal',
      'update_proposal': 'Updated proposal',
      'accept_booking': 'Accepted booking',
      'reject_booking': 'Rejected booking',
      'photo_upload': 'Uploaded portfolio photo',
    };

    await logActivity(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
      activityType: 'vendor',
      activityTitle: 'Vendor: ${action.replaceAll('_', ' ').toUpperCase()}',
      description: description ?? '${actions[action] ?? 'Vendor action'}: $vendorName',
      relatedId: vendorId,
      relatedType: 'vendor',
      metadata: {
        'vendorName': vendorName,
        'vendorId': vendorId,
        ...?vendorData,
      },
    );
  }

  /// Log payment activities
  Future<void> logPaymentActivity(
    UserModel user, {
    required String action, // payment_initiated, payment_success, payment_failed, refund
    required String paymentId,
    required double amount,
    String? description,
    Map<String, dynamic>? paymentData,
  }) async {
    final actions = {
      'payment_initiated': 'Initiated payment',
      'payment_success': 'Payment successful',
      'payment_failed': 'Payment failed',
      'refund_initiated': 'Initiated refund',
      'refund_success': 'Refund successful',
    };

    await logActivity(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
      activityType: 'payment',
      activityTitle: 'Payment: ${action.replaceAll('_', ' ').toUpperCase()}',
      description: description ??
          '${actions[action] ?? 'Payment action'}: ₹${amount.toStringAsFixed(2)}',
      relatedId: paymentId,
      relatedType: 'payment',
      metadata: {
        'amount': amount,
        'paymentId': paymentId,
        ...?paymentData,
      },
    );
  }

  /// Log chat activities
  Future<void> logChatActivity(
    UserModel user, {
    required String action,
    required String conversationId,
    required String participantName,
    String? description,
  }) async {
    final actions = {
      'message_sent': 'Sent message',
      'message_deleted': 'Deleted message',
      'conversation_started': 'Started conversation',
    };

    await logActivity(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
      activityType: 'chat',
      activityTitle: 'Chat: ${action.replaceAll('_', ' ').toUpperCase()}',
      description: description ??
          '${actions[action] ?? 'Chat action'} with $participantName',
      relatedId: conversationId,
      relatedType: 'conversation',
      metadata: {
        'conversationId': conversationId,
        'participantName': participantName,
      },
    );
  }

  /// Log admin actions
  Future<void> logAdminActivity(
    UserModel user, {
    required String action,
    required String description,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? metadata,
  }) async {
    await logActivity(
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      userRole: user.role,
      activityType: 'admin',
      activityTitle: 'Admin: ${action.replaceAll('_', ' ').toUpperCase()}',
      description: description,
      relatedId: targetId,
      relatedType: targetType,
      metadata: metadata,
    );
  }
}
