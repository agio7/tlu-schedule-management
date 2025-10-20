// lib/services/admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/teacher.dart';
import '../models/schedule.dart';
import '../models/leave_request.dart';
import 'firebase_service.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy các số liệu thống kê cho dashboard từ dữ liệu thật
  static Future<Map<String, int>> getDashboardStats() async {
    try {
      print('📊 AdminService: Đang lấy thống kê dashboard...');
      
      // Chạy các truy vấn song song để tăng tốc độ
      final results = await Future.wait([
        _firestore.collection('users').where('role', isEqualTo: 'teacher').count().get(),
        _firestore.collection('users').where('role', isEqualTo: 'department_head').count().get(),
        _firestore.collection('schedules').count().get(),
        _firestore.collection('leaveRequests').where('status', isEqualTo: 'pending').count().get(),
        _firestore.collection('classrooms').count().get(),
        _firestore.collection('subjects').count().get(),
        _firestore.collection('rooms').count().get(),
        _firestore.collection('departments').count().get(),
      ]);

      final stats = {
        'totalTeachers': results[0].count ?? 0,
        'totalDepartmentHeads': results[1].count ?? 0,
        'totalSchedules': results[2].count ?? 0,
        'pendingLeaveRequests': results[3].count ?? 0,
        'totalClassrooms': results[4].count ?? 0,
        'totalSubjects': results[5].count ?? 0,
        'totalRooms': results[6].count ?? 0,
        'totalDepartments': results[7].count ?? 0,
      };

      print('📊 AdminService: Thống kê dashboard: $stats');
      return stats;
    } catch (e) {
      print('❌ Error getting dashboard stats: $e');
      rethrow;
    }
  }

  // Lấy danh sách người dùng theo vai trò (dạng stream để tự động cập nhật)
  static Stream<List<User>> getUsersStreamByRole(String role) {
    print('👥 AdminService: Lấy stream users với role: $role');
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      print('👥 AdminService: Nhận được ${snapshot.docs.length} users với role $role');
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  // Lấy danh sách giảng viên (dạng stream)
  static Stream<List<Teacher>> getTeachersStream() {
    print('👨‍🏫 AdminService: Lấy stream teachers...');
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) {
      print('👨‍🏫 AdminService: Nhận được ${snapshot.docs.length} teachers');
      return snapshot.docs.map((doc) {
        return Teacher.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  // Lấy danh sách lịch trình (dạng stream)
  static Stream<List<Schedule>> getSchedulesStream() {
    print('📅 AdminService: Lấy stream schedules...');
    return _firestore
        .collection('schedules')
        .orderBy('startTime', descending: false)
        .snapshots()
        .map((snapshot) {
      print('📅 AdminService: Nhận được ${snapshot.docs.length} schedules');
      return snapshot.docs.map((doc) {
        return Schedule.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
    });
  }

  // Lấy danh sách yêu cầu nghỉ phép (dạng stream)
  static Stream<List<LeaveRequest>> getLeaveRequestsStream() {
    print('📝 AdminService: Lấy stream leave requests...');
    return _firestore
        .collection('leaveRequests')
        .snapshots()
        .map((snapshot) {
      print('📝 AdminService: Nhận được ${snapshot.docs.length} leave requests');
      return snapshot.docs.map((doc) {
        return LeaveRequest.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
    });
  }

  // Lấy yêu cầu nghỉ phép theo trạng thái
  static Stream<List<LeaveRequest>> getLeaveRequestsByStatusStream(String status) {
    print('📝 AdminService: Lấy stream leave requests với status: $status');
    return _firestore
        .collection('leaveRequests')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      print('📝 AdminService: Nhận được ${snapshot.docs.length} leave requests với status $status');
      return snapshot.docs.map((doc) {
        return LeaveRequest.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
    });
  }

  // Xóa một người dùng
  static Future<void> deleteUser(String userId) async {
    try {
      print('🗑️ AdminService: Xóa user $userId...');
      await _firestore.collection('users').doc(userId).delete();
      print('✅ AdminService: User $userId đã được xóa khỏi Firestore.');
    } catch (e) {
      print('❌ Error deleting user $userId: $e');
      rethrow;
    }
  }

  // Cập nhật trạng thái yêu cầu nghỉ phép
  static Future<void> updateLeaveRequestStatus(String requestId, String status, String? approverNotes) async {
    try {
      print('📝 AdminService: Cập nhật leave request $requestId với status: $status');
      await _firestore.collection('leaveRequests').doc(requestId).update({
        'status': status,
        'approverNotes': approverNotes,
        'approvedDate': status == 'approved' ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ AdminService: Leave request $requestId đã được cập nhật.');
    } catch (e) {
      print('❌ Error updating leave request $requestId: $e');
      rethrow;
    }
  }

  // Lấy thông tin chi tiết của một user
  static Future<User?> getUserById(String userId) async {
    try {
      print('👤 AdminService: Lấy thông tin user $userId...');
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting user $userId: $e');
      rethrow;
    }
  }

  // Lấy thông tin chi tiết của một schedule
  static Future<Schedule?> getScheduleById(String scheduleId) async {
    try {
      print('📅 AdminService: Lấy thông tin schedule $scheduleId...');
      final doc = await _firestore.collection('schedules').doc(scheduleId).get();
      if (doc.exists) {
        return Schedule.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      print('❌ Error getting schedule $scheduleId: $e');
      rethrow;
    }
  }
}








