import 'package:ayojana_hub/activity_model.dart';
import 'package:ayojana_hub/booking_model.dart';
import 'package:ayojana_hub/event_model.dart';
import 'package:ayojana_hub/usermodels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
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

  // Stream subscriptions for real-time updates
  StreamSubscription<QuerySnapshot>? _usersSubscription;
  StreamSubscription<QuerySnapshot>? _bookingsSubscription;
  StreamSubscription<QuerySnapshot>? _eventsSubscription;
  StreamSubscription<QuerySnapshot>? _activityLogsSubscription;

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
      // Cancel existing subscriptions
      await _cancelSubscriptions();

      // Set up real-time listeners
      _setupRealtimeListeners();

      // Initial fetch for immediate data
      await _fetchInitialData();

    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching admin stats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchInitialData() async {
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
  }

  void _setupRealtimeListeners() {
    // Users listener
    _usersSubscription = _firestore.collection('users').snapshots().listen(
      (snapshot) {
        _allUsers = snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList();
        _totalUsers = _allUsers.length;

        _allVendors = _allUsers
            .where((user) => user.role == 'vendor')
            .toList();
        _vendorSignups = _allVendors.length;

        notifyListeners();
      },
      onError: (error) {
        debugPrint('Users listener error: $error');
      },
    );

    // Bookings listener
    _bookingsSubscription = _firestore.collection('bookings').snapshots().listen(
      (snapshot) {
        _allBookings = snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();
        _totalBookings = _allBookings.length;

        final completedSnapshot = _allBookings
            .where((b) => b.paymentStatus == 'completed')
            .toList();
        _completedBookings = completedSnapshot.length;

        // Recalculate revenue
        double revenue = 0.0;
        for (var booking in completedSnapshot) {
          revenue += booking.price;
        }
        _totalRevenue = revenue;

        notifyListeners();
      },
      onError: (error) {
        debugPrint('Bookings listener error: $error');
      },
    );

    // Events listener
    _eventsSubscription = _firestore.collection('events').snapshots().listen(
      (snapshot) {
        _allEvents = snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList();
        _totalEvents = _allEvents.length;

        notifyListeners();
      },
      onError: (error) {
        debugPrint('Events listener error: $error');
      },
    );

    // Activity logs listener
    _activityLogsSubscription = _firestore
        .collection('activityLogs')
        .orderBy('timestamp', descending: true)
        .limit(1000)
        .snapshots()
        .listen(
      (snapshot) {
        _activityLogs = snapshot.docs
            .map((doc) => ActivityLog.fromMap(doc.data(), doc.id))
            .toList();

        notifyListeners();
      },
      onError: (error) {
        debugPrint('Activity logs listener error: $error');
      },
    );
  }

  Future<void> _cancelSubscriptions() async {
    await _usersSubscription?.cancel();
    await _bookingsSubscription?.cancel();
    await _eventsSubscription?.cancel();
    await _activityLogsSubscription?.cancel();

    _usersSubscription = null;
    _bookingsSubscription = null;
    _eventsSubscription = null;
    _activityLogsSubscription = null;
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

  Future<bool> createUser(UserModel user) async {
    try {
      final docRef = await _firestore.collection('users').add(user.toMap());
      final newUser = UserModel(
        id: docRef.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        profileImage: user.profileImage,
        createdAt: user.createdAt,
        vendorCategory: user.vendorCategory,
        vendorDescription: user.vendorDescription,
        vendorLocation: user.vendorLocation,
        vendorServices: user.vendorServices,
        businessName: user.businessName,
      );

      _allUsers.add(newUser);
      _totalUsers++;
      if (newUser.role == 'vendor') {
        _allVendors.add(newUser);
        _vendorSignups++;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
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

  /// Get activity logs filtered by user role (vendor or customer)
  List<ActivityLog> getActivityLogsByRole(String userRole) {
    return _activityLogs.where((log) => log.userRole == userRole).toList();
  }

  /// Get all vendor activities
  List<ActivityLog> getVendorActivities() {
    return getActivityLogsByRole('vendor');
  }

  /// Get all customer activities
  List<ActivityLog> getCustomerActivities() {
    return getActivityLogsByRole('customer');
  }

  /// Get activities for a specific activity type (booking, event, vendor, etc.)
  List<ActivityLog> getActivityLogsByActivityType(String activityType) {
    return _activityLogs
        .where((log) => log.activityType == activityType)
        .toList();
  }

  /// Get activity logs within a date range
  List<ActivityLog> getActivitiesByDateRange(DateTime startDate, DateTime endDate) {
    return _activityLogs
        .where((log) =>
            log.timestamp.isAfter(startDate) &&
            log.timestamp.isBefore(endDate))
        .toList();
  }

  /// Get recent activities (last N hours)
  List<ActivityLog> getRecentActivities({int hoursAgo = 24}) {
    final cutoffDate = DateTime.now().subtract(Duration(hours: hoursAgo));
    return _activityLogs
        .where((log) => log.timestamp.isAfter(cutoffDate))
        .toList();
  }

  /// Get activity logs for a specific related entity (event, booking, vendor, etc.)
  List<ActivityLog> getActivityLogsForEntity(String relatedId) {
    return _activityLogs.where((log) => log.relatedId == relatedId).toList();
  }

  /// Get activities filtered by type and role
  List<ActivityLog> getActivitiesByTypeAndRole(String activityType, String userRole) {
    return _activityLogs
        .where((log) =>
            log.activityType == activityType && log.userRole == userRole)
        .toList();
  }

  /// Get activity statistics by type
  Map<String, int> getActivityStatsByType() {
    final stats = <String, int>{};
    for (var log in _activityLogs) {
      stats[log.activityType] = (stats[log.activityType] ?? 0) + 1;
    }
    return stats;
  }

  /// Get activity statistics by user role
  Map<String, int> getActivityStatsByRole() {
    final stats = <String, int>{};
    for (var log in _activityLogs) {
      stats[log.userRole] = (stats[log.userRole] ?? 0) + 1;
    }
    return stats;
  }

  /// Get top active users
  List<MapEntry<String, int>> getTopActiveUsers({int limit = 10}) {
    final userActivity = <String, int>{};
    for (var log in _activityLogs) {
      final key = log.userName;
      userActivity[key] = (userActivity[key] ?? 0) + 1;
    }
    final sorted = userActivity.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }

  /// Count activities by a specific criteria
  int countActivitiesByType(String activityType) {
    return _activityLogs.where((log) => log.activityType == activityType).length;
  }

  /// Count activities by role
  int countActivitiesByRole(String userRole) {
    return _activityLogs.where((log) => log.userRole == userRole).length;
  }

  /// Get vendor-specific activity summary
  Map<String, dynamic> getVendorActivitySummary(String vendorId) {
    final activities = _activityLogs.where((log) => log.userId == vendorId).toList();
    return {
      'totalActivities': activities.length,
      'recentActivity': activities.isNotEmpty ? activities.first.timestamp : null,
      'activityTypes': activities.map((a) => a.activityType).toSet().length,
      'activities': activities,
    };
  }

  /// Get customer-specific activity summary
  Map<String, dynamic> getCustomerActivitySummary(String customerId) {
    final activities = _activityLogs.where((log) => log.userId == customerId).toList();
    return {
      'totalActivities': activities.length,
      'recentActivity': activities.isNotEmpty ? activities.first.timestamp : null,
      'activityTypes': activities.map((a) => a.activityType).toSet().length,
      'activities': activities,
    };
  }

  Future<bool> deleteUser(String userId) async {
    try {
      final existingUserIndex = _allUsers.indexWhere((u) => u.id == userId);
      final existingUser = existingUserIndex != -1 ? _allUsers[existingUserIndex] : null;

      await _firestore.collection('users').doc(userId).delete();

      if (existingUserIndex != -1) {
        _allUsers.removeAt(existingUserIndex);
        if (_totalUsers > 0) _totalUsers--;

        if (existingUser?.role == 'vendor') {
          _allVendors.removeWhere((v) => v.id == userId);
          if (_vendorSignups > 0) _vendorSignups--;
        }
      }

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
      final userIndex = _allUsers.indexWhere((u) => u.id == userId);
      if (userIndex == -1) {
        _error = 'User not found';
        notifyListeners();
        return false;
      }

      final user = _allUsers[userIndex];
      await _firestore.collection('users').doc(userId).update({'role': newRole});

      if (user.role == 'vendor' && newRole != 'vendor') {
        _allVendors.removeWhere((v) => v.id == userId);
        if (_vendorSignups > 0) _vendorSignups--;
      } else if (user.role != 'vendor' && newRole == 'vendor') {
        _allVendors.add(UserModel(
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
        ));
        _vendorSignups++;
      }

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

  Future<bool> updateUser(UserModel user) async {
    try {
      final currentIndex = _allUsers.indexWhere((u) => u.id == user.id);
      final currentUser = currentIndex != -1 ? _allUsers[currentIndex] : null;

      await _firestore.collection('users').doc(user.id).update(user.toMap());

      if (currentIndex != -1) {
        _allUsers[currentIndex] = user;
      }

      if (currentUser != null) {
        if (currentUser.role == 'vendor' && user.role != 'vendor') {
          _allVendors.removeWhere((v) => v.id == user.id);
          if (_vendorSignups > 0) {
            _vendorSignups--;
          }
        } else if (currentUser.role != 'vendor' && user.role == 'vendor') {
          if (!_allVendors.any((v) => v.id == user.id)) {
            _allVendors.add(user);
            _vendorSignups++;
          }
        }
      } else if (user.role == 'vendor' && !_allVendors.any((v) => v.id == user.id)) {
        _allVendors.add(user);
        _vendorSignups++;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(String eventId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('events').doc(eventId).update(data);
      final eventIndex = _allEvents.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        final existing = _allEvents[eventIndex];
        final mergedData = {...existing.toMap(), ...data};

        if (mergedData['eventDate'] is DateTime) {
          mergedData['eventDate'] = Timestamp.fromDate(mergedData['eventDate'] as DateTime);
        }

        _allEvents[eventIndex] = EventModel.fromMap(mergedData, eventId);
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
      final bookingIndex = _allBookings.indexWhere((b) => b.id == bookingId);
      final booking = bookingIndex != -1 ? _allBookings[bookingIndex] : null;

      await _firestore.collection('bookings').doc(bookingId).delete();

      if (bookingIndex != -1) {
        _allBookings.removeAt(bookingIndex);
        if (_totalBookings > 0) _totalBookings--;
        if (booking?.paymentStatus == 'completed' && _completedBookings > 0) {
          _completedBookings--;
          _totalRevenue = (_totalRevenue - (booking?.price ?? 0)).clamp(0.0, double.infinity);
        }
      }

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
      final eventIndex = _allEvents.indexWhere((e) => e.id == eventId);
      await _firestore.collection('events').doc(eventId).delete();

      if (eventIndex != -1) {
        _allEvents.removeAt(eventIndex);
        if (_totalEvents > 0) _totalEvents--;
      }

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

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}
