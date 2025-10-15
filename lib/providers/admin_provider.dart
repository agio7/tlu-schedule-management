import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user.dart';

class AdminProvider with ChangeNotifier {
  Map<String, int> _dashboardStats = {};
  List<User> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, int> get dashboardStats => _dashboardStats;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadDashboardStats() async {
    _setLoading(true);
    _clearError();
    try {
      _dashboardStats = await AdminService.getDashboardStats();
    } catch (e) {
      _setError('Không thể tải dữ liệu tổng quan: $e');
      print('Error loading dashboard stats: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUsersByRole(String role) async {
    _setLoading(true);
    _clearError();
    try {
      AdminService.getUsersStreamByRole(role).listen((users) {
        _users = users;
        _setLoading(false); // Set loading to false once data is received
      }, onError: (e) {
        _setError('Không thể tải danh sách người dùng: $e');
        print('Error loading users by role: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('Không thể tải danh sách người dùng: $e');
      print('Error setting up user stream: $e');
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();
    try {
      await AdminService.deleteUser(userId);
      // Data will automatically refresh via stream in loadUsersByRole
    } catch (e) {
      _setError('Không thể xóa người dùng: $e');
      print('Error deleting user: $e');
    } finally {
      _setLoading(false);
    }
  }
}



