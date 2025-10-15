// services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'firebase_service.dart';

class AuthService {
  static final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  static Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final String uid = userCredential.user!.uid;

      final userModel = await getUserDataFromFirestore(uid);

      if (userModel == null) {
        return {'success': false, 'message': 'Không tìm thấy thông tin người dùng trong cơ sở dữ liệu.'};
      }
      return {'success': true, 'userData': userModel};

    } on firebase.FirebaseAuthException catch (e) {
      print('💥 AuthService FirebaseAuth Error: ${e.code}');
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return {'success': false, 'message': 'Email hoặc mật khẩu không đúng.'};
      }
      return {'success': false, 'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.'};
    } catch (e) {
      print('💥 AuthService General Error: $e');
      return {'success': false, 'message': 'Lỗi không xác định: $e'};
    }
  }

  // PHIÊN BẢN CẬP NHẬT
  static Future<User?> getUserDataFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        // 1. Truyền cả ID của tài liệu và dữ liệu vào hàm fromJson
        return User.fromJson(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('💥 AuthService: Error getting user data from Firestore: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    print('✅ AuthService: User signed out from Firebase');
  }
}

