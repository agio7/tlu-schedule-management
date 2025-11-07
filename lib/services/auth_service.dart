import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';
import 'firebase_service.dart';

class AuthService {
  static final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Loại bỏ pre-check mạng dễ gây timeout; dựa vào lỗi Firebase để xác định trạng thái mạng

  static Future<Map<String, dynamic>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 AuthService: Bắt đầu đăng nhập với email: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Timeout: Không thể kết nối đến server. Vui lòng thử lại.');
        },
      );

      print('✅ AuthService: Firebase Auth thành công, UID: ${userCredential.user?.uid}');
      final String uid = userCredential.user!.uid;

      // Ưu tiên lấy theo UID; nếu không có, fallback tìm theo email
      print('🔍 AuthService: Tìm kiếm user data trong Firestore với UID: $uid');
      // Giữ phiên bản HEAD (dùng getUsersDataFromFirestore)
      final userModel = await getUsersDataFromFirestore(uid, fallbackEmail: email);

      if (userModel == null) {
        print('❌ AuthService: Không tìm thấy user data trong Firestore');
        return {
          'success': false,
          'message': 'Không tìm thấy thông tin người dùng trong cơ sở dữ liệu.'
        };
      }

      print('✅ AuthService: Tìm thấy user data: ${userModel.fullName} (${userModel.role})');
      return {'success': true, 'userData': userModel};

    } on TimeoutException catch (e) {
      // Bắt riêng TimeoutException để thông báo rõ ràng hơn
      print('❌ AuthService: TimeoutException: $e');
      return {'success': false, 'message': 'Kết nối chậm. Vui lòng kiểm tra mạng và thử lại.'};
    } on firebase.FirebaseAuthException catch (e) {
      // Giữ lại phần xử lý lỗi chi tiết của HEAD
      print('❌ AuthService: FirebaseAuthException - Code: ${e.code}, Message: ${e.message}');

      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email hoặc mật khẩu không đúng.';
          break;
        case 'network-request-failed':
          message = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet và thử lại.';
          break;
        case 'too-many-requests':
          message = 'Quá nhiều lần thử đăng nhập. Vui lòng thử lại sau.';
          break;
        case 'user-disabled':
          message = 'Tài khoản này đã bị vô hiệu hóa.';
          break;
        case 'invalid-email':
          message = 'Email không hợp lệ.';
          break;
        case 'weak-password':
          message = 'Mật khẩu quá yếu.';
          break;
        case 'email-already-in-use':
          message = 'Email này đã được sử dụng.';
          break;
        default:
          message = 'Đã có lỗi xảy ra: ${e.message ?? e.code}';
      }

      return {'success': false, 'message': message};
    } catch (e) {
      // Giữ lại log của HEAD
      print('❌ AuthService: General Exception: $e');
      return {'success': false, 'message': 'Lỗi không xác định: $e'};
    }
  }

  // Giữ lại hoàn toàn hàm getUsersDataFromFirestore của HEAD
  static Future<Users?> getUsersDataFromFirestore(String uid, {String? fallbackEmail}) async {
    try {
      print('🔍 AuthService: getUsersDataFromFirestore - UID: $uid, FallbackEmail: $fallbackEmail');

      final doc = await _firestore.collection('users').doc(uid).get();
      print('📄 AuthService: Document exists: ${doc.exists}');

      if (doc.exists) {
        print('✅ AuthService: Tìm thấy user theo UID');
        return Users.fromJson(doc.id, doc.data()!);
      }

      if (fallbackEmail != null) {
        print('🔍 AuthService: Tìm kiếm theo email: $fallbackEmail');
        final q = await _firestore
            .collection('users')
            .where('email', isEqualTo: fallbackEmail)
            .limit(1)
            .get();

        print('📄 AuthService: Query results count: ${q.docs.length}');

        if (q.docs.isNotEmpty) {
          final d = q.docs.first;
          print('✅ AuthService: Tìm thấy user theo email');
          return Users.fromJson(d.id, d.data());
        }
      }

      print('❌ AuthService: Không tìm thấy user data');
      return null;
    } catch (e) {
      print('❌ AuthService: Error in getUsersDataFromFirestore: $e');
      return null;
    }
  }

  // Gộp hàm signOut: Lấy của HEAD nhưng thêm 'print' từ Thanh
  static Future<void> signOut() async {
    await _auth.signOut();
    print(' AuthService: User signed out from Firebase'); // <-- Lấy từ nhánh Thanh
  }

  // Giữ lại toàn bộ các hàm mới từ HEAD
  static Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Link đặt lại mật khẩu đã được gửi đến email của bạn.'};
    } on firebase.FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy người dùng với email này.';
      } else {
        message = 'Lỗi khi gửi email đặt lại mật khẩu: ${e.message}';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Lỗi không xác định: $e'};
    }
  }

  // Debug method để kiểm tra dữ liệu trong Firestore
  static Future<void> debugCheckFirestoreData() async {
    try {
      print('🔍 AuthService: Kiểm tra dữ liệu trong Firestore...');

      // Kiểm tra Firebase Auth users trước
      print('🔐 AuthService: Kiểm tra Firebase Auth users...');
      final currentUsers = _auth.currentUser;
      print('👤 AuthService: Current Firebase Auth user: ${currentUsers?.email} (${currentUsers?.uid})');

      if (currentUsers != null) {
        // Chỉ kiểm tra user document của chính mình
        final userDoc = await _firestore.collection('users').doc(currentUsers.uid).get();
        if (userDoc.exists) {
          print('✅ AuthService: Tìm thấy user data trong Firestore: ${userDoc.data()}');
        } else {
          print('❌ AuthService: Không tìm thấy user data trong Firestore cho UID: ${currentUsers.uid}');

          // Thử tìm theo email nếu không tìm thấy theo UID
          final emailQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: currentUsers.email)
              .limit(1)
              .get();

          if (emailQuery.docs.isNotEmpty) {
            print('✅ AuthService: Tìm thấy user theo email: ${emailQuery.docs.first.data()}');
          } else {
            print('❌ AuthService: Không tìm thấy user theo email: ${currentUsers.email}');
          }
        }
      } else {
        print('❌ AuthService: Không có Firebase Auth user');
      }

    } catch (e) {
      print('❌ AuthService: Error in debugCheckFirestoreData: $e');
    }
  }

  // Method để retry đăng nhập với exponential backoff
  static Future<Map<String, dynamic>> signInWithRetry({
    required String email,
    required String password,
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      print('🔄 AuthService: Thử đăng nhập lần $attempt/$maxRetries');

      final result = await signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result['success']) {
        return result;
      }

      // Nếu là lỗi network và chưa hết số lần thử
      if (result['message'].contains('mạng') && attempt < maxRetries) {
        final delay = Duration(seconds: attempt * 2); // 2s, 4s, 6s
        print('⏳ AuthService: Chờ $delay trước khi thử lại...');
        await Future.delayed(delay);
      } else {
        return result; // Trả về lỗi nếu không phải network error hoặc đã hết số lần thử
      }
    }

    return {'success': false, 'message': 'Đã thử đăng nhập $maxRetries lần nhưng không thành công.'};
  }
}