import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subjects.dart';
import 'firebase_service.dart';

class SubjectService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả subjects
  static Stream<List<Subjects>> getSubjectsStream() {
    return _firestore.collection('subjects').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Subjects.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy subjects theo department
  static Stream<List<Subjects>> getSubjectsByDepartmentStream(String departmentId) {
    return _firestore
        .collection('subjects')
        .where('departmentId', isEqualTo: departmentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Subjects.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm subject mới
  static Future<String> addSubject(Subjects subject) async {
    final docRef = await _firestore.collection('subjects').add(subject.toJson());
    return docRef.id;
  }

  // Cập nhật subject
  static Future<void> updateSubject(String subjectId, Subjects subject) async {
    await _firestore.collection('subjects').doc(subjectId).update(subject.toJson());
  }

  // Xóa subject
  static Future<void> deleteSubject(String subjectId) async {
    await _firestore.collection('subjects').doc(subjectId).delete();
  }

  // Lấy subject theo ID
  static Future<Subjects?> getSubjectById(String subjectId) async {
    final doc = await _firestore.collection('subjects').doc(subjectId).get();
    if (doc.exists) {
      return Subjects.fromJson(doc.id, doc.data()!);
    }
    return null;
  }
}


