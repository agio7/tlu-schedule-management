import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/users.dart';

class AuthProvider with ChangeNotifier {
  Users? _userData;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  Users? get userData => _userData;
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

    print('AuthProvider: Bắt đầu đăng nhập cho $email...');
    await AuthService.debugCheckFirestoreData();

    final result = await AuthService.signInWithRetry(
      email: email,
      password: password,
    );

    print('AuthProvider: Nhận kết quả từ AuthService: $result');

    if (result['success']) {
      _userData = result['userData'];
      _isAuthenticated = true;
      print('✅ AuthProvider: Đăng nhập THÀNH CÔNG cho ${_userData?.fullName}. Trạng thái isAuthenticated: $_isAuthenticated');
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _setError(result['message']);
      _isAuthenticated = false;
      print('❌ AuthProvider: Đăng nhập THẤT BẠI. Lý do: ${result['message']}');
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

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    clearError();
    final result = await AuthService.sendPasswordResetEmail(email);
    if (!result['success']) {
      _setError(result['message']);
    }
    _setLoading(false);
    return result['success'];
  }
}








