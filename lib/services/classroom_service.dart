import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/classroom.dart';
import 'firebase_service.dart';

class ClassroomService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy danh sách tất cả lớp học
  static Stream<List<Classroom>> getClassroomsStream() {
    print('🏫 ClassroomService: Lấy stream classrooms...');
    return _firestore
        .collection('classrooms')
        .snapshots()
        .map((snapshot) {
      print('🏫 ClassroomService: Nhận được ${snapshot.docs.length} classrooms');
      return snapshot.docs.map((doc) {
        return Classroom.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
    });
  }

  // Lấy lớp học theo ID
  static Future<Classroom?> getClassroomById(String classroomId) async {
    try {
      print('🏫 ClassroomService: Lấy classroom $classroomId...');
      final doc = await _firestore.collection('classrooms').doc(classroomId).get();
      if (doc.exists) {
        return Classroom.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      print('❌ ClassroomService: Lỗi khi lấy classroom: $e');
      rethrow;
    }
  }

  // Thêm lớp học mới
  static Future<String> addClassroom(Classroom classroom) async {
    try {
      print('🏫 ClassroomService: Thêm classroom mới...');
      final docRef = await _firestore.collection('classrooms').add({
        'name': classroom.name,
        'code': classroom.code,
        'departmentId': classroom.departmentId,
        'studentCount': classroom.studentCount,
        'academicYear': classroom.academicYear,
        'semester': classroom.semester,
        'description': classroom.description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ ClassroomService: Đã thêm classroom với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ ClassroomService: Lỗi khi thêm classroom: $e');
      rethrow;
    }
  }

  // Cập nhật lớp học
  static Future<void> updateClassroom(String classroomId, Classroom classroom) async {
    try {
      print('🏫 ClassroomService: Cập nhật classroom $classroomId...');
      await _firestore.collection('classrooms').doc(classroomId).update({
        'name': classroom.name,
        'code': classroom.code,
        'departmentId': classroom.departmentId,
        'studentCount': classroom.studentCount,
        'academicYear': classroom.academicYear,
        'semester': classroom.semester,
        'description': classroom.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ ClassroomService: Đã cập nhật classroom $classroomId');
    } catch (e) {
      print('❌ ClassroomService: Lỗi khi cập nhật classroom: $e');
      rethrow;
    }
  }

  // Xóa lớp học
  static Future<void> deleteClassroom(String classroomId) async {
    try {
      print('🏫 ClassroomService: Xóa classroom $classroomId...');
      await _firestore.collection('classrooms').doc(classroomId).delete();
      print('✅ ClassroomService: Đã xóa classroom $classroomId');
    } catch (e) {
      print('❌ ClassroomService: Lỗi khi xóa classroom: $e');
      rethrow;
    }
  }

  // Tìm kiếm lớp học
  static Stream<List<Classroom>> searchClassrooms(String query) {
    print('🏫 ClassroomService: Tìm kiếm classrooms với query: $query');
    return _firestore
        .collection('classrooms')
        .snapshots()
        .map((snapshot) {
      final classrooms = snapshot.docs.map((doc) {
        return Classroom.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
      
      if (query.isEmpty) {
        return classrooms;
      }
      
      return classrooms.where((classroom) {
        return classroom.name.toLowerCase().contains(query.toLowerCase()) ||
               classroom.code.toLowerCase().contains(query.toLowerCase()) ||
               (classroom.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }
}

