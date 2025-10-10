import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _selectedClass = 'CNTT01';
  String _selectedSubject = 'Lập trình Java';
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _students = [
    {'id': '1', 'name': 'Nguyễn Văn An', 'studentId': '2021001', 'status': 'present'},
    {'id': '2', 'name': 'Trần Thị Bình', 'studentId': '2021002', 'status': 'present'},
    {'id': '3', 'name': 'Lê Văn Cường', 'studentId': '2021003', 'status': 'absent'},
    {'id': '4', 'name': 'Phạm Thị Dung', 'studentId': '2021004', 'status': 'late'},
    {'id': '5', 'name': 'Hoàng Văn Em', 'studentId': '2021005', 'status': 'present'},
    {'id': '6', 'name': 'Vũ Thị Phương', 'studentId': '2021006', 'status': 'present'},
    {'id': '7', 'name': 'Đặng Văn Giang', 'studentId': '2021007', 'status': 'absent'},
    {'id': '8', 'name': 'Bùi Thị Hoa', 'studentId': '2021008', 'status': 'present'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điểm danh sinh viên'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          // Class Info Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.class_, color: Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                    Text(
                      'Lớp: $_selectedClass',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.book, color: Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                    Text(
                      'Môn: $_selectedSubject',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                    const SizedBox(width: 8),
                    Text(
                      'Ngày: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.edit),
                      label: const Text('Thay đổi'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Có mặt',
                    _getAttendanceCount('present').toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Vắng mặt',
                    _getAttendanceCount('absent').toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Đi muộn',
                    _getAttendanceCount('late').toString(),
                    Colors.orange,
                    Icons.schedule,
                  ),
                ),
              ],
            ),
          ),

          // Students List
          Expanded(
            child: ListView.builder(
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                return _buildStudentCard(student, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveAttendance,
        icon: const Icon(Icons.save),
        label: const Text('Lưu điểm danh'),
        backgroundColor: const Color(0xFF1976D2),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (student['status']) {
      case 'present':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Có mặt';
        break;
      case 'absent':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Vắng mặt';
        break;
      case 'late':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Đi muộn';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = 'Chưa điểm danh';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          student['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('MSSV: ${student['studentId']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _students[index]['status'] = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'present',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Có mặt'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'absent',
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Vắng mặt'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'late',
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Đi muộn'),
                    ],
                  ),
                ),
              ],
              child: Icon(Icons.more_vert, color: statusColor),
            ),
          ],
        ),
      ),
    );
  }

  int _getAttendanceCount(String status) {
    return _students.where((student) => student['status'] == status).length;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveAttendance() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lưu điểm danh'),
        content: const Text('Bạn có chắc chắn muốn lưu kết quả điểm danh?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessMessage();
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu điểm danh thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

