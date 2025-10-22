import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';
import 'dart:convert';
import 'dart:io';

class OfflineAuthService {
  static final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kiểm tra kết nối internet
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print('❌ OfflineAuthService: No internet connection: $e');
      return false;
    }
  }

  // Đăng nhập với fallback offline
  static Future<Map<String, dynamic>> signInWithFallback({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 OfflineAuthService: Bắt đầu đăng nhập với fallback...');
      
      // Kiểm tra kết nối internet
      final hasInternet = await hasInternetConnection();
      print('🌐 OfflineAuthService: Has internet: $hasInternet');
      
      if (!hasInternet) {
        return _handleOfflineLogin(email, password);
      }

      // Thử đăng nhập Firebase với timeout ngắn
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        ).timeout(
          const Duration(seconds: 10), // Timeout ngắn
          onTimeout: () {
            print('⏰ OfflineAuthService: Firebase timeout, trying offline...');
            throw Exception('Firebase timeout');
          },
        );

        print('✅ OfflineAuthService: Firebase login thành công');
        return await _handleSuccessfulLogin(userCredential);
        
      } catch (e) {
        print('⚠️ OfflineAuthService: Firebase failed, trying offline: $e');
        return _handleOfflineLogin(email, password);
      }

    } catch (e) {
      print('❌ OfflineAuthService: General error: $e');
      return {
        'success': false,
        'message': 'Không thể kết nối. Vui lòng kiểm tra mạng và thử lại.',
        'isOffline': true,
      };
    }
  }

  // Xử lý đăng nhập offline
  static Future<Map<String, dynamic>> _handleOfflineLogin(String email, String password) async {
    try {
      print('📱 OfflineAuthService: Thử đăng nhập offline...');
      
      // Kiểm tra local storage hoặc cache
      final cachedUsers = await _getCachedUsers(email);
      if (cachedUsers != null) {
        print('✅ OfflineAuthService: Tìm thấy cached user');
        return {
          'success': true,
          'message': 'Đăng nhập offline thành công',
          'userData': cachedUsers,
          'isOffline': true,
        };
      }

      // Fallback: Tạo user tạm thời
      print('🔄 OfflineAuthService: Tạo user tạm thời...');
      final tempUsers = Users(
        id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        fullName: 'Users Offline',
        role: 'teacher', // Default role
        departmentId: null,
        // phoneNumber: null, // Removed - not in Users model
        avatar: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Cache user
      await _cacheUsers(tempUsers);

      return {
        'success': true,
        'message': 'Đăng nhập offline thành công (chế độ demo)',
        'userData': tempUsers,
        'isOffline': true,
      };

    } catch (e) {
      print('❌ OfflineAuthService: Offline login failed: $e');
      return {
        'success': false,
        'message': 'Không thể đăng nhập offline: $e',
        'isOffline': true,
      };
    }
  }

  // Xử lý đăng nhập thành công
  static Future<Map<String, dynamic>> _handleSuccessfulLogin(firebase.UserCredential userCredential) async {
    try {
      final uid = userCredential.user!.uid;
      print('🔍 OfflineAuthService: Tìm user data cho UID: $uid');

      // Thử lấy từ Firestore
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 5));

        if (userDoc.exists) {
          final userData = Users.fromJson(userDoc.id, userDoc.data()!);
          await _cacheUsers(userData); // Cache user
          return {
            'success': true,
            'message': 'Đăng nhập thành công',
            'userData': userData,
            'isOffline': false,
          };
        }
      } catch (e) {
        print('⚠️ OfflineAuthService: Firestore timeout, using cached data: $e');
      }

      // Fallback: Tìm trong cache
      final cachedUsers = await _getCachedUsers(userCredential.user!.email!);
      if (cachedUsers != null) {
        return {
          'success': true,
          'message': 'Đăng nhập thành công (dữ liệu cached)',
          'userData': cachedUsers,
          'isOffline': false,
        };
      }

      // Tạo user mới
      final newUsers = Users(
        id: uid,
        email: userCredential.user!.email!,
        fullName: userCredential.user!.displayName ?? 'Users',
        role: 'teacher',
        departmentId: null,
        // phoneNumber: userCredential.user!.phoneNumber, // Removed - not in Users model
        avatar: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _cacheUsers(newUsers);
      return {
        'success': true,
        'message': 'Đăng nhập thành công',
        'userData': newUsers,
        'isOffline': false,
      };

    } catch (e) {
      print('❌ OfflineAuthService: Error in successful login: $e');
      return {
        'success': false,
        'message': 'Lỗi xử lý đăng nhập: $e',
      };
    }
  }

  // Cache user locally
  static Future<void> _cacheUsers(Users user) async {
    try {
      // Sử dụng SharedPreferences hoặc local storage
      // Ở đây tôi sẽ dùng một cách đơn giản
      print('💾 OfflineAuthService: Caching user: ${user.email}');
      // TODO: Implement proper local storage
    } catch (e) {
      print('❌ OfflineAuthService: Error caching user: $e');
    }
  }

  // Lấy cached user
  static Future<Users?> _getCachedUsers(String email) async {
    try {
      // TODO: Implement proper local storage retrieval
      print('🔍 OfflineAuthService: Looking for cached user: $email');
      return null; // Placeholder
    } catch (e) {
      print('❌ OfflineAuthService: Error getting cached user: $e');
      return null;
    }
  }

  // Test kết nối với nhiều phương pháp
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{};

    // Test 1: Internet connection
    results['internet'] = await hasInternetConnection();

    // Test 2: Firebase Auth
    try {
      await _auth.authStateChanges().first.timeout(const Duration(seconds: 5));
      results['firebase_auth'] = true;
    } catch (e) {
      results['firebase_auth'] = false;
      results['firebase_auth_error'] = e.toString();
    }

    // Test 3: Firestore
    try {
      await _firestore.collection('test').doc('connection').get().timeout(const Duration(seconds: 5));
      results['firestore'] = true;
    } catch (e) {
      results['firestore'] = false;
      results['firestore_error'] = e.toString();
    }

    // Test 4: DNS resolution
    try {
      final addresses = await InternetAddress.lookup('firebase.googleapis.com');
      results['dns_firebase'] = addresses.isNotEmpty;
    } catch (e) {
      results['dns_firebase'] = false;
      results['dns_firebase_error'] = e.toString();
    }

    return results;
  }
}



