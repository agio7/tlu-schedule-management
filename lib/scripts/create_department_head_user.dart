import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../firebase_options.dart';

class CreateDepartmentHeadUser {
  static Future<void> createDepartmentHead() async {
    print('🚀 Tạo tài khoản Trưởng Bộ Môn...');

    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully.');

      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      const email = 'truongkhoa@tlu.edu.vn';
      const password = 'admin123'; // Mật khẩu mặc định

      // 1. Tạo user trong Firebase Auth
      print('👤 Tạo user trong Firebase Auth...');
      UserCredential? userCredential;
      
      try {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        print('✅ Đã tạo user trong Firebase Auth: ${userCredential.user!.uid}');
      } catch (e) {
        if (e.toString().contains('email-already-in-use')) {
          print('⚠️ User đã tồn tại trong Firebase Auth');
          // Thử đăng nhập để lấy UID
          try {
            userCredential = await auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            print('✅ Đã tìm thấy user: ${userCredential.user!.uid}');
          } catch (signInError) {
            print('❌ Sai mật khẩu hoặc user không tồn tại');
            print('💡 Vui lòng tạo user thủ công trong Firebase Console');
            return;
          }
        } else {
          print('❌ Technician: $e');
          return;
        }
      }

      // 2. Tạo user document trong Firestore
      if (userCredential.user != null) {
        print('📄 Tạo user document trong Firestore...');
        await firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'fullName': 'Trần Văn Trưởng Khoa',
          'role': 'department_head',
          'departmentId': 'dept_001',
          'employeeId': 'EMP002',
          'academicRank': 'Giáo sư',
          'avatar': '',
          'specialization': 'Quản lý bộ môn',
          'phoneNumber': '0123456788',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print('✅ Đã tạo user document trong Firestore');

        print('\n🎉 Hoàn thành! Tài khoản Trưởng Bộ Môn:');
        print('   📧 Email: $email');
        print('   🔑 Mật khẩu: $password');
        print('   🆔 UID: ${userCredential.user!.uid}');
        print('   👤 Role: department_head');
      }

    } catch (e) {
      print('❌ Lỗi: $e');
    }
  }
}

void main() async {
  await CreateDepartmentHeadUser.createDepartmentHead();
  exit(0);
}




