import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'leave_request_screen.dart';

class SessionDetailScreen extends StatelessWidget {
  final String subject;
  final String className;
  final String room;
  final String timeRange;
  final DateTime date;

  const SessionDetailScreen({super.key, required this.subject, required this.className, required this.room, required this.timeRange, required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết buổi học'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('$className • Phòng $room'),
                  const SizedBox(height: 4),
                  Text('${_formatDate(date)} • $timeRange'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tác vụ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
          ),
          const SizedBox(height: 8),
          _ActionButton(
            icon: Icons.note_add_outlined,
            label: 'Nhập nội dung buổi học',
            onPressed: () => _openContentSheet(context),
          ),
          _ActionButton(
            icon: Icons.how_to_reg,
            label: 'Điểm danh sinh viên',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen())),
          ),
          _ActionButton(
            icon: Icons.event_busy,
            label: 'Nghỉ dạy / Dạy bù',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveRequestScreen())),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _openContentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final controller = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nội dung buổi học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Nhập nội dung giảng dạy, bài tập, ghi chú...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu nội dung buổi học')));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), foregroundColor: Colors.white),
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: Icon(icon, color: const Color(0xFF1976D2)),
          label: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(label),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}



