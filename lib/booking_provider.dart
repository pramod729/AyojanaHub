import 'package:ayojana_hub/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> loadMyBookings(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      _bookings = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error loading bookings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createBooking(BookingModel booking) async {
    try {
      await _firestore.collection('bookings').add(booking.toMap());
      return null;
    } catch (e) {
      return 'Failed to create booking';
    }
  }

  Future<String?> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': 'cancelled',
      });
      return null;
    } catch (e) {
      return 'Failed to cancel booking';
    }
  }
}