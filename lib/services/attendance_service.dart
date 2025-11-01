import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance.dart';
import 'firebase_service.dart';

class AttendanceService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả attendance
  static Stream<List<Attendance>> getAttendanceStream() {
    return _firestore.collection('attendance').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Attendance.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy attendance theo schedule
  static Stream<List<Attendance>> getAttendanceByScheduleStream(String scheduleId) {
    return _firestore
        .collection('attendance')
        .where('scheduleId', isEqualTo: scheduleId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Attendance.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy attendance theo student
  static Stream<List<Attendance>> getAttendanceByStudentStream(String studentId) {
    return _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Attendance.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy attendance theo status
  static Stream<List<Attendance>> getAttendanceByStatusStream(String status) {
    return _firestore
        .collection('attendance')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Attendance.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm attendance mới
  static Future<String> addAttendance(Attendance attendance) async {
    final docRef = await _firestore.collection('attendance').add(attendance.toJson());
    return docRef.id;
  }

  // Cập nhật attendance
  static Future<void> updateAttendance(String attendanceId, Attendance attendance) async {
    await _firestore.collection('attendance').doc(attendanceId).update(attendance.toJson());
  }

  // Xóa attendance
  static Future<void> deleteAttendance(String attendanceId) async {
    await _firestore.collection('attendance').doc(attendanceId).delete();
  }

  // Lấy attendance theo ID
  static Future<Attendance?> getAttendanceById(String attendanceId) async {
    final doc = await _firestore.collection('attendance').doc(attendanceId).get();
    if (doc.exists) {
      return Attendance.fromJson(doc.id, doc.data()!);
    }
    return null;
  }

  // Lấy attendance theo schedule và student
  static Future<Attendance?> getAttendanceByScheduleAndStudent(String scheduleId, String studentId) async {
    final query = await _firestore
        .collection('attendance')
        .where('scheduleId', isEqualTo: scheduleId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return Attendance.fromJson(doc.id, doc.data());
    }
    return null;
  }
}


