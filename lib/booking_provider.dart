import 'package:ayojana_hub/booking_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyBookings(String customerId) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          .get();

      final bookingsList = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();

      bookingsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _bookings = bookingsList;
    } catch (e) {
      _error = 'Failed to load bookings: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadVendorBookings(String vendorId) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      final bookingsList = snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();

      bookingsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _bookings = bookingsList;
    } catch (e) {
      _error = 'Failed to load vendor bookings: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createBooking(BookingModel booking) async {
    try {
      await _firestore.collection('bookings').add(booking.toMap());
      return null;
    } catch (e) {
      return 'Failed to create booking: $e';
    }
  }

  Future<String?> updateBooking(BookingModel booking) async {
    try {
      await _firestore.collection('bookings').doc(booking.id).update(booking.toMap());
      final bookingIndex = _bookings.indexWhere((b) => b.id == booking.id);
      if (bookingIndex != -1) {
        _bookings[bookingIndex] = booking;
        notifyListeners();
      }
      return null;
    } catch (e) {
      return 'Failed to update booking: $e';
    }
  }

  Future<String?> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
      _bookings.removeWhere((b) => b.id == bookingId);
      notifyListeners();
      return null;
    } catch (e) {
      return 'Failed to delete booking: $e';
    }
  }

  Future<String?> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return 'Failed to update booking status: $e';
    }
  }

  Future<String?> cancelBooking(String bookingId) async {
    return updateBookingStatus(bookingId, 'cancelled');
  }

  // Payment related methods
  Future<String?> updatePaymentStatus({
    required String bookingId,
    required String paymentStatus,
    String? transactionId,
    String? orderId,
    String? errorMessage,
  }) async {
    try {
      final updateData = {
        'paymentStatus': paymentStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (transactionId != null) {
        updateData['transactionId'] = transactionId;
      }
      if (orderId != null) {
        updateData['orderId'] = orderId;
      }
      if (errorMessage != null) {
        updateData['paymentError'] = errorMessage;
      }
      if (paymentStatus == 'completed') {
        updateData['paymentDate'] = Timestamp.now();
        updateData['status'] = 'confirmed';
      }

      await _firestore.collection('bookings').doc(bookingId).update(updateData);
      return null;
    } catch (e) {
      return 'Failed to update payment status: $e';
    }
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore.collection('bookings').doc(bookingId).get();
      if (doc.exists) {
        return BookingModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching booking: $e');
      return null;
    }
  }

  Future<List<BookingModel>> getUnpaidBookings(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('customerId', isEqualTo: customerId)
          .where('paymentStatus', whereIn: ['pending', 'failed'])
          .get();

      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching unpaid bookings: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPaymentDetails(String bookingId) async {
    try {
      final doc = await _firestore.collection('payments').doc(bookingId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching payment details: $e');
      return null;
    }
  }
}
