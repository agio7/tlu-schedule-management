import 'package:cloud_firestore/cloud_firestore.dart';

class TestFirebase {
  static Future<bool> testConnection() async {
    try {
      // Test Firestore connection
      await FirebaseFirestore.instance.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test successful',
        'app_name': 'TLU Schedule Management',
      });
      
      print('✅ Firebase Firestore: Connected successfully');
      
      return true;
    } catch (e) {
      print('❌ Firebase connection failed: $e');
      return false;
    }
  }
  
  static Future<void> testWriteData() async {
    try {
      await FirebaseFirestore.instance.collection('test_data').add({
        'message': 'Hello from TLU Schedule Management!',
        'timestamp': FieldValue.serverTimestamp(),
        'app_version': '1.0.0',
        'test_successful': true,
      });
      print('✅ Test data written successfully');
    } catch (e) {
      print('❌ Failed to write test data: $e');
    }
  }
}
