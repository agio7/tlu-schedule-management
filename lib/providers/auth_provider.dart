import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _userData;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  User? get userData => _userData;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    initializeAuth();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> initializeAuth() async {
    _setLoading(true);
    // Mock initialization - in real app, you'd check for existing session
    _setLoading(false);
  }

  // trong file providers/auth_provider.dart

  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    clearError();

    final result = await AuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result['success']) {
      _userData = result['userData'];
      _isAuthenticated = true;
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _setError(result['message']);
      _isAuthenticated = false;
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    clearError();
    await AuthService.signOut();
    _userData = null;
    _isAuthenticated = false;
    _setLoading(false);
  }
}



