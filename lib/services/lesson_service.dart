import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lesson.dart';
import 'firebase_service.dart';

class LessonService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy tất cả lessons
  static Future<List<Lesson>> getAllLessons() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('lessons').get();
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting lessons: $e');
      return [];
    }
  }

  // Lấy lessons theo teacher ID
  static Future<List<Lesson>> getLessonsByTeacher(String teacherId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('lessons')
          .where('teacherId', isEqualTo: teacherId)
          .get();
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting lessons by teacher: $e');
      return [];
    }
  }

  // Lấy lessons theo ngày
  static Future<List<Lesson>> getLessonsByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final QuerySnapshot snapshot = await _firestore
          .collection('lessons')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting lessons by date: $e');
      return [];
    }
  }

  // Lấy lessons theo teacher và ngày
  static Future<List<Lesson>> getLessonsByTeacherAndDate(String teacherId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final QuerySnapshot snapshot = await _firestore
          .collection('lessons')
          .where('teacherId', isEqualTo: teacherId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .get();
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting lessons by teacher and date: $e');
      return [];
    }
  }

  // Lấy lesson theo ID
  static Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('lessons').doc(lessonId).get();
      if (doc.exists) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting lesson by ID: $e');
      return null;
    }
  }

  // Tạo lesson mới
  static Future<String?> createLesson(Lesson lesson) async {
    try {
      final DocumentReference docRef = await _firestore.collection('lessons').add(lesson.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating lesson: $e');
      return null;
    }
  }

  // Cập nhật lesson
  static Future<bool> updateLesson(String lessonId, Lesson lesson) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).update(lesson.toMap());
      return true;
    } catch (e) {
      print('Error updating lesson: $e');
      return false;
    }
  }

  // Xóa lesson
  static Future<bool> deleteLesson(String lessonId) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).delete();
      return true;
    } catch (e) {
      print('Error deleting lesson: $e');
      return false;
    }
  }

  // Cập nhật nội dung lesson
  static Future<bool> updateLessonContent(String lessonId, String content) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).update({
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating lesson content: $e');
      return false;
    }
  }

  // Cập nhật danh sách điểm danh
  static Future<bool> updateAttendance(String lessonId, List<String> attendanceList) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).update({
        'attendanceList': attendanceList,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating attendance: $e');
      return false;
    }
  }

  // Đánh dấu lesson đã hoàn thành
  static Future<bool> markLessonCompleted(String lessonId) async {
    try {
      await _firestore.collection('lessons').doc(lessonId).update({
        'isCompleted': true,
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error marking lesson completed: $e');
      return false;
    }
  }

  // Stream lessons theo teacher (real-time updates)
  static Stream<List<Lesson>> getLessonsStreamByTeacher(String teacherId) {
    return _firestore
        .collection('lessons')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Stream lessons theo ngày (real-time updates)
  static Stream<List<Lesson>> getLessonsStreamByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _firestore
        .collection('lessons')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}