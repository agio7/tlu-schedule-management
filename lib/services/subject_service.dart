import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subject.dart';
import 'firebase_service.dart';

class SubjectService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy danh sách tất cả môn học
  static Stream<List<Subject>> getSubjectsStream() {
    print('📚 SubjectService: Lấy stream subjects...');
    return _firestore
        .collection('subjects')
        .snapshots()
        .map((snapshot) {
      print('📚 SubjectService: Nhận được ${snapshot.docs.length} subjects');
      return snapshot.docs.map((doc) {
        return Subject.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
    });
  }

  // Lấy môn học theo ID
  static Future<Subject?> getSubjectById(String subjectId) async {
    try {
      print('📚 SubjectService: Lấy subject $subjectId...');
      final doc = await _firestore.collection('subjects').doc(subjectId).get();
      if (doc.exists) {
        return Subject.fromJson(doc.data()!..['id'] = doc.id);
      }
      return null;
    } catch (e) {
      print('❌ SubjectService: Lỗi khi lấy subject: $e');
      rethrow;
    }
  }

  // Thêm môn học mới
  static Future<String> addSubject(Subject subject) async {
    try {
      print('📚 SubjectService: Thêm subject mới...');
      final docRef = await _firestore.collection('subjects').add({
        'name': subject.name,
        'code': subject.code,
        'credits': subject.credits,
        'departmentId': subject.departmentId,
        'description': subject.description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ SubjectService: Đã thêm subject với ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ SubjectService: Lỗi khi thêm subject: $e');
      rethrow;
    }
  }

  // Cập nhật môn học
  static Future<void> updateSubject(String subjectId, Subject subject) async {
    try {
      print('📚 SubjectService: Cập nhật subject $subjectId...');
      await _firestore.collection('subjects').doc(subjectId).update({
        'name': subject.name,
        'code': subject.code,
        'credits': subject.credits,
        'departmentId': subject.departmentId,
        'description': subject.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ SubjectService: Đã cập nhật subject $subjectId');
    } catch (e) {
      print('❌ SubjectService: Lỗi khi cập nhật subject: $e');
      rethrow;
    }
  }

  // Xóa môn học
  static Future<void> deleteSubject(String subjectId) async {
    try {
      print('📚 SubjectService: Xóa subject $subjectId...');
      await _firestore.collection('subjects').doc(subjectId).delete();
      print('✅ SubjectService: Đã xóa subject $subjectId');
    } catch (e) {
      print('❌ SubjectService: Lỗi khi xóa subject: $e');
      rethrow;
    }
  }

  // Tìm kiếm môn học
  static Stream<List<Subject>> searchSubjects(String query) {
    print('📚 SubjectService: Tìm kiếm subjects với query: $query');
    return _firestore
        .collection('subjects')
        .snapshots()
        .map((snapshot) {
      final subjects = snapshot.docs.map((doc) {
        return Subject.fromJson(doc.data()..['id'] = doc.id);
      }).toList();
      
      if (query.isEmpty) {
        return subjects;
      }
      
      return subjects.where((subject) {
        return subject.name.toLowerCase().contains(query.toLowerCase()) ||
               subject.code.toLowerCase().contains(query.toLowerCase()) ||
               (subject.description?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }
}

