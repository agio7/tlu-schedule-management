import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'firebase_service.dart';

class StudentService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả sinh viên
  static Future<List<User>> getAllStudents() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
      
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error getting all students: $e');
      return [];
    }
  }

  // Lấy sinh viên theo className
  static Future<List<User>> getStudentsByClassName(String className) async {
    try {
      // Query từ Firebase với className
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('className', isEqualTo: className)
          .orderBy('fullName')
          .get();
      
      // Chỉ trả về dữ liệu từ Firebase, không tạo thủ công
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error getting students by className: $e');
      // Nếu query fail, chỉ trả về empty list (không fallback)
      return [];
    }
  }

  // Lấy sinh viên theo classroomId
  static Future<List<User>> getStudentsByClassroomId(String classroomId) async {
    try {
      // Query từ Firebase với classroomId
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('classroomId', isEqualTo: classroomId)
          .orderBy('fullName')
          .get();
      
      // Chỉ trả về dữ liệu từ Firebase, không tạo thủ công
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error getting students by classroomId: $e');
      // Nếu query fail, chỉ trả về empty list (không fallback)
      return [];
    }
  }

  // Stream sinh viên theo className (real-time updates)
  static Stream<List<User>> getStudentsStreamByClassName(String className) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('className', isEqualTo: className)
        .orderBy('fullName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Stream sinh viên theo classroomId (real-time updates)
  static Stream<List<User>> getStudentsStreamByClassroomId(String classroomId) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'student')
        .where('classroomId', isEqualTo: classroomId)
        .orderBy('fullName')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // Lấy sinh viên theo ID
  static Future<User?> getStudentById(String studentId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(studentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['role'] == 'student') {
          return User.fromJson(doc.id, data);
        }
      }
      return null;
    } catch (e) {
      print('Error getting student by ID: $e');
      return null;
    }
  }
}

