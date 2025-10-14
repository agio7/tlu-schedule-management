import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'firebase_service.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  static Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        return await getUserData(result.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  // Sign up with email and password
  static Future<UserModel?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? departmentId,
    String? phoneNumber,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user document in Firestore
        UserModel newUser = UserModel(
          id: result.user!.uid,
          email: email,
          fullName: fullName,
          role: role,
          departmentId: departmentId,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(result.user!.uid).set(newUser.toJson());
        return newUser;
      }
      return null;
    } catch (e) {
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get user data from Firestore
  static Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng: $e');
    }
  }

  // Update user data
  static Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin người dùng: $e');
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Không thể gửi email đặt lại mật khẩu: $e');
    }
  }

  // Change password
  static Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Re-authenticate user
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        
        // Update password
        await user.updatePassword(newPassword);
      }
    } catch (e) {
      throw Exception('Không thể thay đổi mật khẩu: $e');
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _auth.currentUser != null;

  // Get user role
  static Future<String?> getUserRole() async {
    if (currentUser != null) {
      UserModel? user = await getUserData(currentUser!.uid);
      return user?.role;
    }
    return null;
  }
}



