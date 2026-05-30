import 'package:ayojana_hub/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Map<String, List<String>> _eventServiceMapping = {
    'Wedding': ['Catering', 'Photography', 'Decoration', 'DJ & Music', 'Venue'],
    'Birthday Party': ['Catering', 'Decoration', 'DJ & Music', 'Photography'],
    'Family Function': ['Catering', 'Venue'],
    'Anniversary': ['Catering', 'Photography', 'Decoration'],
    'Engagement': ['Catering', 'Photography', 'Decoration', 'Venue'],
    'Reception': ['Catering', 'Photography', 'Decoration', 'DJ & Music', 'Venue'],
    'Baby Shower': ['Catering', 'Decoration'],
    'Corporate Event': ['Catering', 'Photography', 'Venue'],
    'Seminar': ['Catering', 'Venue'],
    'Workshop': ['Catering', 'Venue'],
    'Conference': ['Catering', 'Photography', 'Venue'],
    'Party': ['Catering', 'DJ & Music', 'Decoration'],
    'Other': ['Catering'],
  };

  List<String> getRequiredServicesForEventType(String eventType) {
    return _eventServiceMapping[eventType] ?? ['Catering'];
  }

  Future<void> loadMyEvents(String userId) async {
    if (_isLoading) return; // Prevent multiple simultaneous loads
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('events')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _events = snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createEvent(EventModel event) async {
    try {
      final eventRef = await _firestore.collection('events').add(event.toMap());
      
      await _notifyMatchingVendors(eventRef.id, event);
      
      return null;
    } catch (e) {
      return 'Failed to create event: ${e.toString()}';
    }
  }

  Future<void> _notifyMatchingVendors(String eventId, EventModel event) async {
    try {
      final usersSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'vendor')
          .get();

      if (usersSnapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var userDoc in usersSnapshot.docs) {
        // Only notify vendors whose category is one of the services this event
        // needs. If the event lists no specific services, notify all vendors.
        final vendorCategory = (userDoc.data()['vendorCategory'] ?? '') as String;
        if (event.requiredServices.isNotEmpty &&
            vendorCategory.isNotEmpty &&
            !event.requiredServices.contains(vendorCategory)) {
          continue;
        }
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': userDoc.id,
          'type': 'new_event_opportunity',
          'title': 'New Event Opportunity',
          'message': 'A new event "${event.eventName}" is now available for proposals.',
          'eventId': eventId,
          'eventName': event.eventName,
          'eventType': event.eventType,
          'eventDate': event.eventDate,
          'location': event.location,
          'requiredServices': event.requiredServices,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error notifying vendors about new event: $e');
    }
  }

  Future<String?> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('events').doc(eventId).update(data);
      return null;
    } catch (e) {
      return 'Failed to update event';
    }
  }

  Future<String?> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      return null;
    } catch (e) {
      return 'Failed to delete event';
    }
  }
}