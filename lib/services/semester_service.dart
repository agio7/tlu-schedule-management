import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/semesters.dart';
import 'firebase_service.dart';

class SemesterService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả semesters
  static Stream<List<Semesters>> getSemestersStream() {
    return _firestore.collection('semesters').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Semesters.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy semester hiện tại
  static Future<Semesters?> getCurrentSemester() async {
    final now = DateTime.now();
    final query = await _firestore
        .collection('semesters')
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return Semesters.fromJson(doc.id, doc.data());
    }
    return null;
  }

  // Thêm semester mới
  static Future<String> addSemester(Semesters semester) async {
    final docRef = await _firestore.collection('semesters').add(semester.toJson());
    return docRef.id;
  }

  // Cập nhật semester
  static Future<void> updateSemester(String semesterId, Semesters semester) async {
    await _firestore.collection('semesters').doc(semesterId).update(semester.toJson());
  }

  // Xóa semester
  static Future<void> deleteSemester(String semesterId) async {
    await _firestore.collection('semesters').doc(semesterId).delete();
  }

  // Lấy semester theo ID
  static Future<Semesters?> getSemesterById(String semesterId) async {
    final doc = await _firestore.collection('semesters').doc(semesterId).get();
    if (doc.exists) {
      return Semesters.fromJson(doc.id, doc.data()!);
    }
    return null;
  }
}


