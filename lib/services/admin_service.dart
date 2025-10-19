// lib/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'firebase_service.dart'; // Giả sử bạn có file này để lấy instance của firestore

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
        // Thêm các thống kê khác nếu cần
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
        // Sử dụng factory constructor đã sửa đổi
        return User.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  // Xóa một người dùng
  static Future<void> deleteUser(String userId) async {
    try {
      // Lưu ý: Việc xóa người dùng ở Firestore không xóa họ khỏi Firebase Authentication.
      // Bạn sẽ cần thêm logic xóa khỏi Auth nếu cần.
      await _firestore.collection('users').doc(userId).delete();
      print('User $userId deleted from Firestore.');
    } catch (e) {
      print('Error deleting user $userId: $e');
      rethrow;
    }
  }
}

