import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/students.dart';
import 'firebase_service.dart';

class StudentService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả students
  static Stream<List<Students>> getStudentsStream() {
    return _firestore.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Students.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy students theo classroom
  static Stream<List<Students>> getStudentsByClassroomStream(String classroomId) {
    return _firestore
        .collection('students')
        .where('classroomId', isEqualTo: classroomId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Students.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm student mới
  static Future<String> addStudent(Students student) async {
    final docRef = await _firestore.collection('students').add(student.toJson());
    return docRef.id;
  }

  // Cập nhật student
  static Future<void> updateStudent(String studentId, Students student) async {
    await _firestore.collection('students').doc(studentId).update(student.toJson());
  }

  // Xóa student
  static Future<void> deleteStudent(String studentId) async {
    await _firestore.collection('students').doc(studentId).delete();
  }

  // Lấy student theo ID
  static Future<Students?> getStudentById(String studentId) async {
    final doc = await _firestore.collection('students').doc(studentId).get();
    if (doc.exists) {
      return Students.fromJson(doc.id, doc.data()!);
    }
    return null;
  }

  // Lấy student theo email
  static Future<Students?> getStudentByEmail(String email) async {
    final query = await _firestore
        .collection('students')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return Students.fromJson(doc.id, doc.data());
    }
    return null;
  }
}


