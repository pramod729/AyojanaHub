
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
      debugPrint('Error loading user data: $e');
    }
  }

  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address';
      case 'wrong-password':
        return 'Incorrect password. Please try again';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later';
      default:
        return 'An error occurred. Please try again';
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

      // Email validation
      if (!_isValidEmail(email)) {
        _isLoading = false;
        notifyListeners();
        return 'Please enter a valid email address';
      }

      // Password validation
      if (password.length < 8) {
        _isLoading = false;
        notifyListeners();
        return 'Password must be at least 8 characters long';
      }

      // Phone validation
      if (!_isValidPhone(phone)) {
        _isLoading = false;
        notifyListeners();
        return 'Please enter a valid phone number';
      }

      // Name validation
      if (name.trim().isEmpty || name.trim().split(' ').length < 2) {
        _isLoading = false;
        notifyListeners();
        return 'Please enter your full name';
      }

      // Check if email already exists
      final signInMethods =
          await _auth.fetchSignInMethodsForEmail(email.trim());
      if (signInMethods.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'An account already exists with this email address';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await credential.user!.updateDisplayName(name.trim());

      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'displayName': name.trim(),
        'photoURL': '',
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getFirebaseErrorMessage(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Registration error: $e');
      return 'An unexpected error occurred. Please try again';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Email validation
      if (!_isValidEmail(email)) {
        _isLoading = false;
        notifyListeners();
        return 'Please enter a valid email address';
      }

      // Password validation
      if (password.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'Please enter your password';
      }

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _loadUserData();
      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getFirebaseErrorMessage(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Login error: $e');
      return 'An unexpected error occurred. Please try again';
    }
  }

  Future<String?> resetPassword({required String email}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Email validation
      if (!_isValidEmail(email)) {
        _isLoading = false;
        notifyListeners();
        return 'Please enter a valid email address';
      }

      // Check if email exists
      final signInMethods =
          await _auth.fetchSignInMethodsForEmail(email.trim());
      if (signInMethods.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return 'No account found with this email address';
      }

      await _auth.sendPasswordResetEmail(email: email.trim());

      _isLoading = false;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return _getFirebaseErrorMessage(e.code);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Password reset error: $e');
      return 'An unexpected error occurred. Please try again';
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      _userModel = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }

  Future<String?> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      if (_user == null) return 'No user logged in';

      // Name validation
      if (name.trim().isEmpty) {
        return 'Please enter your name';
      }

      // Phone validation
      if (!_isValidPhone(phone)) {
        return 'Please enter a valid phone number';
      }

      await _user!.updateDisplayName(name.trim());

      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name.trim(),
        'displayName': name.trim(),
        'phone': phone.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _loadUserData();
      return null;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return 'Failed to update profile. Please try again';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      if (_user == null) return 'No user logged in';

      final email = _user!.email;
      if (email == null) return 'Email not found';

      // Validate new password
      if (newPassword.length < 8) {
        return 'New password must be at least 8 characters long';
      }

      if (newPassword == currentPassword) {
        return 'New password must be different from current password';
      }

      // Reauthenticate user
      try {
        await _user!.reauthenticateWithCredential(
          EmailAuthProvider.credential(
            email: email,
            password: currentPassword,
          ),
        );
      } on FirebaseAuthException catch (e) {
        return _getFirebaseErrorMessage(e.code);
      }

      // Update password
      await _user!.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getFirebaseErrorMessage(e.code);
    } catch (e) {
      debugPrint('Change password error: $e');
      return 'An unexpected error occurred. Please try again';
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  bool _isValidPhone(String phone) {
    // Remove all non-digit characters and check if at least 10 digits remain
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 10;
  }
}