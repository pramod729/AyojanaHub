import 'package:ayojana_hub/package_model.dart';
import 'package:ayojana_hub/vendor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<VendorModel> _vendors = [];
  List<PackageModel> _packages = [];
  bool _isLoading = false;

  List<VendorModel> get vendors => _vendors;
  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;

  Future<void> loadVendors({String? category}) async {
    _isLoading = true;
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
      print('Error loading vendors: $e');
    }

    _isLoading = false;
    notifyListeners();
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
      print('Error loading packages: $e');
    }
  }
}

