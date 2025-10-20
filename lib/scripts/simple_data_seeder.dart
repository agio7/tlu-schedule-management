import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Script đơn giản để tạo dữ liệu mẫu với ID ngắn
class SimpleDataSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Tạo dữ liệu mẫu đơn giản
  static Future<void> createSampleData() async {
    try {
      print('🚀 Bắt đầu tạo dữ liệu mẫu...');
      
      // Tạo leave request với ID ngắn
      final docRef = await _firestore.collection('leaveRequests').add({
        'teacherId': 'teacher1@tlu.edu.vn',
        'scheduleId': 'schedule_001',
        'reason': 'Nghỉ ốm',
        'attachments': [],
        'status': 'pending',
        'requestDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✅ Đã tạo leaveRequest với ID: ${docRef.id}');
      
      // Tạo thêm một vài requests khác
      await _firestore.collection('leaveRequests').add({
        'teacherId': 'teacher2@tlu.edu.vn',
        'scheduleId': 'schedule_002',
        'reason': 'Họp khoa',
        'attachments': [],
        'status': 'approved',
        'requestDate': FieldValue.serverTimestamp(),
        'approvedDate': FieldValue.serverTimestamp(),
        'approverNotes': 'Đã duyệt bởi admin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      await _firestore.collection('leaveRequests').add({
        'teacherId': 'teacher1@tlu.edu.vn',
        'scheduleId': 'schedule_003',
        'reason': 'Công tác',
        'attachments': [],
        'status': 'rejected',
        'requestDate': FieldValue.serverTimestamp(),
        'approverNotes': 'Lịch bù trùng với lịch khác',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('🎉 Hoàn thành tạo dữ liệu mẫu!');
    } catch (e) {
      print('❌ Lỗi khi tạo dữ liệu mẫu: $e');
    }
  }
}

// Hàm main để chạy script
Future<void> main() async {
  await SimpleDataSeeder.initializeFirebase();
  await SimpleDataSeeder.createSampleData();
}

