import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Script để cập nhật departmentId cho user trong Firestore
/// 
/// Sử dụng:
/// 1. Chạy script này từ terminal: `dart run lib/scripts/fix_user_department.dart`
/// 2. Hoặc gọi từ app: import và gọi hàm `fixDepartmentForUser()`
Future<void> main() async {
  try {
    // Khởi tạo Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print('🔧 Bắt đầu cập nhật departmentId cho user...');
    
    // Email của user cần cập nhật
    const userEmail = 'department@tlu.edu.vn';
    
    // Cập nhật departmentId cho user
    await fixDepartmentForUser(userEmail);
    
    print('✅ Hoàn thành!');
  } catch (e) {
    print('❌ Lỗi: $e');
  }
}

/// Cập nhật departmentId cho user theo email
/// Nếu không tìm thấy department, sẽ tạo department mới
Future<void> fixDepartmentForUser(String email) async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    // Bước 1: Tìm user theo email
    print('🔍 Đang tìm user với email: $email...');
    final userQuery = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    if (userQuery.docs.isEmpty) {
      print('❌ Không tìm thấy user với email: $email');
      return;
    }
    
    final userDoc = userQuery.docs.first;
    final userId = userDoc.id;
    final userData = userDoc.data();
    
    print('✅ Tìm thấy user: ${userData['fullName']} (ID: $userId)');
    
    // Kiểm tra xem user đã có departmentId chưa
    if (userData['departmentId'] != null) {
      print('ℹ️ User đã có departmentId: ${userData['departmentId']}');
      return;
    }
    
    // Bước 2: Tìm hoặc tạo department
    print('🔍 Đang tìm department...');
    String? departmentId;
    
    // Thử tìm department đầu tiên
    final departmentsQuery = await firestore
        .collection('departments')
        .limit(1)
        .get();
    
    if (departmentsQuery.docs.isNotEmpty) {
      departmentId = departmentsQuery.docs.first.id;
      print('✅ Tìm thấy department: $departmentId');
    } else {
      // Tạo department mới nếu chưa có
      print('⚠️ Chưa có department nào. Đang tạo department mới...');
      final newDeptRef = await firestore.collection('departments').add({
        'name': 'Khoa Công nghệ Thông tin',
        'code': 'CNTT',
        'headId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      departmentId = newDeptRef.id;
      print('✅ Đã tạo department mới: $departmentId');
    }
    
    // Bước 3: Cập nhật user với departmentId
    print('🔧 Đang cập nhật user với departmentId: $departmentId...');
    await firestore.collection('users').doc(userId).update({
      'departmentId': departmentId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print('✅ Đã cập nhật user thành công!');
    print('   - User ID: $userId');
    print('   - Email: $email');
    print('   - Department ID: $departmentId');
    
    // Bước 4: Cập nhật department với headId nếu role là department_head
    if (userData['role'] == 'department_head') {
      print('🔧 Đang cập nhật department với headId...');
      await firestore.collection('departments').doc(departmentId).update({
        'headId': userId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Đã cập nhật department với headId: $userId');
    }
    
  } catch (e, stackTrace) {
    print('❌ Lỗi khi cập nhật user: $e');
    print('❌ Stack trace: $stackTrace');
    rethrow;
  }
}

/// Cập nhật departmentId cho tất cả users chưa có departmentId
Future<void> fixAllUsersWithoutDepartment() async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    print('🔍 Đang tìm tất cả users chưa có departmentId...');
    
    // Lấy tất cả users
    final usersQuery = await firestore.collection('users').get();
    final usersWithoutDept = usersQuery.docs
        .where((doc) => doc.data()['departmentId'] == null)
        .toList();
    
    if (usersWithoutDept.isEmpty) {
      print('✅ Tất cả users đã có departmentId!');
      return;
    }
    
    print('⚠️ Tìm thấy ${usersWithoutDept.length} users chưa có departmentId');
    
    // Lấy department đầu tiên
    final departmentsQuery = await firestore
        .collection('departments')
        .limit(1)
        .get();
    
    if (departmentsQuery.docs.isEmpty) {
      print('❌ Chưa có department nào trong Firestore!');
      return;
    }
    
    final departmentId = departmentsQuery.docs.first.id;
    print('✅ Sử dụng department: $departmentId');
    
    // Cập nhật từng user
    for (final userDoc in usersWithoutDept) {
      final userData = userDoc.data();
      print('🔧 Đang cập nhật user: ${userData['email']}...');
      
      await firestore.collection('users').doc(userDoc.id).update({
        'departmentId': departmentId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Đã cập nhật user: ${userData['email']}');
    }
    
    print('✅ Đã cập nhật tất cả users thành công!');
    
  } catch (e, stackTrace) {
    print('❌ Lỗi khi cập nhật users: $e');
    print('❌ Stack trace: $stackTrace');
    rethrow;
  }
}

