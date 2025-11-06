// [DÁN TOÀN BỘ CODE NÀY VÀO: lib/services/leave_request_service.dart]

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_requests.dart'; // Dùng tên file model của bạn
import 'firebase_service.dart';

// [SỬA LỖI] Đổi tên class thành 'LeaveRequests' (số nhiều) ở mọi nơi
class LeaveRequestService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả leave requests
  static Stream<List<LeaveRequests>> getLeaveRequestsStream() {
    return _firestore.collection('leaveRequests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LeaveRequests.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy leave requests theo teacher
  static Stream<List<LeaveRequests>> getLeaveRequestsByTeacherStream(String teacherId) {
    return _firestore
        .collection('leaveRequests')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LeaveRequests.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy leave requests theo status
  static Stream<List<LeaveRequests>> getLeaveRequestsByStatusStream(String status) {
    return _firestore
        .collection('leaveRequests')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LeaveRequests.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy leave requests theo approver
  static Stream<List<LeaveRequests>> getLeaveRequestsByApproverStream(String approverId) {
    return _firestore
        .collection('leaveRequests')
        .where('approverId', isEqualTo: approverId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => LeaveRequests.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm leave request mới
  static Future<String> addLeaveRequest(LeaveRequests leaveRequest) async {
    final docRef = await _firestore.collection('leaveRequests').add(leaveRequest.toJson());
    return docRef.id;
  }

  // [SỬA LỖI] Hàm này phải nhận Map<String, dynamic>
  static Future<void> updateLeaveRequest(String leaveRequestId, Map<String, dynamic> data) async {
    await _firestore.collection('leaveRequests').doc(leaveRequestId).update(data);
  }

  // Xóa leave request
  static Future<void> deleteLeaveRequest(String leaveRequestId) async {
    await _firestore.collection('leaveRequests').doc(leaveRequestId).delete();
  }

  // Lấy leave request theo ID
  static Future<LeaveRequests?> getLeaveRequestById(String leaveRequestId) async {
    final doc = await _firestore.collection('leaveRequests').doc(leaveRequestId).get();
    if (doc.exists) {
      return LeaveRequests.fromJson(doc.id, doc.data()!);
    }
    return null;
  }
}