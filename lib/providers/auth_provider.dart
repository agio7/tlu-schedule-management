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

    print('AuthProvider: Bắt đầu đăng nhập cho $email...'); // <-- THÊM DÒNG NÀY

    final result = await AuthService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print('AuthProvider: Nhận kết quả từ AuthService: $result'); // <-- THÊM DÒNG NÀY

    if (result['success']) {
      _userData = result['userData'];
      _isAuthenticated = true;
      print('✅ AuthProvider: Đăng nhập THÀNH CÔNG cho ${_userData?.fullName}. Trạng thái isAuthenticated: $_isAuthenticated'); // <-- THÊM DÒNG NÀY
      _setLoading(false); // Đảm bảo dừng loading khi thành công
      notifyListeners(); // THÔNG BÁO CHO GIAO DIỆN
      return true;
    } else {
      _setError(result['message']);
      _isAuthenticated = false; // Đảm bảo trạng thái là false
      print('❌ AuthProvider: Đăng nhập THẤT BẠI. Lý do: ${result['message']}'); // <-- THÊM DÒNG NÀY
      _setLoading(false);
      notifyListeners(); // THÔNG BÁO CHO GIAO DIỆN
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



