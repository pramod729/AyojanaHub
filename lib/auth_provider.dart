
import 'package:ayojana_hub/usermodels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    
    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!, doc.id);
        notifyListeners();
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message ?? 'Registration failed';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserData();
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message ?? 'Login failed';
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'An error occurred';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      if (_user == null) return 'No user logged in';

      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        'phone': phone,
      });

      await _loadUserData();
      return null;
    } catch (e) {
      return 'Failed to update profile';
    }
  }
}