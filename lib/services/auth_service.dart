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
      print(' AuthService FirebaseAuth Error: ${e.code}');
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return {'success': false, 'message': 'Email hoặc mật khẩu không đúng.'};
      }
      return {'success': false, 'message': 'Đã có lỗi xảy ra. Vui lòng thử lại.'};
    } catch (e) {
      print(' AuthService General Error: $e');
      return {'success': false, 'message': 'Lỗi không xác định: $e'};
    }
  }

  static Future<User?> getUserDataFromFirestore(String uid) async {
    try {
      // Thử 1: Tìm user bằng document ID = UID (chuẩn Firebase Auth)
      var doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final userData = doc.data()!;
        // Nếu document có field 'id' riêng, sử dụng nó; nếu không, dùng document ID (UID)
        final userId = userData['id'] as String? ?? doc.id;
        print(' Found user by UID: $uid, using userId: $userId');
        return User.fromJson(userId, userData);
      }

      // Thử 2: Nếu không tìm thấy bằng UID, thử tìm bằng email (fallback)
      // Điều này có thể xảy ra nếu user document được tạo thủ công với document ID khác
      print(' User not found by UID: $uid, trying to find by email...');
      
      // Lấy email từ Firebase Auth user
      final authUser = _auth.currentUser;
      if (authUser?.email != null) {
        final querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: authUser!.email)
            .limit(1)
            .get();
        
        if (querySnapshot.docs.isNotEmpty) {
          final doc = querySnapshot.docs.first;
          final userData = doc.data();
          final userId = userData['id'] as String? ?? doc.id;
          print(' Found user by email: ${authUser.email}, using userId: $userId');
          return User.fromJson(userId, userData);
        }
      }
      
      print(' User not found in Firestore');
      return null;
    } catch (e) {
      print(' Error getting user data: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    print(' AuthService: User signed out from Firebase');
  }
}

