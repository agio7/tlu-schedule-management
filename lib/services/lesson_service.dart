import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lessons.dart';
import 'firebase_service.dart';

class LessonService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  static Stream<List<Lessons>> getLessonsStream() {
    return _firestore.collection('lessons').snapshots().map((snapshot) {
      return snapshot.docs.map((d) => Lessons.fromJson(d.id, d.data())).toList();
    });
  }

  static Future<Lessons?> getLessonById(String id) async {
    final doc = await _firestore.collection('lessons').doc(id).get();
    if (doc.exists) return Lessons.fromJson(doc.id, doc.data()!);
    return null;
  }
}


