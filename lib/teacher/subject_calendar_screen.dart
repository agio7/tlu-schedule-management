import 'package:flutter/material.dart';
import 'session_detail_screen.dart';

class SubjectCalendarScreen extends StatefulWidget {
  const SubjectCalendarScreen({super.key});

  @override
  State<SubjectCalendarScreen> createState() => _SubjectCalendarScreenState();
}

class _SubjectCalendarScreenState extends State<SubjectCalendarScreen> {
  String? selectedSubject = 'Lập trình Java';

  @override
  Widget build(BuildContext context) {
    final subjects = const ['Lập trình Java', 'Cơ sở dữ liệu', 'Mạng máy tính', 'Flutter'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch theo môn'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: const InputDecoration(
                labelText: 'Chọn môn học',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book),
              ),
              items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => selectedSubject = v),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 8,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index * 2));
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.event_note, color: Color(0xFF1976D2)),
                    title: Text('$selectedSubject - Tuần ${index + 1}'),
                    subtitle: Text('${_formatDate(date)} • 08:00 - 10:00 • P.101'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionDetailScreen(
                          subject: selectedSubject ?? 'Môn học',
                          className: 'CNTT0${(index % 3) + 1}',
                          room: 'P.101',
                          timeRange: '08:00 - 10:00',
                          date: date,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}



