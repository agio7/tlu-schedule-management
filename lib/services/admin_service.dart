import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy dashboard statistics
  static Future<Map<String, int>> getDashboardStats() async {
    try {
      print('📊 AdminService: Lấy dashboard stats...');
      
      // Đếm users theo role
      final usersQuery = await _firestore.collection('users').get();
      final teachersCount = usersQuery.docs.where((doc) => doc.data()['role'] == 'teacher').length;
      final adminsCount = usersQuery.docs.where((doc) => doc.data()['role'] == 'admin').length;
      
      // Đếm subjects
      final subjectsQuery = await _firestore.collection('subjects').get();
      final subjectsCount = subjectsQuery.docs.length;
      
      // Đếm classrooms
      final classroomsQuery = await _firestore.collection('classrooms').get();
      final classroomsCount = classroomsQuery.docs.length;
      
      // Đếm rooms
      final roomsQuery = await _firestore.collection('rooms').get();
      final roomsCount = roomsQuery.docs.length;
      
      // Đếm pending leave requests
      final leaveRequestsQuery = await _firestore
          .collection('leaveRequests')
          .where('status', isEqualTo: 'pending')
          .get();
      final pendingLeaveRequestsCount = leaveRequestsQuery.docs.length;
      
      // Đếm schedules
      final schedulesQuery = await _firestore.collection('schedules').get();
      final schedulesCount = schedulesQuery.docs.length;
      
      final stats = {
        'totalUsers': usersQuery.docs.length,
        'teachers': teachersCount,
        'admins': adminsCount,
        'subjects': subjectsCount,
        'classrooms': classroomsCount,
        'rooms': roomsCount,
        'schedules': schedulesCount,
        'pendingLeaveRequests': pendingLeaveRequestsCount,
      };
      
      print('✅ AdminService: Dashboard stats: $stats');
      return stats;
    } catch (e) {
      print('❌ AdminService: Error getting dashboard stats: $e');
      return {
        'totalUsers': 0,
        'teachers': 0,
        'admins': 0,
        'subjects': 0,
        'classrooms': 0,
        'rooms': 0,
        'schedules': 0,
        'pendingLeaveRequests': 0,
      };
    }
  }

  // Lấy users stream theo role
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

  // Lấy teachers stream
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

  // Lấy leave requests stream
  static Stream<List<Map<String, dynamic>>> getLeaveRequestsStream() {
    return _firestore.collection('leaveRequests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();
    });
  }

  // Lấy leave requests theo status
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

  // Duyệt leave request
  static Future<void> approveLeaveRequest(String leaveRequestId, String approverId) async {
    await _firestore.collection('leaveRequests').doc(leaveRequestId).update({
      'status': 'approved',
      'approverId': approverId,
      'updatedAt': Timestamp.now(),
    });
  }

  // Từ chối leave request
  static Future<void> rejectLeaveRequest(String leaveRequestId, String approverId) async {
    await _firestore.collection('leaveRequests').doc(leaveRequestId).update({
      'status': 'rejected',
      'approverId': approverId,
      'updatedAt': Timestamp.now(),
    });
  }
}


