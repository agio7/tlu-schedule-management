import 'package:flutter/material.dart';
import '../../../scripts/test_schedule_generation.dart';

class ScheduleTestScreen extends StatefulWidget {
  const ScheduleTestScreen({super.key});

  @override
  State<ScheduleTestScreen> createState() => _ScheduleTestScreenState();
}

class _ScheduleTestScreenState extends State<ScheduleTestScreen> {
  bool _isLoading = false;
  String _log = '';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
      _log = _logs.join('\n');
    });
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _log = '';
    });
  }

  Future<void> _runTest() async {
    setState(() {
      _isLoading = true;
    });

    _addLog('🧪 Bắt đầu test sinh lịch tự động...');

    try {
      await TestScheduleGeneration.runTest();
      _addLog('✅ Test hoàn thành thành công!');
    } catch (e) {
      _addLog('❌ Test thất bại: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cleanup() async {
    setState(() {
      _isLoading = true;
    });

    _addLog('🧹 Dọn dẹp dữ liệu test...');

    try {
      await TestScheduleGeneration.cleanup();
      _addLog('✅ Đã dọn dẹp xong');
    } catch (e) {
      _addLog('❌ Lỗi dọn dẹp: $e');
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
        title: const Text('Test Sinh Lịch Tự Động'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Quy Trình Sinh Lịch Tự Động',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Quy trình này sẽ test việc sinh lịch tự động từ CourseSections thành Schedules',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _runTest,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Chạy Test'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _cleanup,
                            icon: const Icon(Icons.cleaning_services),
                            label: const Text('Dọn Dẹp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _clearLogs,
                          icon: const Icon(Icons.clear),
                          label: const Text('Xóa Log'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Logs
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.terminal, color: Color(0xFF1976D2)),
                          const SizedBox(width: 8),
                          const Text(
                            'Logs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _log.isEmpty ? 'Chưa có logs...' : _log,
                              style: const TextStyle(
                                color: Colors.green,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
