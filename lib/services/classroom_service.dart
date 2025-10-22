import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classrooms.dart';
import 'firebase_service.dart';

class ClassroomService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả classrooms
  static Stream<List<Classrooms>> getClassroomsStream() {
    return _firestore.collection('classrooms').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Classrooms.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy classrooms theo department
  static Stream<List<Classrooms>> getClassroomsByDepartmentStream(String departmentId) {
    return _firestore
        .collection('classrooms')
        .where('departmentId', isEqualTo: departmentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Classrooms.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy classrooms theo academic year
  static Stream<List<Classrooms>> getClassroomsByAcademicYearStream(String academicYear) {
    return _firestore
        .collection('classrooms')
        .where('academicYear', isEqualTo: academicYear)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Classrooms.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm classroom mới
  static Future<String> addClassroom(Classrooms classroom) async {
    final docRef = await _firestore.collection('classrooms').add(classroom.toJson());
    return docRef.id;
  }

  // Cập nhật classroom
  static Future<void> updateClassroom(String classroomId, Classrooms classroom) async {
    await _firestore.collection('classrooms').doc(classroomId).update(classroom.toJson());
  }

  // Xóa classroom
  static Future<void> deleteClassroom(String classroomId) async {
    await _firestore.collection('classrooms').doc(classroomId).delete();
  }

  // Lấy classroom theo ID
  static Future<Classrooms?> getClassroomById(String classroomId) async {
    final doc = await _firestore.collection('classrooms').doc(classroomId).get();
    if (doc.exists) {
      return Classrooms.fromJson(doc.id, doc.data()!);
    }
    return null;
  }
}


