import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/makeup_requests.dart';
import 'firebase_service.dart';

class MakeupRequestService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả makeup requests
  static Stream<List<MakeupRequests>> getMakeupRequestsStream() {
    return _firestore.collection('makeupRequests').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MakeupRequests.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy makeup requests theo teacher
  static Stream<List<MakeupRequests>> getMakeupRequestsByTeacherStream(String teacherId) {
    return _firestore
        .collection('makeupRequests')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MakeupRequests.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy makeup requests theo status
  static Stream<List<MakeupRequests>> getMakeupRequestsByStatusStream(String status) {
    return _firestore
        .collection('makeupRequests')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MakeupRequests.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy makeup requests theo leave request
  static Stream<List<MakeupRequests>> getMakeupRequestsByLeaveRequestStream(String leaveRequestId) {
    return _firestore
        .collection('makeupRequests')
        .where('leaveRequestId', isEqualTo: leaveRequestId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MakeupRequests.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm makeup request mới
  static Future<String> addMakeupRequest(MakeupRequests makeupRequest) async {
    final docRef = await _firestore.collection('makeupRequests').add(makeupRequest.toJson());
    return docRef.id;
  }

  // Cập nhật makeup request
  static Future<void> updateMakeupRequest(String makeupRequestId, MakeupRequests makeupRequest) async {
    await _firestore.collection('makeupRequests').doc(makeupRequestId).update(makeupRequest.toJson());
  }

  // Xóa makeup request
  static Future<void> deleteMakeupRequest(String makeupRequestId) async {
    await _firestore.collection('makeupRequests').doc(makeupRequestId).delete();
  }

  // Lấy makeup request theo ID
  static Future<MakeupRequests?> getMakeupRequestById(String makeupRequestId) async {
    final doc = await _firestore.collection('makeupRequests').doc(makeupRequestId).get();
    if (doc.exists) {
      return MakeupRequests.fromJson(doc.id, doc.data()!);
    }
    return null;
  }

  // Duyệt makeup request
  static Future<void> approveMakeupRequest(String makeupRequestId, String approverId) async {
    await _firestore.collection('makeupRequests').doc(makeupRequestId).update({
      'status': 'approved',
      'approverId': approverId,
      'updatedAt': Timestamp.now(),
    });
  }

  // Từ chối makeup request
  static Future<void> rejectMakeupRequest(String makeupRequestId, String approverId) async {
    await _firestore.collection('makeupRequests').doc(makeupRequestId).update({
      'status': 'rejected',
      'approverId': approverId,
      'updatedAt': Timestamp.now(),
    });
  }
}


