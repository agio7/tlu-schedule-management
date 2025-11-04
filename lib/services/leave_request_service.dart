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
      print(' Querying Firebase for leaveRequests where teacherId = "$teacherId"');
      final QuerySnapshot snapshot = await _firestore
          .collection('leaveRequests')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      
      print(' Found ${snapshot.docs.length} leave requests with teacherId = "$teacherId"');
      
      // Nếu không tìm thấy, thử query tất cả để xem có dữ liệu gì không (debug)
      if (snapshot.docs.isEmpty) {
        print('️ No leave requests found with teacherId = "$teacherId"');
        print(' Checking all leave requests in Firebase...');
        final allRequests = await _firestore.collection('leaveRequests').limit(5).get();
        if (allRequests.docs.isNotEmpty) {
          print(' Sample teacherIds in Firebase:');
          for (var doc in allRequests.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print('   - teacherId: "${data['teacherId']}" (type: ${data['type']}, reason: ${data['reason']})');
          }
        } else {
          print('   - No leave requests found in Firebase at all');
        }
      }
      
      final requests = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(' Leave Request: ${data['type']} - ${data['reason']}');
        return LeaveRequest.fromMap(data, doc.id);
      }).toList();
      
      return requests;
    } catch (e) {
      print(' Error getting leave requests by teacher: $e');
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

