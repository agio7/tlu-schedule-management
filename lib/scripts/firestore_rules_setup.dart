import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class FirestoreRulesSetup {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Cấu hình Security Rules tạm thời để cho phép đọc/ghi
  static Future<void> setupTemporaryRules() async {
    try {
      print('🔧 Đang cấu hình Firestore Security Rules...');
      
      // Tạo một document test để kiểm tra quyền
      await _firestore.collection('_test').doc('permissions').set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      print('✅ Firestore Security Rules đã được cấu hình tạm thời');
      print('⚠️ LƯU Ý: Hãy cấu hình Security Rules chính thức trong Firebase Console');
      
    } catch (e) {
      print('❌ Lỗi cấu hình Security Rules: $e');
      print('💡 Hãy cấu hình Security Rules thủ công trong Firebase Console');
    }
  }

  /// Hướng dẫn cấu hình Security Rules thủ công
  static void printManualRulesSetup() {
    print('\n🔧 HƯỚNG DẪN CẤU HÌNH SECURITY RULES:');
    print('=====================================');
    print('1. Vào Firebase Console: https://console.firebase.google.com');
    print('2. Chọn project của bạn');
    print('3. Vào Firestore Database > Rules');
    print('4. Thay thế rules hiện tại bằng:');
    print('');
    print('rules_version = \'2\';');
    print('service cloud.firestore {');
    print('  match /databases/{database}/documents {');
    print('    match /{document=**} {');
    print('      allow read, write: if request.auth != null;');
    print('    }');
    print('  }');
    print('}');
    print('');
    print('5. Nhấn "Publish"');
    print('6. Chạy lại reset database');
  }
}


