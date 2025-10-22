import 'package:flutter/foundation.dart';
import '../services/offline_auth_service.dart';
import '../models/users.dart';

class OfflineAuthProvider with ChangeNotifier {
  Users? _user;
  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;

  // Getters
  Users? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;
  bool get isAuthenticated => _user != null;

  // Đăng nhập với offline support
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      print('🔐 OfflineAuthProvider: Bắt đầu đăng nhập...');
      
      final result = await OfflineAuthService.signInWithFallback(
        email: email,
        password: password,
      );

      if (result['success']) {
        _user = result['userData'];
        _isOffline = result['isOffline'] ?? false;
        print('✅ OfflineAuthProvider: Đăng nhập thành công (offline: $_isOffline)');
      } else {
        _setError(result['message'] ?? 'Đăng nhập thất bại');
        print('❌ OfflineAuthProvider: Đăng nhập thất bại: ${result['message']}');
      }
    } catch (e) {
      _setError('Lỗi không xác định: $e');
      print('❌ OfflineAuthProvider: Lỗi đăng nhập: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      _user = null;
      _isOffline = false;
      _clearError();
      print('✅ OfflineAuthProvider: Đã đăng xuất');
      notifyListeners();
    } catch (e) {
      print('❌ OfflineAuthProvider: Lỗi đăng xuất: $e');
    }
  }

  // Test kết nối
  Future<Map<String, dynamic>> testConnection() async {
    try {
      return await OfflineAuthService.testConnection();
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}



