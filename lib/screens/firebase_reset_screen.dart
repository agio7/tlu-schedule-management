import 'package:flutter/material.dart';
import '../scripts/firebase_reset_and_setup.dart';
import '../scripts/auto_setup_admin.dart';

class FirebaseResetScreen extends StatefulWidget {
  const FirebaseResetScreen({super.key});

  @override
  State<FirebaseResetScreen> createState() => _FirebaseResetScreenState();
}

class _FirebaseResetScreenState extends State<FirebaseResetScreen> {
  bool _isLoading = false;
  String _status = '';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _resetDatabase() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang reset database...';
      _logs.clear();
    });

    try {
      _addLog('🚀 Bắt đầu reset Firebase database...');
      
      await FirebaseResetAndSetup.resetAndSetupNewDatabase();
      
      _addLog('✅ Hoàn thành reset database!');
      setState(() {
        _status = 'Reset thành công!';
      });
      
      // Hiển thị dialog thành công
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Thành công'),
            content: const Text('Database đã được reset và tạo lại với schema mới!'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Lỗi: $e');
      setState(() {
        _status = 'Lỗi: $e';
      });
      
      // Hiển thị dialog lỗi với hướng dẫn
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('❌ Lỗi'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Có lỗi xảy ra: $e'),
                  const SizedBox(height: 16),
                  const Text(
                    '💡 HƯỚNG DẪN SỬA LỖI:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Vào Firebase Console: https://console.firebase.google.com'),
                  const Text('2. Chọn project của bạn'),
                  const Text('3. Vào Firestore Database > Rules'),
                  const Text('4. Thay thế rules bằng:'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'rules_version = \'2\';\nservice cloud.firestore {\n  match /databases/{database}/documents {\n    match /{document=**} {\n      allow read, write: if request.auth != null;\n    }\n  }\n}',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                  const Text('5. Nhấn "Publish"'),
                  const Text('6. Chạy lại reset database'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createAdminUser() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang tạo admin user...';
      _logs.clear();
    });

    try {
      _addLog('👤 Bắt đầu tạo admin user...');
      
      await AutoSetupAdmin.createAdminUser();
      
      _addLog('✅ Hoàn thành tạo admin user!');
      setState(() {
        _status = 'Tạo admin user thành công!';
      });
      
      // Hiển thị dialog thành công
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('✅ Thành công'),
            content: const Text('Admin user đã được tạo thành công!\n\nEmail: admin@tlu.edu.vn\nPassword: admin123'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _addLog('❌ Lỗi: $e');
      setState(() {
        _status = 'Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Database Reset'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Card
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'CẢNH BÁO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thao tác này sẽ XÓA TẤT CẢ dữ liệu cũ trong Firebase và tạo lại với schema mới. '
                      'Hãy đảm bảo bạn đã backup dữ liệu quan trọng trước khi tiếp tục.',
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status
            Text(
              'Trạng thái: $_status',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Buttons Row
            Row(
              children: [
                // Reset Database Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetDatabase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 16),
                              Text('Đang xử lý...'),
                            ],
                          )
                        : const Text(
                            'RESET DATABASE',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Auto Create Admin Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAdminUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 16),
                              Text('Đang xử lý...'),
                            ],
                          )
                        : const Text(
                            'AUTO CREATE ADMIN',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Logs
            if (_logs.isNotEmpty) ...[
              const Text(
                'Logs:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListView.builder(
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          _logs[index],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
