import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/users.dart';
import 'firebase_service.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Lấy tất cả users
  static Stream<List<Users>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Users.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy users theo role
  static Stream<List<Users>> getUsersByRoleStream(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Users.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Lấy users theo department
  static Stream<List<Users>> getUsersByDepartmentStream(String departmentId) {
    return _firestore
        .collection('users')
        .where('departmentId', isEqualTo: departmentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Users.fromJson(doc.id, doc.data())).toList();
    });
  }

  // Thêm user mới
  static Future<String> addUser(Users user) async {
    final docRef = await _firestore.collection('users').add(user.toJson());
    return docRef.id;
  }

  // Cập nhật user
  static Future<void> updateUser(String userId, Users user) async {
    await _firestore.collection('users').doc(userId).update(user.toJson());
  }

  // Xóa user
  static Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  // Lấy user theo ID
  static Future<Users?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return Users.fromJson(doc.id, doc.data()!);
    }
    return null;
  }

  // Lấy user theo email
  static Future<Users?> getUserByEmail(String email) async {
    final query = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      return Users.fromJson(doc.id, doc.data());
    }
    return null;
  }
}


