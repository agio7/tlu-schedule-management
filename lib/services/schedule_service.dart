import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedules.dart';
import 'firebase_service.dart';

class ScheduleService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả schedules
  static Stream<List<Schedules>> getSchedulesStream() {
    return _firestore.collection('schedules').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Schedules.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy schedules theo course section
  static Stream<List<Schedules>> getSchedulesByCourseSectionStream(String courseSectionId) {
    return _firestore
        .collection('schedules')
        .where('courseSectionId', isEqualTo: courseSectionId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Schedules.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy schedules theo status
  static Stream<List<Schedules>> getSchedulesByStatusStream(String status) {
    return _firestore
        .collection('schedules')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Schedules.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy schedules theo ngày
  static Stream<List<Schedules>> getSchedulesByDateStream(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _firestore
        .collection('schedules')
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Schedules.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm schedule mới
  static Future<String> addSchedule(Schedules schedule) async {
    final docRef = await _firestore.collection('schedules').add(schedule.toJson());
    return docRef.id;
  }

  // Cập nhật schedule
  static Future<void> updateSchedule(String scheduleId, Schedules schedule) async {
    await _firestore.collection('schedules').doc(scheduleId).update(schedule.toJson());
  }

  // Xóa schedule
  static Future<void> deleteSchedule(String scheduleId) async {
    await _firestore.collection('schedules').doc(scheduleId).delete();
  }

  // Lấy schedule theo ID
  static Future<Schedules?> getScheduleById(String scheduleId) async {
    final doc = await _firestore.collection('schedules').doc(scheduleId).get();
    if (doc.exists) {
      return Schedules.fromJson(doc.id, doc.data()!);
    }
    return null;
  }
}


