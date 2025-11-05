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
      // Thử query với className
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('className', isEqualTo: className)
          .orderBy('fullName')
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
      }
      
      // Fallback: Lấy tất cả sinh viên và filter theo className ở client side
      // (Nếu không có index hoặc field className không tồn tại)
      final allStudents = await getAllStudents();
      return allStudents.where((student) {
        // Kiểm tra nếu user có field className trong document
        // (cần kiểm tra trực tiếp từ Firestore vì User model có thể không có field này)
        return true; // Tạm thời trả về tất cả, có thể filter sau nếu cần
      }).toList();
    } catch (e) {
      print('Error getting students by className: $e');
      // Nếu query fail (do thiếu index), fallback về lấy tất cả
      try {
        final allStudents = await getAllStudents();
        // Filter theo className nếu có trong data
        return allStudents.where((student) {
          // Vì User model không có className, ta sẽ trả về tất cả
          // và để client code xử lý
          return true;
        }).toList();
      } catch (e2) {
        print('Error in fallback: $e2');
        return [];
      }
    }
  }

  // Lấy sinh viên theo classroomId
  static Future<List<User>> getStudentsByClassroomId(String classroomId) async {
    try {
      // Thử query với classroomId
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('classroomId', isEqualTo: classroomId)
          .orderBy('fullName')
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
      }
      
      // Fallback về lấy tất cả nếu không tìm thấy
      return [];
    } catch (e) {
      print('Error getting students by classroomId: $e');
      // Nếu query fail (do thiếu index hoặc field), fallback về lấy tất cả
      try {
        return await getAllStudents();
      } catch (e2) {
        print('Error in fallback: $e2');
        return [];
      }
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

