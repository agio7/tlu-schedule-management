import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'firebase_service.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy các số liệu thống kê cho dashboard
  static Future<Map<String, int>> getDashboardStats() async {
    try {
      // Chạy các truy vấn song song để tăng tốc độ
      final results = await Future.wait([
        _firestore.collection('users').where('role', isEqualTo: 'teacher').count().get(),
        _firestore.collection('classrooms').count().get(),
        _firestore.collection('subjects').count().get(),
        _firestore.collection('rooms').count().get(),
      ]);

      return {
        'totalTeachers': results[0].count ?? 0,
        'totalClassrooms': results[1].count ?? 0,
        'totalSubjects': results[2].count ?? 0,
        'totalRooms': results[3].count ?? 0,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      rethrow;
    }
  }

  // Lấy danh sách người dùng theo vai trò (dạng stream để tự động cập nhật)
  static Stream<List<User>> getUsersStreamByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  // Xóa một người dùng
  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('User $userId deleted from Firestore.');
    } catch (e) {
      print('Error deleting user $userId: $e');
      rethrow;
    }
  }

  // Lấy tất cả người dùng
  static Future<List<User>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  // Cập nhật thông tin người dùng
  static Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Tạo người dùng mới
  static Future<String?> createUser(Map<String, dynamic> userData) async {
    try {
      final DocumentReference docRef = await _firestore.collection('users').add(userData);
      return docRef.id;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }
}
