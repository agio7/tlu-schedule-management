import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/departments.dart';
import 'firebase_service.dart';

class DepartmentService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả departments
  static Stream<List<Departments>> getDepartmentsStream() {
    return _firestore.collection('departments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Departments.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm department mới
  static Future<String> addDepartment(Departments department) async {
    final docRef = await _firestore.collection('departments').add(department.toJson());
    return docRef.id;
  }

  // Cập nhật department
  static Future<void> updateDepartment(String departmentId, Departments department) async {
    await _firestore.collection('departments').doc(departmentId).update(department.toJson());
  }

  // Xóa department
  static Future<void> deleteDepartment(String departmentId) async {
    await _firestore.collection('departments').doc(departmentId).delete();
  }

  // Lấy department theo ID
  static Future<Departments?> getDepartmentById(String departmentId) async {
    final doc = await _firestore.collection('departments').doc(departmentId).get();
    if (doc.exists) {
      return Departments.fromJson(doc.id, doc.data()!);
    }
    return null;
  }
}


