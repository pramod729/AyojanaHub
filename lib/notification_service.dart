import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    try {
      // Request permission for iOS
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iOSSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      await _localNotifications.initialize(settings);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      // Handle background message (setup at app startup)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageOpenedApp(message);
      });

      // Handle terminated state messages
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      debugPrint('Notifications initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'New Message',
        notification.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'messages_channel',
            'Messages',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            badgeNumber: 1,
            sound: 'default',
          ),
        ),
        payload: message.data['conversationId'],
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.messageId}');
    // Handle navigation if needed
  }

  Future<void> sendMessageNotification({
    required String recipientId,
    required String senderName,
    required String message,
    required String conversationId,
  }) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(recipientId).get();

      if (userDoc.exists && userDoc.data()?['fcmToken'] != null) {
        // In production, use Cloud Functions to send notifications
        // For now, we're storing notification in Firestore
        await FirebaseFirestore.instance
            .collection('notifications')
            .add({
          'recipientId': recipientId,
          'senderName': senderName,
          'message': message,
          'conversationId': conversationId,
          'type': 'message',
          'isRead': false,
          'createdAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<void> saveFCMToken(String userId, String? token) async {
    try {
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': Timestamp.now(),
        });
      }
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  Future<void> createUserNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      final Map<String, dynamic> notificationData = {
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'isRead': false,
        'createdAt': Timestamp.now(),
      };

      if (data != null) {
        notificationData.addAll(data);
      }

      await FirebaseFirestore.instance.collection('notifications').add(notificationData);
    } catch (e) {
      debugPrint('Error creating user notification: $e');
    }
  }

  Future<String?> getDeviceToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting device token: $e');
      return null;
    }
  }
}
