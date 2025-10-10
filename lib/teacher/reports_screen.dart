import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo giảng dạy'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatCard(title: 'Giờ giảng tháng này', value: '36 giờ'),
          _StatCard(title: 'Số buổi đã dạy', value: '12'),
          _StatCard(title: 'Số buổi nghỉ', value: '2'),
          _StatCard(title: 'Số buổi dạy bù', value: '1'),
          const SizedBox(height: 8),
          const Text('Chi tiết theo môn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...[
            {'subject': 'Lập trình Java', 'hours': '12h', 'sessions': 6},
            {'subject': 'Cơ sở dữ liệu', 'hours': '10h', 'sessions': 5},
            {'subject': 'Mạng máy tính', 'hours': '14h', 'sessions': 7},
          ].map((e) => Card(
            child: ListTile(
              leading: const Icon(Icons.book, color: Color(0xFF1976D2)),
              title: Text(e['subject'] as String),
              subtitle: Text('Số buổi: ${e['sessions']} • Giờ: ${e['hours']}'),
            ),
          )),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}



