import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson.dart';
import '../models/leave_request.dart';
import 'lesson_service.dart';
import 'leave_request_service.dart';

class RealtimeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream lessons theo teacher ID với real-time updates
  static Stream<List<Lesson>> getLessonsStreamByTeacher(String teacherId) {
    try {
      return _firestore
          .collection('lessons')
          .where('teacherId', isEqualTo: teacherId)
          .orderBy('date')
          .orderBy('startTime')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
      });
    } catch (e) {
      print('Error in getLessonsStreamByTeacher with orderBy: $e');
      // Fallback: return stream without orderBy if index is missing
      return _firestore
          .collection('lessons')
          .where('teacherId', isEqualTo: teacherId)
          .snapshots()
          .map((snapshot) {
        final lessons = snapshot.docs.map((doc) {
          return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        // Sort manually if orderBy fails
        lessons.sort((a, b) {
          final dateCompare = a.date.compareTo(b.date);
          if (dateCompare != 0) return dateCompare;
          return a.startTime.compareTo(b.startTime);
        });
        return lessons;
      });
    }
  }

  // Stream lessons theo ngày với real-time updates
  static Stream<List<Lesson>> getLessonsStreamByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _firestore
        .collection('lessons')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream leave requests theo teacher ID với real-time updates (từ cả 2 collection)
  static Stream<List<LeaveRequest>> getLeaveRequestsStreamByTeacher(String teacherId) {
    return LeaveRequestService.getLeaveRequestsStreamByTeacher(teacherId);
  }

  // Stream tất cả lessons với real-time updates
  static Stream<List<Lesson>> getAllLessonsStream() {
    return _firestore
        .collection('lessons')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream tất cả leave requests với real-time updates (từ cả 2 collection)
  static Stream<List<LeaveRequest>> getAllLeaveRequestsStream() {
    return _firestore
        .collection('leaveRequests')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => LeaveRequest.fromMap(d.data() as Map<String, dynamic>, d.id))
            .toList());
  }
}




