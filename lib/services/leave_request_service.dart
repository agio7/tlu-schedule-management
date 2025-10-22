import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_requests.dart';
import 'firebase_service.dart';

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

  // Cập nhật leave request
  static Future<void> updateLeaveRequest(String leaveRequestId, LeaveRequests leaveRequest) async {
    await _firestore.collection('leaveRequests').doc(leaveRequestId).update(leaveRequest.toJson());
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


