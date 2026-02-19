import 'package:ayojana_hub/activity_model.dart';
import 'package:ayojana_hub/booking_model.dart';
import 'package:ayojana_hub/event_model.dart';
import 'package:ayojana_hub/usermodels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stats
  bool _isLoading = false;
  int _vendorSignups = 0;
  int _totalBookings = 0;
  int _completedBookings = 0;
  int _totalUsers = 0;
  int _totalEvents = 0;
  double _totalRevenue = 0.0;
  String? _error;

  // Lists
  List<UserModel> _allUsers = [];
  List<UserModel> _allVendors = [];
  List<BookingModel> _allBookings = [];
  List<EventModel> _allEvents = [];
  List<ActivityLog> _activityLogs = [];

  // Getters
  bool get isLoading => _isLoading;
  int get vendorSignups => _vendorSignups;
  int get totalBookings => _totalBookings;
  int get completedBookings => _completedBookings;
  int get totalUsers => _totalUsers;
  int get totalEvents => _totalEvents;
  double get totalRevenue => _totalRevenue;
  String? get error => _error;
  List<UserModel> get allUsers => _allUsers;
  List<UserModel> get allVendors => _allVendors;
  List<BookingModel> get allBookings => _allBookings;
  List<EventModel> get allEvents => _allEvents;
  List<ActivityLog> get activityLogs => _activityLogs;

  Future<void> fetchStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch all users
      final usersSnapshot = await _firestore.collection('users').get();
      _allUsers = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      _totalUsers = _allUsers.length;

      // Fetch all vendors
      final vendorsSnapshot = usersSnapshot.docs
          .where((doc) => doc.data()['role'] == 'vendor')
          .toList();
      _allVendors = vendorsSnapshot
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      _vendorSignups = _allVendors.length;

      // Fetch all bookings
      final bookingsSnapshot = await _firestore.collection('bookings').get();
      _allBookings = bookingsSnapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
      _totalBookings = _allBookings.length;

      final completedSnapshot = _allBookings
          .where((b) => b.paymentStatus == 'completed')
          .toList();
      _completedBookings = completedSnapshot.length;

      // Calculate revenue
      double revenue = 0.0;
      for (var booking in completedSnapshot) {
        revenue += booking.price;
      }
      _totalRevenue = revenue;

      // Fetch all events
      final eventsSnapshot = await _firestore.collection('events').get();
      _allEvents = eventsSnapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
      _totalEvents = _allEvents.length;

      // Fetch recent activity logs
      await fetchActivityLogs();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching admin stats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchActivityLogs({int limit = 100}) async {
    try {
      final logsSnapshot = await _firestore
          .collection('activityLogs')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      _activityLogs = logsSnapshot.docs
          .map((doc) => ActivityLog.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching activity logs: $e');
    }
  }

  List<ActivityLog> getActivityLogsByType(String activityType) {
    return _activityLogs
        .where((log) => log.activityType == activityType)
        .toList();
  }

  List<ActivityLog> getActivityLogsByUser(String userId) {
    return _activityLogs.where((log) => log.userId == userId).toList();
  }

  List<ActivityLog> getActivityLogsByDateRange(DateTime start, DateTime end) {
    return _activityLogs
        .where((log) =>
            log.timestamp.isAfter(start) && log.timestamp.isBefore(end))
        .toList();
  }

  List<ActivityLog> searchActivityLogs(String query) {
    final lowerQuery = query.toLowerCase();
    return _activityLogs
        .where((log) =>
            log.activityTitle.toLowerCase().contains(lowerQuery) ||
            log.description.toLowerCase().contains(lowerQuery) ||
            log.userName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      _allUsers.removeWhere((u) => u.id == userId);
      if (_allUsers.any((u) => u.id == userId && u.role == 'vendor')) {
        _allVendors.removeWhere((v) => v.id == userId);
        _vendorSignups--;
      }
      _totalUsers--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({'role': newRole});
      final userIndex = _allUsers.indexWhere((u) => u.id == userId);
      if (userIndex != -1) {
        final user = _allUsers[userIndex];
        _allUsers[userIndex] = UserModel(
          id: user.id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          role: newRole,
          profileImage: user.profileImage,
          createdAt: user.createdAt,
          vendorCategory: user.vendorCategory,
          vendorDescription: user.vendorDescription,
          vendorLocation: user.vendorLocation,
          vendorServices: user.vendorServices,
          businessName: user.businessName,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({'status': newStatus});
      final bookingIndex = _allBookings.indexWhere((b) => b.id == bookingId);
      if (bookingIndex != -1) {
        final booking = _allBookings[bookingIndex];
        _allBookings[bookingIndex] = BookingModel(
          id: booking.id,
          eventId: booking.eventId,
          eventName: booking.eventName,
          customerId: booking.customerId,
          customerName: booking.customerName,
          vendorId: booking.vendorId,
          vendorName: booking.vendorName,
          proposalId: booking.proposalId,
          guestCount: booking.guestCount,
          eventType: booking.eventType,
          vendorCategory: booking.vendorCategory,
          price: booking.price,
          bookingDate: booking.bookingDate,
          eventDate: booking.eventDate,
          status: newStatus,
          notes: booking.notes,
          createdAt: booking.createdAt,
          paymentStatus: booking.paymentStatus,
          orderId: booking.orderId,
          transactionId: booking.transactionId,
          paymentMethod: booking.paymentMethod,
          paymentDate: booking.paymentDate,
          paymentError: booking.paymentError,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
      _allBookings.removeWhere((b) => b.id == bookingId);
      _totalBookings--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      _allEvents.removeWhere((e) => e.id == eventId);
      _totalEvents--;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  List<UserModel> searchUsers(String query) {
    if (query.isEmpty) return _allUsers;
    final lowerQuery = query.toLowerCase();
    return _allUsers
        .where((u) =>
            u.name.toLowerCase().contains(lowerQuery) ||
            u.email.toLowerCase().contains(lowerQuery) ||
            u.phone.contains(query))
        .toList();
  }

  List<BookingModel> filterBookings({String? status}) {
    if (status == null || status.isEmpty) return _allBookings;
    return _allBookings.where((b) => b.status == status).toList();
  }

  List<EventModel> filterEvents({String? status}) {
    if (status == null || status.isEmpty) return _allEvents;
    return _allEvents.where((e) => e.status == status).toList();
  }

  int getBookingsByVendor(String vendorId) {
    return _allBookings.where((b) => b.vendorId == vendorId).length;
  }

  int getEventsByUser(String userId) {
    return _allEvents.where((e) => e.userId == userId).length;
  }

  double getVendorRevenue(String vendorId) {
    return _allBookings
        .where((b) => b.vendorId == vendorId && b.paymentStatus == 'completed')
        .fold(0.0, (sum, b) => sum + b.price);
  }
}
