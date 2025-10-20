import 'package:flutter/material.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() => _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  String _selectedTeacher = 'Tất cả';
  String _selectedClass = 'Tất cả';
  String _selectedSubject = 'Tất cả';
  String _selectedRoom = 'Tất cả';
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bộ lọc
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown('Giảng viên', _selectedTeacher, [
                      'Tất cả',
                      'Nguyễn Văn A',
                      'Trần Thị B',
                      'Lê Văn C',
                    ], (value) {
                      setState(() => _selectedTeacher = value!);
                    }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterDropdown('Lớp học', _selectedClass, [
                      'Tất cả',
                      'CNTT K66',
                      'CNTT K67',
                      'CNTT K68',
                    ], (value) {
                      setState(() => _selectedClass = value!);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown('Môn học', _selectedSubject, [
                      'Tất cả',
                      'Toán học',
                      'Lập trình',
                      'Cơ sở dữ liệu',
                    ], (value) {
                      setState(() => _selectedSubject = value!);
                    }),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterDropdown('Phòng học', _selectedRoom, [
                      'Tất cả',
                      'A101',
                      'A102',
                      'A103',
                    ], (value) {
                      setState(() => _selectedRoom = value!);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Header với nút Import/Sinh lịch
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded( // Thêm Expanded để tránh overflow
                child: Text(
                  'Lịch trình ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18, // Giảm từ 20 xuống 18
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                  overflow: TextOverflow.ellipsis, // Thêm overflow handling
                ),
              ),
              const SizedBox(width: 8), // Thêm spacing
              Flexible( // Thay ElevatedButton.icon bằng Flexible
                child: ElevatedButton.icon(
                  onPressed: () => _showImportDialog(),
                  icon: const Icon(Icons.upload_file, size: 18), // Giảm icon size
                  label: const Text('Import/Sinh lịch', style: TextStyle(fontSize: 12)), // Giảm font size
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Giảm padding
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Lịch trình
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 8,
            itemBuilder: (context, index) {
              final schedules = [
                {'time': '7:30-9:00', 'teacher': 'Nguyễn Văn A', 'subject': 'Toán học', 'class': 'CNTT K66', 'room': 'A101', 'status': 'pending'},
                {'time': '9:30-11:00', 'teacher': 'Trần Thị B', 'subject': 'Lập trình', 'class': 'CNTT K67', 'room': 'A102', 'status': 'completed'},
                {'time': '13:30-15:00', 'teacher': 'Lê Văn C', 'subject': 'Cơ sở dữ liệu', 'class': 'CNTT K68', 'room': 'A103', 'status': 'absent'},
                {'time': '15:30-17:00', 'teacher': 'Nguyễn Văn A', 'subject': 'Toán học', 'class': 'CNTT K66', 'room': 'A101', 'status': 'makeup'},
                {'time': '7:30-9:00', 'teacher': 'Trần Thị B', 'subject': 'Lập trình', 'class': 'CNTT K67', 'room': 'A102', 'status': 'pending'},
                {'time': '9:30-11:00', 'teacher': 'Lê Văn C', 'subject': 'Cơ sở dữ liệu', 'class': 'CNTT K68', 'room': 'A103', 'status': 'completed'},
                {'time': '13:30-15:00', 'teacher': 'Nguyễn Văn A', 'subject': 'Toán học', 'class': 'CNTT K66', 'room': 'A101', 'status': 'pending'},
                {'time': '15:30-17:00', 'teacher': 'Trần Thị B', 'subject': 'Lập trình', 'class': 'CNTT K67', 'room': 'A102', 'status': 'makeup'},
              ];
              
              final schedule = schedules[index];
              return _buildScheduleCard(schedule, context);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11, // Giảm từ 12 xuống 11
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 3), // Giảm từ 4 xuống 3
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true, // Thêm để tránh overflow
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Giảm padding
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6), // Giảm border radius
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(
              item, 
              style: const TextStyle(fontSize: 12), // Giảm từ 14 xuống 12
              overflow: TextOverflow.ellipsis, // Thêm overflow handling
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, String> schedule, BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (schedule['status']) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Đã dạy';
        statusIcon = Icons.check_circle;
        break;
      case 'absent':
        statusColor = Colors.red;
        statusText = 'Đã nghỉ';
        statusIcon = Icons.cancel;
        break;
      case 'makeup':
        statusColor = Colors.orange;
        statusText = 'Dạy bù';
        statusIcon = Icons.schedule;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Chưa dạy';
        statusIcon = Icons.schedule;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          '${schedule['time']} - ${schedule['subject']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GV: ${schedule['teacher']}'),
            Text('Lớp: ${schedule['class']} - Phòng: ${schedule['room']}'),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Chỉnh sửa'),
            ),
            const PopupMenuItem(
              value: 'view',
              child: Text('Xem chi tiết'),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _showEditScheduleDialog(schedule, context);
            }
          },
        ),
        onTap: () => _showEditScheduleDialog(schedule, context),
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import/Sinh lịch trình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file, color: Color(0xFF1976D2)),
              title: const Text('Nhập file phân công'),
              subtitle: const Text('Upload file Excel/CSV'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng upload file đang phát triển')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Color(0xFF1976D2)),
              title: const Text('Tự động sinh lịch trình'),
              subtitle: const Text('Sử dụng thuật toán AI'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng AI đang phát triển')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditScheduleDialog(Map<String, String> schedule, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa lịch trình'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Thời gian: ${schedule['time']}'),
            Text('Môn: ${schedule['subject']}'),
            Text('Lớp: ${schedule['class']}'),
            const SizedBox(height: 16),
            const Text('Chọn giảng viên mới:'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['Nguyễn Văn A', 'Trần Thị B', 'Lê Văn C'].map((teacher) => 
                DropdownMenuItem(value: teacher, child: Text(teacher))
              ).toList(),
              onChanged: (value) {},
            ),
            const SizedBox(height: 8),
            const Text('Chọn phòng mới:'),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: ['A101', 'A102', 'A103'].map((room) => 
                DropdownMenuItem(value: room, child: Text(room))
              ).toList(),
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật lịch trình')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

