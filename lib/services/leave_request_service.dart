import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_request.dart';
import 'firebase_service.dart';

class LeaveRequestService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả leave requests
  static Future<List<LeaveRequest>> getAllLeaveRequests() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('leaveRequests').get();
      return snapshot.docs.map((doc) {
        return LeaveRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting leave requests: $e');
      return [];
    }
  }

  // Lấy leave requests theo teacher ID
  static Future<List<LeaveRequest>> getLeaveRequestsByTeacher(String teacherId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('leaveRequests')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      return snapshot.docs.map((doc) {
        return LeaveRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting leave requests by teacher: $e');
      return [];
    }
  }

  // Tạo leave request mới
  static Future<String?> createLeaveRequest(LeaveRequest request) async {
    try {
      final DocumentReference docRef = await _firestore.collection('leaveRequests').add(request.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating leave request: $e');
      return null;
    }
  }

  // Cập nhật leave request
  static Future<bool> updateLeaveRequest(String requestId, LeaveRequest request) async {
    try {
      await _firestore.collection('leaveRequests').doc(requestId).update(request.toMap());
      return true;
    } catch (e) {
      print('Error updating leave request: $e');
      return false;
    }
  }

  // Xóa leave request
  static Future<bool> deleteLeaveRequest(String requestId) async {
    try {
      await _firestore.collection('leaveRequests').doc(requestId).delete();
      return true;
    } catch (e) {
      print('Error deleting leave request: $e');
      return false;
    }
  }

  // Stream leave requests theo teacher (real-time updates)
  static Stream<List<LeaveRequest>> getLeaveRequestsStreamByTeacher(String teacherId) {
    return _firestore
        .collection('leaveRequests')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LeaveRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}

