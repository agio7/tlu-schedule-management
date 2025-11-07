import 'package:cloud_firestore/cloud_firestore.dart';
// KHÔNG import model User/Users để tránh xung đột, chúng ta sẽ dùng Map
import 'firebase_service.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy dashboard statistics
  // GIỮ PHIÊN BẢN CỦA 'THANH' VÌ NÓ HIỆU QUẢ HƠN (DÙNG .count())
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
      print('❌ AdminService: Error getting dashboard stats: $e');
      // Trả về map lỗi khớp với map thành công
      return {
        'totalTeachers': 0,
        'totalClassrooms': 0,
        'totalSubjects': 0,
        'totalRooms': 0,
      };
    }
  }

  // Lấy users stream theo role
  // GIỮ PHIÊN BẢN CỦA 'HEAD' (TRẢ VỀ MAP) ĐỂ TRÁNH XUNG ĐỘT MODEL
  static Stream<List<Map<String, dynamic>>> getUsersStreamByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  // === CÁC HÀM TỪ 'HEAD' ===
  // (Giữ lại các hàm quản lý leave request)
  static Stream<List<Map<String, dynamic>>> getTeachersStream() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  static Stream<List<Map<String, dynamic>>> getLeaveRequestsStream() {
    return _firestore.collection('leaveRequests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  static Stream<List<Map<String, dynamic>>> getLeaveRequestsByStatusStream(String status) {
    return _firestore
        .collection('leaveRequests')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  static Future<void> approveLeaveRequest(String leaveRequestId, String approverId) async {
    await _firestore.collection('leaveRequests').doc(leaveRequestId).update({
      'status': 'approved',
      'approverId': approverId,
      'updatedAt': Timestamp.now(),
    });
  }

  static Future<void> rejectLeaveRequest(String leaveRequestId, String approverId) async {
    await _firestore.collection('leaveRequests').doc(leaveRequestId).update({
      'status': 'rejected',
      'approverId': approverId,
      'updatedAt': Timestamp.now(),
    });
  }

  // === CÁC HÀM TỪ 'THANH' ===
  // (Giữ lại các hàm quản lý user)

  static Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('User $userId deleted from Firestore.');
    } catch (e) {
      print('Error deleting user $userId: $e');
      rethrow;
    }
  }

  // ĐÃ SỬA: Trả về Map để nhất quán với 'HEAD'
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        // Sửa từ User.fromJson thành trả về Map
        return {
          'id': doc.id,
          ...(doc.data() as Map<String, dynamic>)
        };
      }).toList();
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  static Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

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