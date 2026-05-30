import 'package:ayojana_hub/package_model.dart';
import 'package:ayojana_hub/vendor_model.dart';
import 'package:ayojana_hub/vendor_review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<VendorModel> _vendors = [];
  List<PackageModel> _packages = [];
  List<VendorReviewModel> _vendorReviews = [];
  bool _isLoading = false;
  bool _isReviewLoading = false;
  String? _error;
  String? _reviewError;

  List<VendorModel> get vendors => _vendors;
  List<PackageModel> get packages => _packages;
  List<VendorReviewModel> get vendorReviews => _vendorReviews;
  bool get isLoading => _isLoading;
  bool get isReviewLoading => _isReviewLoading;
  String? get error => _error;
  String? get reviewError => _reviewError;

  Future<void> loadVendors({String? category, bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Query query = _firestore.collection('vendors');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      _vendors = snapshot.docs
          .map((doc) => VendorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to load vendors: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshVendors({String? category}) async {
    await loadVendors(category: category, forceRefresh: true);
  }

  Future<void> loadVendorPackages(String vendorId) async {
    try {
      final snapshot = await _firestore
          .collection('packages')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      _packages = snapshot.docs
          .map((doc) => PackageModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      // Error loading packages
    }
  }

  Future<void> loadVendorReviews(String vendorId) async {
    _isReviewLoading = true;
    _reviewError = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('vendors')
          .doc(vendorId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      _vendorReviews = snapshot.docs
          .map((doc) => VendorReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _reviewError = 'Failed to load reviews: $e';
      _vendorReviews = [];
    }

    _isReviewLoading = false;
    notifyListeners();
  }

  Future<String?> submitVendorReview({
    required String vendorId,
    required String bookingId,
    required String customerId,
    required String customerName,
    required double rating,
    required String comment,
  }) async {
    try {
      final vendorRef = _firestore.collection('vendors').doc(vendorId);
      final reviewRef = vendorRef.collection('reviews').doc(bookingId);
      final bookingRef = _firestore.collection('bookings').doc(bookingId);

      await _firestore.runTransaction((transaction) async {
        final vendorSnapshot = await transaction.get(vendorRef);
        if (!vendorSnapshot.exists) {
          throw Exception('Vendor not found');
        }

        final vendorData = vendorSnapshot.data() ?? {};
        double parseDouble(dynamic value) {
          if (value is double) return value;
          if (value is int) return value.toDouble();
          if (value is String) return double.tryParse(value) ?? 0.0;
          return 0.0;
        }

        final currentRating = parseDouble(vendorData['rating']);
        final currentCountValue = vendorData['reviewCount'];
        final int currentCount = currentCountValue is int
            ? currentCountValue
            : currentCountValue is double
                ? currentCountValue.toInt()
                : int.tryParse(currentCountValue?.toString() ?? '0') ?? 0;
        final nextCount = currentCount + 1;
        final nextRating = nextCount == 0
            ? rating
            : ((currentRating * currentCount) + rating) / nextCount;

        transaction.set(reviewRef, {
          'vendorId': vendorId,
          'bookingId': bookingId,
          'customerId': customerId,
          'customerName': customerName,
          'rating': rating,
          'comment': comment,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(vendorRef, {
          'rating': nextRating,
          'reviewCount': nextCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        transaction.update(bookingRef, {
          'reviewRating': rating,
          'reviewComment': comment,
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      });

      return null;
    } catch (e) {
      return 'Failed to submit review: $e';
    }
  }

  // Creates the vendor's public profile document. The document id is always the
  // vendor's Firebase Auth uid so that vendorId == uid everywhere (proposals,
  // bookings, reviews, security rules). This is the single source of truth for
  // the customer-facing vendor directory.
  Future<String?> createVendorFromRegistration({
    required String userId,
    required String businessName,
    required String category,
    required String description,
    required String phone,
    required String email,
    required String location,
    required List<String> services,
  }) async {
    try {
      await _firestore.collection('vendors').doc(userId).set({
        'userId': userId,
        'name': businessName,
        'category': category,
        'description': description,
        'phone': phone,
        'email': email,
        'location': location,
        'services': services,
        'rating': 5.0,
        'reviewCount': 0,
        'profileImage': null,
        'portfolioImages': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Refresh vendor list
      await loadVendors();
      return null;
    } catch (e) {
      return 'Failed to create vendor profile: $e';
    }
  }

  Future<VendorModel?> getVendorByUserId(String userId) async {
    try {
      // vendors doc id == uid, so a direct lookup is enough. Fall back to a
      // userId query for any legacy auto-id documents.
      final direct = await _firestore.collection('vendors').doc(userId).get();
      if (direct.exists) {
        return VendorModel.fromMap(direct.data() as Map<String, dynamic>, direct.id);
      }

      final doc = await _firestore
          .collection('vendors')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return VendorModel.fromMap(doc.docs.first.data(), doc.docs.first.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<VendorModel?> getVendorById(String vendorId) async {
    try {
      final doc = await _firestore.collection('vendors').doc(vendorId).get();
      if (doc.exists) {
        return VendorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateVendor(VendorModel vendor) async {
    try {
      await _firestore.collection('vendors').doc(vendor.id).update(vendor.toMap());
      await loadVendors();
      return null;
    } catch (e) {
      return 'Failed to update vendor: $e';
    }
  }

  // Upserts the vendor's public directory document (vendors/{uid}) from the
  // profile stored on the user record. Keeps the customer-facing directory in
  // sync whenever a vendor edits their profile.
  Future<String?> updateVendorProfileFromUser({
    required String userId,
    required String businessName,
    required String category,
    required String description,
    required String phone,
    required String email,
    required String location,
    required List<String> services,
  }) async {
    try {
      await _firestore.collection('vendors').doc(userId).set({
        'userId': userId,
        'name': businessName,
        'category': category,
        'description': description,
        'phone': phone,
        'email': email,
        'location': location,
        'services': services,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Refresh vendor list
      await loadVendors();
      return null;
    } catch (e) {
      return 'Failed to update vendor profile: $e';
    }
  }

  Future<String?> deleteVendor(String vendorId) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).delete();
      await loadVendors();
      return null;
    } catch (e) {
      return 'Failed to delete vendor: $e';
    }
  }

  Future<String?> uploadVendorPortfolioImage(
    String vendorId,
    String imageUrl,
  ) async {
    try {
      final vendor = _vendors.firstWhere((v) => v.id == vendorId);
      final updatedImages = [...vendor.portfolioImages, imageUrl];

      await _firestore
          .collection('vendors')
          .doc(vendorId)
          .update({
        'portfolioImages': updatedImages,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadVendors();
      return null;
    } catch (e) {
      debugPrint('Error uploading portfolio image: $e');
      return 'Failed to upload image: $e';
    }
  }
}
