import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher.dart';
import 'firebase_service.dart';

class TeacherService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy danh sách tất cả giảng viên
  static Stream<List<Teacher>> getTeachersStream() {
    print('👨‍🏫 TeacherService: Lấy stream teachers...');
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) {
      print('👨‍🏫 TeacherService: Nhận được ${snapshot.docs.length} teachers');
      return snapshot.docs.map((doc) {
        return Teacher.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  // Lấy giảng viên theo ID
  static Future<Teacher?> getTeacherById(String teacherId) async {
    try {
      print('👨‍🏫 TeacherService: Lấy teacher $teacherId...');
      final doc = await _firestore.collection('users').doc(teacherId).get();
      if (doc.exists) {
        return Teacher.fromJson(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ TeacherService: Lỗi khi lấy teacher: $e');
      rethrow;
    }
  }

  // Thêm giảng viên mới
  static Future<String> addTeacher(Teacher teacher) async {
    try {
      print('👨‍🏫 TeacherService: Thêm teacher mới...');
      final docRef = await _firestore.collection('users').add({
        'email': teacher.email,
        'fullName': teacher.fullName,
        'role': 'teacher',
        'departmentId': teacher.departmentId,
        'phoneNumber': teacher.phoneNumber,
        'avatar': teacher.avatar,
        'employeeId': teacher.employeeId,
        'specialization': teacher.specialization,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ TeacherService: Đã thêm teacher với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ TeacherService: Lỗi khi thêm teacher: $e');
      rethrow;
    }
  }

  // Cập nhật giảng viên
  static Future<void> updateTeacher(String teacherId, Teacher teacher) async {
    try {
      print('👨‍🏫 TeacherService: Cập nhật teacher $teacherId...');
      await _firestore.collection('users').doc(teacherId).update({
        'email': teacher.email,
        'fullName': teacher.fullName,
        'departmentId': teacher.departmentId,
        'phoneNumber': teacher.phoneNumber,
        'avatar': teacher.avatar,
        'employeeId': teacher.employeeId,
        'specialization': teacher.specialization,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ TeacherService: Đã cập nhật teacher $teacherId');
    } catch (e) {
      print('❌ TeacherService: Lỗi khi cập nhật teacher: $e');
      rethrow;
    }
  }

  // Xóa giảng viên
  static Future<void> deleteTeacher(String teacherId) async {
    try {
      print('👨‍🏫 TeacherService: Xóa teacher $teacherId...');
      await _firestore.collection('users').doc(teacherId).delete();
      print('✅ TeacherService: Đã xóa teacher $teacherId');
    } catch (e) {
      print('❌ TeacherService: Lỗi khi xóa teacher: $e');
      rethrow;
    }
  }

  // Tìm kiếm giảng viên
  static Stream<List<Teacher>> searchTeachers(String query) {
    print('👨‍🏫 TeacherService: Tìm kiếm teachers với query: $query');
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'teacher')
        .snapshots()
        .map((snapshot) {
      final teachers = snapshot.docs.map((doc) {
        return Teacher.fromJson(doc.id, doc.data());
      }).toList();
      
      if (query.isEmpty) {
        return teachers;
      }
      
      return teachers.where((teacher) {
        return teacher.fullName.toLowerCase().contains(query.toLowerCase()) ||
               teacher.email.toLowerCase().contains(query.toLowerCase()) ||
               (teacher.employeeId?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (teacher.specialization?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }
}

