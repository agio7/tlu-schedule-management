import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class AutoSetupAdmin {
  static Future<void> createAdminUser() async {
    print('🚀 Tự động tạo admin user...');

    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      print('✅ Firebase initialized successfully.');

      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // 1. Kiểm tra user đã tồn tại chưa
      try {
        final existingUser = await auth.signInWithEmailAndPassword(
          email: 'admin@tlu.edu.vn',
          password: 'admin123',
        );
        if (existingUser.user != null) {
          print('✅ Admin user đã tồn tại');
          return;
        }
      } catch (e) {
        // User không tồn tại, tạo mới
        print('👤 Tạo admin user mới...');
      }

      // 2. Tạo user trong Firebase Auth
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: 'admin@tlu.edu.vn',
        password: 'admin123',
      );
      
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName('Admin System');
        print('✅ Đã tạo user trong Firebase Auth: ${userCredential.user!.uid}');

        // 3. Tạo user document trong Firestore
        print('📄 Tạo user document trong Firestore...');
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': 'admin@tlu.edu.vn',
          'fullName': 'Admin System',
          'role': 'admin',
          'departmentId': null,
          'employeeId': 'EMP001',
          'academicRank': 'Giáo sư',
          'avatar': null,
          'specialization': 'Quản trị hệ thống',
          'phoneNumber': '0123456789',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('✅ Đã tạo user document trong Firestore');

        print('🎉 Hoàn thành! Admin user đã được tạo:');
        print('   - Email: admin@tlu.edu.vn');
        print('   - Password: admin123');
        print('   - UID: ${userCredential.user!.uid}');
      } else {
        print('❌ Không thể tạo user');
      }

    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('✅ Admin user đã tồn tại');
      } else {
        print('❌ Lỗi: $e');
      }
    }
  }
}

void main() async {
  await AutoSetupAdmin.createAdminUser();
  exit(0);
}


