import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_sections.dart';
import 'firebase_service.dart';

class CourseSectionService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả course sections
  static Stream<List<CourseSections>> getCourseSectionsStream() {
    return _firestore.collection('courseSections').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CourseSections.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy course sections theo teacher
  static Stream<List<CourseSections>> getCourseSectionsByTeacherStream(String teacherId) {
    return _firestore
        .collection('courseSections')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CourseSections.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy course sections theo semester
  static Stream<List<CourseSections>> getCourseSectionsBySemesterStream(String semesterId) {
    return _firestore
        .collection('courseSections')
        .where('semesterId', isEqualTo: semesterId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CourseSections.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy course sections theo subject
  static Stream<List<CourseSections>> getCourseSectionsBySubjectStream(String subjectId) {
    return _firestore
        .collection('courseSections')
        .where('subjectId', isEqualTo: subjectId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CourseSections.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm course section mới
  static Future<String> addCourseSection(CourseSections courseSection) async {
    final docRef = await _firestore.collection('courseSections').add(courseSection.toJson());
    return docRef.id;
  }

  // Cập nhật course section
  static Future<void> updateCourseSection(String courseSectionId, CourseSections courseSection) async {
    await _firestore.collection('courseSections').doc(courseSectionId).update(courseSection.toJson());
  }

  // Xóa course section
  static Future<void> deleteCourseSection(String courseSectionId) async {
    await _firestore.collection('courseSections').doc(courseSectionId).delete();
  }

  // Lấy course section theo ID
  static Future<CourseSections?> getCourseSectionById(String courseSectionId) async {
    final doc = await _firestore.collection('courseSections').doc(courseSectionId).get();
    if (doc.exists) {
      return CourseSections.fromJson(doc.id, doc.data()!);
    }
    return null;
  }
}


