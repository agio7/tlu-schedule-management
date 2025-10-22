import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson.dart';
import '../models/leave_request.dart';
import 'lesson_service.dart';
import 'leave_request_service.dart';

class RealtimeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream lessons theo teacher ID với real-time updates
  static Stream<List<Lesson>> getLessonsStreamByTeacher(String teacherId) {
    return _firestore
        .collection('lessons')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream lessons theo ngày với real-time updates
  static Stream<List<Lesson>> getLessonsStreamByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _firestore
        .collection('lessons')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream leave requests theo teacher ID với real-time updates
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

  // Stream tất cả lessons với real-time updates
  static Stream<List<Lesson>> getAllLessonsStream() {
    return _firestore
        .collection('lessons')
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream tất cả leave requests với real-time updates
  static Stream<List<LeaveRequest>> getAllLeaveRequestsStream() {
    return _firestore
        .collection('leaveRequests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return LeaveRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}

